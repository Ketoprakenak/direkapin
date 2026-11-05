import type { Prisma } from '@prisma/client';
import { attachmentsInclude, toAttachmentResponse } from '../attachments/attachments.service.js';

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
