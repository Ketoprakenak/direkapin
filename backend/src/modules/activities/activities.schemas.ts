import { z } from 'zod';
import { attachmentResponse } from '../attachments/attachments.schemas.js';

export const activityResponse = z.object({
  id: z.uuid(),
  title: z.string(),
  date: z.string(),
  time: z.string().nullable(),
  location: z.string().nullable(),
  description: z.string().nullable(),
  isImportant: z.boolean(),
  attachments: z.array(attachmentResponse),
  createdAt: z.string(),
  updatedAt: z.string(),
});
