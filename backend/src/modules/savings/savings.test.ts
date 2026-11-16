import { afterAll, beforeAll, beforeEach, describe, expect, it } from 'vitest';
import { authHeader, buildTestApp, createUser, resetDb } from '../../../test/helpers.js';

const app = buildTestApp();

beforeAll(() => app.ready());
beforeEach(() => resetDb(app.prisma));
afterAll(() => app.close());

type Method = 'GET' | 'POST' | 'PATCH' | 'DELETE';
const now = () => new Date().toISOString();

async function setup(email = 'a@example.test') {
  const { accessToken } = await createUser(app, email);
  const call = (method: Method, url: string, payload?: object) =>
    app.inject({ method, url: `/api/v1${url}`, headers: authHeader(accessToken), payload });

  const bca = (
    await call('POST', '/wallets', {
      name: 'BCA',
      type: 'BANK',
      initialBalance: 1_000_000,
      icon: 'account_balance_rounded',
      color: '#3B82F6',
    })
  ).json().id as string;
  const categories = (await call('GET', '/categories?type=EXPENSE')).json().items;
  const makan = categories.find((c: { name: string }) => c.name === 'Makan').id as string;

  const createSavings = (body: object) =>
    call('POST', '/savings', { name: 'Liburan', fromWalletId: bca, ...body });
  const spend = (walletId: string, amount: number) =>
    call('POST', '/transactions', {
      walletId,
      categoryId: makan,
      type: 'EXPENSE',
      amount,
      occurredAt: now(),
    });
  const balances = async () => {
    const items = (await call('GET', '/wallets?includeSavings=true&includeArchived=true')).json()
      .items as { id: string; balance: number }[];
    return Object.fromEntries(items.map((w) => [w.id, w.balance]));
  };
  return { call, bca, createSavings, spend, balances };
}

describe('savings', () => {
  it('buat dengan setoran awal: saldo total tetap, bisa digunakan berkurang', async () => {
    const ctx = await setup();
    const res = await ctx.createSavings({ initialAmount: 300_000, targetAmount: 5_000_000 });
    expect(res.statusCode).toBe(201);
    expect(res.json()).toMatchObject({
      type: 'SAVINGS',
      icon: 'savings_rounded',
      balance: 300_000,
      targetAmount: 5_000_000,
    });

    const dashboard = (await ctx.call('GET', '/dashboard')).json();
    expect(dashboard.availableBalance).toBe(700_000);
    expect(dashboard.totalBalance).toBe(1_000_000);
    expect(dashboard.savings).toHaveLength(1);
    expect(dashboard.savings[0].balance).toBe(300_000);
    // APK lama tidak boleh menerima tipe SAVINGS di daftar dompet.
    expect(dashboard.wallets.some((w: { type: string }) => w.type === 'SAVINGS')).toBe(false);
    expect(dashboard.month.expense).toBe(0);
  });

  it('PATCH /wallets tidak bisa mengubah tabungan (jenis, arsip, saldo awal)', async () => {
    const ctx = await setup();
    const id = (await ctx.createSavings({ initialAmount: 100_000 })).json().id as string;
    for (const body of [{ type: 'BANK' }, { isArchived: true }, { initialBalance: 0 }]) {
      expect((await ctx.call('PATCH', `/wallets/${id}`, body)).statusCode).toBe(404);
    }
    const dashboard = (await ctx.call('GET', '/dashboard')).json();
    expect(dashboard.savings).toHaveLength(1);
    expect(dashboard.savings[0]).toMatchObject({ type: 'SAVINGS', balance: 100_000 });
  });

  it('GET /wallets menyembunyikan tabungan kecuali includeSavings', async () => {
    const ctx = await setup();
    const id = (await ctx.createSavings({ initialAmount: 100_000 })).json().id;
    const plain = (await ctx.call('GET', '/wallets')).json();
    expect(plain.items.map((w: { id: string }) => w.id)).not.toContain(id);
    expect(plain.totalBalance).toBe(900_000);
    const all = (await ctx.call('GET', '/wallets?includeSavings=true')).json();
    expect(all.items.find((w: { id: string }) => w.id === id).type).toBe('SAVINGS');
  });

  it('validasi: setoran tanpa dompet, dompet tabungan/user lain, target 0, nama dobel', async () => {
    const ctx = await setup();
    const other = await setup('b@example.test');
    const noWallet = await ctx.call('POST', '/savings', { name: 'A', initialAmount: 1 });
    expect(noWallet.statusCode).toBe(400);
    expect(noWallet.json().error.details.fromWalletId).toBe('Pilih dompet');

    expect(
      (await ctx.createSavings({ initialAmount: 1, fromWalletId: other.bca })).statusCode,
    ).toBe(400);
    expect((await ctx.createSavings({ targetAmount: 0 })).statusCode).toBe(400);

    const first = (await ctx.createSavings({})).json().id;
    expect((await ctx.createSavings({})).statusCode).toBe(409);
    const fromSavings = await ctx.call('POST', '/savings', {
      name: 'B',
      initialAmount: 1,
      fromWalletId: first,
    });
    expect(fromSavings.statusCode).toBe(400);
    expect(fromSavings.json().error.details.fromWalletId).toBe('Tabungan tidak bisa ditarik');
  });

  it('setor lewat transfer boleh, tarik dari tabungan ditolak (juga saat edit)', async () => {
    const ctx = await setup();
    const id = (await ctx.createSavings({})).json().id;
    const deposit = await ctx.call('POST', '/transfers', {
      fromWalletId: ctx.bca,
      toWalletId: id,
      amount: 50_000,
      occurredAt: now(),
    });
    expect(deposit.statusCode).toBe(201);

    const withdraw = await ctx.call('POST', '/transfers', {
      fromWalletId: id,
      toWalletId: ctx.bca,
      amount: 10_000,
      occurredAt: now(),
    });
    expect(withdraw.statusCode).toBe(400);
    expect(withdraw.json().error.details.fromWalletId).toBe('Tabungan tidak bisa ditarik');

    const cash = (await ctx.call('GET', '/wallets'))
      .json()
      .items.find((w: { name: string }) => w.name !== 'BCA').id;
    const edit = await ctx.call('PATCH', `/transfers/${deposit.json().id}`, {
      fromWalletId: id,
      toWalletId: cash,
    });
    expect(edit.statusCode).toBe(400);

    const asWallet = await ctx.call('POST', '/wallets', {
      name: 'X',
      type: 'SAVINGS',
      icon: 'savings_rounded',
      color: '#000000',
    });
    expect(asWallet.statusCode).toBe(400);
  });

  it('pengeluaran dari tabungan masuk laporan dan mengurangi saldo tabungan', async () => {
    const ctx = await setup();
    const id = (await ctx.createSavings({ initialAmount: 300_000 })).json().id;
    expect((await ctx.spend(id, 50_000)).statusCode).toBe(201);
    const dashboard = (await ctx.call('GET', '/dashboard')).json();
    expect(dashboard.month.expense).toBe(50_000);
    expect(dashboard.savings[0].balance).toBe(250_000);
    expect(dashboard.totalBalance).toBe(950_000);
  });

  it('ubah dan hapus target; bukan tabungan atau milik user lain 404', async () => {
    const ctx = await setup();
    const other = await setup('b@example.test');
    const id = (await ctx.createSavings({ targetAmount: 5_000_000 })).json().id;

    const cleared = await ctx.call('PATCH', `/savings/${id}`, { targetAmount: null });
    expect(cleared.statusCode).toBe(200);
    expect(cleared.json().targetAmount).toBeNull();
    const set = await ctx.call('PATCH', `/savings/${id}`, { targetAmount: 2_000_000 });
    expect(set.json().targetAmount).toBe(2_000_000);
    expect((await ctx.call('PATCH', `/savings/${id}`, { targetAmount: -1 })).statusCode).toBe(400);

    expect((await ctx.call('PATCH', `/savings/${ctx.bca}`, { targetAmount: 1 })).statusCode).toBe(
      404,
    );
    expect((await other.call('PATCH', `/savings/${id}`, { targetAmount: 1 })).statusCode).toBe(404);
  });

  it('hapus dengan sisa positif: sisa kembali, riwayat tetap, hapus kedua 404', async () => {
    const ctx = await setup();
    const id = (await ctx.createSavings({ initialAmount: 300_000 })).json().id;
    await ctx.spend(id, 50_000);

    const noTarget = await ctx.call('DELETE', `/savings/${id}`);
    expect(noTarget.statusCode).toBe(400);
    expect(noTarget.json().error.details.toWalletId).toBe('Pilih dompet untuk sisa saldo');

    expect((await ctx.call('DELETE', `/savings/${id}?toWalletId=${ctx.bca}`)).statusCode).toBe(204);
    const balances = await ctx.balances();
    expect(balances[ctx.bca]).toBe(950_000);
    expect(balances[id]).toBe(0);

    const dashboard = (await ctx.call('GET', '/dashboard')).json();
    expect(dashboard.savings).toHaveLength(0);
    expect(dashboard.month.expense).toBe(50_000);
    expect((await ctx.call('DELETE', `/savings/${id}?toWalletId=${ctx.bca}`)).statusCode).toBe(404);
  });

  it('hapus dengan sisa negatif: kekurangan dipotong dari dompet pilihan', async () => {
    const ctx = await setup();
    const id = (await ctx.createSavings({ initialAmount: 10_000 })).json().id;
    await ctx.spend(id, 25_000);
    expect((await ctx.call('DELETE', `/savings/${id}?toWalletId=${ctx.bca}`)).statusCode).toBe(204);
    const balances = await ctx.balances();
    expect(balances[ctx.bca]).toBe(975_000);
    expect(balances[id]).toBe(0);
  });

  it('hapus sisa 0 tanpa dompet boleh; dompet biasa atau milik user lain 404', async () => {
    const ctx = await setup();
    const other = await setup('b@example.test');
    const id = (await ctx.createSavings({})).json().id;
    expect((await other.call('DELETE', `/savings/${id}`)).statusCode).toBe(404);
    expect((await ctx.call('DELETE', `/savings/${ctx.bca}`)).statusCode).toBe(404);
    expect((await ctx.call('DELETE', `/savings/${id}`)).statusCode).toBe(204);
  });
});
