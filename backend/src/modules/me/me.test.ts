import { access, rm } from 'node:fs/promises';
import { join } from 'node:path';
import jwt from 'jsonwebtoken';
import sharp from 'sharp';
import { afterAll, beforeAll, beforeEach, describe, expect, it } from 'vitest';
import { authHeader, buildTestApp, createUser, resetDb } from '../../../test/helpers.js';

const app = buildTestApp();
const secret = process.env.JWT_SECRET!;
const uploadDir = process.env.UPLOAD_DIR!;

beforeAll(() => app.ready());
beforeEach(() => resetDb(app.prisma));
afterAll(async () => {
  await app.close();
  await rm(uploadDir, { recursive: true, force: true });
});

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

describe('avatar /me/avatar', () => {
  const url = '/api/v1/me/avatar';
  const jpeg = () =>
    sharp({
      create: { width: 800, height: 400, channels: 3, background: '#0f766e' },
    })
      .jpeg()
      .toBuffer();
  const png = () =>
    sharp({
      create: { width: 300, height: 300, channels: 3, background: '#0f766e' },
    })
      .png()
      .toBuffer();

  function upload(accessToken: string | undefined, file?: Buffer) {
    const boundary = 'direkapin-avatar-boundary';
    const parts = file
      ? [
          Buffer.from(
            `--${boundary}\r\nContent-Disposition: form-data; name="file"; filename="../../x.jpg"\r\n` +
              'Content-Type: image/jpeg\r\n\r\n',
          ),
          file,
          Buffer.from('\r\n'),
        ]
      : [];
    parts.push(Buffer.from(`--${boundary}--\r\n`));
    return app.inject({
      method: 'PUT',
      url,
      headers: {
        ...(accessToken ? authHeader(accessToken) : {}),
        'content-type': `multipart/form-data; boundary=${boundary}`,
      },
      payload: Buffer.concat(parts),
    });
  }
  const get = (accessToken: string) => app.inject({ url, headers: authHeader(accessToken) });
  const del = (accessToken: string) =>
    app.inject({ method: 'DELETE', url, headers: authHeader(accessToken) });
  const exists = (path: string) =>
    access(join(uploadDir, path)).then(
      () => true,
      () => false,
    );
  const avatarPathOf = async (id: string) =>
    (await app.prisma.user.findUniqueOrThrow({ where: { id } })).avatarPath!;

  it('upload JPEG: hasAvatar true, GET mengembalikan JPEG 512x512', async () => {
    const { accessToken } = await createUser(app);
    const res = await upload(accessToken, await jpeg());
    expect(res.statusCode).toBe(200);
    expect(res.json().hasAvatar).toBe(true);
    expect(res.json()).not.toHaveProperty('avatarPath');

    const img = await get(accessToken);
    expect(img.statusCode).toBe(200);
    expect(img.headers['content-type']).toContain('image/jpeg');
    const meta = await sharp(img.rawPayload).metadata();
    expect([meta.format, meta.width, meta.height]).toEqual(['jpeg', 512, 512]);

    const me = await app.inject({
      url: '/api/v1/me',
      headers: authHeader(accessToken),
    });
    expect(me.json().hasAvatar).toBe(true);
  });

  it('menerima PNG', async () => {
    const { accessToken } = await createUser(app);
    expect((await upload(accessToken, await png())).statusCode).toBe(200);
  });

  it('bukan gambar 400', async () => {
    const { accessToken } = await createUser(app);
    const res = await upload(accessToken, Buffer.from('bukan gambar'));
    expect(res.statusCode).toBe(400);
    expect(res.json().error.code).toBe('VALIDATION_ERROR');
    expect(res.json().error.details.file).toBeTypeOf('string');
  });

  it('dimensi melebihi batas piksel 400', async () => {
    const { accessToken } = await createUser(app);
    const big = await sharp({
      create: { width: 8000, height: 6000, channels: 3, background: '#fff' },
    })
      .png({ compressionLevel: 9 })
      .toBuffer();
    const res = await upload(accessToken, big);
    expect(res.statusCode).toBe(400);
    expect(res.json().error.code).toBe('VALIDATION_ERROR');
  });

  it('tanpa file 400', async () => {
    const { accessToken } = await createUser(app);
    const res = await upload(accessToken);
    expect(res.statusCode).toBe(400);
    expect(res.json().error.details).toEqual({ file: 'Pilih foto' });
  });

  it('file > batas 413', async () => {
    const { accessToken } = await createUser(app);
    const res = await upload(accessToken, Buffer.alloc(Number(process.env.MAX_UPLOAD_BYTES) + 1));
    expect(res.statusCode).toBe(413);
    expect(res.json().error.code).toBe('FILE_TOO_LARGE');
  });

  it('tanpa token 401', async () => {
    expect((await upload(undefined, await jpeg())).statusCode).toBe(401);
    expect((await app.inject({ url })).statusCode).toBe(401);
    expect((await app.inject({ method: 'DELETE', url })).statusCode).toBe(401);
  });

  it('mengganti foto menghapus file lama', async () => {
    const { accessToken, user } = await createUser(app);
    await upload(accessToken, await jpeg());
    const first = await avatarPathOf(user.id);
    expect(first).toMatch(new RegExp(`^avatars/${user.id}-[0-9a-f-]{36}\\.jpg$`));
    expect(await exists(first)).toBe(true);

    await upload(accessToken, await png());
    const second = await avatarPathOf(user.id);
    expect(second).not.toBe(first);
    expect(await exists(second)).toBe(true);
    expect(await exists(first)).toBe(false);
  });

  it('DELETE 204, lalu GET 404 dan hasAvatar false; idempoten', async () => {
    const { accessToken, user } = await createUser(app);
    await upload(accessToken, await jpeg());
    const path = await avatarPathOf(user.id);

    expect((await del(accessToken)).statusCode).toBe(204);
    expect((await get(accessToken)).statusCode).toBe(404);
    expect(await exists(path)).toBe(false);
    const me = await app.inject({
      url: '/api/v1/me',
      headers: authHeader(accessToken),
    });
    expect(me.json().hasAvatar).toBe(false);
    expect((await del(accessToken)).statusCode).toBe(204);
  });

  it('GET tanpa foto 404; file hilang 404', async () => {
    const { accessToken, user } = await createUser(app);
    const res = await get(accessToken);
    expect(res.statusCode).toBe(404);
    expect(res.json().error.code).toBe('NOT_FOUND');

    await app.prisma.user.update({
      where: { id: user.id },
      data: { avatarPath: `avatars/${user.id}-hilang.jpg` },
    });
    expect((await get(accessToken)).statusCode).toBe(404);
  });

  it('foto user lain tidak terlihat (404)', async () => {
    const a = await createUser(app, 'a@example.test');
    const b = await createUser(app, 'b@example.test');
    await upload(a.accessToken, await jpeg());
    expect((await get(a.accessToken)).statusCode).toBe(200);
    expect((await get(b.accessToken)).statusCode).toBe(404);
  });
});
