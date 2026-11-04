import { z } from 'zod';
import { hexColor, iconName, shortName } from '../../lib/schemas.js';

const walletType = z.enum(['CASH', 'BANK', 'EWALLET'], { error: 'Jenis dompet tidak valid' });
const balance = z
  .number({ error: 'Saldo awal harus bilangan bulat' })
  .int('Saldo awal harus bilangan bulat')
  .min(-999_999_999, 'Saldo awal terlalu kecil')
  .max(999_999_999, 'Saldo awal terlalu besar');

export const listWalletsQuery = z.object({
  includeArchived: z.stringbool().default(false),
});

export const createWalletBody = z.object({
  name: shortName,
  type: walletType,
  initialBalance: balance.default(0),
  icon: iconName,
  color: hexColor,
  sortOrder: z.number().int().optional(),
});

export const updateWalletBody = z.object({
  name: shortName.optional(),
  type: walletType.optional(),
  initialBalance: balance.optional(),
  icon: iconName.optional(),
  color: hexColor.optional(),
  sortOrder: z.number().int().optional(),
  isArchived: z.boolean().optional(),
});

export const walletResponse = z.object({
  id: z.uuid(),
  name: z.string(),
  type: walletType,
  initialBalance: z.number().int(),
  balance: z.number().int(),
  icon: z.string(),
  color: z.string(),
  isArchived: z.boolean(),
  sortOrder: z.number().int(),
});

export const walletListResponse = z.object({
  items: z.array(walletResponse),
  totalBalance: z.number().int(),
});
