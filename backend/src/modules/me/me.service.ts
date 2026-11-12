import { randomUUID } from 'node:crypto';
import type { PrismaClient, User } from '@prisma/client';
import type { FastifyBaseLogger } from 'fastify';
import sharp from 'sharp';
import type { z } from 'zod';
import { AppError } from '../../lib/app-error.js';
import { readUpload, removeUploads, writeUpload } from '../../lib/storage.js';
import type { updateMeBody, userResponse } from './me.schemas.js';

const AVATAR_PX = 512;
// Batas piksel input (anti decompression bomb); melebihi batas -> 400.
const AVATAR_LIMIT = { limitInputPixels: 40_000_000 };

export function toUserResponse(user: User): z.infer<typeof userResponse> {
  return {
    id: user.id,
    name: user.name,
    email: user.email,
    timezone: user.timezone,
    reminderTime: user.reminderTime,
    hasAvatar: user.avatarPath !== null,
    createdAt: user.createdAt.toISOString(),
  };
}

export async function getMe(prisma: PrismaClient, userId: string) {
  const user = await prisma.user.findFirst({ where: { id: userId } });
  if (!user) throw new AppError('NOT_FOUND', 404, 'Data tidak ditemukan');
  return toUserResponse(user);
}

export async function getTimezone(prisma: PrismaClient, userId: string) {
  const user = await prisma.user.findFirst({ where: { id: userId }, select: { timezone: true } });
  if (!user) throw new AppError('NOT_FOUND', 404, 'Data tidak ditemukan');
  return user.timezone;
}

export async function updateMe(
  prisma: PrismaClient,
  userId: string,
  input: z.infer<typeof updateMeBody>,
) {
  await getMe(prisma, userId);
  return toUserResponse(await prisma.user.update({ where: { id: userId }, data: input }));
}

async function setAvatarPath(prisma: PrismaClient, userId: string, avatarPath: string | null) {
  return prisma.user.update({ where: { id: userId }, data: { avatarPath } });
}

export async function setAvatar(
  prisma: PrismaClient,
  userId: string,
  data: Buffer,
  uploadDir: string,
  log: FastifyBaseLogger,
) {
  const invalid = new AppError('VALIDATION_ERROR', 400, 'Data belum valid', {
    file: 'Foto harus berformat JPEG, PNG, atau WebP',
  });
  let image: Buffer;
  try {
    // Jenis file dibaca dari isinya; header dari client tidak dipercaya.
    const { format } = await sharp(data, AVATAR_LIMIT).metadata();
    if (format !== 'jpeg' && format !== 'png' && format !== 'webp') throw invalid;
    image = await sharp(data, AVATAR_LIMIT)
      .rotate()
      .flatten({ background: '#ffffff' })
      .resize(AVATAR_PX, AVATAR_PX, { fit: 'cover', position: 'centre' })
      .jpeg({ quality: 80 })
      .toBuffer();
  } catch {
    throw invalid;
  }

  // shortcut: PUT/DELETE bersamaan bisa meninggalkan file yatim, ganti ke update bersyarat jika ada lebih dari satu sesi aktif per akun.
  const old = await prisma.user.findFirst({
    where: { id: userId },
    select: { avatarPath: true },
  });
  if (!old) throw new AppError('NOT_FOUND', 404, 'Data tidak ditemukan');
  const path = `avatars/${userId}-${randomUUID()}.jpg`;
  await writeUpload(uploadDir, path, image);
  let user: User;
  try {
    user = await setAvatarPath(prisma, userId, path);
  } catch (error) {
    await removeUploads(uploadDir, [path], log);
    throw error;
  }
  if (old.avatarPath) await removeUploads(uploadDir, [old.avatarPath], log);
  return toUserResponse(user);
}

export async function readAvatar(prisma: PrismaClient, userId: string, uploadDir: string) {
  const user = await prisma.user.findFirst({
    where: { id: userId },
    select: { avatarPath: true },
  });
  if (!user?.avatarPath) throw new AppError('NOT_FOUND', 404, 'Data tidak ditemukan');
  try {
    return await readUpload(uploadDir, user.avatarPath);
  } catch (error) {
    if ((error as NodeJS.ErrnoException).code !== 'ENOENT') throw error;
    throw new AppError('NOT_FOUND', 404, 'Data tidak ditemukan');
  }
}

export async function deleteAvatar(
  prisma: PrismaClient,
  userId: string,
  uploadDir: string,
  log: FastifyBaseLogger,
) {
  const user = await prisma.user.findFirst({
    where: { id: userId },
    select: { avatarPath: true },
  });
  if (!user?.avatarPath) return;
  await setAvatarPath(prisma, userId, null);
  await removeUploads(uploadDir, [user.avatarPath], log);
}
