import { z } from 'zod';
import { activityResponse } from '../activities/activities.schemas.js';
import { walletResponse } from '../wallets/wallets.schemas.js';

export const seriesPoint = z.object({
  label: z.string(),
  income: z.number().int(),
  expense: z.number().int(),
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
    activities: z.array(activityResponse),
    hasEntry: z.boolean(),
  }),
  last7Days: z.array(seriesPoint),
  streak: z.object({ current: z.number().int(), longest: z.number().int() }),
});
