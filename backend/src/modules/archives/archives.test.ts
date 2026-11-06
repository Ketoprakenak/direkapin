import { execFileSync } from 'node:child_process';
import { randomUUID } from 'node:crypto';
import {
  access,
  mkdir,
  mkdtemp,
  readdir,
  readFile,
  rm,
  truncate,
  writeFile,
} from 'node:fs/promises';
import { get as httpGet } from 'node:http';
import type { AddressInfo } from 'node:net';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import sharp from 'sharp';
import { afterAll, beforeAll, beforeEach, describe, expect, it, vi } from 'vitest';
import { authHeader, buildTestApp, createUser, resetDb } from '../../../test/helpers.js';
import { runArchiveJob } from '../../jobs/archive.job.js';
import { pruneBackups, runBackupJob } from '../../jobs/backup.job.js';

const app = buildTestApp();
const uploadDir = process.env.UPLOAD_DIR!;
const archiveDir = process.env.ARCHIVE_DIR!;
const dirs = { UPLOAD_DIR: uploadDir, ARCHIVE_DIR: archiveDir };

beforeAll(() => app.ready());
beforeEach(async () => {
  await resetDb(app.prisma);
  await rm(archiveDir, { recursive: true, force: true });
});
afterAll(async () => {
  await app.close();
  await rm(uploadDir, { recursive: true, force: true });
  await rm(archiveDir, { recursive: true, force: true });
});

const NOW = new Date('2026-11-15T05:00:00Z');
const SEPT = new Date('2026-09-10T05:00:00Z');

const exists = (path: string) =>
  access(path).then(
    () => true,
    () => false,
  );

async function setup(email = 'a@example.test') {
  const { accessToken, user } = await createUser(app, email);
  const wallet = await app.prisma.wallet.findFirstOrThrow({ where: { userId: user.id } });
  const category = await app.prisma.category.findFirstOrThrow({
    where: { userId: user.id, type: 'EXPENSE' },
  });
  return {
    headers: authHeader(accessToken),
    userId: user.id,
    walletId: wallet.id,
    categoryId: category.id,
  };
}

type Setup = Awaited<ReturnType<typeof setup>>;

async function addPhoto({ userId, walletId, categoryId }: Setup, createdAt = SEPT, note?: string) {
  const tx = await app.prisma.transaction.create({
    data: {
      userId,
      walletId,
      categoryId,
      type: 'EXPENSE',
      amount: 15000n,
      occurredAt: createdAt,
      note,
    },
  });
  const id = randomUUID();
  const filePath = `${userId}/${id}.jpg`;
  const thumbPath = `${userId}/${id}_thumb.jpg`;
  const data = await sharp({
    create: { width: 40, height: 30, channels: 3, background: '#0f766e' },
  })
    .jpeg()
    .toBuffer();
  await mkdir(join(uploadDir, userId), { recursive: true });
  await writeFile(join(uploadDir, filePath), data);
  await writeFile(join(uploadDir, thumbPath), data);
  return app.prisma.attachment.create({
    data: {
      id,
      userId,
      transactionId: tx.id,
      filePath,
      thumbPath,
      mimeType: 'image/jpeg',
      sizeBytes: data.length,
      width: 40,
      height: 30,
      createdAt,
    },
  });
}

const runJob = (now = NOW) => runArchiveJob(app.prisma, dirs, app.log, now);
const onlyArchive = () => app.prisma.archive.findFirstOrThrow();
const pause = (ms: number) => new Promise((resolve) => setTimeout(resolve, ms));

describe('job arsip', () => {
  it('membuat ZIP M-2 berisi foto dan CSV, foto asli belum dihapus', async () => {
    const user = await setup();
    const photo = await addPhoto(user, SEPT, '=SUM(A1) "kopi"');
    await app.prisma.activity.create({
      data: { userId: user.userId, title: 'Rapat', date: new Date('2026-09-11T00:00:00Z') },
    });

    await runJob();

    const archive = await onlyArchive();
    expect(archive).toMatchObject({ month: '2026-09', status: 'READY', photoCount: 1 });
    expect(archive.expiresAt.getTime() - archive.createdAt.getTime()).toBe(30 * 86_400_000);
    // ZIP tanpa kompresi, jadi isinya terbaca langsung.
    const zip = (await readFile(join(archiveDir, archive.zipPath!))).toString('latin1');
    expect(zip).toContain(`foto/2026-09-10_${photo.id}.jpg`);
    expect(zip).toContain('transaksi.csv');
    expect(zip).toContain('kegiatan.csv');
    expect(zip).toContain(`"15000","'=SUM(A1) ""kopi"""`);
    expect(zip).toContain('"Rapat"');

    const row = await app.prisma.attachment.findUniqueOrThrow({ where: { id: photo.id } });
    expect(row).toMatchObject({ archiveId: archive.id, archivedAt: null });
    expect(await exists(join(uploadDir, row.filePath!))).toBe(true);
  });

  it('melewati bulan M-1, bulan ini, dan bulan tanpa foto', async () => {
    const user = await setup();
    await addPhoto(user, new Date('2026-10-31T16:59:00Z')); // masih Oktober di Jakarta
    await addPhoto(user, NOW);
    await runJob();
    expect(await app.prisma.archive.count()).toBe(0);
  });

  it('bulan foto mengikuti zona waktu user', async () => {
    const user = await setup();
    await addPhoto(user, new Date('2026-09-30T17:30:00Z')); // 1 Oktober di Jakarta
    await runJob();
    expect(await app.prisma.archive.count()).toBe(0);
    await runJob(new Date('2026-12-01T05:00:00Z'));
    expect((await onlyArchive()).month).toBe('2026-10');
  });

  it('mengejar bulan yang terlewat dan tidak membuat dobel', async () => {
    const user = await setup();
    await addPhoto(user, new Date('2026-08-10T05:00:00Z'));
    await addPhoto(user);
    await runJob();
    await runJob();
    const rows = await app.prisma.archive.findMany({ orderBy: { month: 'asc' } });
    expect(rows.map((row) => row.month)).toEqual(['2026-08', '2026-09']);
  });

  it('foto hilang: FAILED, foto lain utuh, besok berhasil', async () => {
    const user = await setup();
    const good = await addPhoto(user);
    const missing = await addPhoto(user);
    const missingPath = join(uploadDir, missing.filePath!);
    const content = await readFile(missingPath);
    await rm(missingPath);

    await runJob();
    const failed = await onlyArchive();
    expect(failed).toMatchObject({ status: 'FAILED', zipPath: null, photoCount: 0, sizeBytes: 0n });
    const row = await app.prisma.attachment.findUniqueOrThrow({ where: { id: good.id } });
    expect(row).toMatchObject({ archiveId: null, archivedAt: null });
    expect(await exists(join(uploadDir, good.filePath!))).toBe(true);
    expect(await readdir(join(archiveDir, user.userId))).toEqual([]);

    await writeFile(missingPath, content);
    await runJob();
    expect(await onlyArchive()).toMatchObject({ id: failed.id, status: 'READY', photoCount: 2 });
  });

  it('FAILED yang fotonya sudah dihapus user ikut hilang', async () => {
    const user = await setup();
    const photo = await addPhoto(user);
    await rm(join(uploadDir, photo.filePath!));
    await runJob();
    await app.prisma.attachment.delete({ where: { id: photo.id } });
    await runJob();
    expect(await app.prisma.archive.count()).toBe(0);
  });

  it('kedaluwarsa: ZIP dan foto asli dihapus, thumbnail tetap', async () => {
    const user = await setup();
    const photo = await addPhoto(user);
    await runJob();
    const archive = await onlyArchive();

    await runJob(new Date(archive.expiresAt.getTime() - 1000));
    expect((await onlyArchive()).status).toBe('READY');

    await runJob(new Date(archive.expiresAt.getTime() + 1000));
    expect(await onlyArchive()).toMatchObject({ status: 'EXPIRED', zipPath: null });
    expect(await exists(join(archiveDir, archive.zipPath!))).toBe(false);
    const row = await app.prisma.attachment.findUniqueOrThrow({ where: { id: photo.id } });
    expect(row.filePath).toBeNull();
    expect(row.archivedAt).not.toBeNull();
    expect(await exists(join(uploadDir, photo.filePath!))).toBe(false);
    expect(await exists(join(uploadDir, photo.thumbPath))).toBe(true);
  });
});

describe('GET /archives', () => {
  it('membalas daftar milik sendiri, terbaru dulu', async () => {
    const user = await setup();
    const other = await setup('b@example.test');
    await addPhoto(user, new Date('2026-08-10T05:00:00Z'));
    await addPhoto(user);
    await addPhoto(other);
    await runJob();

    const res = await app.inject({ url: '/api/v1/archives', headers: user.headers });
    expect(res.statusCode).toBe(200);
    const items = res.json().items;
    expect(items.map((item: { month: string }) => item.month)).toEqual(['2026-09', '2026-08']);
    expect(items[0]).toMatchObject({ photoCount: 1, status: 'READY', downloadedAt: null });
    expect(items[0].sizeBytes).toBeGreaterThan(0);
  });

  it('butuh token', async () => {
    expect((await app.inject({ url: '/api/v1/archives' })).statusCode).toBe(401);
  });
});

describe('GET /archives/{id}/download', () => {
  const url = (id: string) => `/api/v1/archives/${id}/download`;

  it('download utuh: DOWNLOADED, foto asli dihapus, bisa download ulang', async () => {
    const user = await setup();
    const photo = await addPhoto(user);
    await runJob();
    const archive = await onlyArchive();

    const res = await app.inject({ url: url(archive.id), headers: user.headers });
    expect(res.statusCode).toBe(200);
    expect(res.headers['content-type']).toBe('application/zip');
    expect(Number(res.headers['content-length'])).toBe(Number(archive.sizeBytes));
    expect(res.rawPayload.length).toBe(Number(archive.sizeBytes));

    await vi.waitFor(async () => {
      expect(await exists(join(uploadDir, photo.filePath!))).toBe(false);
    });
    const downloaded = await onlyArchive();
    expect(downloaded.status).toBe('DOWNLOADED');
    const row = await app.prisma.attachment.findUniqueOrThrow({ where: { id: photo.id } });
    expect(row.filePath).toBeNull();
    expect(row.archivedAt).not.toBeNull();
    expect(await exists(join(uploadDir, photo.thumbPath))).toBe(true);

    const again = await app.inject({ url: url(archive.id), headers: user.headers });
    expect(again.statusCode).toBe(200);
    await pause(100);
    expect((await onlyArchive()).downloadedAt).toEqual(downloaded.downloadedAt);
  });

  it('koneksi putus di tengah: status tetap, foto asli utuh', async () => {
    const user = await setup();
    const photo = await addPhoto(user);
    await runJob();
    const archive = await onlyArchive();
    // Lebih besar dari buffer socket, jadi tidak mungkin terkirim sebelum diputus.
    await truncate(join(archiveDir, archive.zipPath!), 64 * 1024 * 1024);

    const server = buildTestApp();
    await server.listen({ port: 0, host: '127.0.0.1' });
    const { port } = server.server.address() as AddressInfo;
    await new Promise<void>((resolve, reject) => {
      const req = httpGet(
        { port, host: '127.0.0.1', path: url(archive.id), headers: user.headers },
        (res) => {
          if (res.statusCode !== 200) reject(new Error(`status ${res.statusCode}`));
          res.once('data', () => {
            req.destroy();
            resolve();
          });
        },
      );
      req.on('error', (error) => {
        if ((error as NodeJS.ErrnoException).code !== 'ECONNRESET') reject(error);
      });
    });
    await pause(300);
    await server.close();

    expect((await onlyArchive()).status).toBe('READY');
    const row = await app.prisma.attachment.findUniqueOrThrow({ where: { id: photo.id } });
    expect(row.filePath).toBe(photo.filePath);
    expect(await exists(join(uploadDir, photo.filePath!))).toBe(true);
  });

  it('HEAD tidak tersedia, jadi tidak bisa menandai ter-download', async () => {
    const user = await setup();
    await addPhoto(user);
    await runJob();
    const archive = await onlyArchive();
    const res = await app.inject({ method: 'HEAD', url: url(archive.id), headers: user.headers });
    expect(res.statusCode).toBe(404);
    await pause(100);
    expect((await onlyArchive()).status).toBe('READY');
  });

  it('arsip user lain 404 dan tidak mengubah status', async () => {
    const user = await setup();
    const other = await setup('b@example.test');
    await addPhoto(user);
    await runJob();
    const archive = await onlyArchive();
    const res = await app.inject({ url: url(archive.id), headers: other.headers });
    expect(res.statusCode).toBe(404);
    await pause(100);
    expect((await onlyArchive()).status).toBe('READY');
  });

  it('FAILED 404, id tidak valid 400, tanpa token 401', async () => {
    const user = await setup();
    const photo = await addPhoto(user);
    await rm(join(uploadDir, photo.filePath!));
    await runJob();
    const { id } = await onlyArchive();
    const { headers } = user;
    expect((await app.inject({ url: url(id), headers })).statusCode).toBe(404);
    expect((await app.inject({ url: url('bukan-uuid'), headers })).statusCode).toBe(400);
    expect((await app.inject({ url: url(id) })).statusCode).toBe(401);
  });

  it('lewat expiresAt 410 ARCHIVE_EXPIRED, walau job belum jalan', async () => {
    const user = await setup();
    await addPhoto(user);
    await runJob();
    const archive = await onlyArchive();
    await app.prisma.archive.update({
      where: { id: archive.id },
      data: { expiresAt: new Date(Date.now() - 1000) },
    });
    const res = await app.inject({ url: url(archive.id), headers: user.headers });
    expect(res.statusCode).toBe(410);
    expect(res.json().error.code).toBe('ARCHIVE_EXPIRED');
  });
});

describe('job backup', () => {
  it('rotasi menyimpan 14 hari dan hanya menyentuh file backup', async () => {
    const dir = await mkdtemp(join(tmpdir(), 'direkapin-backup-'));
    const names = [
      'direkapin-2026-11-15.dump',
      'direkapin-2026-11-02.dump',
      'direkapin-2026-11-01.dump',
      'catatan.txt',
    ];
    await Promise.all(names.map((name) => writeFile(join(dir, name), '')));
    await pruneBackups(dir, '2026-11-15', app.log);
    expect((await readdir(dir)).sort()).toEqual([
      'catatan.txt',
      'direkapin-2026-11-02.dump',
      'direkapin-2026-11-15.dump',
    ]);
    await rm(dir, { recursive: true, force: true });
  });

  const hasPgTools = (() => {
    try {
      execFileSync('pg_dump', ['--version'], { stdio: 'ignore' });
      return true;
    } catch {
      return false;
    }
  })();

  // Butuh folder bin PostgreSQL di PATH.
  it.runIf(hasPgTools)('hasilnya bisa di-restore ke database kosong', async () => {
    const user = await setup();
    await addPhoto(user);
    const dir = await mkdtemp(join(tmpdir(), 'direkapin-backup-'));
    const config = {
      DATABASE_URL: process.env.DATABASE_URL!,
      BACKUP_DIR: dir,
      TZ: 'Asia/Jakarta',
    };
    const path = await runBackupJob(config, app.log, NOW);
    expect(await readdir(dir)).toEqual(['direkapin-2026-11-15.dump']);

    const url = new URL(config.DATABASE_URL);
    const env = { ...process.env, PGPASSWORD: decodeURIComponent(url.password) };
    const base = [
      '-h',
      url.hostname,
      '-p',
      url.port || '5432',
      '-U',
      decodeURIComponent(url.username),
    ];
    await app.prisma.$executeRawUnsafe('DROP DATABASE IF EXISTS direkapin_restore WITH (FORCE)');
    await app.prisma.$executeRawUnsafe('CREATE DATABASE direkapin_restore');
    try {
      execFileSync('pg_restore', [...base, '-d', 'direkapin_restore', '--exit-on-error', path], {
        env,
      });
      const count = execFileSync(
        'psql',
        [...base, '-d', 'direkapin_restore', '-tAc', 'SELECT count(*) FROM attachments'],
        { env },
      );
      expect(count.toString().trim()).toBe('1');
    } finally {
      await app.prisma.$executeRawUnsafe('DROP DATABASE IF EXISTS direkapin_restore WITH (FORCE)');
      await rm(dir, { recursive: true, force: true });
    }
  });
});
