import type { FastifyInstance } from 'fastify';
import type { ZodTypeProvider } from 'fastify-type-provider-zod';
import { idParams } from '../../lib/schemas.js';
import {
  createTransferBody,
  listTransfersQuery,
  transferListResponse,
  transferResponse,
  updateTransferBody,
} from './transfers.schemas.js';
import {
  createTransfer,
  deleteTransfer,
  listTransfers,
  updateTransfer,
} from './transfers.service.js';

export function transferRoutes(app: FastifyInstance) {
  const routes = app.withTypeProvider<ZodTypeProvider>();
  const onRequest = [app.authenticate];

  routes.get(
    '/transfers',
    {
      onRequest,
      schema: { querystring: listTransfersQuery, response: { 200: transferListResponse } },
    },
    (request) => listTransfers(app.prisma, request.userId, request.query),
  );

  routes.post(
    '/transfers',
    { onRequest, schema: { body: createTransferBody, response: { 201: transferResponse } } },
    async (request, reply) =>
      reply.status(201).send(await createTransfer(app.prisma, request.userId, request.body)),
  );

  routes.patch(
    '/transfers/:id',
    {
      onRequest,
      schema: { params: idParams, body: updateTransferBody, response: { 200: transferResponse } },
    },
    (request) => updateTransfer(app.prisma, request.userId, request.params.id, request.body),
  );

  routes.delete(
    '/transfers/:id',
    { onRequest, schema: { params: idParams } },
    async (request, reply) => {
      await deleteTransfer(app.prisma, request.userId, request.params.id);
      return reply.status(204).send();
    },
  );
}
