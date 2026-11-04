import { z } from 'zod';

const envSchema = z.object({
  DATABASE_URL: z.string().min(1),
  JWT_SECRET: z.string().min(32),
  JWT_REFRESH_SECRET: z.string().min(32),
  ACCESS_TOKEN_TTL: z.string().min(1),
  REFRESH_TOKEN_TTL_DAYS: z.coerce.number().int().positive(),
  PORT: z.coerce.number().int().positive(),
  NODE_ENV: z.enum(['development', 'test', 'production']),
  TZ: z.string().min(1),
  LOG_LEVEL: z.string().min(1),
  UPLOAD_DIR: z.string().min(1),
  ARCHIVE_DIR: z.string().min(1),
  BACKUP_DIR: z.string().min(1),
  MAX_UPLOAD_BYTES: z.coerce.number().int().positive(),
  LATEST_APK_VERSION: z.string().min(1),
  LATEST_APK_URL: z.url(),
});

export type Config = z.infer<typeof envSchema>;

export function loadConfig(env: NodeJS.ProcessEnv): Config {
  const result = envSchema.safeParse(env);
  if (!result.success) {
    // Hanya nama variabel: nilainya bisa berisi secret.
    const names = result.error.issues.map((issue) => issue.path.join('.')).join(', ');
    throw new Error(`Environment variable kurang atau tidak valid: ${names}`);
  }
  return result.data;
}
