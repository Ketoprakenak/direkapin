import type { FastifyInstance } from 'fastify';
import type { ZodTypeProvider } from 'fastify-type-provider-zod';
import { idParams } from '../../lib/schemas.js';
import {
  createWalletBody,
  listWalletsQuery,
  updateWalletBody,
  walletListResponse,
  walletResponse,
} from './wallets.schemas.js';
import { createWallet, deleteWallet, listWallets, updateWallet } from './wallets.service.js';

export function walletRoutes(app: FastifyInstance) {
  const routes = app.withTypeProvider<ZodTypeProvider>();
  const onRequest = [app.authenticate];

  routes.get(
    '/wallets',
    { onRequest, schema: { querystring: listWalletsQuery, response: { 200: walletListResponse } } },
    (request) => listWallets(app.prisma, request.userId, request.query.includeArchived),
  );

  routes.post(
    '/wallets',
    { onRequest, schema: { body: createWalletBody, response: { 201: walletResponse } } },
    async (request, reply) =>
      reply.status(201).send(await createWallet(app.prisma, request.userId, request.body)),
  );

  routes.patch(
    '/wallets/:id',
    {
      onRequest,
      schema: { params: idParams, body: updateWalletBody, response: { 200: walletResponse } },
    },
    (request) => updateWallet(app.prisma, request.userId, request.params.id, request.body),
  );

  routes.delete(
    '/wallets/:id',
    { onRequest, schema: { params: idParams } },
    async (request, reply) => {
      await deleteWallet(app.prisma, request.userId, request.params.id);
      return reply.status(204).send();
    },
  );
}
