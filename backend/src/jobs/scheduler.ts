import type { FastifyInstance } from 'fastify';
import cron from 'node-cron';
import type { Config } from '../config.js';
import { DISK_HIGH_PERCENT, readDiskUsage, runArchiveJob } from './archive.job.js';
import { runBackupJob } from './backup.job.js';

type UsageReader = () => Promise<number>;

/**
 * Satu kunci untuk job 02:00 dan cek per jam supaya tidak jalan bersamaan
 * (noOverlap node-cron hanya per task). Cek per jam meneruskan angka yang sudah
 * diukur ke job, jadi statfs tidak dibaca dua kali.
 */
export function archiveGate(run: (usage: UsageReader) => Promise<unknown>, readUsage: UsageReader) {
  let busy = false;
  const locked = async (usage: UsageReader) => {
    if (busy) return;
    busy = true;
    try {
      await run(usage);
    } finally {
      busy = false;
    }
  };
  return {
    daily: () => locked(readUsage),
    hourly: async () => {
      if (busy) return;
      const used = await readUsage();
      if (used > DISK_HIGH_PERCENT) await locked(() => Promise.resolve(used));
    },
  };
}

export function startScheduler(app: FastifyInstance, config: Config) {
  const options = { timezone: config.TZ, noOverlap: true };
  const guarded = (name: string, job: () => Promise<unknown>) => async () => {
    try {
      await job();
    } catch (err) {
      app.log.error({ err, job: name }, 'job terjadwal gagal');
    }
  };
  const gate = archiveGate(
    (usage) => runArchiveJob(app.prisma, config, app.log, new Date(), usage),
    () => readDiskUsage(config.UPLOAD_DIR, app.log),
  );
  const tasks = [
    cron.schedule('0 1 * * *', guarded('backup', () => runBackupJob(config, app.log)), options),
    cron.schedule('0 2 * * *', guarded('archive', gate.daily), options),
    cron.schedule('0 * * * *', guarded('archive-disk', gate.hourly), options),
  ];
  app.addHook('onClose', () => Promise.all(tasks.map((task) => task.stop())));
}
