import { randomUUID } from 'node:crypto';
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
      initialBalance: 100_000,
      icon: 'account_balance_rounded',
      color: '#3B82F6',
    })
  ).json().id as string;
  const create = (
    debtors = [
      { name: 'Budi', amount: 50_000 },
      { name: 'Andi', amount: 100_000 },
    ],
  ) => call('POST', '/receivables', { title: 'Makan bakso', date: '2026-11-16', debtors });
  const pay = (debtorId: string, amount: number, extra: object = {}) =>
    call('POST', `/receivables/debtors/${debtorId}/payments`, {
      amount,
      walletId: bca,
      occurredAt: now(),
      ...extra,
    });
  const balance = async () =>
    (await call('GET', '/wallets')).json().items.find((w: { id: string }) => w.id === bca)
      .balance as number;
  return { call, bca, create, pay, balance };
}

describe('receivables', () => {
  it('buat dan daftar: total dan sisa per orang', async () => {
    const ctx = await setup();
    const res = await ctx.create();
    expect(res.statusCode).toBe(201);
    expect(res.json()).toMatchObject({
      title: 'Makan bakso',
      date: '2026-11-16',
      total: 150_000,
      remaining: 150_000,
      debtors: [
        { name: 'Budi', amount: 50_000, paid: 0, remaining: 50_000, payments: [] },
        { name: 'Andi', amount: 100_000, paid: 0, remaining: 100_000 },
      ],
    });
    const list = (await ctx.call('GET', '/receivables')).json();
    expect(list.items).toHaveLength(1);
    expect(list.totalRemaining).toBe(150_000);
  });

  it('validasi: tanpa orang, nominal 0, 21 orang, tanggal salah', async () => {
    const ctx = await setup();
    expect((await ctx.create([])).statusCode).toBe(400);
    const zero = await ctx.create([{ name: 'Budi', amount: 0 }]);
    expect(zero.statusCode).toBe(400);
    expect(zero.json().error.details['debtors.0.amount']).toBe('Nominal harus lebih dari 0');
    const many = Array.from({ length: 21 }, (_, i) => ({ name: `O${i}`, amount: 1 }));
    expect((await ctx.create(many)).statusCode).toBe(400);
    const badDate = await ctx.call('POST', '/receivables', {
      title: 'X',
      date: '16-11-2026',
      debtors: [{ name: 'A', amount: 1 }],
    });
    expect(badDate.statusCode).toBe(400);
  });

  it('cicil sampai lunas: saldo naik, pemasukan Piutang dibayar, hilang dari open', async () => {
    const ctx = await setup();
    const budi = (await ctx.create()).json().debtors[0].id;

    const first = await ctx.pay(budi, 20_000);
    expect(first.statusCode).toBe(201);
    expect(first.json().debtors[0]).toMatchObject({ paid: 20_000, remaining: 30_000 });
    expect(first.json().debtors[0].payments[0]).toMatchObject({
      amount: 20_000,
      wallet: { id: ctx.bca, name: 'BCA' },
    });
    expect(await ctx.balance()).toBe(120_000);

    const tx = (await ctx.call('GET', '/transactions')).json().items[0];
    expect(tx).toMatchObject({ type: 'INCOME', note: 'Bayar Budi · Makan bakso' });
    expect(tx.category.name).toBe('Piutang dibayar');

    const over = await ctx.pay(budi, 30_001);
    expect(over.statusCode).toBe(400);
    expect(over.json().error.details.amount).toBe('Melebihi sisa utang Rp30.000');

    await ctx.pay(budi, 30_000);
    const dashboard = (await ctx.call('GET', '/dashboard')).json();
    expect(dashboard.receivableRemaining).toBe(100_000);
    expect(dashboard.totalBalance).toBe(150_000);

    // Andi belum bayar, jadi talangan masih "open"; setelah lunas hilang dari open.
    const andi = (await ctx.call('GET', '/receivables')).json().items[0].debtors[1].id;
    await ctx.pay(andi, 100_000);
    expect((await ctx.call('GET', '/receivables')).json().items).toHaveLength(0);
    expect((await ctx.call('GET', '/receivables?status=all')).json().items).toHaveLength(1);
  });

  it('dua cicilan bersamaan tidak melewati sisa', async () => {
    const ctx = await setup();
    const budi = (await ctx.create()).json().debtors[0].id;
    const results = await Promise.all([ctx.pay(budi, 30_000), ctx.pay(budi, 30_000)]);
    expect(results.map((r) => r.statusCode).sort()).toEqual([201, 400]);
  });

  it('hapus transaksi pembayaran mengembalikan sisa; clientId sama tidak dobel', async () => {
    const ctx = await setup();
    const budi = (await ctx.create()).json().debtors[0].id;
    const clientId = randomUUID();
    const paid = (await ctx.pay(budi, 20_000, { clientId })).json();
    await ctx.pay(budi, 20_000, { clientId });
    expect((await ctx.call('GET', '/transactions')).json().items).toHaveLength(1);

    const txId = paid.debtors[0].payments[0].transactionId;
    expect((await ctx.call('DELETE', `/transactions/${txId}`)).statusCode).toBe(204);
    const after = (await ctx.call('GET', '/receivables')).json().items[0].debtors[0];
    expect(after).toMatchObject({ paid: 0, remaining: 50_000 });
  });

  it('ubah judul dan orang; nominal tidak boleh di bawah yang sudah dibayar', async () => {
    const ctx = await setup();
    const created = (await ctx.create()).json();
    const budi = created.debtors[0].id;
    const patched = await ctx.call('PATCH', `/receivables/${created.id}`, { title: 'Bakso' });
    expect(patched.json().title).toBe('Bakso');

    await ctx.pay(budi, 20_000);
    const low = await ctx.call('PATCH', `/receivables/debtors/${budi}`, { amount: 10_000 });
    expect(low.statusCode).toBe(400);
    expect(low.json().error.details.amount).toBe(
      'Nominal tidak boleh kurang dari yang sudah dibayar',
    );
    const ok = await ctx.call('PATCH', `/receivables/debtors/${budi}`, {
      name: 'Budi S',
      amount: 20_000,
    });
    expect(ok.json().debtors[0]).toMatchObject({ name: 'Budi S', remaining: 0 });
  });

  it('hapus talangan: pemasukan yang sudah diterima tetap ada', async () => {
    const ctx = await setup();
    const created = (await ctx.create()).json();
    await ctx.pay(created.debtors[0].id, 20_000);
    expect((await ctx.call('DELETE', `/receivables/${created.id}`)).statusCode).toBe(204);
    expect(await ctx.balance()).toBe(120_000);
    expect((await ctx.call('GET', '/transactions')).json().items).toHaveLength(1);
    expect((await ctx.call('GET', '/dashboard')).json().receivableRemaining).toBe(0);
  });

  it('milik user lain: URL 404, dompet asing di body 400', async () => {
    const ctx = await setup();
    const other = await setup('b@example.test');
    const created = (await ctx.create()).json();
    const budi = created.debtors[0].id;

    expect((await other.call('GET', '/receivables')).json().items).toHaveLength(0);
    expect(
      (await other.call('PATCH', `/receivables/${created.id}`, { title: 'X' })).statusCode,
    ).toBe(404);
    expect((await other.call('DELETE', `/receivables/${created.id}`)).statusCode).toBe(404);
    expect((await other.pay(budi, 1_000)).statusCode).toBe(404);
    const foreignWallet = await ctx.pay(budi, 1_000, { walletId: other.bca });
    expect(foreignWallet.statusCode).toBe(400);
    expect(foreignWallet.json().error.details.walletId).toBe('Pilih dompet');
  });
});

describe('payables (utang, FIN-20)', () => {
  type Ctx = Awaited<ReturnType<typeof setup>>;
  const utang = (ctx: Ctx, extra: object = {}, amount = 50_000) =>
    ctx.call('POST', '/receivables', {
      direction: 'PAYABLE',
      title: 'Makan siang',
      date: '2026-11-16',
      debtors: [{ name: 'Rina', amount }],
      ...extra,
    });
  const categoryId = async (ctx: Ctx, type: string) =>
    (await ctx.call('GET', `/categories?type=${type}`)).json().items[0].id as string;
  const transactions = async (ctx: Ctx) =>
    (await ctx.call('GET', '/transactions')).json().items as {
      id: string;
      type: string;
      amount: number;
      note: string | null;
      category: { id: string; name: string };
    }[];

  it('utang talangan: saldo tetap, terpisah dari piutang', async () => {
    const ctx = await setup();
    await ctx.create();
    const res = await utang(ctx);
    expect(res.statusCode).toBe(201);
    expect(res.json()).toMatchObject({ direction: 'PAYABLE', loan: null, remaining: 50_000 });
    expect(await ctx.balance()).toBe(100_000);
    const payables = (await ctx.call('GET', '/receivables?direction=payable')).json();
    expect(payables.items).toHaveLength(1);
    expect(payables.totalRemaining).toBe(50_000);
    const receivables = (await ctx.call('GET', '/receivables')).json();
    expect(receivables.items.map((r: { direction: string }) => r.direction)).toEqual([
      'RECEIVABLE',
    ]);
    expect(receivables.totalRemaining).toBe(150_000);
  });

  it('pinjam tunai: pemasukan Pinjaman diterima ke dompet', async () => {
    const ctx = await setup();
    const res = await utang(ctx, { loanWalletId: ctx.bca }, 1_000_000);
    expect(res.statusCode).toBe(201);
    expect(res.json().loan).toMatchObject({ amount: 1_000_000, wallet: { id: ctx.bca } });
    expect(await ctx.balance()).toBe(1_100_000);
    const [tx] = await transactions(ctx);
    expect(tx).toMatchObject({
      type: 'INCOME',
      amount: 1_000_000,
      note: 'Pinjam Rina · Makan siang',
      category: { name: 'Pinjaman diterima' },
    });
  });

  it('validasi utang: 1 orang, loanWalletId hanya utang dan dompet sah', async () => {
    const ctx = await setup();
    const two = await utang(ctx, {
      debtors: [
        { name: 'Rina', amount: 1 },
        { name: 'Dodi', amount: 1 },
      ],
    });
    expect(two.statusCode).toBe(400);
    expect(two.json().error.details.debtors).toBe('Utang hanya untuk 1 orang');
    const onReceivable = await ctx.call('POST', '/receivables', {
      title: 'X',
      date: '2026-11-16',
      debtors: [{ name: 'A', amount: 1 }],
      loanWalletId: ctx.bca,
    });
    expect(onReceivable.statusCode).toBe(400);
    expect(onReceivable.json().error.details.loanWalletId).toBeDefined();
    const other = await setup('b@example.test');
    const foreign = await utang(ctx, { loanWalletId: other.bca });
    expect(foreign.statusCode).toBe(400);
    expect(foreign.json().error.details.loanWalletId).toBeDefined();
    await ctx.call('PATCH', `/wallets/${ctx.bca}`, { isArchived: true });
    const archived = await utang(ctx, { loanWalletId: ctx.bca });
    expect(archived.statusCode).toBe(400);
    expect(archived.json().error.details.loanWalletId).toBeDefined();
  });

  it('clientId sama: kirim ulang dan bersamaan tidak membuat utang/pinjaman dobel', async () => {
    const ctx = await setup();
    const clientId = randomUUID();
    const first = await utang(ctx, { loanWalletId: ctx.bca, clientId });
    const again = await utang(ctx, { loanWalletId: ctx.bca, clientId });
    expect(first.statusCode).toBe(201);
    expect(again.statusCode).toBe(201);
    expect(again.json().id).toBe(first.json().id);

    const parallelId = randomUUID();
    const results = await Promise.all([
      utang(ctx, { loanWalletId: ctx.bca, clientId: parallelId }),
      utang(ctx, { loanWalletId: ctx.bca, clientId: parallelId }),
    ]);
    expect(results.map((r) => r.statusCode)).toEqual([201, 201]);
    expect(results[0].json().id).toBe(results[1].json().id);

    const list = (await ctx.call('GET', '/receivables?direction=payable')).json();
    expect(list.items).toHaveLength(2);
    expect(await transactions(ctx)).toHaveLength(2);
    expect(await ctx.balance()).toBe(200_000);
  });

  it('hapus utang tunai: pinjaman tetap; hapus transaksi pinjaman: loan null', async () => {
    const ctx = await setup();
    const a = (await utang(ctx, { loanWalletId: ctx.bca })).json();
    expect((await ctx.call('DELETE', `/receivables/${a.id}`)).statusCode).toBe(204);
    expect(await ctx.balance()).toBe(150_000);
    expect(await transactions(ctx)).toHaveLength(1);

    const b = (await utang(ctx, { loanWalletId: ctx.bca })).json();
    const del = await ctx.call('DELETE', `/transactions/${b.loan.transactionId}`);
    expect(del.statusCode).toBe(204);
    const after = (await ctx.call('GET', '/receivables?direction=payable')).json().items[0];
    expect(after).toMatchObject({ id: b.id, loan: null, remaining: 50_000 });
  });

  it('cicil utang: pengeluaran berkategori, saldo turun, lunas hilang dari open', async () => {
    const ctx = await setup();
    const makan = await categoryId(ctx, 'EXPENSE');
    const debtorId = (await utang(ctx)).json().debtors[0].id as string;
    const first = await ctx.pay(debtorId, 20_000, { categoryId: makan });
    expect(first.statusCode).toBe(201);
    expect(first.json().debtors[0]).toMatchObject({ paid: 20_000, remaining: 30_000 });
    expect(await ctx.balance()).toBe(80_000);
    const [tx] = await transactions(ctx);
    expect(tx).toMatchObject({
      type: 'EXPENSE',
      amount: 20_000,
      note: 'Bayar utang Rina · Makan siang',
      category: { id: makan },
    });
    const over = await ctx.pay(debtorId, 40_000, { categoryId: makan });
    expect(over.json().error.details.amount).toBe('Melebihi sisa utang Rp30.000');
    expect((await ctx.pay(debtorId, 30_000, { categoryId: makan })).statusCode).toBe(201);
    const open = (await ctx.call('GET', '/receivables?direction=payable')).json();
    expect(open.items).toHaveLength(0);
  });

  it('cicil utang: kategori wajib EXPENSE milik sendiri; piutang abaikan kategori', async () => {
    const ctx = await setup();
    const debtorId = (await utang(ctx)).json().debtors[0].id as string;
    const none = await ctx.pay(debtorId, 1_000);
    expect(none.statusCode).toBe(400);
    expect(none.json().error.details.categoryId).toBe('Pilih kategori');
    const income = await ctx.pay(debtorId, 1_000, { categoryId: await categoryId(ctx, 'INCOME') });
    expect(income.statusCode).toBe(400);
    const other = await setup('b@example.test');
    const foreign = await ctx.pay(debtorId, 1_000, {
      categoryId: await categoryId(other, 'EXPENSE'),
    });
    expect(foreign.statusCode).toBe(400);

    const budi = (await ctx.create()).json().debtors[0].id as string;
    const paid = await ctx.pay(budi, 1_000, { categoryId: await categoryId(ctx, 'EXPENSE') });
    expect(paid.statusCode).toBe(201);
    const [tx] = await transactions(ctx);
    expect(tx).toMatchObject({ type: 'INCOME', category: { name: 'Piutang dibayar' } });
  });

  it('transaksi tertaut: nominal/jenis dikunci, catatan tetap boleh diubah', async () => {
    const ctx = await setup();
    const makan = await categoryId(ctx, 'EXPENSE');
    const created = (await utang(ctx, { loanWalletId: ctx.bca })).json();
    await ctx.pay(created.debtors[0].id, 20_000, { categoryId: makan });
    const [payment] = await transactions(ctx);
    const loanId = created.loan.transactionId as string;
    for (const [id, flipped] of [
      [payment!.id, 'INCOME'],
      [loanId, 'EXPENSE'],
    ] as const) {
      const amount = await ctx.call('PATCH', `/transactions/${id}`, { amount: 60_000 });
      expect(amount.statusCode).toBe(400);
      expect(amount.json().error.details.amount).toBe('Ubah lewat menu Utang & Piutang');
      const type = await ctx.call('PATCH', `/transactions/${id}`, { type: flipped });
      expect(type.statusCode).toBe(400);
      const note = await ctx.call('PATCH', `/transactions/${id}`, { note: 'oke' });
      expect(note.statusCode).toBe(200);
    }
    const after = (await ctx.call('GET', '/receivables?direction=payable')).json().items[0];
    expect(after.debtors[0]).toMatchObject({ paid: 20_000, remaining: 30_000 });
  });

  it('dashboard: piutang dan utang dipisah, totalBalance tidak berubah rumus', async () => {
    const ctx = await setup();
    const budi = (await ctx.create()).json().debtors[0].id as string;
    await ctx.pay(budi, 20_000);
    await utang(ctx);
    const dashboard = (await ctx.call('GET', '/dashboard')).json();
    expect(dashboard.receivableRemaining).toBe(130_000);
    expect(dashboard.payableRemaining).toBe(50_000);
    expect(dashboard.totalBalance).toBe(120_000);
    // Talangan 50.000 langsung memotong Bisa digunakan (D-81).
    expect(dashboard.availableBalance).toBe(70_000);
  });

  it('talangan memotong Bisa digunakan; Saldo total baru turun saat bayar (D-81)', async () => {
    const ctx = await setup();
    const dash = async () => {
      const d = (await ctx.call('GET', '/dashboard')).json();
      return [d.totalBalance, d.availableBalance, d.frontedPayableRemaining];
    };
    const rina = (await utang(ctx)).json().debtors[0].id as string;
    expect(await dash()).toEqual([100_000, 50_000, 50_000]);

    await ctx.pay(rina, 20_000, { categoryId: await categoryId(ctx, 'EXPENSE') });
    expect(await dash()).toEqual([80_000, 50_000, 30_000]);

    const loan = (await utang(ctx, { loanWalletId: ctx.bca }, 1_000_000)).json();
    expect(await dash()).toEqual([1_080_000, 1_050_000, 30_000]);

    await utang(ctx, {}, 2_000_000);
    expect(await dash()).toEqual([1_080_000, -950_000, 2_030_000]);

    // Transaksi pinjaman dihapus: uangnya tidak ada lagi, jadi dihitung seperti talangan.
    await ctx.call('DELETE', `/transactions/${loan.loan.transactionId}`);
    expect(await dash()).toEqual([80_000, -2_950_000, 3_030_000]);
  });
});

describe('bagi pengeluaran (FIN-21)', () => {
  type Ctx = Awaited<ReturnType<typeof setup>>;
  const category = async (ctx: Ctx, type: string, name: string) =>
    (await ctx.call('GET', `/categories?type=${type}`))
      .json()
      .items.find((c: { name: string }) => c.name === name).id as string;
  const expense = async (ctx: Ctx, type = 'EXPENSE', name = 'Makan') =>
    (
      await ctx.call('POST', '/transactions', {
        type,
        amount: 200_000,
        walletId: ctx.bca,
        categoryId: await category(ctx, type, name),
        occurredAt: now(),
      })
    ).json().id as string;
  const split = (ctx: Ctx, sourceTransactionId: string, amounts: number[], extra: object = {}) =>
    ctx.call('POST', '/receivables', {
      title: 'Makan',
      date: '2026-11-16',
      sourceTransactionId,
      debtors: amounts.map((amount, i) => ({ name: `T${i}`, amount })),
      ...extra,
    });

  it('bagi: piutang tertaut, transaksi tahu piutangnya', async () => {
    const ctx = await setup();
    const id = await expense(ctx);
    const res = await split(ctx, id, [66_666, 66_666]);
    expect(res.statusCode).toBe(201);
    expect(res.json().source).toEqual({
      transactionId: id,
      amount: 200_000,
      categoryName: 'Makan',
    });
    const tx = (await ctx.call('GET', `/transactions/${id}`)).json();
    expect(tx.receivableId).toBe(res.json().id);
    const plain = (
      await ctx.call('POST', '/receivables', {
        title: 'X',
        date: '2026-11-16',
        debtors: [{ name: 'A', amount: 1 }],
      })
    ).json();
    expect(plain.source).toBeNull();
  });

  it('batas: melebihi nominal ditolak, tepat sama boleh', async () => {
    const ctx = await setup();
    const id = await expense(ctx);
    const over = await split(ctx, id, [100_000, 100_001]);
    expect(over.statusCode).toBe(400);
    expect(over.json().error.details.debtors).toBe('Melebihi nominal pengeluaran Rp200.000');
    expect((await split(ctx, id, [100_000, 100_000])).statusCode).toBe(201);
  });

  it('sekali saja; kiriman ulang clientId sama = catatan yang sama', async () => {
    const ctx = await setup();
    const id = await expense(ctx);
    const clientId = randomUUID();
    const first = await split(ctx, id, [1_000], { clientId });
    const again = await split(ctx, id, [1_000], { clientId });
    expect(again.statusCode).toBe(201);
    expect(again.json().id).toBe(first.json().id);
    const second = await split(ctx, id, [1_000], { clientId: randomUUID() });
    expect(second.statusCode).toBe(400);
    expect(second.json().error.details.sourceTransactionId).toBe('Pengeluaran ini sudah dibagi');
  });

  it('sumber salah: pemasukan, milik user lain, atau utang ditolak', async () => {
    const ctx = await setup();
    const other = await setup('b@example.test');
    const income = await split(ctx, await expense(ctx, 'INCOME', 'Gaji / Uang saku'), [1_000]);
    expect(income.json().error.details.sourceTransactionId).toBe('Pilih pengeluaran');
    const foreign = await split(ctx, await expense(other), [1_000]);
    expect(foreign.statusCode).toBe(400);
    expect(foreign.json().error.details.sourceTransactionId).toBe('Pilih pengeluaran');
    const payable = await split(ctx, await expense(ctx), [1_000], { direction: 'PAYABLE' });
    expect(payable.statusCode).toBe(400);
    expect(payable.json().error.details.sourceTransactionId).toBe('Hanya untuk piutang');
  });

  it('pengeluaran yang sudah dibagi tidak bisa jadi pemasukan', async () => {
    const ctx = await setup();
    const id = await expense(ctx);
    await split(ctx, id, [50_000]);
    const res = await ctx.call('PATCH', `/transactions/${id}`, {
      type: 'INCOME',
      categoryId: await category(ctx, 'INCOME', 'Gaji / Uang saku'),
    });
    expect(res.statusCode).toBe(400);
    expect(res.json().error.details.amount).toBe('Ubah lewat menu Utang & Piutang');
    const amount = await ctx.call('PATCH', `/transactions/${id}`, { amount: 150_000 });
    expect(amount.statusCode).toBe(200);
  });

  it('biaya admin transfer dan cicilan utang tidak bisa dibagi', async () => {
    const ctx = await setup();
    const cash = (await ctx.call('GET', '/wallets'))
      .json()
      .items.find((w: { id: string }) => w.id !== ctx.bca).id as string;
    await ctx.call('POST', '/transfers', {
      fromWalletId: ctx.bca,
      toWalletId: cash,
      amount: 10_000,
      fee: 2_500,
      feePaidBy: 'FROM',
      occurredAt: now(),
    });
    const fee = (await ctx.call('GET', '/transactions')).json().items[0].id as string;
    const feeSplit = await split(ctx, fee, [1_000]);
    expect(feeSplit.statusCode).toBe(400);
    expect(feeSplit.json().error.details.sourceTransactionId).toBe('Pilih pengeluaran');

    const debt = (
      await ctx.call('POST', '/receivables', {
        direction: 'PAYABLE',
        title: 'Utang',
        date: '2026-11-16',
        debtors: [{ name: 'Rina', amount: 50_000 }],
      })
    ).json();
    await ctx.pay(debt.debtors[0].id, 10_000, {
      categoryId: await category(ctx, 'EXPENSE', 'Makan'),
    });
    const repayment = (await ctx.call('GET', '/transactions')).json().items[0].id as string;
    expect((await split(ctx, repayment, [1_000])).statusCode).toBe(400);
  });

  it('hapus pengeluaran: piutang dan cicilan tetap, source null', async () => {
    const ctx = await setup();
    const id = await expense(ctx);
    const created = (await split(ctx, id, [50_000])).json();
    await ctx.pay(created.debtors[0].id, 20_000);
    expect((await ctx.call('DELETE', `/transactions/${id}`)).statusCode).toBe(204);
    const after = (await ctx.call('GET', '/receivables')).json().items[0];
    expect(after).toMatchObject({ id: created.id, source: null });
    expect(after.debtors[0].paid).toBe(20_000);
  });
});
