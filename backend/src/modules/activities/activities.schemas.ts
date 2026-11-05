import { z } from 'zod';
import { dateString } from '../../lib/schemas.js';
import { attachmentResponse } from '../attachments/attachments.schemas.js';

const title = z.string().trim().min(1, 'Judul wajib diisi').max(100, 'Judul terlalu panjang');
const time = z.string().regex(/^([01]\d|2[0-3]):[0-5]\d$/, 'Jam tidak valid');
const location = z.string().max(100, 'Lokasi terlalu panjang');
const description = z.string().max(1000, 'Deskripsi terlalu panjang');

export const listActivitiesQuery = z.object({
  from: dateString,
  to: dateString,
});

export const createActivityBody = z.object({
  title,
  date: dateString,
  time: time.optional(),
  location: location.optional(),
  description: description.optional(),
  isImportant: z.boolean().default(false),
});

export const updateActivityBody = z.object({
  title: title.optional(),
  date: dateString.optional(),
  time: time.nullable().optional(),
  location: location.nullable().optional(),
  description: description.nullable().optional(),
  isImportant: z.boolean().optional(),
});

export const activityResponse = z.object({
  id: z.uuid(),
  title: z.string(),
  date: z.string(),
  time: z.string().nullable(),
  location: z.string().nullable(),
  description: z.string().nullable(),
  isImportant: z.boolean(),
  attachments: z.array(attachmentResponse),
  createdAt: z.string(),
  updatedAt: z.string(),
});

export const activityListResponse = z.object({
  items: z.array(activityResponse),
});
