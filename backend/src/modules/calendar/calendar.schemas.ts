import { z } from 'zod';
import { dateString } from '../../lib/schemas.js';
import { activityResponse } from '../activities/activities.schemas.js';
import { transactionResponse } from '../transactions/transactions.schemas.js';
import { transferResponse } from '../transfers/transfers.schemas.js';

export const calendarQuery = z.object({
  month: z.string({ error: 'Bulan tidak valid' }).regex(/^\d{4}-(0[1-9]|1[0-2])$/, 'Bulan tidak valid'),
});

export const calendarResponse = z.object({
  month: z.string(),
  days: z.array(
    z.object({
      date: z.string(),
      income: z.number().int(),
      expense: z.number().int(),
      activityCount: z.number().int(),
      hasImportant: z.boolean(),
      mood: z.string().nullable(),
    }),
  ),
});

export const dayParams = z.object({ date: dateString });

export const dailyNoteResponse = z.object({
  date: z.string(),
  mood: z.string().nullable(),
  note: z.string().nullable(),
});

/** Mood = satu emoji (ACT-05). Kosongkan keduanya untuk menghapus catatan hari itu. */
export const dailyNoteBody = z.object({
  mood: z.string().trim().min(1, 'Mood tidak valid').max(16, 'Mood tidak valid').nullable().optional(),
  note: z.string().max(1000, 'Catatan terlalu panjang').nullable().optional(),
});

export const dayResponse = z.object({
  date: z.string(),
  income: z.number().int(),
  expense: z.number().int(),
  transactions: z.array(transactionResponse),
  transfers: z.array(transferResponse),
  activities: z.array(activityResponse),
  note: dailyNoteResponse.nullable(),
});
