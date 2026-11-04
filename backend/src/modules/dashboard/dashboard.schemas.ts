import { z } from 'zod';
import { walletResponse } from '../wallets/wallets.schemas.js';

const seriesPoint = z.object({
  label: z.string(),
  income: z.number().int(),
  expense: z.number().int(),
});

const activity = z.object({
  id: z.uuid(),
  title: z.string(),
  date: z.string(),
  time: z.string().nullable(),
  location: z.string().nullable(),
  description: z.string().nullable(),
  isImportant: z.boolean(),
  // shortcut: selalu kosong sampai upload foto ada, isi skemanya di Slice 4.
  attachments: z.array(z.never()),
  createdAt: z.string(),
  updatedAt: z.string(),
});

export const dashboardResponse = z.object({
  totalBalance: z.number().int(),
  wallets: z.array(walletResponse),
  month: z.object({
    income: z.number().int(),
    expense: z.number().int(),
    net: z.number().int(),
  }),
  today: z.object({
    date: z.string(),
    expense: z.number().int(),
    activities: z.array(activity),
    hasEntry: z.boolean(),
  }),
  last7Days: z.array(seriesPoint),
  streak: z.object({ current: z.number().int(), longest: z.number().int() }),
});
