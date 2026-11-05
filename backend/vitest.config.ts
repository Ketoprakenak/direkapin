import { existsSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { defineConfig } from 'vitest/config';

if (existsSync('.env')) process.loadEnvFile('.env');

const testUrl = new URL(process.env.DATABASE_URL ?? '');
// Database test di-drop setiap kali test jalan, jadi jangan pernah keluar dari laptop (D-19).
if (!['localhost', '127.0.0.1'].includes(testUrl.hostname)) {
  throw new Error('Test hanya boleh memakai PostgreSQL lokal');
}
testUrl.pathname = '/direkapin_test';
process.env.TEST_DATABASE_URL = testUrl.href;

export default defineConfig({
  test: {
    env: {
      DATABASE_URL: testUrl.href,
      NODE_ENV: 'test',
      UPLOAD_DIR: join(tmpdir(), 'direkapin-test-uploads'),
    },
    globalSetup: './test/global-setup.ts',
    include: ['src/**/*.test.ts', 'test/**/*.test.ts'],
    fileParallelism: false,
    // bcrypt sengaja lambat, dan satu test bisa memanggilnya berkali-kali.
    testTimeout: 30_000,
  },
});
