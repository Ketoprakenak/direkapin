import { execSync } from 'node:child_process';
import { PrismaClient } from '@prisma/client';

// Selalu mulai dari database kosong, sekaligus membuktikan migrasi jalan dari nol.
export default async function setup() {
  const testUrl = process.env.TEST_DATABASE_URL;
  if (!testUrl) throw new Error('TEST_DATABASE_URL belum diisi');

  const adminUrl = new URL(testUrl);
  adminUrl.pathname = '/postgres';
  const admin = new PrismaClient({ datasources: { db: { url: adminUrl.href } } });
  await admin.$executeRawUnsafe('DROP DATABASE IF EXISTS direkapin_test WITH (FORCE)');
  await admin.$executeRawUnsafe('CREATE DATABASE direkapin_test');
  await admin.$disconnect();

  execSync('npx prisma migrate deploy', {
    env: { ...process.env, DATABASE_URL: testUrl },
    stdio: 'pipe',
  });
}
