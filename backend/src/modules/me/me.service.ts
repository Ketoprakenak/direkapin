import type { PrismaClient, User } from '@prisma/client';
import type { z } from 'zod';
import { AppError } from '../../lib/app-error.js';
import type { updateMeBody, userResponse } from './me.schemas.js';

export function toUserResponse(user: User): z.infer<typeof userResponse> {
  return {
    id: user.id,
    name: user.name,
    email: user.email,
    timezone: user.timezone,
    reminderTime: user.reminderTime,
    createdAt: user.createdAt.toISOString(),
  };
}

export async function getMe(prisma: PrismaClient, userId: string) {
  const user = await prisma.user.findFirst({ where: { id: userId } });
  if (!user) throw new AppError('NOT_FOUND', 404, 'Data tidak ditemukan');
  return toUserResponse(user);
}

export async function updateMe(
  prisma: PrismaClient,
  userId: string,
  input: z.infer<typeof updateMeBody>,
) {
  await getMe(prisma, userId);
  return toUserResponse(await prisma.user.update({ where: { id: userId }, data: input }));
}
