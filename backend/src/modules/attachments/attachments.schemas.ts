import { z } from 'zod';

export const uploadFields = z
  .object({
    transactionId: z.uuid().optional(),
    activityId: z.uuid().optional(),
  })
  .refine((fields) => !fields.transactionId !== !fields.activityId, {
    error: 'Isi tepat satu dari transactionId atau activityId',
  });

export const attachmentQuery = z.object({
  size: z.enum(['thumb', 'full']).default('full'),
});

export const attachmentResponse = z.object({
  id: z.uuid(),
  thumbUrl: z.string(),
  fullUrl: z.string().nullable(),
  isArchived: z.boolean(),
  archiveMonth: z.string().nullable(),
  width: z.number().int(),
  height: z.number().int(),
  sizeBytes: z.number().int(),
  createdAt: z.string(),
});
