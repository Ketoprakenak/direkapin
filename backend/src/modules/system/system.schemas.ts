import { z } from 'zod';

export const healthResponse = z.object({ status: z.literal('ok') });

export const versionResponse = z.object({
  latestVersion: z.string(),
  downloadUrl: z.url(),
  releaseNotes: z.array(z.object({ version: z.string(), items: z.array(z.string()) })),
});
