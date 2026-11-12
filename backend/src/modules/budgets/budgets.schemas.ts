import { z } from 'zod';
import { amount } from '../../lib/schemas.js';
import { calendarQuery } from '../calendar/calendar.schemas.js';
import { categoryRef } from '../categories/categories.schemas.js';

const month = calendarQuery.shape.month;

const budgetName = z
  .string({ error: 'Nama budget wajib diisi' })
  .trim()
  .min(1, 'Nama budget wajib diisi')
  .max(40, 'Nama budget maksimal 40 karakter');

const categoryIds = z
  .array(z.uuid('Kategori tidak valid'), {
    error: 'Pilih minimal satu kategori',
  })
  .min(1, 'Pilih minimal satu kategori')
  .max(20, 'Maksimal 20 kategori')
  .refine((ids) => new Set(ids).size === ids.length, 'Kategori tidak boleh dobel');

export const budgetMonthQuery = z.object({ month });

export const createBudgetBody = z.object({
  name: budgetName,
  limitAmount: amount,
  categoryIds,
  month,
});

export const updateBudgetBody = z.object({
  name: budgetName.optional(),
  limitAmount: amount.optional(),
  categoryIds: categoryIds.optional(),
  month,
});

export const budgetResponse = z.object({
  id: z.uuid(),
  name: z.string(),
  limitAmount: z.number().int(),
  startMonth: z.string(),
  endMonth: z.string().nullable(),
  categories: z.array(categoryRef),
  spent: z.number().int(),
});

export const budgetListResponse = z.object({ items: z.array(budgetResponse) });
