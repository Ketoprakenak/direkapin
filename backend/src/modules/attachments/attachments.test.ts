import { randomBytes, randomUUID } from 'node:crypto';
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

const smallJpeg = () =>
  sharp({ create: { width: 800, height: 600, channels: 3, background: '#0f766e' } })
    .jpeg()
    .toBuffer();

/** Noise tidak bisa dikompres, jadi ukurannya bisa melewati 1 MB. */
function noise(width: number, height: number) {
  return sharp(randomBytes(width * height * 3), { raw: { width, height, channels: 3 } });
}

function multipart(fields: Record<string, string>, file?: Buffer) {
  const boundary = 'direkapin-test-boundary';
  const parts: Buffer[] = [];
  // File sengaja lebih dulu: urutan part tidak boleh berpengaruh.
  if (file) {
    parts.push(
      Buffer.from(
        `--${boundary}\r\nContent-Disposition: form-data; name="file"; filename="../../x.jpg"\r\n` +
          'Content-Type: image/jpeg\r\n\r\n',
      ),
      file,
      Buffer.from('\r\n'),
    );
  }
  for (const [name, value] of Object.entries(fields)) {
    parts.push(
      Buffer.from(`--${boundary}\r\nContent-Disposition: form-data; name="${name}"\r\n\r\n${value}\r\n`),
    );
  }
  parts.push(Buffer.from(`--${boundary}--\r\n`));
  return {
    payload: Buffer.concat(parts),
    contentType: `multipart/form-data; boundary=${boundary}`,
  };
}

async function setup(email = 'a@example.test') {
  const { accessToken, user } = await createUser(app, email);
  const headers = authHeader(accessToken);
  const wallets = (await app.inject({ url: '/api/v1/wallets', headers })).json().items;
  const categories = (await app.inject({ url: '/api/v1/categories', headers })).json().items as {
    id: string;
    type: string;
  }[];
  const transaction = (
    await app.inject({
      method: 'POST',
      url: '/api/v1/transactions',
      headers,
      payload: {
        walletId: wallets[0].id,
        categoryId: categories.find((c) => c.type === 'EXPENSE')!.id,
        type: 'EXPENSE',
        amount: 25000,
        occurredAt: new Date().toISOString(),
      },
    })
  ).json() as { id: string };

  const upload = (fields: Record<string, string>, file?: Buffer) => {
    const { payload, contentType } = multipart(fields, file);
    return app.inject({
      method: 'POST',
      url: '/api/v1/attachments',
      headers: { ...headers, 'content-type': contentType },
      payload,
    });
  };
  const get = (id: string, size = 'full') =>
    app.inject({ url: `/api/v1/attachments/${id}?size=${size}`, headers });
  const remove = (id: string) =>
    app.inject({ method: 'DELETE', url: `/api/v1/attachments/${id}`, headers });

  return { userId: user.id, headers, transactionId: transaction.id, upload, get, remove };
}

const exists = (relativePath: string) =>
  access(join(uploadDir, relativePath)).then(
    () => true,
    () => false,
  );

describe('POST /attachments', () => {
  it('menyimpan foto dan menampilkannya di transaksi', async () => {
    const { upload, transactionId, headers, userId } = await setup();

    const res = await upload({ transactionId }, await smallJpeg());

    expect(res.statusCode).toBe(201);
    const body = res.json();
    expect(body).toMatchObject({
      thumbUrl: `/api/v1/attachments/${body.id}?size=thumb`,
      fullUrl: `/api/v1/attachments/${body.id}?size=full`,
      isArchived: false,
      archiveMonth: null,
      width: 800,
      height: 600,
    });

    const row = await app.prisma.attachment.findUniqueOrThrow({ where: { id: body.id } });
    expect(row.filePath).toMatch(new RegExp(`^${userId}/\\d{4}/\\d{2}/${body.id}\\.jpg$`));
    expect(await exists(row.filePath!)).toBe(true);
    expect(await exists(row.thumbPath)).toBe(true);

    const tx = await app.inject({ url: `/api/v1/transactions/${transactionId}`, headers });
    expect(tx.json().attachments).toEqual([body]);
  });

  it('menampilkan foto kegiatan di halaman hari', async () => {
    const { upload, headers, userId } = await setup();
    const date = '2026-11-05';
    const activity = await app.prisma.activity.create({
      data: { userId, title: 'Rapat', date: new Date(`${date}T00:00:00Z`) },
    });

    const res = await upload({ activityId: activity.id }, await smallJpeg());
    expect(res.statusCode).toBe(201);

    const day = await app.inject({ url: `/api/v1/days/${date}`, headers });
    expect(day.json().activities[0].attachments[0].id).toBe(res.json().id);
  });

  it('menolak jika pemilik tidak tepat satu', async () => {
    const { upload, transactionId } = await setup();
    const file = await smallJpeg();

    expect((await upload({}, file)).statusCode).toBe(400);
    const both = await upload({ transactionId, activityId: randomUUID() }, file);
    expect(both.statusCode).toBe(400);
    expect(both.json().error.code).toBe('VALIDATION_ERROR');
  });

  it('menolak jika file tidak ada', async () => {
    const { upload, transactionId } = await setup();
    const res = await upload({ transactionId });
    expect(res.statusCode).toBe(400);
    expect(res.json().error.details.file).toBeDefined();
  });

  it('membalas 404 untuk transaksi atau kegiatan user lain', async () => {
    const owner = await setup('pemilik@example.test');
    const other = await setup('lain@example.test');
    const file = await smallJpeg();
    const activity = await app.prisma.activity.create({
      data: { userId: owner.userId, title: 'Rapat', date: new Date('2026-11-05T00:00:00Z') },
    });

    const tx = await other.upload({ transactionId: owner.transactionId }, file);
    expect(tx.statusCode).toBe(404);
    expect((await other.upload({ activityId: activity.id }, file)).statusCode).toBe(404);
  });

  it('menolak file > batas dengan 413', async () => {
    const { upload, transactionId } = await setup();
    const res = await upload(
      { transactionId },
      Buffer.alloc(Number(process.env.MAX_UPLOAD_BYTES) + 1),
    );
    expect(res.statusCode).toBe(413);
    expect(res.json().error.code).toBe('FILE_TOO_LARGE');
  });

  it('memeriksa jenis file dari isinya, bukan header', async () => {
    const { upload, transactionId } = await setup();
    const res = await upload({ transactionId }, Buffer.from('bukan gambar'));
    expect(res.statusCode).toBe(415);
    expect(res.json().error.code).toBe('UNSUPPORTED_MEDIA');

    const gif = await sharp({
      create: { width: 8, height: 8, channels: 3, background: '#000000' },
    })
      .gif()
      .toBuffer();
    expect((await upload({ transactionId }, gif)).statusCode).toBe(415);
  });

  it('membatasi 3 foto per transaksi', async () => {
    const { upload, transactionId } = await setup();
    const file = await smallJpeg();
    for (let i = 0; i < 3; i++) {
      expect((await upload({ transactionId }, file)).statusCode).toBe(201);
    }
    const res = await upload({ transactionId }, file);
    expect(res.statusCode).toBe(422);
    expect(res.json().error.code).toBe('PHOTO_LIMIT_REACHED');
  });

  it('membatasi 5 foto per kegiatan', async () => {
    const { upload, userId } = await setup();
    const activity = await app.prisma.activity.create({
      data: { userId, title: 'Rapat', date: new Date('2026-11-05T00:00:00Z') },
    });
    const file = await smallJpeg();
    for (let i = 0; i < 5; i++) {
      expect((await upload({ activityId: activity.id }, file)).statusCode).toBe(201);
    }
    expect((await upload({ activityId: activity.id }, file)).statusCode).toBe(422);
  });

  it('me-resize ulang file > 1 MB', async () => {
    const { upload, transactionId } = await setup();
    const file = await noise(2000, 1000).jpeg({ quality: 70 }).toBuffer();
    expect(file.length).toBeGreaterThan(1024 * 1024);
    expect(file.length).toBeLessThanOrEqual(Number(process.env.MAX_UPLOAD_BYTES));

    const res = await upload({ transactionId }, file);

    expect(res.statusCode).toBe(201);
    expect(res.json()).toMatchObject({ width: 1600, height: 800 });
  });

  it('mengubah PNG menjadi JPEG', async () => {
    const { upload, get, transactionId } = await setup();
    const png = await sharp({
      create: { width: 100, height: 50, channels: 4, background: { r: 0, g: 0, b: 0, alpha: 0 } },
    })
      .png()
      .toBuffer();

    const res = await upload({ transactionId }, png);

    expect(res.statusCode).toBe(201);
    const full = await get(res.json().id);
    expect(full.headers['content-type']).toBe('image/jpeg');
    expect((await sharp(full.rawPayload).metadata()).format).toBe('jpeg');
  });

  it('memakai ukuran setelah rotasi EXIF', async () => {
    const { upload, get, transactionId } = await setup();
    const rotated = await sharp({
      create: { width: 400, height: 200, channels: 3, background: '#0f766e' },
    })
      .jpeg()
      .withMetadata({ orientation: 6 })
      .toBuffer();

    const res = await upload({ transactionId }, rotated);

    expect(res.json()).toMatchObject({ width: 200, height: 400 });
    const thumb = await sharp((await get(res.json().id, 'thumb')).rawPayload).metadata();
    expect(thumb).toMatchObject({ width: 160, height: 320 });
  });
});

describe('GET /attachments/:id', () => {
  it('mengembalikan foto penuh dan thumbnail', async () => {
    const { upload, get, transactionId } = await setup();
    const file = await smallJpeg();
    const { id } = (await upload({ transactionId }, file)).json();

    const full = await get(id);
    expect(full.statusCode).toBe(200);
    expect(full.headers['content-type']).toBe('image/jpeg');
    expect(full.rawPayload.equals(file)).toBe(true);

    const thumb = await get(id, 'thumb');
    expect(thumb.statusCode).toBe(200);
    expect(await sharp(thumb.rawPayload).metadata()).toMatchObject({ width: 320, height: 240 });
  });

  it('butuh token', async () => {
    const res = await app.inject({ url: `/api/v1/attachments/${randomUUID()}` });
    expect(res.statusCode).toBe(401);
  });

  it('membalas 400 untuk size yang salah', async () => {
    const { get } = await setup();
    expect((await get(randomUUID(), 'besar')).statusCode).toBe(400);
  });

  it('membalas 404 untuk foto user lain', async () => {
    const owner = await setup('pemilik@example.test');
    const other = await setup('lain@example.test');
    const { id } = (await owner.upload({ transactionId: owner.transactionId }, await smallJpeg())).json();

    expect((await other.get(id)).statusCode).toBe(404);
    expect((await other.get(id, 'thumb')).statusCode).toBe(404);
  });

  it('membalas 410 untuk foto asli yang sudah diarsip, thumbnail tetap ada', async () => {
    const { upload, get, headers, transactionId } = await setup();
    const { id } = (await upload({ transactionId }, await smallJpeg())).json();
    await app.prisma.attachment.update({
      where: { id },
      data: { filePath: null, archivedAt: new Date() },
    });

    const full = await get(id);
    expect(full.statusCode).toBe(410);
    expect(full.json().error.code).toBe('ARCHIVED');
    expect((await get(id, 'thumb')).statusCode).toBe(200);

    const tx = await app.inject({ url: `/api/v1/transactions/${transactionId}`, headers });
    expect(tx.json().attachments[0]).toMatchObject({ fullUrl: null, isArchived: true });
  });
});

describe('penghapusan foto', () => {
  it('DELETE menghapus record dan file', async () => {
    const { upload, get, remove, transactionId } = await setup();
    const { id } = (await upload({ transactionId }, await smallJpeg())).json();
    const row = await app.prisma.attachment.findUniqueOrThrow({ where: { id } });

    expect((await remove(id)).statusCode).toBe(204);

    expect((await get(id)).statusCode).toBe(404);
    expect(await exists(row.filePath!)).toBe(false);
    expect(await exists(row.thumbPath)).toBe(false);
  });

  it('DELETE foto user lain membalas 404 dan file tetap ada', async () => {
    const owner = await setup('pemilik@example.test');
    const other = await setup('lain@example.test');
    const { id } = (await owner.upload({ transactionId: owner.transactionId }, await smallJpeg())).json();

    expect((await other.remove(id)).statusCode).toBe(404);
    expect((await owner.get(id)).statusCode).toBe(200);
  });

  it('hapus transaksi ikut menghapus file', async () => {
    const { upload, headers, transactionId } = await setup();
    const { id } = (await upload({ transactionId }, await smallJpeg())).json();
    const row = await app.prisma.attachment.findUniqueOrThrow({ where: { id } });

    const res = await app.inject({
      method: 'DELETE',
      url: `/api/v1/transactions/${transactionId}`,
      headers,
    });

    expect(res.statusCode).toBe(204);
    expect(await app.prisma.attachment.count({ where: { id } })).toBe(0);
    expect(await exists(row.filePath!)).toBe(false);
    expect(await exists(row.thumbPath)).toBe(false);
  });
});
