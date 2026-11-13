import { z } from 'zod';
import { amount } from '../../lib/schemas.js';

const NAME_ERROR = 'Nama minimal 2 karakter';

export const nameSchema = z
  .string({ error: NAME_ERROR })
  .trim()
  .min(2, NAME_ERROR)
  .max(50, 'Nama maksimal 50 karakter');

function isValidTimezone(value: string) {
  try {
    new Intl.DateTimeFormat('en', { timeZone: value });
    return true;
  } catch {
    return false;
  }
}

export const heatmapSchema = z.object({
  mode: z.enum(['AUTO', 'FIXED']),
  thresholds: z
    .array(amount)
    .length(3, 'Batas harus 3')
    .refine(([a, b, c]) => a! < b! && b! < c!, 'Batas harus naik'),
});

export const updateMeBody = z.object({
  name: nameSchema.optional(),
  timezone: z.string().refine(isValidTimezone, 'Zona waktu tidak valid').optional(),
  reminderTime: z
    .string()
    .regex(/^([01]\d|2[0-3]):[0-5]\d$/, 'Jam harus berformat HH:mm')
    .optional(),
  heatmap: heatmapSchema.optional(),
});

export const userResponse = z.object({
  id: z.uuid(),
  name: z.string(),
  email: z.email(),
  timezone: z.string(),
  reminderTime: z.string(),
  hasAvatar: z.boolean(),
  heatmap: heatmapSchema,
  createdAt: z.string(),
});
