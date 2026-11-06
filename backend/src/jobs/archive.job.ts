import { createWriteStream } from 'node:fs';
import { mkdir, rename, rm, stat } from 'node:fs/promises';
import { dirname, extname, join } from 'node:path';
import { pipeline } from 'node:stream/promises';
import type { PrismaClient } from '@prisma/client';
import { ZipArchive } from 'archiver';
import type { FastifyBaseLogger } from 'fastify';
import type { Config } from '../config.js';
import {
  firstOfNextMonth,
  localDate,
  monthRange,
  shiftMonth,
  startOfDay,
  toDbDate,
} from '../lib/dates.js';
import { toNumber } from '../lib/money.js';
import { releaseOriginals } from '../modules/archives/archives.service.js';

const EXPIRY_MS = 30 * 86_400_000;
const BOM = '﻿';

type Dirs = Pick<Config, 'UPLOAD_DIR' | 'ARCHIVE_DIR'>;
type Photo = { id: string; filePath: string | null; createdAt: Date };
type ArchiveUser = { id: string; timezone: string };

/** Teks dari user yang diawali tanda ini dijalankan sebagai formula oleh Excel. */
function csvText(value: string | null) {
  const text = value ?? '';
  return /^[=+\-@\t\r]/.test(text) ? `'${text}` : text;
}

function csv(rows: (string | number)[][]) {
  const lines = rows.map((row) =>
    row.map((cell) => `"${String(cell).replaceAll('"', '""')}"`).join(','),
  );
  return `${BOM}${lines.join('\r\n')}\r\n`;
}

async function transactionsCsv(
  prisma: PrismaClient,
  userId: string,
  month: string,
  timeZone: string,
) {
  const rows = await prisma.transaction.findMany({
    where: { userId, occurredAt: monthRange(`${month}-01`, timeZone) },
    include: { wallet: { select: { name: true } }, category: { select: { name: true } } },
    orderBy: { occurredAt: 'asc' },
  });
  const time = new Intl.DateTimeFormat('en-GB', { timeZone, hour: '2-digit', minute: '2-digit' });
  return csv([
    ['tanggal', 'jam', 'jenis', 'dompet', 'kategori', 'nominal', 'catatan'],
    ...rows.map((row) => [
      localDate(row.occurredAt, timeZone),
      time.format(row.occurredAt),
      row.type === 'INCOME' ? 'Pemasukan' : 'Pengeluaran',
      csvText(row.wallet.name),
      csvText(row.category.name),
      toNumber(row.amount),
      csvText(row.note),
    ]),
  ]);
}

async function activitiesCsv(prisma: PrismaClient, userId: string, month: string) {
  const first = `${month}-01`;
  const rows = await prisma.activity.findMany({
    where: { userId, date: { gte: toDbDate(first), lt: toDbDate(firstOfNextMonth(first)) } },
    orderBy: [{ date: 'asc' }, { time: 'asc' }],
  });
  return csv([
    ['tanggal', 'jam', 'judul', 'lokasi', 'deskripsi', 'penting'],
    ...rows.map((row) => [
      row.date.toISOString().slice(0, 10),
      row.time ?? '',
      csvText(row.title),
      csvText(row.location),
      csvText(row.description),
      row.isImportant ? 'Ya' : 'Tidak',
    ]),
  ]);
}

async function writeZip(
  path: string,
  photos: Photo[],
  csvs: { transactions: string; activities: string },
  uploadDir: string,
  timeZone: string,
) {
  // JPEG sudah terkompres; mengompres ulang hanya membebani Celeron.
  const zip = new ZipArchive({ store: true });
  const written = pipeline(zip, createWriteStream(path));
  const failed = new Promise<never>((_, reject) => {
    // File yang hilang hanya jadi 'warning', padahal arsipnya jadi tidak lengkap.
    zip.on('warning', reject);
    zip.on('error', reject);
  });
  for (const photo of photos) {
    const name = `${localDate(photo.createdAt, timeZone)}_${photo.id}${extname(photo.filePath!)}`;
    zip.file(join(uploadDir, photo.filePath!), { name: `foto/${name}` });
  }
  zip.append(csvs.transactions, { name: 'transaksi.csv' });
  zip.append(csvs.activities, { name: 'kegiatan.csv' });
  try {
    await Promise.race([Promise.all([zip.finalize(), written]), failed]);
  } catch (error) {
    // Lepaskan file temp supaya bisa dihapus pemanggil.
    zip.destroy();
    await written.catch(() => undefined);
    throw error;
  }
}

async function createArchive(
  prisma: PrismaClient,
  user: ArchiveUser,
  month: string,
  photos: Photo[],
  dirs: Dirs,
  log: FastifyBaseLogger,
) {
  const zipPath = `${user.id}/${month}.zip`;
  const path = join(dirs.ARCHIVE_DIR, zipPath);
  const temp = `${path}.tmp`;
  const now = new Date();
  const expiresAt = new Date(now.getTime() + EXPIRY_MS);
  const key = { userId_month: { userId: user.id, month } };
  try {
    await mkdir(dirname(path), { recursive: true });
    const csvs = {
      transactions: await transactionsCsv(prisma, user.id, month, user.timezone),
      activities: await activitiesCsv(prisma, user.id, month),
    };
    await writeZip(temp, photos, csvs, dirs.UPLOAD_DIR, user.timezone);
    const { size } = await stat(temp);
    await rename(temp, path);

    const values = {
      zipPath,
      sizeBytes: BigInt(size),
      photoCount: photos.length,
      status: 'READY' as const,
      createdAt: now,
      expiresAt,
    };
    await prisma.$transaction(async (tx) => {
      const archive = await tx.archive.upsert({
        where: key,
        create: { userId: user.id, month, ...values },
        update: values,
      });
      await tx.attachment.updateMany({
        where: { id: { in: photos.map((photo) => photo.id) } },
        data: { archiveId: archive.id },
      });
    });
    log.info({ userId: user.id, month, photos: photos.length }, 'arsip dibuat');
  } catch (err) {
    log.error({ err, userId: user.id, month }, 'gagal membuat arsip, dicoba lagi besok');
    await rm(temp, { force: true }).catch(() => undefined);
    await rm(path, { force: true }).catch(() => undefined);
    const values = {
      zipPath: null,
      sizeBytes: 0n,
      photoCount: 0,
      status: 'FAILED' as const,
      createdAt: now,
      expiresAt,
    };
    await prisma.archive.upsert({
      where: key,
      create: { userId: user.id, month, ...values },
      update: values,
    });
  }
}

/** Arsip M-2 dan bulan sebelumnya yang belum ada atau `FAILED` (D-23). */
async function archiveUser(
  prisma: PrismaClient,
  user: ArchiveUser,
  now: Date,
  dirs: Dirs,
  log: FastifyBaseLogger,
) {
  const currentMonth = localDate(now, user.timezone).slice(0, 7);
  const before = startOfDay(`${shiftMonth(currentMonth, -1)}-01`, user.timezone);
  const photos = await prisma.attachment.findMany({
    where: { userId: user.id, archiveId: null, filePath: { not: null }, createdAt: { lt: before } },
    select: { id: true, filePath: true, createdAt: true },
  });
  const byMonth = new Map<string, Photo[]>();
  for (const photo of photos) {
    const month = localDate(photo.createdAt, user.timezone).slice(0, 7);
    byMonth.set(month, [...(byMonth.get(month) ?? []), photo]);
  }

  const archives = await prisma.archive.findMany({
    where: { userId: user.id },
    select: { id: true, month: true, status: true },
  });
  for (const archive of archives) {
    if (archive.status !== 'FAILED') byMonth.delete(archive.month);
    // Semua fotonya sudah dihapus user, jadi tidak ada lagi yang perlu dicoba.
    else if (!byMonth.has(archive.month)) {
      await prisma.archive.delete({ where: { id: archive.id } });
    }
  }
  for (const [month, monthPhotos] of byMonth) {
    await createArchive(prisma, user, month, monthPhotos, dirs, log);
  }
}

/** Lewat hari ke-30: foto asli yang tersisa dan ZIP dihapus (ARC-04). */
async function expireArchives(prisma: PrismaClient, now: Date, dirs: Dirs, log: FastifyBaseLogger) {
  const rows = await prisma.archive.findMany({
    where: { status: { in: ['READY', 'DOWNLOADED'] }, expiresAt: { lte: now } },
  });
  for (const row of rows) {
    try {
      await releaseOriginals(
        prisma,
        row.id,
        { status: 'EXPIRED', zipPath: null },
        dirs.UPLOAD_DIR,
        log,
      );
      if (row.zipPath) await rm(join(dirs.ARCHIVE_DIR, row.zipPath), { force: true });
    } catch (err) {
      log.error({ err, archiveId: row.id }, 'gagal membereskan arsip kedaluwarsa');
    }
  }
}

export async function runArchiveJob(
  prisma: PrismaClient,
  dirs: Dirs,
  log: FastifyBaseLogger,
  now = new Date(),
) {
  const users = await prisma.user.findMany({ select: { id: true, timezone: true } });
  for (const user of users) {
    try {
      await archiveUser(prisma, user, now, dirs, log);
    } catch (err) {
      log.error({ err, userId: user.id }, 'job arsip gagal untuk user ini');
    }
  }
  await expireArchives(prisma, now, dirs, log);
}
