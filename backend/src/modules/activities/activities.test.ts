import { randomUUID } from 'node:crypto';
import { access, rm } from 'node:fs/promises';
import { join } from 'node:path';
import sharp from 'sharp';
import { afterAll, beforeAll, beforeEach, describe, expect, it } from 'vitest';
import { authHeader, buildTestApp, createUser, resetDb } from '../../../test/helpers.js';

const app = buildTestApp();
const uploadDir = process.env.UPLOAD_DIR!;

beforeAll(() => app.ready());
beforeEach(() => resetDb(app.prisma));
afterAll(async () => {
  await app.close();
  await rm(uploadDir, { recursive: true, force: true });
});

type Method = 'GET' | 'POST' | 'PATCH' | 'DELETE';

async function setup(email = 'a@example.test') {
  const { accessToken } = await createUser(app, email);
  const headers = authHeader(accessToken);
  const call = (method: Method, url: string, payload?: object) =>
    app.inject({ method, url: `/api/v1${url}`, headers, payload });
  const add = async (fields: object = {}) => {
    const res = await call('POST', '/activities', {
      title: 'Rapat',
      date: '2026-11-05',
      ...fields,
    });
    expect(res.statusCode).toBe(201);
    return res.json() as { id: string };
  };
  return { call, add, headers };
}

async function uploadPhoto(activityId: string, headers: Record<string, string>) {
  const file = await sharp({
    create: { width: 80, height: 60, channels: 3, background: '#2563eb' },
  })
    .jpeg()
    .toBuffer();
  const boundary = 'direkapin-test-boundary';
  const payload = Buffer.concat([
    Buffer.from(
      `--${boundary}\r\nContent-Disposition: form-data; name="activityId"\r\n\r\n${activityId}\r\n` +
        `--${boundary}\r\nContent-Disposition: form-data; name="file"; filename="x.jpg"\r\n\r\n`,
    ),
    file,
    Buffer.from(`\r\n--${boundary}--\r\n`),
  ]);
  const res = await app.inject({
    method: 'POST',
    url: '/api/v1/attachments',
    headers: { ...headers, 'content-type': `multipart/form-data; boundary=${boundary}` },
    payload,
  });
  expect(res.statusCode).toBe(201);
  return res.json() as { id: string };
}

describe('POST /activities', () => {
  it('cukup judul dan tanggal', async () => {
    const { call } = await setup();
    const res = await call('POST', '/activities', { title: 'Rapat', date: '2026-11-05' });

    expect(res.statusCode).toBe(201);
    expect(res.json()).toMatchObject({
      title: 'Rapat',
      date: '2026-11-05',
      time: null,
      location: null,
      description: null,
      isImportant: false,
      attachments: [],
    });
  });

  it('menyimpan semua field', async () => {
    const { call } = await setup();
    const body = {
      title: 'Seminar',
      date: '2026-11-05',
      time: '09:30',
      location: 'Aula',
      description: 'Bawa laptop',
      isImportant: true,
    };
    const res = await call('POST', '/activities', body);
    expect(res.statusCode).toBe(201);
    expect(res.json()).toMatchObject(body);
  });

  it.each([
    ['judul kosong', { title: '   ', date: '2026-11-05' }, 'title'],
    ['judul terlalu panjang', { title: 'x'.repeat(101), date: '2026-11-05' }, 'title'],
    ['tanggal salah', { title: 'Rapat', date: '05-11-2026' }, 'date'],
    ['jam salah', { title: 'Rapat', date: '2026-11-05', time: '24:00' }, 'time'],
    ['lokasi terlalu panjang', { title: 'Rapat', date: '2026-11-05', location: 'x'.repeat(101) }, 'location'],
    ['deskripsi terlalu panjang', { title: 'Rapat', date: '2026-11-05', description: 'x'.repeat(1001) }, 'description'],
  ])('menolak %s', async (_name, body, field) => {
    const { call } = await setup();
    const res = await call('POST', '/activities', body);
    expect(res.statusCode).toBe(400);
    expect(res.json().error.code).toBe('VALIDATION_ERROR');
    expect(res.json().error.details[field]).toBeDefined();
  });
});

describe('GET /activities', () => {
  it('memfilter rentang tanggal: penting dulu, lalu jam, tanpa jam di akhir', async () => {
    const { call, add } = await setup();
    await add({ title: 'Seharian', date: '2026-11-05' });
    await add({ title: 'Sore', date: '2026-11-05', time: '16:00' });
    await add({ title: 'Pagi', date: '2026-11-05', time: '08:00' });
    await add({ title: 'Penting', date: '2026-11-05', time: '20:00', isImportant: true });
    await add({ title: 'Besok', date: '2026-11-06' });
    await add({ title: 'Di luar rentang', date: '2026-11-07' });

    const res = await call('GET', '/activities?from=2026-11-05&to=2026-11-06');

    expect(res.statusCode).toBe(200);
    expect(res.json().items.map((item: { title: string }) => item.title)).toEqual([
      'Penting',
      'Pagi',
      'Sore',
      'Seharian',
      'Besok',
    ]);
  });

  it('from dan to wajib', async () => {
    const { call } = await setup();
    expect((await call('GET', '/activities?from=2026-11-05')).statusCode).toBe(400);
  });

  it('tidak menampilkan kegiatan user lain', async () => {
    const owner = await setup('pemilik@example.test');
    const other = await setup('lain@example.test');
    await owner.add();

    const res = await other.call('GET', '/activities?from=2026-11-05&to=2026-11-05');
    expect(res.json().items).toEqual([]);
  });
});

describe('/activities/:id', () => {
  it('GET mengembalikan detail beserta foto', async () => {
    const { call, add, headers } = await setup();
    const { id } = await add();
    const photo = await uploadPhoto(id, headers);

    const res = await call('GET', `/activities/${id}`);

    expect(res.statusCode).toBe(200);
    expect(res.json().attachments[0].id).toBe(photo.id);
  });

  it('PATCH mengubah hanya field yang dikirim, null menghapus', async () => {
    const { call, add } = await setup();
    const { id } = await add({ time: '09:00', location: 'Aula', description: 'Catatan' });

    const res = await call('PATCH', `/activities/${id}`, {
      date: '2026-11-10',
      time: null,
      location: null,
      isImportant: true,
    });

    expect(res.statusCode).toBe(200);
    expect(res.json()).toMatchObject({
      title: 'Rapat',
      date: '2026-11-10',
      time: null,
      location: null,
      description: 'Catatan',
      isImportant: true,
    });
  });

  it('PATCH menolak nilai tidak valid', async () => {
    const { call, add } = await setup();
    const { id } = await add();
    expect((await call('PATCH', `/activities/${id}`, { title: '' })).statusCode).toBe(400);
  });

  it('pindah tanggal memindahkan penanda kalender dan Halaman Hari', async () => {
    const { call, add } = await setup();
    const { id } = await add({ isImportant: true });

    await call('PATCH', `/activities/${id}`, { date: '2026-12-01' });

    expect((await call('GET', '/days/2026-11-05')).json().activities).toEqual([]);
    expect((await call('GET', '/days/2026-12-01')).json().activities[0].id).toBe(id);
    const calendar = await call('GET', '/calendar?month=2026-12');
    expect(calendar.json().days).toEqual([
      expect.objectContaining({ date: '2026-12-01', activityCount: 1, hasImportant: true }),
    ]);
  });

  it('kegiatan user lain membalas 404 dan tidak berubah', async () => {
    const owner = await setup('pemilik@example.test');
    const other = await setup('lain@example.test');
    const { id } = await owner.add();

    expect((await other.call('GET', `/activities/${id}`)).statusCode).toBe(404);
    expect((await other.call('PATCH', `/activities/${id}`, { title: 'Dicuri' })).statusCode).toBe(404);
    expect((await other.call('DELETE', `/activities/${id}`)).statusCode).toBe(404);

    expect((await owner.call('GET', `/activities/${id}`)).json().title).toBe('Rapat');
  });

  it('ID tidak dikenal membalas 404', async () => {
    const { call } = await setup();
    expect((await call('GET', `/activities/${randomUUID()}`)).statusCode).toBe(404);
  });

  it('DELETE menghapus kegiatan dan file fotonya', async () => {
    const { call, add, headers } = await setup();
    const { id } = await add();
    const photo = await uploadPhoto(id, headers);
    const row = await app.prisma.attachment.findUniqueOrThrow({ where: { id: photo.id } });
    const exists = (path: string) =>
      access(join(uploadDir, path)).then(
        () => true,
        () => false,
      );
    expect(await exists(row.filePath!)).toBe(true);

    expect((await call('DELETE', `/activities/${id}`)).statusCode).toBe(204);

    expect((await call('GET', `/activities/${id}`)).statusCode).toBe(404);
    expect(await app.prisma.attachment.count({ where: { id: photo.id } })).toBe(0);
    expect(await exists(row.filePath!)).toBe(false);
    expect(await exists(row.thumbPath)).toBe(false);
  });
});
