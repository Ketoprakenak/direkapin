import type { PrismaClient } from '@prisma/client';
import { loadConfig } from '../src/config.js';
import { buildApp } from '../src/server.js';

export function buildTestApp() {
  return buildApp(loadConfig(process.env));
}

export async function resetDb(prisma: PrismaClient) {
  const tables = await prisma.$queryRaw<{ tablename: string }[]>`
    SELECT tablename FROM pg_tables
    WHERE schemaname = 'public' AND tablename <> '_prisma_migrations'`;
  const names = tables.map((t) => `"${t.tablename}"`).join(', ');
  await prisma.$executeRawUnsafe(`TRUNCATE ${names} CASCADE`);
}
