import { z } from 'zod';
import {
  amount,
  dateString,
  note,
  occurredAt,
  pageQuery,
  walletRef,
} from '../../lib/schemas.js';

const SAME_WALLET_ERROR = 'Dompet asal dan tujuan harus berbeda';
const FEE_TOO_BIG_ERROR = 'Biaya admin harus lebih kecil dari nominal transfer';

const fee = z
  .number({ error: 'Biaya admin tidak valid' })
  .int('Biaya admin tidak valid')
  .min(0, 'Biaya admin tidak boleh negatif')
  .max(999_999_999, 'Nominal maksimal Rp999.999.999');
const feePaidBy = z.enum(['FROM', 'TO'], { error: 'Pilih dompet yang dipotong' });

export const listTransfersQuery = z.object({
  from: dateString.optional(),
  to: dateString.optional(),
  wallet: z.uuid().optional(),
  ...pageQuery,
});

export const createTransferBody = z
  .object({
    fromWalletId: z.uuid({ error: 'Pilih dompet' }),
    toWalletId: z.uuid({ error: 'Pilih dompet' }),
    amount,
    occurredAt,
    note: note.optional(),
    fee: fee.optional(),
    feePaidBy: feePaidBy.optional(),
  })
  .refine((body) => body.fromWalletId !== body.toWalletId, {
    path: ['toWalletId'],
    error: SAME_WALLET_ERROR,
  })
  // Dipotong dari tujuan: yang diterima harus tetap lebih dari 0.
  .refine((body) => body.feePaidBy === 'FROM' || (body.fee ?? 0) < body.amount, {
    path: ['fee'],
    error: FEE_TOO_BIG_ERROR,
  });

export const updateTransferBody = z.object({
  fromWalletId: z.uuid({ error: 'Pilih dompet' }).optional(),
  toWalletId: z.uuid({ error: 'Pilih dompet' }).optional(),
  amount: amount.optional(),
  occurredAt: occurredAt.optional(),
  note: note.nullable().optional(),
  fee: fee.optional(),
  feePaidBy: feePaidBy.optional(),
});

export const transferResponse = z.object({
  id: z.uuid(),
  fromWallet: walletRef,
  toWallet: walletRef,
  amount: z.number().int(),
  occurredAt: z.string(),
  note: z.string().nullable(),
  fee: z.number().int(),
  feePaidBy: feePaidBy.nullable(),
});

export const transferListResponse = z.object({
  items: z.array(transferResponse),
  nextCursor: z.string().nullable(),
});

export { FEE_TOO_BIG_ERROR, SAME_WALLET_ERROR };
