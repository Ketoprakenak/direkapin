import { randomUUID } from 'node:crypto';
import type { Prisma, PrismaClient } from '@prisma/client';
import type { FastifyBaseLogger } from 'fastify';
import sharp from 'sharp';
import { AppError } from '../../lib/app-error.js';
import { readUpload, removeUploads, writeUpload } from '../../lib/storage.js';

const RESIZE_ABOVE_BYTES = 1024 * 1024;
const FULL_MAX_PX = 1600;
const THUMB_MAX_PX = 320;
const TRANSACTION_PHOTO_LIMIT = 3;
const ACTIVITY_PHOTO_LIMIT = 5;

const archiveMonth = { archive: { select: { month: true } } };

/** Dipakai sebagai `attachments` di include transaksi dan kegiatan. */
export const attachmentsInclude = {
  include: archiveMonth,
  orderBy: { createdAt: 'asc' },
} satisfies Prisma.Transaction$attachmentsArgs;

type AttachmentRow = Prisma.AttachmentGetPayload<{ include: typeof archiveMonth }>;

export function toAttachmentResponse(row: AttachmentRow) {
  const url = `/api/v1/attachments/${row.id}`;
  return {
    id: row.id,
    thumbUrl: `${url}?size=thumb`,
    fullUrl: row.filePath && `${url}?size=full`,
    isArchived: row.archivedAt !== null,
    archiveMonth: row.archive?.month ?? null,
    width: row.width,
    height: row.height,
    sizeBytes: row.sizeBytes,
    createdAt: row.createdAt.toISOString(),
  };
}

export function attachmentFiles(row: { filePath: string | null; thumbPath: string }) {
  return row.filePath ? [row.filePath, row.thumbPath] : [row.thumbPath];
}

function toJpeg(data: Buffer, maxPx: number, quality: number) {
  return sharp(data)
    .rotate()
    .flatten({ background: '#ffffff' })
    .resize({ width: maxPx, height: maxPx, fit: 'inside', withoutEnlargement: true })
    .jpeg({ quality })
    .toBuffer({ resolveWithObject: true });
}

async function processImage(data: Buffer) {
  try {
    // Jenis file dibaca dari isinya; header dari client tidak dipercaya.
    const { format, autoOrient } = await sharp(data).metadata();
    if (format !== 'jpeg' && format !== 'png' && format !== 'webp') return null;

    const thumb = (await toJpeg(data, THUMB_MAX_PX, 70)).data;
    // Foto dari aplikasi sudah dikompres di HP (D-11). Kontrak GET hanya JPEG dan WebP.
    if (format !== 'png' && data.length <= RESIZE_ABOVE_BYTES) {
      return {
        full: data,
        thumb,
        extension: format === 'jpeg' ? 'jpg' : 'webp',
        mimeType: `image/${format}`,
        width: autoOrient.width,
        height: autoOrient.height,
      };
    }
    const full = await toJpeg(data, FULL_MAX_PX, 80);
    return {
      full: full.data,
      thumb,
      extension: 'jpg',
      mimeType: 'image/jpeg',
      width: full.info.width,
      height: full.info.height,
    };
  } catch {
    return null;
  }
}

async function assertOwnerHasRoom(
  prisma: PrismaClient,
  userId: string,
  transactionId: string | undefined,
  activityId: string | undefined,
) {
  const where = { id: transactionId ?? activityId, userId };
  const select = { id: true };
  const owner = transactionId
    ? await prisma.transaction.findFirst({ where, select })
    : await prisma.activity.findFirst({ where, select });
  if (!owner) throw new AppError('NOT_FOUND', 404, 'Data tidak ditemukan');

  const limit = transactionId ? TRANSACTION_PHOTO_LIMIT : ACTIVITY_PHOTO_LIMIT;
  // shortcut: tanpa kunci, dua upload bersamaan bisa melewati batas; aplikasi upload berurutan, kunci baris kalau ada klien lain.
  const count = await prisma.attachment.count({ where: { userId, transactionId, activityId } });
  if (count >= limit) {
    throw new AppError('PHOTO_LIMIT_REACHED', 422, `Maksimal ${limit} foto`);
  }
}

export async function createAttachment(
  prisma: PrismaClient,
  userId: string,
  input: { data: Buffer; transactionId?: string; activityId?: string },
  uploadDir: string,
  log: FastifyBaseLogger,
) {
  await assertOwnerHasRoom(prisma, userId, input.transactionId, input.activityId);

  const image = await processImage(input.data);
  if (!image) {
    throw new AppError('UNSUPPORTED_MEDIA', 415, 'Format foto harus JPEG, PNG, atau WebP');
  }

  const id = randomUUID();
  const now = new Date();
  const month = String(now.getUTCMonth() + 1).padStart(2, '0');
  const folder = `${userId}/${now.getUTCFullYear()}/${month}`;
  const filePath = `${folder}/${id}.${image.extension}`;
  const thumbPath = `${folder}/${id}_thumb.jpg`;

  try {
    await writeUpload(uploadDir, filePath, image.full);
    await writeUpload(uploadDir, thumbPath, image.thumb);
    const row = await prisma.attachment.create({
      data: {
        id,
        userId,
        transactionId: input.transactionId,
        activityId: input.activityId,
        filePath,
        thumbPath,
        mimeType: image.mimeType,
        sizeBytes: image.full.length,
        width: image.width,
        height: image.height,
      },
      include: archiveMonth,
    });
    return toAttachmentResponse(row);
  } catch (error) {
    await removeUploads(uploadDir, [filePath, thumbPath], log);
    throw error;
  }
}

export async function readAttachment(
  prisma: PrismaClient,
  userId: string,
  id: string,
  size: 'thumb' | 'full',
  uploadDir: string,
) {
  const row = await prisma.attachment.findFirst({ where: { id, userId } });
  if (!row) throw new AppError('NOT_FOUND', 404, 'Data tidak ditemukan');

  if (size === 'full' && !row.filePath) {
    throw new AppError('ARCHIVED', 410, 'Foto asli sudah dipindah ke arsip');
  }
  const path = size === 'full' ? row.filePath! : row.thumbPath;
  try {
    return {
      data: await readUpload(uploadDir, path),
      mimeType: size === 'full' ? row.mimeType : 'image/jpeg',
    };
  } catch (error) {
    if ((error as NodeJS.ErrnoException).code !== 'ENOENT') throw error;
    throw new AppError('NOT_FOUND', 404, 'Data tidak ditemukan');
  }
}

export async function deleteAttachment(
  prisma: PrismaClient,
  userId: string,
  id: string,
  uploadDir: string,
  log: FastifyBaseLogger,
) {
  const row = await prisma.attachment.findFirst({ where: { id, userId } });
  if (!row) throw new AppError('NOT_FOUND', 404, 'Data tidak ditemukan');
  await prisma.attachment.delete({ where: { id } });
  await removeUploads(uploadDir, attachmentFiles(row), log);
}
