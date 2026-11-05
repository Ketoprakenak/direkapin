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
    }),
  ),
});

export const dayParams = z.object({ date: dateString });

export const dayResponse = z.object({
  date: z.string(),
  income: z.number().int(),
  expense: z.number().int(),
  transactions: z.array(transactionResponse),
  transfers: z.array(transferResponse),
  activities: z.array(activityResponse),
  note: z
    .object({
      date: z.string(),
      mood: z.string().nullable(),
      note: z.string().nullable(),
    })
    .nullable(),
});
