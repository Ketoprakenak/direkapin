// Pemicu manual, mis. untuk checklist rilis: `node dist/src/jobs/run.js archive|backup`.
import { loadConfig } from '../config.js';
import { buildApp } from '../server.js';
import { runArchiveJob } from './archive.job.js';
import { runBackupJob } from './backup.job.js';

const name = process.argv[2];
if (name !== 'archive' && name !== 'backup') {
  throw new Error('Pakai salah satu: archive, backup');
}

const config = loadConfig(process.env);
const app = buildApp(config);
await app.ready();
try {
  if (name === 'archive') await runArchiveJob(app.prisma, config, app.log);
  else await runBackupJob(config, app.log);
} finally {
  await app.close();
}
