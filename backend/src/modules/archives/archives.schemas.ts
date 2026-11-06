import { z } from 'zod';

export const archiveResponse = z.object({
  id: z.uuid(),
  month: z.string(),
  sizeBytes: z.number().int(),
  photoCount: z.number().int(),
  status: z.enum(['READY', 'DOWNLOADED', 'EXPIRED', 'FAILED']),
  createdAt: z.string(),
  expiresAt: z.string(),
  downloadedAt: z.string().nullable(),
});

export const archiveListResponse = z.object({ items: z.array(archiveResponse) });
