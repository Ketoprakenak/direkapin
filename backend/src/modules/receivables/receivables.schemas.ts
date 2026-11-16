import { z } from 'zod';
import { amount, clientId, dateString, note, occurredAt, shortName } from '../../lib/schemas.js';

const title = z
  .string({ error: 'Judul wajib diisi' })
  .trim()
  .min(1, 'Judul wajib diisi')
  .max(60, 'Judul maksimal 60 karakter');

const debtor = z.object({ name: shortName, amount });

export const listReceivablesQuery = z.object({
  status: z.enum(['open', 'all']).default('open'),
  direction: z.enum(['receivable', 'payable']).default('receivable'),
});

export const createReceivableBody = z
  .object({
    direction: z.enum(['RECEIVABLE', 'PAYABLE']).default('RECEIVABLE'),
    title,
    date: dateString,
    note: note.optional(),
    debtors: z.array(debtor).min(1, 'Tambah minimal 1 orang').max(20, 'Maksimal 20 orang'),
    loanWalletId: z.uuid('Pilih dompet').optional(),
    clientId: clientId.optional(),
    sourceTransactionId: z.uuid('Pilih pengeluaran').optional(),
  })
  .superRefine((body, ctx) => {
    if (body.direction === 'PAYABLE' && body.debtors.length > 1) {
      ctx.addIssue({ code: 'custom', path: ['debtors'], message: 'Utang hanya untuk 1 orang' });
    }
    if (body.direction === 'PAYABLE' && body.sourceTransactionId) {
      ctx.addIssue({
        code: 'custom',
        path: ['sourceTransactionId'],
        message: 'Hanya untuk piutang',
      });
    }
    if (body.direction === 'RECEIVABLE' && body.loanWalletId) {
      ctx.addIssue({
        code: 'custom',
        path: ['loanWalletId'],
        message: 'Hanya untuk utang pinjam tunai',
      });
    }
  });

export const updateReceivableBody = z.object({
  title: title.optional(),
  date: dateString.optional(),
  note: note.nullable().optional(),
});

export const debtorParams = z.object({ debtorId: z.uuid() });

export const updateDebtorBody = debtor.partial();

export const payBody = z.object({
  amount,
  walletId: z.uuid('Pilih dompet'),
  // Wajib untuk utang (cicilan = pengeluaran berkategori); diabaikan untuk piutang (D-78).
  categoryId: z.uuid('Pilih kategori').optional(),
  occurredAt,
  clientId: clientId.optional(),
});

const money = z.number().int();

const walletRef = z.object({
  id: z.uuid(),
  name: z.string(),
  icon: z.string(),
  color: z.string(),
});

export const receivableResponse = z.object({
  id: z.uuid(),
  direction: z.enum(['RECEIVABLE', 'PAYABLE']),
  title: z.string(),
  date: z.string(),
  note: z.string().nullable(),
  total: money,
  remaining: money,
  loan: z.object({ transactionId: z.uuid(), amount: money, wallet: walletRef }).nullable(),
  source: z.object({ transactionId: z.uuid(), amount: money, categoryName: z.string() }).nullable(),
  debtors: z.array(
    z.object({
      id: z.uuid(),
      name: z.string(),
      amount: money,
      paid: money,
      remaining: money,
      payments: z.array(
        z.object({
          transactionId: z.uuid(),
          amount: money,
          occurredAt: z.string(),
          wallet: walletRef,
        }),
      ),
    }),
  ),
});

export const receivableListResponse = z.object({
  items: z.array(receivableResponse),
  totalRemaining: money,
});
