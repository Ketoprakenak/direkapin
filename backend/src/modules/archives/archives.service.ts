import { stat } from 'node:fs/promises';
import { join } from 'node:path';
import type { Archive, Prisma, PrismaClient } from '@prisma/client';
import type { FastifyBaseLogger } from 'fastify';
import type { z } from 'zod';
import { AppError } from '../../lib/app-error.js';
import { toNumber } from '../../lib/money.js';
import { removeUploads } from '../../lib/storage.js';
import type { archiveResponse } from './archives.schemas.js';

function toArchiveResponse(row: Archive): z.infer<typeof archiveResponse> {
  return {
    id: row.id,
    month: row.month,
    sizeBytes: toNumber(row.sizeBytes),
    photoCount: row.photoCount,
    status: row.status,
    createdAt: row.createdAt.toISOString(),
    expiresAt: row.expiresAt.toISOString(),
    downloadedAt: row.downloadedAt?.toISOString() ?? null,
  };
}

export async function listArchives(prisma: PrismaClient, userId: string) {
  const rows = await prisma.archive.findMany({ where: { userId }, orderBy: { month: 'desc' } });
  return { items: rows.map(toArchiveResponse) };
}

export async function findDownload(
  prisma: PrismaClient,
  userId: string,
  id: string,
  archiveDir: string,
) {
  const row = await prisma.archive.findFirst({ where: { id, userId } });
  if (!row || row.status === 'FAILED') {
    throw new AppError('NOT_FOUND', 404, 'Data tidak ditemukan');
  }
  if (row.status === 'EXPIRED' || !row.zipPath || row.expiresAt <= new Date()) {
    throw new AppError('ARCHIVE_EXPIRED', 410, 'Arsip sudah kedaluwarsa');
  }
  const path = join(archiveDir, row.zipPath);
  try {
    const { size } = await stat(path);
    return { path, size, month: row.month };
  } catch (error) {
    if ((error as NodeJS.ErrnoException).code !== 'ENOENT') throw error;
    throw new AppError('NOT_FOUND', 404, 'Data tidak ditemukan');
  }
}

/** Status arsip berubah bersama pelepasan fotonya, lalu file foto asli dihapus. */
export async function releaseOriginals(
  prisma: PrismaClient,
  archiveId: string,
  data: Prisma.ArchiveUpdateInput,
  uploadDir: string,
  log: FastifyBaseLogger,
) {
  const where = { archiveId, filePath: { not: null } };
  const paths = await prisma.$transaction(async (tx) => {
    const rows = await tx.attachment.findMany({ where, select: { filePath: true } });
    await tx.attachment.updateMany({ where, data: { filePath: null, archivedAt: new Date() } });
    await tx.archive.update({ where: { id: archiveId }, data });
    return rows.map((row) => row.filePath!);
  });
  await removeUploads(uploadDir, paths, log);
}

/** Hanya dipanggil setelah stream selesai utuh (D-22). Download ulang tidak mengubah apa pun. */
export async function markDownloaded(
  prisma: PrismaClient,
  userId: string,
  id: string,
  uploadDir: string,
  log: FastifyBaseLogger,
) {
  const row = await prisma.archive.findFirst({ where: { id, userId, status: 'READY' } });
  if (!row) return;
  await releaseOriginals(
    prisma,
    id,
    { status: 'DOWNLOADED', downloadedAt: new Date() },
    uploadDir,
    log,
  );
}
