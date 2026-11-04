import { z } from 'zod';

export const healthResponse = z.object({ status: z.literal('ok') });

export const versionResponse = z.object({
  latestVersion: z.string(),
  downloadUrl: z.url(),
});
