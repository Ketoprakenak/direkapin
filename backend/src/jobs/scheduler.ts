import type { FastifyInstance } from 'fastify';
import cron from 'node-cron';
import type { Config } from '../config.js';
import { runArchiveJob } from './archive.job.js';
import { runBackupJob } from './backup.job.js';

export function startScheduler(app: FastifyInstance, config: Config) {
  const options = { timezone: config.TZ, noOverlap: true };
  const guarded = (name: string, job: () => Promise<unknown>) => async () => {
    try {
      await job();
    } catch (err) {
      app.log.error({ err, job: name }, 'job terjadwal gagal');
    }
  };
  const tasks = [
    cron.schedule('0 1 * * *', guarded('backup', () => runBackupJob(config, app.log)), options),
    cron.schedule(
      '0 2 * * *',
      guarded('archive', () => runArchiveJob(app.prisma, config, app.log)),
      options,
    ),
  ];
  app.addHook('onClose', () => Promise.all(tasks.map((task) => task.stop())));
}
