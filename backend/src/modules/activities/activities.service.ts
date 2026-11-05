import type { Prisma, PrismaClient } from '@prisma/client';
import type { FastifyBaseLogger } from 'fastify';
import type { z } from 'zod';
import { AppError } from '../../lib/app-error.js';
import { toDbDate } from '../../lib/dates.js';
import { removeUploads } from '../../lib/storage.js';
import {
  attachmentFiles,
  attachmentsInclude,
  toAttachmentResponse,
} from '../attachments/attachments.service.js';
import type {
  createActivityBody,
  listActivitiesQuery,
  updateActivityBody,
} from './activities.schemas.js';

export const activityInclude = { attachments: attachmentsInclude } satisfies Prisma.ActivityInclude;

/** Penting dulu, lalu jam naik, tanpa jam di akhir. */
export const activityOrder = [
  { isImportant: 'desc' },
  { time: { sort: 'asc', nulls: 'last' } },
] satisfies Prisma.ActivityOrderByWithRelationInput[];

export function toActivityResponse(
  activity: Prisma.ActivityGetPayload<{ include: typeof activityInclude }>,
) {
  return {
    id: activity.id,
    title: activity.title,
    date: activity.date.toISOString().slice(0, 10),
    time: activity.time,
    location: activity.location,
    description: activity.description,
    isImportant: activity.isImportant,
    attachments: activity.attachments.map(toAttachmentResponse),
    createdAt: activity.createdAt.toISOString(),
    updatedAt: activity.updatedAt.toISOString(),
  };
}

async function findOwned(prisma: PrismaClient, userId: string, id: string) {
  const row = await prisma.activity.findFirst({ where: { id, userId }, include: activityInclude });
  if (!row) throw new AppError('NOT_FOUND', 404, 'Data tidak ditemukan');
  return row;
}

export async function listActivities(
  prisma: PrismaClient,
  userId: string,
  query: z.infer<typeof listActivitiesQuery>,
) {
  const rows = await prisma.activity.findMany({
    where: { userId, date: { gte: toDbDate(query.from), lte: toDbDate(query.to) } },
    include: activityInclude,
    orderBy: [{ date: 'asc' }, ...activityOrder],
  });
  return { items: rows.map(toActivityResponse) };
}

export async function getActivity(prisma: PrismaClient, userId: string, id: string) {
  return toActivityResponse(await findOwned(prisma, userId, id));
}

export async function createActivity(
  prisma: PrismaClient,
  userId: string,
  input: z.infer<typeof createActivityBody>,
) {
  const row = await prisma.activity.create({
    data: { ...input, userId, date: toDbDate(input.date) },
    include: activityInclude,
  });
  return toActivityResponse(row);
}

export async function updateActivity(
  prisma: PrismaClient,
  userId: string,
  id: string,
  input: z.infer<typeof updateActivityBody>,
) {
  await findOwned(prisma, userId, id);
  const row = await prisma.activity.update({
    where: { id },
    data: { ...input, ...(input.date !== undefined && { date: toDbDate(input.date) }) },
    include: activityInclude,
  });
  return toActivityResponse(row);
}

export async function deleteActivity(
  prisma: PrismaClient,
  userId: string,
  id: string,
  uploadDir: string,
  log: FastifyBaseLogger,
) {
  const row = await findOwned(prisma, userId, id);
  await prisma.activity.delete({ where: { id } });
  await removeUploads(uploadDir, row.attachments.flatMap(attachmentFiles), log);
}
