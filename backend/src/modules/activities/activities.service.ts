import type { Activity, Prisma } from '@prisma/client';

/** Penting dulu, lalu jam naik, tanpa jam di akhir. */
export const activityOrder = [
  { isImportant: 'desc' },
  { time: { sort: 'asc', nulls: 'last' } },
] satisfies Prisma.ActivityOrderByWithRelationInput[];

export function toActivityResponse(activity: Activity) {
  return {
    id: activity.id,
    title: activity.title,
    date: activity.date.toISOString().slice(0, 10),
    time: activity.time,
    location: activity.location,
    description: activity.description,
    isImportant: activity.isImportant,
    attachments: [],
    createdAt: activity.createdAt.toISOString(),
    updatedAt: activity.updatedAt.toISOString(),
  };
}
