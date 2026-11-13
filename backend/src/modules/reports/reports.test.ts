import { randomUUID } from 'node:crypto';
import { afterAll, beforeAll, beforeEach, describe, expect, it } from 'vitest';
import { authHeader, buildTestApp, createUser, resetDb } from '../../../test/helpers.js';

const app = buildTestApp();

beforeAll(() => app.ready());
beforeEach(() => resetDb(app.prisma));
afterAll(() => app.close());

async function setup(email = 'a@example.test') {
  const { accessToken } = await createUser(app, email);
  const headers = authHeader(accessToken);
  const get = (url: string) => app.inject({ url: `/api/v1${url}`, headers });
  const post = (url: string, payload: object) =>
    app.inject({ method: 'POST', url: `/api/v1${url}`, headers, payload });

  const cashId = (await get('/wallets')).json().items[0].id as string;
  const categories = (await get('/categories')).json().items as {
    id: string;
    name: string;
    type: string;
  }[];
  const category = (name: string, type = 'EXPENSE') =>
    categories.find((c) => c.name === name && c.type === type)!.id;

  const addTx = async (
    amount: number,
    occurredAt: string,
    overrides: Partial<{ walletId: string; categoryId: string; type: string; note: string }> = {},
  ) => {
    const res = await post('/transactions', {
      walletId: cashId,
      categoryId: category('Makan'),
      type: 'EXPENSE',
      amount,
      occurredAt,
      ...overrides,
    });
    expect(res.statusCode).toBe(201);
  };
  const addIncome = (amount: number, occurredAt: string) =>
    addTx(amount, occurredAt, { type: 'INCOME', categoryId: category('Gaji / Uang saku', 'INCOME') });
  const addWallet = async () =>
    (
      await post('/wallets', {
        name: 'Bank',
        type: 'BANK',
        initialBalance: 0,
        icon: 'account_balance_rounded',
        color: '#3B82F6',
      })
    ).json().id as string;

  return { get, post, cashId, category, addTx, addIncome, addWallet };
}

describe('GET /reports/daily', () => {
  it('menghitung total dan kategori, series kosong, comparison null', async () => {
    const { get, category, addTx, addIncome } = await setup();
    await addTx(10000, '2026-11-04T02:00:00.000Z');
    await addTx(30000, '2026-11-04T03:00:00.000Z', { categoryId: category('Transport') });
    await addIncome(100000, '2026-11-04T04:00:00.000Z');

    const res = await get('/reports/daily?date=2026-11-04');

    expect(res.statusCode).toBe(200);
    expect(res.json()).toMatchObject({
      period: { type: 'daily', start: '2026-11-04', end: '2026-11-04' },
      totals: { income: 100000, expense: 40000, net: 60000, transactionCount: 3 },
      series: [],
      comparison: null,
    });
    const byCategory = res.json().byCategory as { category: { name: string }; amount: number; share: number }[];
    expect(byCategory.map((row) => [row.category.name, row.amount, row.share])).toEqual([
      ['Transport', 30000, 0.75],
      ['Makan', 10000, 0.25],
    ]);
  });

  it('memakai batas hari zona waktu user (Asia/Jakarta)', async () => {
    const { get, addTx } = await setup();
    await addTx(1000, '2026-11-04T16:30:00.000Z'); // 23.30 WIB, 4 Nov
    await addTx(2000, '2026-11-04T17:30:00.000Z'); // 00.30 WIB, 5 Nov

    expect((await get('/reports/daily?date=2026-11-04')).json().totals.expense).toBe(1000);
    expect((await get('/reports/daily?date=2026-11-05')).json().totals.expense).toBe(2000);
  });

  it('transfer tidak dihitung', async () => {
    const { get, post, cashId, addWallet } = await setup();
    const bankId = await addWallet();
    const transfer = await post('/transfers', {
      fromWalletId: cashId,
      toWalletId: bankId,
      amount: 50000,
      occurredAt: '2026-11-04T02:00:00.000Z',
    });
    expect(transfer.statusCode).toBe(201);

    expect((await get('/reports/daily?date=2026-11-04')).json().totals).toEqual({
      income: 0,
      expense: 0,
      net: 0,
      transactionCount: 0,
    });
  });

  it('periode kosong tidak error', async () => {
    const { get } = await setup();
    const res = await get('/reports/daily?date=2026-11-04');
    expect(res.statusCode).toBe(200);
    expect(res.json().byCategory).toEqual([]);
  });

  it('menolak tanggal tidak valid dan tanpa token', async () => {
    const { get } = await setup();
    expect((await get('/reports/daily?date=04-11-2026')).statusCode).toBe(400);
    expect((await get('/reports/daily')).statusCode).toBe(400);
    expect(
      (await app.inject({ url: '/api/v1/reports/daily?date=2026-11-04' })).statusCode,
    ).toBe(401);
  });

  it('memfilter per dompet', async () => {
    const { get, cashId, addTx, addWallet } = await setup();
    const bankId = await addWallet();
    await addTx(1000, '2026-11-04T02:00:00.000Z');
    await addTx(5000, '2026-11-04T02:00:00.000Z', { walletId: bankId });

    const expense = async (query: string) =>
      (await get(`/reports/daily?date=2026-11-04${query}`)).json().totals.expense;
    expect(await expense('')).toBe(6000);
    expect(await expense(`&wallet=${cashId}`)).toBe(1000);
    expect(await expense(`&wallet=${bankId}`)).toBe(5000);
  });

  it('data user lain tidak ikut, dompet asing menghasilkan laporan kosong', async () => {
    const owner = await setup('pemilik@example.test');
    const other = await setup('lain@example.test');
    await owner.addTx(1000, '2026-11-04T02:00:00.000Z');

    const own = await other.get('/reports/daily?date=2026-11-04');
    expect(own.json().totals.transactionCount).toBe(0);

    const foreign = await other.get(`/reports/daily?date=2026-11-04&wallet=${owner.cashId}`);
    expect(foreign.statusCode).toBe(200);
    expect(foreign.json().totals.transactionCount).toBe(0);

    const unknown = await other.get(`/reports/daily?date=2026-11-04&wallet=${randomUUID()}`);
    expect(unknown.statusCode).toBe(200);
  });
});

describe('GET /reports/weekly', () => {
  it('series 7 hari Senin-Minggu, termasuk hari kosong', async () => {
    const { get, addTx, addIncome } = await setup();
    await addTx(1000, '2026-11-02T02:00:00.000Z'); // Senin
    await addIncome(7000, '2026-11-08T02:00:00.000Z'); // Minggu
    await addTx(9000, '2026-11-09T02:00:00.000Z'); // Senin berikutnya

    const res = await get('/reports/weekly?start=2026-11-02');

    expect(res.statusCode).toBe(200);
    const body = res.json();
    expect(body.period).toEqual({ type: 'weekly', start: '2026-11-02', end: '2026-11-08' });
    expect(body.totals).toMatchObject({ income: 7000, expense: 1000, transactionCount: 2 });
    expect(body.series).toHaveLength(7);
    expect(body.series[0]).toEqual({ label: '2026-11-02', income: 0, expense: 1000 });
    expect(body.series[3]).toEqual({ label: '2026-11-05', income: 0, expense: 0 });
    expect(body.series[6]).toEqual({ label: '2026-11-08', income: 7000, expense: 0 });
    expect(body.comparison).toBeNull();
  });

  it('series ikut filter dompet', async () => {
    const { get, addTx, addWallet } = await setup();
    const bankId = await addWallet();
    await addTx(1000, '2026-11-02T02:00:00.000Z');
    await addTx(5000, '2026-11-02T02:00:00.000Z', { walletId: bankId });

    const res = await get(`/reports/weekly?start=2026-11-02&wallet=${bankId}`);
    expect(res.json().series[0].expense).toBe(5000);
  });

  it('menolak start yang bukan Senin', async () => {
    const { get } = await setup();
    const res = await get('/reports/weekly?start=2026-11-03');
    expect(res.statusCode).toBe(400);
    expect(res.json().error.code).toBe('VALIDATION_ERROR');
  });
});

describe('GET /reports/monthly', () => {
  it.each([
    ['2026-11', '2026-11-30', 30],
    ['2026-12', '2026-12-31', 31],
    ['2027-02', '2027-02-28', 28],
    ['2028-02', '2028-02-29', 29],
  ])('series %s berisi satu titik per hari', async (month, end, days) => {
    const { get } = await setup();
    const body = (await get(`/reports/monthly?month=${month}`)).json();
    expect(body.period).toEqual({ type: 'monthly', start: `${month}-01`, end });
    expect(body.series).toHaveLength(days);
    expect(body.series.at(-1).label).toBe(end);
  });

  it('membandingkan pengeluaran dengan bulan lalu', async () => {
    const { get, addTx } = await setup();
    await addTx(40000, '2026-10-15T02:00:00.000Z');
    await addTx(50000, '2026-11-15T02:00:00.000Z');

    expect((await get('/reports/monthly?month=2026-11')).json().comparison).toEqual({
      previousExpense: 40000,
      changePct: 25,
    });
  });

  it('bulan Januari membandingkan dengan Desember tahun lalu', async () => {
    const { get, addTx } = await setup();
    await addTx(40000, '2026-12-15T02:00:00.000Z');
    await addTx(10000, '2027-01-15T02:00:00.000Z');

    expect((await get('/reports/monthly?month=2027-01')).json().comparison).toEqual({
      previousExpense: 40000,
      changePct: -75,
    });
  });

  it('changePct null jika bulan lalu 0', async () => {
    const { get, addTx } = await setup();
    await addTx(50000, '2026-11-15T02:00:00.000Z');

    expect((await get('/reports/monthly?month=2026-11')).json().comparison).toEqual({
      previousExpense: 0,
      changePct: null,
    });
  });

  it('perbandingan ikut filter dompet', async () => {
    const { get, addTx, addWallet } = await setup();
    const bankId = await addWallet();
    await addTx(40000, '2026-10-15T02:00:00.000Z');
    await addTx(10000, '2026-10-15T02:00:00.000Z', { walletId: bankId });

    const res = await get(`/reports/monthly?month=2026-11&wallet=${bankId}`);
    expect(res.json().comparison.previousExpense).toBe(10000);
  });

  it('menolak bulan tidak valid', async () => {
    const { get } = await setup();
    expect((await get('/reports/monthly?month=2026-13')).statusCode).toBe(400);
  });
});

describe('GET /reports/range', () => {
  it('series per hari sepanjang rentang lintas bulan', async () => {
    const { get, addTx, addIncome, post, cashId, addWallet } = await setup();
    const bankId = await addWallet();
    await addTx(1000, '2026-10-30T02:00:00.000Z');
    await addIncome(7000, '2026-11-02T02:00:00.000Z');
    await addTx(9000, '2026-11-03T02:00:00.000Z'); // di luar rentang
    await post('/transfers', {
      fromWalletId: cashId,
      toWalletId: bankId,
      amount: 5000,
      occurredAt: '2026-10-31T02:00:00.000Z',
    });

    const res = await get('/reports/range?from=2026-10-30&to=2026-11-02');

    expect(res.statusCode).toBe(200);
    const body = res.json();
    expect(body.period).toEqual({ type: 'range', start: '2026-10-30', end: '2026-11-02' });
    expect(body.series).toHaveLength(4);
    expect(body.series[0]).toEqual({ label: '2026-10-30', income: 0, expense: 1000 });
    expect(body.totals).toEqual({ income: 7000, expense: 1000, net: 6000, transactionCount: 2 });
  });

  it('membandingkan dengan periode sepanjang sama sebelumnya', async () => {
    const { get, addTx } = await setup();
    await addTx(40000, '2026-10-26T02:00:00.000Z');
    await addTx(1000, '2026-10-29T02:00:00.000Z');
    await addTx(99000, '2026-10-25T02:00:00.000Z'); // di luar periode sebelumnya
    await addTx(51000, '2026-11-01T02:00:00.000Z');

    expect((await get('/reports/range?from=2026-10-30&to=2026-11-02')).json().comparison).toEqual({
      previousExpense: 41000,
      changePct: 24.4,
    });
    expect((await get('/reports/range?from=2026-10-10&to=2026-10-12')).json().comparison).toEqual({
      previousExpense: 0,
      changePct: null,
    });
  });

  it('menerima tepat 366 hari', async () => {
    const { get } = await setup();
    const res = await get('/reports/range?from=2025-01-01&to=2026-01-01');
    expect(res.statusCode).toBe(200);
    expect(res.json().series).toHaveLength(366);
  });

  it('menolak lebih dari 366 hari', async () => {
    const { get } = await setup();
    const res = await get('/reports/range?from=2025-01-01&to=2026-01-02');
    expect(res.statusCode).toBe(400);
    expect(res.json().error.code).toBe('VALIDATION_ERROR');
  });

  it('menolak to sebelum from', async () => {
    const { get } = await setup();
    const res = await get('/reports/range?from=2026-11-10&to=2026-11-09');
    expect(res.statusCode).toBe(400);
    expect(res.json().error.code).toBe('VALIDATION_ERROR');
  });

  it('menolak tanggal tidak valid dan tanpa token', async () => {
    const { get } = await setup();
    expect((await get('/reports/range?from=2026-13-01&to=2026-11-09')).statusCode).toBe(400);
    expect((await get('/reports/range?from=2026-11-01')).statusCode).toBe(400);
    expect(
      (await app.inject({ url: '/api/v1/reports/range?from=2026-11-01&to=2026-11-02' })).statusCode,
    ).toBe(401);
  });

  it('data user lain tidak ikut, dompet asing menghasilkan laporan kosong', async () => {
    const owner = await setup('pemilik@example.test');
    const other = await setup('lain@example.test');
    await owner.addTx(1000, '2026-11-04T02:00:00.000Z');

    const own = await other.get('/reports/range?from=2026-11-01&to=2026-11-07');
    expect(own.json().totals.transactionCount).toBe(0);

    const foreign = await other.get(
      `/reports/range?from=2026-11-01&to=2026-11-07&wallet=${owner.cashId}`,
    );
    expect(foreign.statusCode).toBe(200);
    expect(foreign.json().totals.transactionCount).toBe(0);
  });
});

describe('GET /reports/export', () => {
  it('CSV: transaksi di rentang, tanpa transfer, formula dinetralkan', async () => {
    const { get, addTx, addIncome, post, cashId, addWallet } = await setup();
    const bankId = await addWallet();
    await addTx(1000, '2026-10-30T02:00:00.000Z', { note: '=SUM(A1)' });
    await addIncome(7000, '2026-11-02T02:00:00.000Z');
    await addTx(9000, '2026-11-03T02:00:00.000Z'); // di luar rentang
    await post('/transfers', {
      fromWalletId: cashId,
      toWalletId: bankId,
      amount: 5000,
      occurredAt: '2026-10-31T02:00:00.000Z',
    });

    const res = await get('/reports/export?from=2026-10-30&to=2026-11-02&format=csv');

    expect(res.statusCode).toBe(200);
    expect(res.headers['content-type']).toContain('text/csv');
    expect(res.headers['content-disposition']).toBe(
      'attachment; filename="direkapin-laporan-2026-10-30_2026-11-02.csv"',
    );
    const lines = res.body.replace(/^\uFEFF/, '').trimEnd().split('\r\n');
    expect(lines).toEqual([
      '"tanggal","jam","jenis","dompet","kategori","nominal","catatan"',
      `"2026-10-30","09:00","Pengeluaran","Cash","Makan","1000","'=SUM(A1)"`,
      '"2026-11-02","09:00","Pemasukan","Cash","Gaji / Uang saku","7000",""',
    ]);
  });

  it('PDF: file PDF dengan nama sesuai rentang', async () => {
    const { get, addTx } = await setup();
    await addTx(25000, '2026-11-01T02:00:00.000Z', { note: 'Bakso 🍜' });

    const res = await get('/reports/export?from=2026-11-01&to=2026-11-30&format=pdf');

    expect(res.statusCode).toBe(200);
    expect(res.headers['content-type']).toBe('application/pdf');
    expect(res.headers['content-disposition']).toContain(
      'direkapin-laporan-2026-11-01_2026-11-30.pdf',
    );
    expect(res.rawPayload.subarray(0, 5).toString()).toBe('%PDF-');
  });

  it('menolak format, rentang tidak valid, dan tanpa token', async () => {
    const { get } = await setup();
    const status = async (query: string) => (await get(`/reports/export?${query}`)).statusCode;
    expect(await status('from=2026-11-01&to=2026-11-02&format=xls')).toBe(400);
    expect(await status('from=2026-11-02&to=2026-11-01&format=csv')).toBe(400);
    expect(await status('from=2025-01-01&to=2026-01-02&format=csv')).toBe(400);
    const res = await app.inject({
      url: '/api/v1/reports/export?from=2026-11-01&to=2026-11-02&format=csv',
    });
    expect(res.statusCode).toBe(401);
  });

  it('data user lain tidak ikut', async () => {
    const owner = await setup('pemilik@example.test');
    const other = await setup('lain@example.test');
    await owner.addTx(1000, '2026-11-04T02:00:00.000Z');

    const res = await other.get(
      `/reports/export?from=2026-11-01&to=2026-11-30&format=csv&wallet=${owner.cashId}`,
    );
    expect(res.statusCode).toBe(200);
    expect(res.body.trimEnd().split('\r\n')).toHaveLength(1);
  });
});
