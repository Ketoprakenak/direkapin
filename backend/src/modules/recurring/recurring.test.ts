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

  const wallets = (await call('GET', '/wallets')).json().items as { id: string }[];
  const categories = (await call('GET', '/categories')).json().items as {
    id: string;
    name: string;
    type: string;
  }[];
  const category = (name: string, type = 'EXPENSE') =>
    categories.find((c) => c.name === name && c.type === type)!.id;
  const body = (over: object = {}) => ({
    walletId: wallets[0]!.id,
    categoryId: category('Makan'),
    type: 'EXPENSE',
    amount: 1_500_000,
    dayOfMonth: 31,
    startMonth: '2026-01',
    ...over,
  });
  const create = async (over: object = {}) => (await call('POST', '/recurring', body(over))).json();
  return { call, category, body, create, walletId: wallets[0]!.id };
}

describe('recurring (FIN-15) CRUD', () => {
  it('POST sukses 201 dengan wallet, category, dan next', async () => {
    const ctx = await setup();
    const res = await ctx.call('POST', '/recurring', ctx.body({ note: 'Kos' }));
    expect(res.statusCode).toBe(201);
    expect(res.json()).toMatchObject({
      type: 'EXPENSE',
      amount: 1_500_000,
      note: 'Kos',
      dayOfMonth: 31,
      startMonth: '2026-01',
      endMonth: null,
      lastHandledMonth: null,
      wallet: { id: ctx.walletId, name: expect.any(String) },
      category: { name: 'Makan' },
      next: { month: '2026-01', dueDate: '2026-01-31' },
    });
  });

  it.each([
    ['amount 0', { amount: 0 }, 'amount'],
    ['dayOfMonth 0', { dayOfMonth: 0 }, 'dayOfMonth'],
    ['dayOfMonth 32', { dayOfMonth: 32 }, 'dayOfMonth'],
    ['endMonth < startMonth', { startMonth: '2026-05', endMonth: '2026-04' }, 'endMonth'],
    ['bulan tidak valid', { startMonth: '2026-13' }, 'startMonth'],
  ])('POST validasi gagal: %s → 400', async (_name, over, field) => {
    const ctx = await setup();
    const res = await ctx.call('POST', '/recurring', ctx.body(over));
    expect(res.statusCode).toBe(400);
    expect(res.json().error.code).toBe('VALIDATION_ERROR');
    expect(res.json().error.details).toHaveProperty(field);
  });

  it('POST kategori jenis lain → 400', async () => {
    const ctx = await setup();
    const res = await ctx.call(
      'POST',
      '/recurring',
      ctx.body({ categoryId: ctx.category('Gaji / Uang saku', 'INCOME') }),
    );
    expect(res.statusCode).toBe(400);
    expect(res.json().error.details).toHaveProperty('categoryId');
  });

  it('POST dompet arsip → 400', async () => {
    const ctx = await setup();
    await ctx.call('PATCH', `/wallets/${ctx.walletId}`, { isArchived: true });
    const res = await ctx.call('POST', '/recurring', ctx.body());
    expect(res.statusCode).toBe(400);
    expect(res.json().error.details).toHaveProperty('walletId');
  });

  it('tanpa token → 401', async () => {
    const res = await app.inject({ method: 'GET', url: '/api/v1/recurring' });
    expect(res.statusCode).toBe(401);
  });

  it('GET hanya milik sendiri', async () => {
    const a = await setup('a@example.test');
    const b = await setup('b@example.test');
    await a.create();
    expect((await b.call('GET', '/recurring')).json().items).toHaveLength(0);
    expect((await a.call('GET', '/recurring')).json().items).toHaveLength(1);
  });

  it('PATCH mengubah field dan endMonth null boleh; next ikut berubah', async () => {
    const ctx = await setup();
    const rule = await ctx.create({ endMonth: '2026-06' });
    const res = await ctx.call('PATCH', `/recurring/${rule.id}`, {
      amount: 2_000_000,
      dayOfMonth: 5,
      endMonth: null,
      note: null,
    });
    expect(res.statusCode).toBe(200);
    expect(res.json()).toMatchObject({
      amount: 2_000_000,
      dayOfMonth: 5,
      endMonth: null,
      next: { month: '2026-01', dueDate: '2026-01-05' },
    });
  });

  it('PATCH endMonth sebelum startMonth yang tersimpan → 400', async () => {
    const ctx = await setup();
    const rule = await ctx.create({ startMonth: '2026-05' });
    const res = await ctx.call('PATCH', `/recurring/${rule.id}`, { endMonth: '2026-04' });
    expect(res.statusCode).toBe(400);
    expect(res.json().error.details).toHaveProperty('endMonth');
  });

  it('PATCH jenis tanpa ganti kategori → 400', async () => {
    const ctx = await setup();
    const rule = await ctx.create();
    const res = await ctx.call('PATCH', `/recurring/${rule.id}`, { type: 'INCOME' });
    expect(res.statusCode).toBe(400);
  });

  it('PATCH/DELETE milik user lain → 404', async () => {
    const a = await setup('a@example.test');
    const b = await setup('b@example.test');
    const rule = await a.create();
    expect((await b.call('PATCH', `/recurring/${rule.id}`, { amount: 1 })).statusCode).toBe(404);
    expect((await b.call('DELETE', `/recurring/${rule.id}`)).statusCode).toBe(404);
    expect((await a.call('GET', '/recurring')).json().items).toHaveLength(1);
  });

  it('DELETE 204 dan tidak menghapus transaksi yang sudah tercatat', async () => {
    const ctx = await setup();
    const rule = await ctx.create();
    const tx = await ctx.call('POST', '/transactions', {
      walletId: ctx.walletId,
      categoryId: ctx.category('Makan'),
      type: 'EXPENSE',
      amount: 1_500_000,
      occurredAt: '2026-01-31T03:00:00Z',
    });
    expect(tx.statusCode).toBe(201);
    expect((await ctx.call('DELETE', `/recurring/${rule.id}`)).statusCode).toBe(204);
    expect((await ctx.call('GET', '/recurring')).json().items).toHaveLength(0);
    expect((await ctx.call('GET', `/transactions/${tx.json().id}`)).statusCode).toBe(200);
  });
});

describe('recurring: dompet/kategori yang dipakai aturan', () => {
  it('hapus dompet yang dipakai aturan → 409 WALLET_IN_USE, bukan 500', async () => {
    const ctx = await setup();
    // Dompet kedua supaya dompet pertama boleh dicoba dihapus.
    const second = (
      await ctx.call('POST', '/wallets', {
        name: 'Bank',
        type: 'BANK',
        icon: 'account_balance_rounded',
        color: '#0EA5E9',
      })
    ).json();
    await ctx.create({ walletId: second.id });
    const res = await ctx.call('DELETE', `/wallets/${second.id}`);
    expect(res.statusCode).toBe(409);
    expect(res.json().error.code).toBe('WALLET_IN_USE');
  });

  it('hapus kategori buatan sendiri yang dipakai aturan → 204, aturan pindah ke "Lainnya"', async () => {
    const ctx = await setup();
    const custom = (
      await ctx.call('POST', '/categories', {
        name: 'Kos',
        type: 'EXPENSE',
        icon: 'home_rounded',
        color: '#0EA5E9',
      })
    ).json();
    const rule = await ctx.create({ categoryId: custom.id });
    const res = await ctx.call('DELETE', `/categories/${custom.id}`);
    expect(res.statusCode).toBe(204);
    const list = (await ctx.call('GET', '/recurring')).json().items;
    expect(list.find((r: { id: string }) => r.id === rule.id).category.name).toBe('Lainnya');
  });
});
