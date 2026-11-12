import { afterAll, afterEach, beforeAll, beforeEach, describe, expect, it, vi } from 'vitest';
import { authHeader, buildTestApp, createUser, resetDb } from '../../../test/helpers.js';

const app = buildTestApp();

beforeAll(() => app.ready());
beforeEach(() => resetDb(app.prisma));
afterEach(() => vi.useRealTimers());
afterAll(() => app.close());

async function setup(email = 'a@example.test') {
  const { accessToken } = await createUser(app, email);
  const headers = authHeader(accessToken);
  const call = (method: 'GET' | 'POST' | 'PATCH', url: string, payload?: object) =>
    app.inject({ method, url: `/api/v1${url}`, headers, payload });
  const wallets = (await call('GET', '/wallets')).json().items as { id: string }[];
  const categories = (await call('GET', '/categories')).json().items as {
    id: string;
    name: string;
    type: string;
  }[];
  const body = (over: object = {}) => ({
    walletId: wallets[0]!.id,
    categoryId: categories.find((c) => c.name === 'Makan' && c.type === 'EXPENSE')!.id,
    type: 'EXPENSE',
    amount: 1_500_000,
    dayOfMonth: 31,
    startMonth: '2026-01',
    ...over,
  });
  const create = async (over: object = {}) => (await call('POST', '/recurring', body(over))).json();
  return { call, create };
}
type Ctx = Awaited<ReturnType<typeof setup>>;

// Hanya Date yang dipalsukan; dipasang sebelum setup/login, jadi token dan data seed ikut memakai waktu palsu.
const at = (iso: string) => vi.useFakeTimers({ toFake: ['Date'], now: new Date(iso) });
const due = async (ctx: Ctx) =>
  (await ctx.call('GET', '/recurring/due')).json().items as { month: string; dueDate: string }[];
const record = (ctx: Ctx, id: string, payload: object) =>
  ctx.call('POST', `/recurring/${id}/record`, payload);
const skip = (ctx: Ctx, id: string, month: string) =>
  ctx.call('POST', `/recurring/${id}/skip`, { month });

describe('recurring (FIN-15) jatuh tempo', () => {
  it('day 5 muncul pada 05 Nov 23:30 WIB, day 6 tidak (zona waktu user)', async () => {
    at('2026-11-05T16:30:00Z');
    const ctx = await setup();
    await ctx.create({ dayOfMonth: 6, startMonth: '2026-11' });
    expect(await due(ctx)).toHaveLength(0);
    await ctx.create({ dayOfMonth: 5, startMonth: '2026-11' });
    expect(await due(ctx)).toHaveLength(1);
  });

  it('aturan selesai, milik user lain, dan belum jatuh tempo tidak muncul; urut dueDate', async () => {
    at('2026-11-25T05:00:00Z');
    const ctx = await setup();
    const other = await setup('b@example.test');
    await other.create({ startMonth: '2026-01' });
    await ctx.create({ dayOfMonth: 20, startMonth: '2026-11' });
    await ctx.create({ dayOfMonth: 3, startMonth: '2026-11' });
    await ctx.create({ dayOfMonth: 28, startMonth: '2026-11' });
    const ended = await ctx.create({ startMonth: '2026-01', endMonth: '2026-01' });
    expect((await skip(ctx, ended.id, '2026-01')).statusCode).toBe(204);
    expect((await due(ctx)).map((d) => d.dueDate)).toEqual(['2026-11-03', '2026-11-20']);
  });

  it('bulan terlewat: tampil bulan tertua, setelah skip bulan berikutnya, tanpa transaksi', async () => {
    at('2026-11-12T05:00:00Z');
    const ctx = await setup();
    const rule = await ctx.create({ dayOfMonth: 10, startMonth: '2026-08' });
    expect((await due(ctx))[0]).toMatchObject({ month: '2026-08', dueDate: '2026-08-10' });
    expect((await skip(ctx, rule.id, '2026-08')).statusCode).toBe(204);
    expect((await due(ctx))[0]).toMatchObject({ month: '2026-09', dueDate: '2026-09-10' });
    expect((await ctx.call('GET', '/transactions')).json().items).toHaveLength(0);
  });
});

describe('recurring (FIN-15) catat', () => {
  it('201, nominal aturan, occurredAt 12:00 WIB, lastHandledMonth maju, muncul di transaksi dan dashboard', async () => {
    at('2026-11-05T05:00:00Z');
    const ctx = await setup();
    const rule = await ctx.create({ dayOfMonth: 5, startMonth: '2026-11', note: 'Kos' });
    const res = await record(ctx, rule.id, { month: '2026-11' });
    expect(res.statusCode).toBe(201);
    expect(res.json()).toMatchObject({
      amount: 1_500_000,
      type: 'EXPENSE',
      note: 'Kos',
      occurredAt: '2026-11-05T05:00:00.000Z',
    });
    const list = (await ctx.call('GET', '/recurring')).json().items;
    expect(list[0].lastHandledMonth).toBe('2026-11');
    expect((await ctx.call('GET', '/transactions')).json().items).toHaveLength(1);
    expect((await ctx.call('GET', '/dashboard')).json().month.expense).toBe(1_500_000);
  });

  it('override nominal dan catatan', async () => {
    at('2026-11-05T05:00:00Z');
    const ctx = await setup();
    const rule = await ctx.create({ dayOfMonth: 5, startMonth: '2026-11' });
    const res = await record(ctx, rule.id, { month: '2026-11', amount: 1_000, note: 'Diskon' });
    expect(res.json()).toMatchObject({ amount: 1_000, note: 'Diskon' });
  });

  it('bulan bukan kejadian berikutnya → 409 CONFLICT', async () => {
    at('2026-11-12T05:00:00Z');
    const ctx = await setup();
    const rule = await ctx.create({ dayOfMonth: 5, startMonth: '2026-09' });
    const res = await record(ctx, rule.id, { month: '2026-10' });
    expect(res.statusCode).toBe(409);
    expect(res.json().error.code).toBe('CONFLICT');
  });

  it('belum jatuh tempo → 409', async () => {
    at('2026-11-12T05:00:00Z');
    const ctx = await setup();
    const rule = await ctx.create({ dayOfMonth: 20, startMonth: '2026-11' });
    expect((await record(ctx, rule.id, { month: '2026-11' })).statusCode).toBe(409);
  });

  it('dua panggilan bersamaan → satu 201, satu 409, satu transaksi', async () => {
    at('2026-11-12T05:00:00Z');
    const ctx = await setup();
    const rule = await ctx.create({ dayOfMonth: 5, startMonth: '2026-11' });
    const codes = (
      await Promise.all([record(ctx, rule.id, { month: '2026-11' }), record(ctx, rule.id, { month: '2026-11' })])
    )
      .map((r) => r.statusCode)
      .sort();
    expect(codes).toEqual([201, 409]);
    expect((await ctx.call('GET', '/transactions')).json().items).toHaveLength(1);
  });

  it('dompet diarsipkan setelah aturan dibuat → 400, kejadian tetap jatuh tempo', async () => {
    at('2026-11-12T05:00:00Z');
    const ctx = await setup();
    const second = (
      await ctx.call('POST', '/wallets', {
        name: 'Bank',
        type: 'BANK',
        icon: 'account_balance_rounded',
        color: '#0EA5E9',
      })
    ).json();
    const rule = await ctx.create({ walletId: second.id, dayOfMonth: 5, startMonth: '2026-11' });
    await ctx.call('PATCH', `/wallets/${second.id}`, { isArchived: true });
    expect((await record(ctx, rule.id, { month: '2026-11' })).statusCode).toBe(400);
    expect(await due(ctx)).toHaveLength(1);
  });

  it('aturan user lain → 404 (record dan skip); month tidak valid → 400', async () => {
    const ctx = await setup();
    const other = await setup('b@example.test');
    const rule = await other.create({ startMonth: '2026-01' });
    expect((await record(ctx, rule.id, { month: '2026-01' })).statusCode).toBe(404);
    expect((await skip(ctx, rule.id, '2026-01')).statusCode).toBe(404);
    const mine = await ctx.create();
    expect((await skip(ctx, mine.id, 'x')).statusCode).toBe(400);
  });
});
