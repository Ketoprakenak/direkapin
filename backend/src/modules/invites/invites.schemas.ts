import { z } from 'zod';

export const inviteResponse = z.object({
  code: z.string(),
  createdAt: z.string(),
  expiresAt: z.string(),
  usedAt: z.string().nullable(),
  usedByName: z.string().nullable(),
});

export const inviteListResponse = z.object({ items: z.array(inviteResponse) });
