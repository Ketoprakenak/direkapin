import { z } from 'zod';

export const activityResponse = z.object({
  id: z.uuid(),
  title: z.string(),
  date: z.string(),
  time: z.string().nullable(),
  location: z.string().nullable(),
  description: z.string().nullable(),
  isImportant: z.boolean(),
  // shortcut: selalu kosong sampai upload foto ada, isi skemanya di Slice 4.
  attachments: z.array(z.never()),
  createdAt: z.string(),
  updatedAt: z.string(),
});
