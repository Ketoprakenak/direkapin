import { afterAll, beforeAll, beforeEach, describe, expect, it } from 'vitest';
import { loadConfig } from '../../config.js';
import { buildApp } from '../../server.js';
import { authHeader, createUser, PASSWORD, resetDb } from '../../../test/helpers.js';
import { createInvite, isOwner } from './invites.service.js';

// Huruf besar: owner tetap dikenali walau beda kapital.
const app = buildApp(loadConfig({ ...process.env, OWNER_EMAIL: 'OWNER@EXAMPLE.TEST' }));

beforeAll(() => app.ready());
beforeEach(() => resetDb(app.prisma));
afterAll(() => app.close());

const DAY = 86_400_000;

async function as(email: string) {
  const { accessToken, user } = await createUser(app, email);
  const call = (method: 'GET' | 'POST', url: string) =>
    app.inject({ method, url: `/api/v1${url}`, headers: authHeader(accessToken) });
  return { call, userId: user.id };
}

const register = (inviteCode: string, email = 'budi@example.test') =>
  app.inject({
    method: 'POST',
    url: '/api/v1/auth/register',
    payload: { name: 'Budi', email, password: PASSWORD, inviteCode },
  });

describe('invites (AUTH-07)', () => {
  it('isOwner: tanpa beda huruf, kosong = bukan owner', () => {
    expect(isOwner('A@x.test', 'a@x.test')).toBe(true);
    expect(isOwner('a@x.test', undefined)).toBe(false);
    expect(isOwner('b@x.test', 'a@x.test')).toBe(false);
  });

  it('owner: isOwner, buat kode 7 hari, daftar', async () => {
    const owner = await as('owner@example.test');
    expect((await owner.call('GET', '/me')).json().isOwner).toBe(true);
    const res = await owner.call('POST', '/invites');
    expect(res.statusCode).toBe(201);
    const invite = res.json();
    expect(invite.code).toMatch(/^[0-9A-F]{16}$/);
    expect(Date.parse(invite.expiresAt) - Date.parse(invite.createdAt)).toBe(7 * DAY);
    const list = (await owner.call('GET', '/invites')).json();
    expect(list.items).toEqual([{ ...invite, usedAt: null, usedByName: null }]);
  });

  it('kode dari app bisa dipakai daftar dan tercatat siapa pemakainya', async () => {
    const owner = await as('owner@example.test');
    const { code } = (await owner.call('POST', '/invites')).json();
    expect((await register(code)).statusCode).toBe(201);
    const [item] = (await owner.call('GET', '/invites')).json().items;
    expect(item.usedByName).toBe('Budi');
    expect(item.usedAt).not.toBeNull();
  });

  it('kode lewat 7 hari ditolak saat daftar', async () => {
    const owner = await as('owner@example.test');
    const old = await createInvite(
      app.prisma,
      owner.userId,
      'owner@example.test',
      new Date(Date.now() - 8 * DAY),
    );
    const res = await register(old.code);
    expect(res.statusCode).toBe(422);
    expect(res.json().error.code).toBe('INVITE_INVALID');
  });

  it('bukan owner: isOwner false, /invites 404', async () => {
    await as('owner@example.test');
    const other = await as('lain@example.test');
    expect((await other.call('GET', '/me')).json().isOwner).toBe(false);
    expect((await other.call('GET', '/invites')).statusCode).toBe(404);
    expect((await other.call('POST', '/invites')).statusCode).toBe(404);
  });
});
