import { z } from 'zod';
import { shortName } from '../../lib/schemas.js';

const target = z
  .number({ error: 'Target harus bilangan bulat' })
  .int('Target harus bilangan bulat')
  .min(1, 'Target minimal Rp1')
  .max(999_999_999, 'Target terlalu besar');

export const createSavingsBody = z.object({
  name: shortName,
  targetAmount: target.optional(),
  initialAmount: z
    .number({ error: 'Setoran harus bilangan bulat' })
    .int('Setoran harus bilangan bulat')
    .min(0, 'Setoran tidak boleh negatif')
    .max(999_999_999, 'Setoran terlalu besar')
    .default(0),
  fromWalletId: z.uuid('Pilih dompet').optional(),
});

export const updateSavingsBody = z.object({
  targetAmount: target.nullable(),
});

export const deleteSavingsQuery = z.object({
  toWalletId: z.uuid('Pilih dompet untuk sisa saldo').optional(),
});
