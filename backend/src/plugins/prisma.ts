import { PrismaClient } from '@prisma/client';
import type { FastifyInstance } from 'fastify';

declare module 'fastify' {
  interface FastifyInstance {
    prisma: PrismaClient;
  }
}

export function setupPrisma(app: FastifyInstance, databaseUrl: string) {
  const prisma = new PrismaClient({ datasources: { db: { url: databaseUrl } } });
  app.decorate('prisma', prisma);
  app.addHook('onClose', () => prisma.$disconnect());
}
