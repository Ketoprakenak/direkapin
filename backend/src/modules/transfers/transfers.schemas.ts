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
  })
  .refine((body) => body.fromWalletId !== body.toWalletId, {
    path: ['toWalletId'],
    error: SAME_WALLET_ERROR,
  });

export const updateTransferBody = z.object({
  fromWalletId: z.uuid({ error: 'Pilih dompet' }).optional(),
  toWalletId: z.uuid({ error: 'Pilih dompet' }).optional(),
  amount: amount.optional(),
  occurredAt: occurredAt.optional(),
  note: note.nullable().optional(),
});

export const transferResponse = z.object({
  id: z.uuid(),
  fromWallet: walletRef,
  toWallet: walletRef,
  amount: z.number().int(),
  occurredAt: z.string(),
  note: z.string().nullable(),
});

export const transferListResponse = z.object({
  items: z.array(transferResponse),
  nextCursor: z.string().nullable(),
});

export { SAME_WALLET_ERROR };
