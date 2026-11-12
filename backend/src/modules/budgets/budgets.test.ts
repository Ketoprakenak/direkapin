import { afterAll, beforeAll, beforeEach, describe, expect, it } from 'vitest';
import { authHeader, buildTestApp, createUser, resetDb } from '../../../test/helpers.js';

const app = buildTestApp();

beforeAll(() => app.ready());
beforeEach(() => resetDb(app.prisma));
afterAll(() => app.close());

async function setup(email = 'a@example.test') {
  const { accessToken } = await createUser(app, email);
  const headers = authHeader(accessToken);
  const call = (method: 'GET' | 'POST' | 'PATCH' | 'DELETE', url: string, payload?: object) =>
    app.inject({ method, url: `/api/v1${url}`, headers, payload });

  const wallets = (await call('GET', '/wallets')).json().items as {
    id: string;
  }[];
  const categories = (await call('GET', '/categories')).json().items as {
    id: string;
    name: string;
    type: string;
  }[];
  const category = (name: string, type = 'EXPENSE') =>
    categories.find((c) => c.name === name && c.type === type)!.id;
  const addTx = (name: string, amount: number, occurredAt: string, type = 'EXPENSE') =>
    call('POST', '/transactions', {
      walletId: wallets[0]!.id,
      categoryId: category(name, type),
      type,
      amount,
      occurredAt,
    });
  const list = async (month: string) =>
    (await call('GET', `/budgets?month=${month}`)).json().items as {
      id: string;
      name: string;
      limitAmount: number;
      startMonth: string;
      endMonth: string | null;
      categories: { name: string }[];
      spent: number;
    }[];
  return { call, category, addTx, list, cashId: wallets[0]!.id };
}

describe('budgets (FIN-12)', () => {
  it('multi kategori: spent menjumlahkan kategori budget di bulan itu saja', async () => {
    const ctx = await setup();
    const created = await ctx.call('POST', '/budgets', {
      name: 'Makan & Transport',
      limitAmount: 2_500_000,
      categoryIds: [ctx.category('Makan'), ctx.category('Transport')],
      month: '2026-11',
    });
    expect(created.statusCode).toBe(201);
    expect(created.json()).toMatchObject({
      name: 'Makan & Transport',
      limitAmount: 2_500_000,
      startMonth: '2026-11',
      endMonth: null,
      spent: 0,
    });

    await ctx.addTx('Makan', 50_000, '2026-11-10T03:00:00Z');
    await ctx.addTx('Transport', 20_000, '2026-11-11T03:00:00Z');
    // Di luar budget: kategori lain, bulan lain (1 Des 00.30 WIB), pemasukan.
    await ctx.addTx('Belanja', 99_000, '2026-11-10T03:00:00Z');
    await ctx.addTx('Makan', 7_000, '2026-11-30T17:30:00Z');
    await ctx.addTx('Gaji / Uang saku', 1_000_000, '2026-11-10T03:00:00Z', 'INCOME');

    const [budget] = await ctx.list('2026-11');
    expect(budget!.spent).toBe(70_000);
    expect(budget!.categories.map((c) => c.name).sort()).toEqual(['Makan', 'Transport']);
  });

  it('biaya admin transfer tidak masuk budget walau kategorinya dipilih', async () => {
    const ctx = await setup();
    const bank = (
      await ctx.call('POST', '/wallets', {
        name: 'BCA',
        type: 'BANK',
        initialBalance: 100_000,
        icon: 'account_balance_rounded',
        color: '#3B82F6',
      })
    ).json().id;
    await ctx.call('POST', '/transfers', {
      fromWalletId: bank,
      toWalletId: ctx.cashId,
      amount: 15_000,
      fee: 1_000,
      feePaidBy: 'FROM',
      occurredAt: '2026-11-10T03:00:00Z',
    });
    const fee = (await ctx.call('GET', '/categories'))
      .json()
      .items.find((c: { name: string }) => c.name === 'Biaya Admin').id;
    await ctx.call('POST', '/budgets', {
      name: 'Admin',
      limitAmount: 10_000,
      categoryIds: [fee],
      month: '2026-11',
    });

    expect((await ctx.list('2026-11'))[0]!.spent).toBe(0);
  });

  it('lanjut ke bulan berikutnya; ubah di tengah tidak mengubah bulan lama', async () => {
    const ctx = await setup();
    const id = (
      await ctx.call('POST', '/budgets', {
        name: 'Makan',
        limitAmount: 1_000_000,
        categoryIds: [ctx.category('Makan')],
        month: '2026-10',
      })
    ).json().id;
    expect(await ctx.list('2026-09')).toEqual([]);
    expect((await ctx.list('2027-03'))[0]!.limitAmount).toBe(1_000_000);

    const updated = await ctx.call('PATCH', `/budgets/${id}`, {
      limitAmount: 1_500_000,
      month: '2026-12',
    });
    expect(updated.statusCode).toBe(200);
    expect(updated.json()).toMatchObject({
      limitAmount: 1_500_000,
      startMonth: '2026-12',
    });

    expect(await ctx.list('2026-11')).toEqual([
      expect.objectContaining({
        id,
        limitAmount: 1_000_000,
        endMonth: '2026-11',
      }),
    ]);
    expect((await ctx.list('2027-01'))[0]!.limitAmount).toBe(1_500_000);

    // Ubah lagi di bulan mulainya: diubah langsung, tidak membuat versi baru.
    const newId = updated.json().id;
    await ctx.call('PATCH', `/budgets/${newId}`, {
      name: 'Makan & Transport',
      categoryIds: [ctx.category('Makan'), ctx.category('Transport')],
      month: '2026-12',
    });
    const [december] = await ctx.list('2026-12');
    expect(december).toMatchObject({ id: newId, name: 'Makan & Transport' });
    expect(december!.categories).toHaveLength(2);
  });

  it('hapus: di bulan mulai terhapus, di bulan setelahnya hanya berhenti', async () => {
    const ctx = await setup();
    const make = async (month: string) =>
      (
        await ctx.call('POST', '/budgets', {
          name: `Makan ${month}`,
          limitAmount: 500_000,
          categoryIds: [ctx.category('Makan')],
          month,
        })
      ).json().id;
    const fresh = await make('2026-11');
    const old = await make('2026-09');

    expect((await ctx.call('DELETE', `/budgets/${fresh}?month=2026-11`)).statusCode).toBe(204);
    expect((await ctx.call('DELETE', `/budgets/${old}?month=2026-11`)).statusCode).toBe(204);

    expect(await ctx.list('2026-11')).toEqual([]);
    expect(await ctx.list('2026-10')).toEqual([expect.objectContaining({ id: old })]);
    // Sudah berhenti: tidak bisa diubah di bulan yang tidak berlaku.
    const late = await ctx.call('PATCH', `/budgets/${old}`, {
      limitAmount: 1,
      month: '2026-12',
    });
    expect(late.statusCode).toBe(404);
  });

  it('validasi: kategori pemasukan, kosong, bulan salah → 400', async () => {
    const ctx = await setup();
    const income = await ctx.call('POST', '/budgets', {
      name: 'Gaji',
      limitAmount: 1_000,
      categoryIds: [ctx.category('Gaji / Uang saku', 'INCOME')],
      month: '2026-11',
    });
    expect(income.statusCode).toBe(400);
    expect(income.json().error.message).toBe('Budget hanya untuk kategori pengeluaran');

    const empty = await ctx.call('POST', '/budgets', {
      name: 'Kosong',
      limitAmount: 1_000,
      categoryIds: [],
      month: '2026-11',
    });
    expect(empty.statusCode).toBe(400);
    expect((await ctx.call('GET', '/budgets?month=2026-13')).statusCode).toBe(400);
  });

  it('kategori dan budget milik user lain → 404', async () => {
    const a = await setup('a@example.test');
    const b = await setup('b@example.test');
    const foreign = await a.call('POST', '/budgets', {
      name: 'Pinjam kategori',
      limitAmount: 1_000,
      categoryIds: [b.category('Makan')],
      month: '2026-11',
    });
    expect(foreign.statusCode).toBe(404);

    const id = (
      await b.call('POST', '/budgets', {
        name: 'Punya B',
        limitAmount: 1_000,
        categoryIds: [b.category('Makan')],
        month: '2026-11',
      })
    ).json().id;
    expect(
      (
        await a.call('PATCH', `/budgets/${id}`, {
          limitAmount: 5,
          month: '2026-11',
        })
      ).statusCode,
    ).toBe(404);
    expect((await a.call('DELETE', `/budgets/${id}?month=2026-11`)).statusCode).toBe(404);
    expect(await a.list('2026-11')).toEqual([]);
  });
});
