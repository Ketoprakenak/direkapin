import { z } from 'zod';
import { dateString } from '../../lib/schemas.js';
import { calendarQuery } from '../calendar/calendar.schemas.js';
import { categoryRef } from '../categories/categories.schemas.js';
import { seriesPoint } from '../dashboard/dashboard.schemas.js';

const wallet = z.uuid().optional();

export const dailyReportQuery = z.object({ date: dateString, wallet });

export const weeklyReportQuery = z.object({
  start: dateString.refine((date) => new Date(`${date}T00:00:00Z`).getUTCDay() === 1, {
    error: 'Awal minggu harus hari Senin',
  }),
  wallet,
});

export const monthlyReportQuery = z.object({ month: calendarQuery.shape.month, wallet });

export const reportResponse = z.object({
  period: z.object({
    type: z.enum(['daily', 'weekly', 'monthly']),
    start: z.string(),
    end: z.string(),
  }),
  totals: z.object({
    income: z.number().int(),
    expense: z.number().int(),
    net: z.number().int(),
    transactionCount: z.number().int(),
  }),
  series: z.array(seriesPoint),
  byCategory: z.array(
    z.object({
      category: categoryRef,
      amount: z.number().int(),
      share: z.number(),
    }),
  ),
  comparison: z
    .object({
      previousExpense: z.number().int(),
      changePct: z.number().nullable(),
    })
    .nullable(),
});
