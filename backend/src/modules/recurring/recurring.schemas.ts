import { z } from 'zod';
import { amount, note, occurredAt, walletRef } from '../../lib/schemas.js';
import { calendarQuery } from '../calendar/calendar.schemas.js';
import { categoryRef, txType } from '../categories/categories.schemas.js';

const month = calendarQuery.shape.month;

const dayOfMonth = z
  .number({ error: 'Tanggal harus 1–31' })
  .int('Tanggal harus 1–31')
  .min(1, 'Tanggal harus 1–31')
  .max(31, 'Tanggal harus 1–31');

const walletId = z.uuid({ error: 'Pilih dompet' });
const categoryId = z.uuid({ error: 'Pilih kategori' });

export const END_BEFORE_START = 'Bulan berakhir tidak boleh sebelum bulan mulai';
export function endNotBeforeStart(rule: { startMonth?: string; endMonth?: string | null }) {
  return !rule.startMonth || !rule.endMonth || rule.endMonth >= rule.startMonth;
}

export const createRecurringBody = z
  .object({
    walletId,
    categoryId,
    type: txType,
    amount,
    note: note.optional(),
    dayOfMonth,
    startMonth: month,
    endMonth: month.nullable().optional(),
  })
  .refine(endNotBeforeStart, { message: END_BEFORE_START, path: ['endMonth'] });

export const updateRecurringBody = z
  .object({
    walletId: walletId.optional(),
    categoryId: categoryId.optional(),
    type: txType.optional(),
    amount: amount.optional(),
    note: note.nullable().optional(),
    dayOfMonth: dayOfMonth.optional(),
    startMonth: month.optional(),
    endMonth: month.nullable().optional(),
  })
  .refine(endNotBeforeStart, { message: END_BEFORE_START, path: ['endMonth'] });

export const recurringResponse = z.object({
  id: z.uuid(),
  type: txType,
  amount: z.number().int(),
  note: z.string().nullable(),
  dayOfMonth: z.number().int(),
  startMonth: z.string(),
  endMonth: z.string().nullable(),
  lastHandledMonth: z.string().nullable(),
  wallet: walletRef,
  category: categoryRef,
  next: z.object({ month: z.string(), dueDate: z.string() }).nullable(),
});

export const recurringListResponse = z.object({ items: z.array(recurringResponse) });

export const dueResponse = z.object({
  items: z.array(z.object({ recurring: recurringResponse, month: z.string(), dueDate: z.string() })),
});

export const skipBody = z.object({ month });

export const recordBody = z.object({
  month,
  amount: amount.optional(),
  occurredAt: occurredAt.optional(),
  walletId: walletId.optional(),
  note: note.nullable().optional(),
});
