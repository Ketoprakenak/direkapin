import { execFile } from 'node:child_process';
import { mkdir, readdir, rename, rm } from 'node:fs/promises';
import { join } from 'node:path';
import { promisify } from 'node:util';
import type { FastifyBaseLogger } from 'fastify';
import type { Config } from '../config.js';
import { addDays, localDate } from '../lib/dates.js';

const KEEP_DAYS = 14;
const BACKUP_FILE = /^direkapin-(\d{4}-\d{2}-\d{2})\.dump$/;

/** Hanya file buatan job ini yang dihapus. Hari ini termasuk dalam [KEEP_DAYS]. */
export async function pruneBackups(dir: string, today: string, log: FastifyBaseLogger) {
  const oldest = addDays(today, 1 - KEEP_DAYS);
  for (const name of await readdir(dir)) {
    const date = BACKUP_FILE.exec(name)?.[1];
    if (date && date < oldest) {
      await rm(join(dir, name), { force: true }).catch((err: unknown) =>
        log.error({ err, name }, 'gagal menghapus backup lama'),
      );
    }
  }
}

export async function runBackupJob(
  config: Pick<Config, 'DATABASE_URL' | 'BACKUP_DIR' | 'TZ'>,
  log: FastifyBaseLogger,
  now = new Date(),
) {
  const today = localDate(now, config.TZ);
  const path = join(config.BACKUP_DIR, `direkapin-${today}.dump`);
  const temp = `${path}.tmp`;
  const url = new URL(config.DATABASE_URL);
  await mkdir(config.BACKUP_DIR, { recursive: true });
  try {
    // Lewat env, karena argumen perintah terlihat di daftar proses.
    await promisify(execFile)('pg_dump', ['--format=custom', '--file', temp], {
      env: {
        ...process.env,
        PGHOST: url.hostname,
        PGPORT: url.port || '5432',
        PGUSER: decodeURIComponent(url.username),
        PGPASSWORD: decodeURIComponent(url.password),
        PGDATABASE: url.pathname.slice(1),
      },
    });
    await rename(temp, path);
  } catch (error) {
    await rm(temp, { force: true }).catch(() => undefined);
    throw error;
  }
  await pruneBackups(config.BACKUP_DIR, today, log);
  log.info({ path }, 'backup database selesai');
  return path;
}
