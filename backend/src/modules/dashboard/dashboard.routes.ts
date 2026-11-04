import type { FastifyInstance } from 'fastify';
import type { ZodTypeProvider } from 'fastify-type-provider-zod';
import { dashboardResponse } from './dashboard.schemas.js';
import { getDashboard } from './dashboard.service.js';

export function dashboardRoutes(app: FastifyInstance) {
  app.withTypeProvider<ZodTypeProvider>().get(
    '/dashboard',
    { onRequest: [app.authenticate], schema: { response: { 200: dashboardResponse } } },
    (request) => getDashboard(app.prisma, request.userId),
  );
}
