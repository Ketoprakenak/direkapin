import { afterAll, beforeAll, beforeEach, describe, expect, it } from 'vitest';
import { authHeader, buildTestApp, createUser, resetDb } from '../../../test/helpers.js';

const app = buildTestApp();

beforeAll(() => app.ready());
beforeEach(() => resetDb(app.prisma));
afterAll(() => app.close());

async function setup(email = 'a@example.test') {
  const { accessToken, user } = await createUser(app, email);
  const headers = authHeader(accessToken);
  const get = (url: string) => app.inject({ url: `/api/v1${url}`, headers });
  const post = (url: string, payload: object) =>
    app.inject({ method: 'POST', url: `/api/v1${url}`, headers, payload });
  const patch = (url: string, payload: object) =>
    app.inject({ method: 'PATCH', url: `/api/v1${url}`, headers, payload });

  const walletId = (await get('/wallets')).json().items[0].id as string;
  const categories = (await get('/categories')).json().items as {
    id: string;
    name: string;
    type: string;
  }[];
  const categoryId = (type: string) =>
    categories.find((c) => c.name === 'Lainnya' && c.type === type)!.id;

  const addTx = (amount: number, occurredAt: string, type = 'EXPENSE', note?: string) =>
    post('/transactions', {
      walletId,
      categoryId: categoryId(type),
      type,
      amount,
      occurredAt,
      note,
    });

  const addActivity = (title: string, date: string, extra: object = {}) =>
    app.prisma.activity.create({
      data: { userId: user.id, title, date: new Date(`${date}T00:00:00Z`), ...extra },
    });

  return { get, post, patch, userId: user.id, walletId, addTx, addActivity };
}

describe('GET /calendar', () => {
  it('total per tanggal, hanya tanggal yang punya data, urut naik', async () => {
    const ctx = await setup();
    await ctx.addTx(1000, '2026-11-10T03:00:00Z');
    await ctx.addTx(2000, '2026-11-10T04:00:00Z');
    await ctx.addTx(5000, '2026-11-10T05:00:00Z', 'INCOME');
    await ctx.addTx(300, '2026-11-02T03:00:00Z');
    await ctx.addActivity('Rapat', '2026-11-15');
    await ctx.addActivity('Wisuda', '2026-11-10', { isImportant: true });
    await ctx.addActivity('Kuliah', '2026-11-10');

    const res = await ctx.get('/calendar?month=2026-11');
    expect(res.statusCode).toBe(200);
    expect(res.json()).toEqual({
      month: '2026-11',
      days: [
        { date: '2026-11-02', income: 0, expense: 300, activityCount: 0, hasImportant: false },
        { date: '2026-11-10', income: 5000, expense: 3000, activityCount: 2, hasImportant: true },
        { date: '2026-11-15', income: 0, expense: 0, activityCount: 1, hasImportant: false },
      ],
    });
  });

  it('batas bulan mengikuti zona waktu user', async () => {
    const ctx = await setup();
    // 00.30 WIB 1 November, 23.30 WIB 31 Oktober, 00.30 WIB 1 Desember.
    await ctx.addTx(1, '2026-10-31T17:30:00Z');
    await ctx.addTx(2, '2026-10-31T16:30:00Z');
    await ctx.addTx(3, '2026-11-30T17:30:00Z');

    const nov = (await ctx.get('/calendar?month=2026-11')).json();
    expect(nov.days).toEqual([
      { date: '2026-11-01', income: 0, expense: 1, activityCount: 0, hasImportant: false },
    ]);
    const oct = (await ctx.get('/calendar?month=2026-10')).json();
    expect(oct.days[0]).toMatchObject({ date: '2026-10-31', expense: 2 });
    const dec = (await ctx.get('/calendar?month=2026-12')).json();
    expect(dec.days[0]).toMatchObject({ date: '2026-12-01', expense: 3 });
  });

  it('kegiatan di tanggal terakhir bulan ikut, bulan berikutnya tidak', async () => {
    const ctx = await setup();
    await ctx.addActivity('Akhir', '2026-11-30');
    await ctx.addActivity('Awal', '2026-12-01');
    const days = (await ctx.get('/calendar?month=2026-11')).json().days;
    expect(days.map((d: { date: string }) => d.date)).toEqual(['2026-11-30']);
  });

  it('tanggal yang hanya berisi transfer tidak masuk (D-33)', async () => {
    const ctx = await setup();
    const bank = (
      await ctx.post('/wallets', {
        name: 'Bank',
        type: 'BANK',
        icon: 'x',
        color: '#3B82F6',
      })
    ).json().id;
    await ctx.post('/transfers', {
      fromWalletId: bank,
      toWalletId: ctx.walletId,
      amount: 1000,
      occurredAt: '2026-11-10T03:00:00Z',
    });
    expect((await ctx.get('/calendar?month=2026-11')).json().days).toEqual([]);
  });

  it.each(['2026-13', '2026-1', 'november', ''])('bulan %s ditolak', async (month) => {
    const ctx = await setup();
    const res = await ctx.get(`/calendar?month=${month}`);
    expect(res.statusCode).toBe(400);
    expect(res.json().error.details.month).toBe('Bulan tidak valid');
  });

  it('bulan kosong dan data user lain tidak ikut', async () => {
    const a = await setup('a@example.test');
    const b = await setup('b@example.test');
    await a.addTx(1000, '2026-11-10T03:00:00Z');
    await a.addActivity('Rapat', '2026-11-10');
    expect((await b.get('/calendar?month=2026-11')).json().days).toEqual([]);
  });

  it('tanpa token 401', async () => {
    const res = await app.inject({ url: '/api/v1/calendar?month=2026-11' });
    expect(res.statusCode).toBe(401);
  });
});

describe('GET /days/:date', () => {
  it('isi hari: total, transaksi, transfer tanpa ikut total, dan urutan kegiatan', async () => {
    const ctx = await setup();
    const bank = (
      await ctx.post('/wallets', {
        name: 'Bank',
        type: 'BANK',
        icon: 'x',
        color: '#3B82F6',
      })
    ).json().id;
    await ctx.addTx(1000, '2026-11-10T03:00:00Z');
    await ctx.addTx(2000, '2026-11-10T05:00:00Z');
    await ctx.addTx(9000, '2026-11-10T06:00:00Z', 'INCOME');
    await ctx.post('/transfers', {
      fromWalletId: bank,
      toWalletId: ctx.walletId,
      amount: 5000,
      occurredAt: '2026-11-10T03:00:00Z',
    });
    await ctx.addActivity('tanpa jam', '2026-11-10');
    await ctx.addActivity('pagi', '2026-11-10', { time: '08:00' });
    await ctx.addActivity('sore', '2026-11-10', { time: '17:00' });
    await ctx.addActivity('penting', '2026-11-10', { time: '20:00', isImportant: true });

    const res = await ctx.get('/days/2026-11-10');
    expect(res.statusCode).toBe(200);
    const body = res.json();
    expect(body).toMatchObject({ date: '2026-11-10', income: 9000, expense: 3000, note: null });
    expect(body.transactions.map((t: { amount: number }) => t.amount)).toEqual([9000, 2000, 1000]);
    expect(body.transfers).toHaveLength(1);
    expect(body.transfers[0].amount).toBe(5000);
    expect(body.activities.map((a: { title: string }) => a.title)).toEqual([
      'penting',
      'pagi',
      'sore',
      'tanpa jam',
    ]);
    expect(body.activities[0].date).toBe('2026-11-10');
  });

  it('23.30 dan 00.30 WIB jatuh di tanggal yang benar', async () => {
    const ctx = await setup();
    await ctx.addTx(1, '2026-11-10T16:30:00Z');
    await ctx.addTx(2, '2026-11-10T17:30:00Z');
    expect((await ctx.get('/days/2026-11-10')).json().expense).toBe(1);
    expect((await ctx.get('/days/2026-11-11')).json().expense).toBe(2);
  });

  it('pindah tanggal memindahkan transaksi dan penanda kalender (US-05)', async () => {
    const ctx = await setup();
    const tx = (await ctx.addTx(1000, '2026-11-10T03:00:00Z')).json();
    await ctx.patch(`/transactions/${tx.id}`, { occurredAt: '2026-12-05T03:00:00Z' });

    expect((await ctx.get('/days/2026-11-10')).json().transactions).toEqual([]);
    expect((await ctx.get('/days/2026-12-05')).json().expense).toBe(1000);
    expect((await ctx.get('/calendar?month=2026-11')).json().days).toEqual([]);
    expect((await ctx.get('/calendar?month=2026-12')).json().days).toHaveLength(1);
  });

  it('catatan harian ikut terkirim', async () => {
    const ctx = await setup();
    await app.prisma.dailyNote.create({
      data: { userId: ctx.userId, date: new Date('2026-11-10T00:00:00Z'), mood: 'senang' },
    });
    expect((await ctx.get('/days/2026-11-10')).json().note).toEqual({
      date: '2026-11-10',
      mood: 'senang',
      note: null,
    });
  });

  it('tanggal tidak valid 400', async () => {
    const ctx = await setup();
    expect((await ctx.get('/days/2026-13-40')).statusCode).toBe(400);
    expect((await ctx.get('/days/besok')).statusCode).toBe(400);
  });

  it('hari kosong dan data user lain tidak ikut', async () => {
    const a = await setup('a@example.test');
    const b = await setup('b@example.test');
    await a.addTx(1000, '2026-11-10T03:00:00Z');
    await a.addActivity('Rapat', '2026-11-10');
    await app.prisma.dailyNote.create({
      data: { userId: a.userId, date: new Date('2026-11-10T00:00:00Z'), mood: 'senang' },
    });

    expect((await b.get('/days/2026-11-10')).json()).toEqual({
      date: '2026-11-10',
      income: 0,
      expense: 0,
      transactions: [],
      transfers: [],
      activities: [],
      note: null,
    });
  });

  it('tanpa token 401', async () => {
    expect((await app.inject({ url: '/api/v1/days/2026-11-10' })).statusCode).toBe(401);
  });
});
