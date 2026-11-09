import { randomUUID } from 'node:crypto';
import { afterAll, beforeAll, beforeEach, describe, expect, it } from 'vitest';
import { computeStreak } from '../src/modules/dashboard/dashboard.service.js';
import { authHeader, buildTestApp, createUser, resetDb } from './helpers.js';

const app = buildTestApp();

beforeAll(() => app.ready());
beforeEach(() => resetDb(app.prisma));
afterAll(() => app.close());

type Method = 'GET' | 'POST' | 'PATCH' | 'DELETE';

async function setup(email = 'a@example.test') {
  const { accessToken, user } = await createUser(app, email);
  const call = (method: Method, url: string, payload?: object) =>
    app.inject({ method, url: `/api/v1${url}`, headers: authHeader(accessToken), payload });

  const wallets = (await call('GET', '/wallets')).json().items;
  const categories = (await call('GET', '/categories')).json().items as {
    id: string;
    name: string;
    type: string;
  }[];
  const find = (name: string, type = 'EXPENSE') =>
    categories.find((c) => c.name === name && c.type === type)!.id;

  const addWallet = async (name: string, initialBalance = 0) =>
    (
      await call('POST', '/wallets', {
        name,
        type: 'BANK',
        initialBalance,
        icon: 'account_balance_rounded',
        color: '#3B82F6',
      })
    ).json().id as string;

  const addTx = async (
    amount: number,
    overrides: Partial<{
      walletId: string;
      categoryId: string;
      type: string;
      occurredAt: string;
      note: string;
    }> = {},
  ) =>
    call('POST', '/transactions', {
      walletId: wallets[0].id,
      categoryId: find('Makan'),
      type: 'EXPENSE',
      amount,
      occurredAt: new Date().toISOString(),
      ...overrides,
    });

  return { call, userId: user.id, cashId: wallets[0].id as string, find, addWallet, addTx };
}

const balanceOf = async (ctx: Awaited<ReturnType<typeof setup>>, id: string) => {
  const list = await ctx.call('GET', '/wallets?includeArchived=true');
  return list.json().items.find((w: { id: string }) => w.id === id).balance as number;
};

describe('wallets', () => {
  it('saldo = saldo awal + masuk - keluar +- transfer', async () => {
    const ctx = await setup();
    const bank = await ctx.addWallet('Bank', 500_000);

    await ctx.addTx(25_000);
    await ctx.addTx(100_000, { categoryId: ctx.find('Lainnya', 'INCOME'), type: 'INCOME' });
    await ctx.call('POST', '/transfers', {
      fromWalletId: bank,
      toWalletId: ctx.cashId,
      amount: 100_000,
      occurredAt: new Date().toISOString(),
    });

    expect(await balanceOf(ctx, ctx.cashId)).toBe(175_000);
    expect(await balanceOf(ctx, bank)).toBe(400_000);
    expect((await ctx.call('GET', '/wallets')).json().totalBalance).toBe(575_000);
  });

  it('saldo dan total boleh negatif', async () => {
    const ctx = await setup();
    await ctx.addTx(25_000);
    const res = await ctx.call('GET', '/wallets');
    expect(res.statusCode).toBe(200);
    expect(res.json().items[0].balance).toBe(-25_000);
    expect(res.json().totalBalance).toBe(-25_000);
  });

  it('dompet arsip tidak ikut total, kecuali includeArchived (D-28)', async () => {
    const ctx = await setup();
    const ovo = await ctx.addWallet('OVO', 20_000);
    await ctx.call('PATCH', `/wallets/${ovo}`, { isArchived: true });

    const active = (await ctx.call('GET', '/wallets')).json();
    expect(active.items).toHaveLength(1);
    expect(active.totalBalance).toBe(0);

    const all = (await ctx.call('GET', '/wallets?includeArchived=true')).json();
    expect(all.items).toHaveLength(2);
    expect(all.totalBalance).toBe(20_000);
  });

  it('nama dobel 409, validasi 400', async () => {
    const ctx = await setup();
    const payload = { name: 'Cash', type: 'CASH', icon: 'x', color: '#14B8A6' };
    const dup = await ctx.call('POST', '/wallets', payload);
    expect(dup.statusCode).toBe(409);
    expect(dup.json().error.code).toBe('NAME_TAKEN');

    const bad = await ctx.call('POST', '/wallets', { ...payload, name: '', color: 'merah' });
    expect(bad.statusCode).toBe(400);
    expect(bad.json().error.details).toEqual({
      name: 'Nama wajib diisi',
      color: 'Warna tidak valid',
    });
  });

  it('hapus: kosong boleh, sudah ada transaksi atau transfer WALLET_IN_USE', async () => {
    const ctx = await setup();
    const empty = await ctx.addWallet('Kosong');
    expect((await ctx.call('DELETE', `/wallets/${empty}`)).statusCode).toBe(204);

    await ctx.addTx(1000);
    const used = await ctx.call('DELETE', `/wallets/${ctx.cashId}`);
    expect(used.statusCode).toBe(409);
    expect(used.json().error.code).toBe('WALLET_IN_USE');

    const bank = await ctx.addWallet('Bank');
    const other = await ctx.addWallet('Lain');
    await ctx.call('POST', '/transfers', {
      fromWalletId: bank,
      toWalletId: other,
      amount: 1,
      occurredAt: new Date().toISOString(),
    });
    expect((await ctx.call('DELETE', `/wallets/${other}`)).statusCode).toBe(409);
  });

  it('dompet user lain 404, dan tidak ikut di daftar', async () => {
    const a = await setup('a@example.test');
    const b = await setup('b@example.test');
    expect((await b.call('PATCH', `/wallets/${a.cashId}`, { name: 'x' })).statusCode).toBe(404);
    expect((await b.call('DELETE', `/wallets/${a.cashId}`)).statusCode).toBe(404);
    const items = (await b.call('GET', '/wallets')).json().items;
    expect(items.map((w: { id: string }) => w.id)).toEqual([b.cashId]);
  });

  it('tanpa token 401', async () => {
    const res = await app.inject({ url: '/api/v1/wallets' });
    expect(res.statusCode).toBe(401);
  });
});

describe('transfers', () => {
  it('tidak mengubah total saldo dan tidak masuk pemasukan/pengeluaran', async () => {
    const ctx = await setup();
    const bank = await ctx.addWallet('Bank', 100_000);
    const res = await ctx.call('POST', '/transfers', {
      fromWalletId: bank,
      toWalletId: ctx.cashId,
      amount: 100_000,
      occurredAt: new Date().toISOString(),
    });
    expect(res.statusCode).toBe(201);
    expect(res.json().fromWallet.name).toBe('Bank');

    const dashboard = (await ctx.call('GET', '/dashboard')).json();
    expect(dashboard.totalBalance).toBe(100_000);
    expect(dashboard.month).toEqual({ income: 0, expense: 0, net: 0 });
    expect(dashboard.today.hasEntry).toBe(false);
  });

  it('dompet sama ditolak, juga saat edit', async () => {
    const ctx = await setup();
    const bank = await ctx.addWallet('Bank');
    const payload = {
      fromWalletId: ctx.cashId,
      toWalletId: ctx.cashId,
      amount: 1,
      occurredAt: new Date().toISOString(),
    };
    const same = await ctx.call('POST', '/transfers', payload);
    expect(same.statusCode).toBe(400);
    expect(same.json().error.details.toWalletId).toBe('Dompet asal dan tujuan harus berbeda');

    const ok = await ctx.call('POST', '/transfers', { ...payload, toWalletId: bank });
    const edit = await ctx.call('PATCH', `/transfers/${ok.json().id}`, { toWalletId: ctx.cashId });
    expect(edit.statusCode).toBe(400);
  });

  it('edit dan hapus mengubah saldo', async () => {
    const ctx = await setup();
    const bank = await ctx.addWallet('Bank');
    const { id } = (
      await ctx.call('POST', '/transfers', {
        fromWalletId: bank,
        toWalletId: ctx.cashId,
        amount: 1000,
        occurredAt: new Date().toISOString(),
      })
    ).json();

    await ctx.call('PATCH', `/transfers/${id}`, { amount: 3000, note: 'tarik tunai' });
    expect(await balanceOf(ctx, ctx.cashId)).toBe(3000);
    expect((await ctx.call('DELETE', `/transfers/${id}`)).statusCode).toBe(204);
    expect(await balanceOf(ctx, ctx.cashId)).toBe(0);
  });

  it('filter dompet dan halaman', async () => {
    const ctx = await setup();
    const bank = await ctx.addWallet('Bank');
    const other = await ctx.addWallet('Lain');
    for (const [from, to] of [
      [bank, ctx.cashId],
      [ctx.cashId, bank],
      [bank, other],
    ]) {
      await ctx.call('POST', '/transfers', {
        fromWalletId: from,
        toWalletId: to,
        amount: 1,
        occurredAt: new Date().toISOString(),
      });
    }
    const filtered = (await ctx.call('GET', `/transfers?wallet=${ctx.cashId}`)).json();
    expect(filtered.items).toHaveLength(2);

    const first = (await ctx.call('GET', '/transfers?limit=2')).json();
    expect(first.items).toHaveLength(2);
    const second = (await ctx.call('GET', `/transfers?limit=2&cursor=${first.nextCursor}`)).json();
    expect(second.items).toHaveLength(1);
    expect(second.nextCursor).toBeNull();
  });

  describe('biaya admin (FIN-17)', () => {
    const now = () => new Date().toISOString();
    const month = () => new Date().toISOString().slice(0, 7);

    it('dipotong dari tujuan: tujuan terima amount - fee, biaya masuk pengeluaran', async () => {
      const ctx = await setup();
      const bca = await ctx.addWallet('BCA', 50_000);
      const res = await ctx.call('POST', '/transfers', {
        fromWalletId: bca,
        toWalletId: ctx.cashId,
        amount: 15_000,
        fee: 1000,
        occurredAt: now(),
      });
      expect(res.statusCode).toBe(201);
      expect(res.json()).toMatchObject({ amount: 15_000, fee: 1000, feePaidBy: 'TO' });

      expect(await balanceOf(ctx, bca)).toBe(35_000);
      expect(await balanceOf(ctx, ctx.cashId)).toBe(14_000);
      const report = (await ctx.call('GET', `/reports/monthly?month=${month()}`)).json();
      expect(report.totals.expense).toBe(1000);
      expect(report.totals.income).toBe(0);
    });

    it('dipotong dari asal boleh lebih besar dari nominal', async () => {
      const ctx = await setup();
      const bca = await ctx.addWallet('BCA', 50_000);
      const res = await ctx.call('POST', '/transfers', {
        fromWalletId: bca,
        toWalletId: ctx.cashId,
        amount: 1000,
        fee: 2500,
        feePaidBy: 'FROM',
        occurredAt: now(),
      });
      expect(res.json()).toMatchObject({ fee: 2500, feePaidBy: 'FROM' });
      expect(await balanceOf(ctx, bca)).toBe(46_500);
      expect(await balanceOf(ctx, ctx.cashId)).toBe(1000);
    });

    it('tanpa biaya: fee 0, feePaidBy null, tidak ada transaksi', async () => {
      const ctx = await setup();
      const bca = await ctx.addWallet('BCA');
      const res = await ctx.call('POST', '/transfers', {
        fromWalletId: bca,
        toWalletId: ctx.cashId,
        amount: 1000,
        occurredAt: now(),
      });
      expect(res.json()).toMatchObject({ fee: 0, feePaidBy: null });
      expect((await ctx.call('GET', '/transactions')).json().items).toEqual([]);
    });

    it('validasi: negatif ditolak, dan fee >= nominal ditolak jika tujuan yang bayar', async () => {
      const ctx = await setup();
      const bca = await ctx.addWallet('BCA');
      const base = { fromWalletId: bca, toWalletId: ctx.cashId, amount: 1000, occurredAt: now() };
      const negative = await ctx.call('POST', '/transfers', { ...base, fee: -1 });
      expect(negative.statusCode).toBe(400);
      expect(negative.json().error.details.fee).toBe('Biaya admin tidak boleh negatif');

      const tooBig = await ctx.call('POST', '/transfers', { ...base, fee: 1000 });
      expect(tooBig.statusCode).toBe(400);
      expect(tooBig.json().error.details.fee).toBe(
        'Biaya admin harus lebih kecil dari nominal transfer',
      );

      const { id } = (await ctx.call('POST', '/transfers', base)).json();
      const editBig = await ctx.call('PATCH', `/transfers/${id}`, { fee: 5000 });
      expect(editBig.statusCode).toBe(400);
      expect((await ctx.call('GET', '/transactions')).json().items).toEqual([]);
    });

    it('edit: ubah biaya, pindah pembayar, hapus biaya; kategori dipakai ulang', async () => {
      const ctx = await setup();
      const bca = await ctx.addWallet('BCA', 50_000);
      const { id } = (
        await ctx.call('POST', '/transfers', {
          fromWalletId: bca,
          toWalletId: ctx.cashId,
          amount: 15_000,
          fee: 1000,
          occurredAt: now(),
        })
      ).json();

      const edited = await ctx.call('PATCH', `/transfers/${id}`, { fee: 2500, feePaidBy: 'FROM' });
      expect(edited.statusCode).toBe(200);
      expect(edited.json()).toMatchObject({ fee: 2500, feePaidBy: 'FROM' });
      expect(await balanceOf(ctx, bca)).toBe(32_500);
      expect(await balanceOf(ctx, ctx.cashId)).toBe(15_000);

      // Edit tanpa field biaya mempertahankan biayanya.
      const kept = await ctx.call('PATCH', `/transfers/${id}`, { amount: 20_000 });
      expect(kept.json()).toMatchObject({ amount: 20_000, fee: 2500, feePaidBy: 'FROM' });

      const removed = await ctx.call('PATCH', `/transfers/${id}`, { fee: 0 });
      expect(removed.json()).toMatchObject({ fee: 0, feePaidBy: null });
      expect((await ctx.call('GET', '/transactions')).json().items).toEqual([]);

      await ctx.call('PATCH', `/transfers/${id}`, { fee: 500 });
      const categories = (await ctx.call('GET', '/categories?type=EXPENSE')).json().items;
      expect(categories.filter((c: { name: string }) => c.name === 'Biaya Admin')).toHaveLength(1);
    });

    it('hapus transfer ikut menghapus biayanya; hapus biaya langsung membuat fee 0', async () => {
      const ctx = await setup();
      const bca = await ctx.addWallet('BCA', 50_000);
      const payload = {
        fromWalletId: bca,
        toWalletId: ctx.cashId,
        amount: 15_000,
        fee: 1000,
        occurredAt: now(),
      };
      const first = (await ctx.call('POST', '/transfers', payload)).json();
      expect((await ctx.call('DELETE', `/transfers/${first.id}`)).statusCode).toBe(204);
      expect((await ctx.call('GET', '/transactions')).json().items).toEqual([]);
      expect(await balanceOf(ctx, bca)).toBe(50_000);

      const second = (await ctx.call('POST', '/transfers', payload)).json();
      const [feeTx] = (await ctx.call('GET', '/transactions')).json().items;
      expect((await ctx.call('DELETE', `/transactions/${feeTx.id}`)).statusCode).toBe(204);
      const list = (await ctx.call('GET', '/transfers')).json().items;
      expect(list.find((t: { id: string }) => t.id === second.id)).toMatchObject({ fee: 0 });
    });
  });

  it('dompet user lain di body 400, transfer user lain 404', async () => {
    const a = await setup('a@example.test');
    const b = await setup('b@example.test');
    const res = await b.call('POST', '/transfers', {
      fromWalletId: b.cashId,
      toWalletId: a.cashId,
      amount: 1,
      occurredAt: new Date().toISOString(),
    });
    expect(res.statusCode).toBe(400);
    expect(res.json().error.details.toWalletId).toBe('Pilih dompet');

    const bankA = await a.addWallet('Bank');
    const { id } = (
      await a.call('POST', '/transfers', {
        fromWalletId: bankA,
        toWalletId: a.cashId,
        amount: 1,
        occurredAt: new Date().toISOString(),
      })
    ).json();
    expect((await b.call('PATCH', `/transfers/${id}`, { amount: 2 })).statusCode).toBe(404);
    expect((await b.call('DELETE', `/transfers/${id}`)).statusCode).toBe(404);
    expect((await b.call('GET', '/transfers')).json().items).toEqual([]);
  });
});

describe('categories', () => {
  it('filter tipe, kategori tersembunyi hanya muncul jika diminta', async () => {
    const ctx = await setup();
    const income = (await ctx.call('GET', '/categories?type=INCOME')).json().items;
    expect(income).toHaveLength(2);

    await ctx.call('PATCH', `/categories/${ctx.find('Hiburan')}`, { isHidden: true });
    expect((await ctx.call('GET', '/categories')).json().items).toHaveLength(8);
    expect((await ctx.call('GET', '/categories?includeHidden=true')).json().items).toHaveLength(9);
  });

  it('nama sama boleh beda tipe, dobel di tipe sama 409', async () => {
    const ctx = await setup();
    const payload = { name: 'Makan', type: 'INCOME', icon: 'x', color: '#EF4444' };
    expect((await ctx.call('POST', '/categories', payload)).statusCode).toBe(201);
    const dup = await ctx.call('POST', '/categories', payload);
    expect(dup.statusCode).toBe(409);
    expect(dup.json().error.code).toBe('NAME_TAKEN');
  });

  it('kategori bawaan: nama dan hapus ditolak, warna boleh', async () => {
    const ctx = await setup();
    const id = ctx.find('Makan');
    const rename = await ctx.call('PATCH', `/categories/${id}`, { name: 'Jajan' });
    expect(rename.statusCode).toBe(409);
    expect(rename.json().error.code).toBe('CATEGORY_DEFAULT');
    expect((await ctx.call('DELETE', `/categories/${id}`)).statusCode).toBe(409);
    expect((await ctx.call('PATCH', `/categories/${id}`, { color: '#EF4444' })).statusCode).toBe(200);
  });

  it('hapus custom memindahkan transaksinya ke Lainnya bertipe sama', async () => {
    const ctx = await setup();
    const { id } = (
      await ctx.call('POST', '/categories', {
        name: 'Kopi',
        type: 'EXPENSE',
        icon: 'x',
        color: '#EF4444',
      })
    ).json();
    const tx = (await ctx.addTx(1000, { categoryId: id })).json();

    expect((await ctx.call('DELETE', `/categories/${id}`)).statusCode).toBe(204);
    const moved = (await ctx.call('GET', `/transactions/${tx.id}`)).json();
    expect(moved.category.id).toBe(ctx.find('Lainnya'));
  });

  it('validasi 400, kategori user lain 404', async () => {
    const a = await setup('a@example.test');
    const b = await setup('b@example.test');
    const bad = await a.call('POST', '/categories', { name: 'x', type: 'SALAH', icon: 'x', color: '#EF4444' });
    expect(bad.statusCode).toBe(400);
    const id = a.find('Makan');
    expect((await b.call('PATCH', `/categories/${id}`, { color: '#EF4444' })).statusCode).toBe(404);
    expect((await b.call('DELETE', `/categories/${id}`)).statusCode).toBe(404);
  });
});

describe('transactions', () => {
  it('nominal + kategori cukup, catatan opsional, respons sesuai kontrak', async () => {
    const ctx = await setup();
    const res = await ctx.addTx(25_000);
    expect(res.statusCode).toBe(201);
    expect(res.json()).toMatchObject({
      type: 'EXPENSE',
      amount: 25_000,
      note: null,
      attachments: [],
      wallet: { name: 'Cash' },
      category: { name: 'Makan' },
    });
  });

  it.each([
    ['nominal 0', { amount: 0 }, 'amount', 'Nominal harus lebih dari 0'],
    ['nominal desimal', { amount: 1.5 }, 'amount', 'Nominal harus lebih dari 0'],
    ['nominal kebesaran', { amount: 1_000_000_000 }, 'amount', 'Nominal maksimal Rp999.999.999'],
    ['catatan panjang', { note: 'x'.repeat(1001) }, 'note', 'Catatan terlalu panjang'],
    [
      'tanggal terlalu jauh',
      { occurredAt: new Date(Date.now() + 400 * 86_400_000).toISOString() },
      'occurredAt',
      'Tanggal terlalu jauh ke depan',
    ],
    ['dompet tidak ada', { walletId: randomUUID() }, 'walletId', 'Pilih dompet'],
    ['kategori tidak ada', { categoryId: randomUUID() }, 'categoryId', 'Pilih kategori'],
  ])('%s ditolak', async (_name, body, field, message) => {
    const ctx = await setup();
    const res = await ctx.call('POST', '/transactions', {
      walletId: ctx.cashId,
      categoryId: ctx.find('Makan'),
      type: 'EXPENSE',
      amount: 1000,
      occurredAt: new Date().toISOString(),
      ...body,
    });
    expect(res.statusCode).toBe(400);
    expect(res.json().error.details[field]).toBe(message);
  });

  it('tipe kategori harus cocok, juga saat edit', async () => {
    const ctx = await setup();
    const res = await ctx.addTx(1000, { type: 'INCOME' });
    expect(res.statusCode).toBe(400);
    expect(res.json().error.details.categoryId).toBe('Pilih kategori');

    const tx = (await ctx.addTx(1000)).json();
    expect((await ctx.call('PATCH', `/transactions/${tx.id}`, { type: 'INCOME' })).statusCode).toBe(400);
    const both = await ctx.call('PATCH', `/transactions/${tx.id}`, {
      type: 'INCOME',
      categoryId: ctx.find('Lainnya', 'INCOME'),
    });
    expect(both.statusCode).toBe(200);
    expect(both.json().type).toBe('INCOME');
  });

  it('dompet arsip: tidak bisa dipakai baru, transaksi lamanya tetap bisa diedit (D-29)', async () => {
    const ctx = await setup();
    const ovo = await ctx.addWallet('OVO');
    const tx = (await ctx.addTx(1000, { walletId: ovo })).json();
    await ctx.call('PATCH', `/wallets/${ovo}`, { isArchived: true });

    expect((await ctx.addTx(1000, { walletId: ovo })).statusCode).toBe(400);
    const edit = await ctx.call('PATCH', `/transactions/${tx.id}`, { amount: 2000 });
    expect(edit.statusCode).toBe(200);
    const moveBack = await ctx.call('PATCH', `/transactions/${tx.id}`, { walletId: ctx.cashId });
    expect(moveBack.statusCode).toBe(200);
    const moveAgain = await ctx.call('PATCH', `/transactions/${tx.id}`, { walletId: ovo });
    expect(moveAgain.statusCode).toBe(400);
  });

  it('filter tanggal mengikuti zona waktu user: 23.30 dan 00.30 WIB', async () => {
    const ctx = await setup();
    await ctx.addTx(1000, { occurredAt: '2026-11-04T16:30:00Z', note: 'malam' });
    await ctx.addTx(2000, { occurredAt: '2026-11-04T17:30:00Z', note: 'dini hari' });

    const day4 = (await ctx.call('GET', '/transactions?from=2026-11-04&to=2026-11-04')).json();
    expect(day4.items.map((t: { note: string }) => t.note)).toEqual(['malam']);
    const day5 = (await ctx.call('GET', '/transactions?from=2026-11-05&to=2026-11-05')).json();
    expect(day5.items.map((t: { note: string }) => t.note)).toEqual(['dini hari']);
  });

  it('filter dompet, kategori, tipe, kata kunci, dan urutan terbaru', async () => {
    const ctx = await setup();
    const bank = await ctx.addWallet('Bank');
    await ctx.addTx(1, { occurredAt: '2026-01-01T00:00:00Z', note: 'Nasi Goreng' });
    await ctx.addTx(2, { occurredAt: '2026-01-02T00:00:00Z', walletId: bank });
    await ctx.addTx(3, {
      occurredAt: '2026-01-03T00:00:00Z',
      categoryId: ctx.find('Lainnya', 'INCOME'),
      type: 'INCOME',
    });

    const amounts = async (query: string) =>
      (await ctx.call('GET', `/transactions?${query}`))
        .json()
        .items.map((t: { amount: number }) => t.amount);

    expect(await amounts('')).toEqual([3, 2, 1]);
    expect(await amounts(`wallet=${bank}`)).toEqual([2]);
    expect(await amounts('type=INCOME')).toEqual([3]);
    expect(await amounts(`category=${ctx.find('Makan')}`)).toEqual([2, 1]);
    expect(await amounts('q=nasi')).toEqual([1]);
  });

  it('halaman tidak melompati atau mengulang data', async () => {
    const ctx = await setup();
    for (let i = 1; i <= 5; i++) await ctx.addTx(i, { occurredAt: '2026-01-01T00:00:00Z' });

    const seen: number[] = [];
    let cursor: string | null = null;
    do {
      const url: string = `/transactions?limit=2${cursor ? `&cursor=${cursor}` : ''}`;
      const page = (await ctx.call('GET', url)).json();
      seen.push(...page.items.map((t: { amount: number }) => t.amount));
      cursor = page.nextCursor;
    } while (cursor);
    expect(seen.sort()).toEqual([1, 2, 3, 4, 5]);
  });

  it('edit tanggal dan hapus', async () => {
    const ctx = await setup();
    const tx = (await ctx.addTx(1000, { note: 'lama' })).json();
    const edit = await ctx.call('PATCH', `/transactions/${tx.id}`, {
      occurredAt: '2026-01-01T00:00:00Z',
      note: null,
    });
    expect(edit.json().occurredAt).toBe('2026-01-01T00:00:00.000Z');
    expect(edit.json().note).toBeNull();

    expect((await ctx.call('DELETE', `/transactions/${tx.id}`)).statusCode).toBe(204);
    expect((await ctx.call('GET', `/transactions/${tx.id}`)).statusCode).toBe(404);
    expect(await balanceOf(ctx, ctx.cashId)).toBe(0);
  });

  it('data user lain: 404 lewat URL, 400 lewat body, kosong di daftar', async () => {
    const a = await setup('a@example.test');
    const b = await setup('b@example.test');
    const tx = (await a.addTx(1000)).json();

    expect((await b.call('GET', `/transactions/${tx.id}`)).statusCode).toBe(404);
    expect((await b.call('PATCH', `/transactions/${tx.id}`, { amount: 1 })).statusCode).toBe(404);
    expect((await b.call('DELETE', `/transactions/${tx.id}`)).statusCode).toBe(404);
    expect((await b.call('GET', '/transactions')).json().items).toEqual([]);
    expect((await b.call('GET', `/transactions?wallet=${a.cashId}`)).json().items).toEqual([]);

    const walletA = await b.addTx(1, { walletId: a.cashId });
    expect(walletA.statusCode).toBe(400);
    expect(walletA.json().error.details.walletId).toBe('Pilih dompet');
    const categoryA = await b.addTx(1, { categoryId: a.find('Makan') });
    expect(categoryA.statusCode).toBe(400);
    expect(categoryA.json().error.details.categoryId).toBe('Pilih kategori');

    const stored = await app.prisma.transaction.findUniqueOrThrow({ where: { id: tx.id } });
    expect(stored.amount).toBe(1000n);
  });

  it('id bukan UUID 400', async () => {
    const ctx = await setup();
    expect((await ctx.call('GET', '/transactions/bukan-uuid')).statusCode).toBe(400);
  });
});

describe('computeStreak', () => {
  it.each([
    ['tanpa catatan', [], { current: 0, longest: 0 }],
    ['hari ini saja', ['2026-11-04'], { current: 1, longest: 1 }],
    ['hari ini belum, kemarin ada: belum putus', ['2026-11-02', '2026-11-03'], { current: 2, longest: 2 }],
    ['ada hari kosong: putus', ['2026-11-01', '2026-11-02'], { current: 0, longest: 2 }],
    [
      'rekor lama lebih panjang',
      ['2026-10-01', '2026-10-02', '2026-10-03', '2026-11-03', '2026-11-04'],
      { current: 2, longest: 3 },
    ],
    ['melewati akhir bulan', ['2026-10-31', '2026-11-01'], { current: 0, longest: 2 }],
  ])('%s', (_name, days, expected) => {
    expect(computeStreak(days, '2026-11-04')).toEqual(expected);
  });
});

describe('GET /dashboard', () => {
  it('ringkasan bulan, hari ini, 7 hari, dan streak', async () => {
    const ctx = await setup();
    const now = new Date();
    await ctx.addTx(25_000, { occurredAt: now.toISOString() });
    await ctx.addTx(10_000, { occurredAt: new Date(now.getTime() - 86_400_000).toISOString() });
    await ctx.addTx(100_000, { categoryId: ctx.find('Lainnya', 'INCOME'), type: 'INCOME' });

    const res = await ctx.call('GET', '/dashboard');
    expect(res.statusCode).toBe(200);
    const body = res.json();
    expect(body.totalBalance).toBe(65_000);
    expect(body.wallets).toHaveLength(1);
    expect(body.today.expense).toBe(25_000);
    expect(body.today.hasEntry).toBe(true);
    expect(body.last7Days).toHaveLength(7);
    expect(body.last7Days.at(-1)).toMatchObject({ label: body.today.date, expense: 25_000, income: 100_000 });
    expect(body.last7Days.at(-2).expense).toBe(10_000);
    expect(body.streak).toEqual({ current: 2, longest: 2 });
    expect(body.month.net).toBe(body.month.income - body.month.expense);
  });

  it('kegiatan hari ini: penting dulu, tanpa jam di akhir, dan dihitung streak', async () => {
    const ctx = await setup();
    const date = (await ctx.call('GET', '/dashboard')).json().today.date as string;
    const dbDate = new Date(`${date}T00:00:00Z`);
    await app.prisma.activity.createMany({
      data: [
        { userId: ctx.userId, title: 'tanpa jam', date: dbDate },
        { userId: ctx.userId, title: 'pagi', date: dbDate, time: '08:00' },
        { userId: ctx.userId, title: 'penting', date: dbDate, time: '20:00', isImportant: true },
      ],
    });

    const body = (await ctx.call('GET', '/dashboard')).json();
    expect(body.today.activities.map((a: { title: string }) => a.title)).toEqual([
      'penting',
      'pagi',
      'tanpa jam',
    ]);
    expect(body.today.hasEntry).toBe(true);
    expect(body.streak.current).toBe(1);
  });

  it('data user lain tidak ikut', async () => {
    const a = await setup('a@example.test');
    const b = await setup('b@example.test');
    await a.addTx(25_000);
    const body = (await b.call('GET', '/dashboard')).json();
    expect(body.totalBalance).toBe(0);
    expect(body.today.expense).toBe(0);
    expect(body.streak.current).toBe(0);
  });

  it('tanpa token 401', async () => {
    expect((await app.inject({ url: '/api/v1/dashboard' })).statusCode).toBe(401);
  });
});
