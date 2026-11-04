import { afterAll, beforeAll, beforeEach, describe, expect, it } from 'vitest';
import { PASSWORD, buildTestApp, createInvite, createUser, resetDb } from '../../../test/helpers.js';

const app = buildTestApp();

beforeAll(() => app.ready());
beforeEach(() => resetDb(app.prisma));
afterAll(() => app.close());

const body = (inviteCode: string, email = 'baru@example.test') => ({
  name: 'Baru',
  email,
  password: PASSWORD,
  inviteCode,
});

const post = (path: string, payload: object, headers: Record<string, string> = {}) =>
  app.inject({ method: 'POST', url: `/api/v1/auth/${path}`, payload, headers });

describe('POST /auth/register', () => {
  it('membuat akun, dompet Cash, kategori bawaan, dan memakai kode', async () => {
    const code = await createInvite(app.prisma);
    const res = await post('register', body(code));
    expect(res.statusCode).toBe(201);

    const { user, accessToken, refreshToken, expiresIn } = res.json();
    expect(accessToken).toBeTruthy();
    expect(refreshToken).toBeTruthy();
    expect(expiresIn).toBe(900);
    expect(user).toMatchObject({
      name: 'Baru',
      email: 'baru@example.test',
      timezone: 'Asia/Jakarta',
      reminderTime: '21:00',
    });
    expect(user).not.toHaveProperty('passwordHash');

    const wallets = await app.prisma.wallet.findMany({ where: { userId: user.id } });
    expect(wallets).toMatchObject([{ name: 'Cash', type: 'CASH', initialBalance: 0n }]);

    const categories = await app.prisma.category.findMany({ where: { userId: user.id } });
    expect(categories).toHaveLength(9);
    expect(categories.every((c) => c.isDefault)).toBe(true);

    const invite = await app.prisma.inviteCode.findUnique({ where: { code } });
    expect(invite?.usedById).toBe(user.id);
    expect(invite?.usedAt).toBeTruthy();
  });

  it('menyimpan email dalam huruf kecil', async () => {
    const res = await post('register', body(await createInvite(app.prisma), 'BaRu@Example.TEST'));
    expect(res.json().user.email).toBe('baru@example.test');
  });

  it.each([
    ['salah', async () => 'kode-ngawur'],
    ['kedaluwarsa', () => createInvite(app.prisma, new Date(Date.now() - 1000))],
    [
      'terpakai',
      async () => {
        const code = await createInvite(app.prisma);
        await post('register', body(code, 'lain@example.test'));
        return code;
      },
    ],
  ])('kode undangan %s ditolak dan akun tidak dibuat', async (_name, makeCode) => {
    const res = await post('register', body(await makeCode()));
    expect(res.statusCode).toBe(422);
    expect(res.json().error).toEqual({
      code: 'INVITE_INVALID',
      message: 'Kode undangan tidak valid',
    });
    expect(await app.prisma.user.count({ where: { email: 'baru@example.test' } })).toBe(0);
  });

  it('email terdaftar ditolak dan kode tidak terpakai', async () => {
    await createUser(app, 'baru@example.test');
    const code = await createInvite(app.prisma);
    const res = await post('register', body(code, 'BARU@example.test'));
    expect(res.statusCode).toBe(409);
    expect(res.json().error).toEqual({ code: 'EMAIL_TAKEN', message: 'Email sudah dipakai' });
    const invite = await app.prisma.inviteCode.findUnique({ where: { code } });
    expect(invite?.usedById).toBeNull();
  });

  it('tanpa kode valid, email terdaftar tidak terbocorkan', async () => {
    await createUser(app, 'baru@example.test');
    const res = await post('register', body('kode-ngawur'));
    expect(res.statusCode).toBe(422);
  });

  it('satu kode dipakai barengan: hanya satu yang berhasil', async () => {
    const code = await createInvite(app.prisma);
    const results = await Promise.all([
      post('register', body(code, 'a@example.test')),
      post('register', body(code, 'b@example.test')),
    ]);
    expect(results.map((r) => r.statusCode).sort()).toEqual([201, 422]);
    expect(await app.prisma.user.count()).toBe(1);
    expect(await app.prisma.wallet.count()).toBe(1);
  });

  it('validasi per field', async () => {
    const res = await post('register', {
      name: 'A',
      email: 'bukan-email',
      password: 'hanyahuruf',
      inviteCode: 'x',
    });
    expect(res.statusCode).toBe(400);
    expect(res.json().error.details).toEqual({
      name: 'Nama minimal 2 karakter',
      email: 'Email tidak valid',
      password: 'Password minimal 8 karakter dengan huruf dan angka',
    });
  });
});

describe('POST /auth/login', () => {
  it('sukses, email tidak peka huruf besar', async () => {
    const { user } = await createUser(app, 'uji@example.test');
    const res = await post('login', { email: 'UJI@example.test', password: PASSWORD });
    expect(res.statusCode).toBe(200);
    expect(res.json().user.id).toBe(user.id);
  });

  it('password salah dan email tak dikenal memberi jawaban yang sama', async () => {
    await createUser(app, 'uji@example.test');
    const wrong = await post(
      'login',
      { email: 'uji@example.test', password: 'salah12345' },
      { 'cf-connecting-ip': '10.0.0.1' },
    );
    const unknown = await post(
      'login',
      { email: 'nggak-ada@example.test', password: PASSWORD },
      { 'cf-connecting-ip': '10.0.0.1' },
    );
    expect(wrong.statusCode).toBe(401);
    expect(unknown.statusCode).toBe(401);
    expect(wrong.json()).toEqual(unknown.json());
    expect(wrong.json().error.code).toBe('INVALID_CREDENTIALS');
  });

  it('percobaan ke-11 kena RATE_LIMITED dengan sisa waktu, IP lain tidak ikut terkunci', async () => {
    const payload = { email: 'nggak-ada@example.test', password: PASSWORD };
    const ip = { 'cf-connecting-ip': '10.0.0.2' };
    for (let i = 0; i < 10; i++) {
      expect((await post('login', payload, ip)).statusCode).toBe(401);
    }
    const blocked = await post('login', payload, ip);
    expect(blocked.statusCode).toBe(429);
    expect(blocked.json().error.code).toBe('RATE_LIMITED');
    expect(blocked.json().error.message).toMatch(/Coba lagi dalam 15 menit/);

    const other = await post('login', payload, { 'cf-connecting-ip': '10.0.0.3' });
    expect(other.statusCode).toBe(401);
  });
});

describe('POST /auth/refresh', () => {
  it('merotasi token: token lama ditolak, token baru jalan', async () => {
    const { refreshToken } = await createUser(app);

    const first = await post('refresh', { refreshToken });
    expect(first.statusCode).toBe(200);
    expect(first.json().refreshToken).not.toBe(refreshToken);

    const reused = await post('refresh', { refreshToken });
    expect(reused.statusCode).toBe(401);
    expect(reused.json().error.code).toBe('REFRESH_INVALID');

    const second = await post('refresh', { refreshToken: first.json().refreshToken });
    expect(second.statusCode).toBe(200);
  });

  it('refresh barengan dengan token yang sama: hanya satu yang berhasil', async () => {
    const { refreshToken } = await createUser(app);
    const results = await Promise.all([
      post('refresh', { refreshToken }),
      post('refresh', { refreshToken }),
    ]);
    expect(results.map((r) => r.statusCode).sort()).toEqual([200, 401]);
  });

  it('token kedaluwarsa dan token ngawur ditolak', async () => {
    const { refreshToken } = await createUser(app);
    await app.prisma.refreshToken.updateMany({
      data: { expiresAt: new Date(Date.now() - 1000) },
    });
    expect((await post('refresh', { refreshToken })).statusCode).toBe(401);
    expect((await post('refresh', { refreshToken: 'ngawur' })).statusCode).toBe(401);
  });

  it('token mentah tidak disimpan di database', async () => {
    const { refreshToken } = await createUser(app);
    const stored = await app.prisma.refreshToken.findFirstOrThrow();
    expect(stored.tokenHash).not.toBe(refreshToken);
  });
});

describe('POST /auth/logout', () => {
  it('mencabut token tanpa butuh access token', async () => {
    const { refreshToken } = await createUser(app);
    const res = await post('logout', { refreshToken });
    expect(res.statusCode).toBe(204);
    expect((await post('refresh', { refreshToken })).statusCode).toBe(401);
  });

  it('token tak dikenal tetap 204, body kosong 400', async () => {
    expect((await post('logout', { refreshToken: 'ngawur' })).statusCode).toBe(204);
    expect((await post('logout', {})).statusCode).toBe(400);
  });
});
