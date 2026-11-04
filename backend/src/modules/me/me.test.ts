import jwt from 'jsonwebtoken';
import { afterAll, beforeAll, beforeEach, describe, expect, it } from 'vitest';
import { authHeader, buildTestApp, createUser, resetDb } from '../../../test/helpers.js';

const app = buildTestApp();
const secret = process.env.JWT_SECRET!;

beforeAll(() => app.ready());
beforeEach(() => resetDb(app.prisma));
afterAll(() => app.close());

describe('GET /me', () => {
  it('mengembalikan profil pemilik token saja', async () => {
    const a = await createUser(app, 'a@example.test');
    const b = await createUser(app, 'b@example.test');

    const resA = await app.inject({ url: '/api/v1/me', headers: authHeader(a.accessToken) });
    expect(resA.statusCode).toBe(200);
    expect(resA.json().id).toBe(a.user.id);
    expect(resA.json().email).toBe('a@example.test');
    expect(resA.json()).not.toHaveProperty('passwordHash');

    const resB = await app.inject({ url: '/api/v1/me', headers: authHeader(b.accessToken) });
    expect(resB.json().id).toBe(b.user.id);
  });

  it('tanpa token 401', async () => {
    const res = await app.inject({ url: '/api/v1/me' });
    expect(res.statusCode).toBe(401);
    expect(res.json().error.code).toBe('UNAUTHORIZED');
  });

  it.each([
    ['kedaluwarsa', () => jwt.sign({}, secret, { subject: 'x', expiresIn: -10 })],
    ['secret lain', () => jwt.sign({}, 'secret-lain', { subject: 'x' })],
    ['tanpa tanda tangan', () => jwt.sign({}, '', { subject: 'x', algorithm: 'none' })],
    ['tanpa subject', () => jwt.sign({}, secret)],
    ['ngawur', () => 'bukan.token.jwt'],
  ])('token %s 401', async (_name, makeToken) => {
    const res = await app.inject({ url: '/api/v1/me', headers: authHeader(makeToken()) });
    expect(res.statusCode).toBe(401);
  });

  it('token user yang sudah tidak ada 404', async () => {
    const { accessToken, user } = await createUser(app);
    await app.prisma.user.delete({ where: { id: user.id } });
    const res = await app.inject({ url: '/api/v1/me', headers: authHeader(accessToken) });
    expect(res.statusCode).toBe(404);
  });
});

describe('PATCH /me', () => {
  const patch = (accessToken: string, payload: object) =>
    app.inject({
      method: 'PATCH',
      url: '/api/v1/me',
      headers: authHeader(accessToken),
      payload,
    });

  it('mengubah profil dan jam reminder milik sendiri saja', async () => {
    const a = await createUser(app, 'a@example.test');
    const b = await createUser(app, 'b@example.test');

    const res = await patch(a.accessToken, {
      name: 'Nama Baru',
      timezone: 'Asia/Makassar',
      reminderTime: '20:30',
    });
    expect(res.statusCode).toBe(200);
    expect(res.json()).toMatchObject({
      name: 'Nama Baru',
      timezone: 'Asia/Makassar',
      reminderTime: '20:30',
    });

    const other = await app.prisma.user.findUniqueOrThrow({ where: { id: b.user.id } });
    expect(other.name).toBe('Pengguna Uji');
  });

  it('field lain seperti email dan passwordHash diabaikan', async () => {
    const { accessToken, user } = await createUser(app, 'a@example.test');
    await patch(accessToken, { email: 'lain@example.test', passwordHash: 'x' });
    const stored = await app.prisma.user.findUniqueOrThrow({ where: { id: user.id } });
    expect(stored.email).toBe('a@example.test');
    expect(stored.passwordHash).not.toBe('x');
  });

  it('validasi gagal 400', async () => {
    const { accessToken } = await createUser(app);
    const res = await patch(accessToken, {
      name: 'A',
      timezone: 'Mars/Olympus',
      reminderTime: '25:00',
    });
    expect(res.statusCode).toBe(400);
    expect(res.json().error.details).toEqual({
      name: 'Nama minimal 2 karakter',
      timezone: 'Zona waktu tidak valid',
      reminderTime: 'Jam harus berformat HH:mm',
    });
  });

  it('tanpa token 401', async () => {
    const res = await app.inject({ method: 'PATCH', url: '/api/v1/me', payload: {} });
    expect(res.statusCode).toBe(401);
  });
});
