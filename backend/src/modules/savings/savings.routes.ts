import type { FastifyInstance } from 'fastify';
import type { ZodTypeProvider } from 'fastify-type-provider-zod';
import { idParams } from '../../lib/schemas.js';
import { walletResponse } from '../wallets/wallets.schemas.js';
import { createSavingsBody, deleteSavingsQuery, updateSavingsBody } from './savings.schemas.js';
import { createSavings, deleteSavings, updateSavings } from './savings.service.js';

export function savingsRoutes(app: FastifyInstance) {
  const routes = app.withTypeProvider<ZodTypeProvider>();
  const onRequest = [app.authenticate];

  routes.post(
    '/savings',
    { onRequest, schema: { body: createSavingsBody, response: { 201: walletResponse } } },
    async (request, reply) =>
      reply.status(201).send(await createSavings(app.prisma, request.userId, request.body)),
  );

  routes.patch(
    '/savings/:id',
    {
      onRequest,
      schema: { params: idParams, body: updateSavingsBody, response: { 200: walletResponse } },
    },
    (request) => updateSavings(app.prisma, request.userId, request.params.id, request.body),
  );

  routes.delete(
    '/savings/:id',
    { onRequest, schema: { params: idParams, querystring: deleteSavingsQuery } },
    async (request, reply) => {
      await deleteSavings(app.prisma, request.userId, request.params.id, request.query.toWalletId);
      return reply.status(204).send();
    },
  );
}
