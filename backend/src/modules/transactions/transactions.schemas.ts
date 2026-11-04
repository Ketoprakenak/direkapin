import { z } from 'zod';
import {
  amount,
  dateString,
  note,
  occurredAt,
  pageQuery,
  walletRef,
} from '../../lib/schemas.js';
import { categoryRef, txType } from '../categories/categories.schemas.js';

export const listTransactionsQuery = z.object({
  from: dateString.optional(),
  to: dateString.optional(),
  wallet: z.uuid().optional(),
  category: z.uuid().optional(),
  type: txType.optional(),
  q: z.string().max(100).optional(),
  ...pageQuery,
});

export const createTransactionBody = z.object({
  walletId: z.uuid({ error: 'Pilih dompet' }),
  categoryId: z.uuid({ error: 'Pilih kategori' }),
  type: txType,
  amount,
  occurredAt,
  note: note.optional(),
});

export const updateTransactionBody = z.object({
  walletId: z.uuid({ error: 'Pilih dompet' }).optional(),
  categoryId: z.uuid({ error: 'Pilih kategori' }).optional(),
  type: txType.optional(),
  amount: amount.optional(),
  occurredAt: occurredAt.optional(),
  note: note.nullable().optional(),
});

export const transactionResponse = z.object({
  id: z.uuid(),
  type: txType,
  amount: z.number().int(),
  occurredAt: z.string(),
  note: z.string().nullable(),
  wallet: walletRef,
  category: categoryRef,
  // shortcut: selalu kosong sampai upload foto ada, isi skemanya di Slice 4.
  attachments: z.array(z.never()),
  createdAt: z.string(),
  updatedAt: z.string(),
});

export const transactionListResponse = z.object({
  items: z.array(transactionResponse),
  nextCursor: z.string().nullable(),
});
