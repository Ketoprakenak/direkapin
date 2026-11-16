import type { FastifyInstance } from 'fastify';
import type { ZodTypeProvider } from 'fastify-type-provider-zod';
import { idParams } from '../../lib/schemas.js';
import {
  createReceivableBody,
  debtorParams,
  listReceivablesQuery,
  payBody,
  receivableListResponse,
  receivableResponse,
  updateDebtorBody,
  updateReceivableBody,
} from './receivables.schemas.js';
import {
  createReceivable,
  deleteReceivable,
  listReceivables,
  payDebtor,
  updateDebtor,
  updateReceivable,
} from './receivables.service.js';

export function receivableRoutes(app: FastifyInstance) {
  const routes = app.withTypeProvider<ZodTypeProvider>();
  const onRequest = [app.authenticate];

  routes.get(
    '/receivables',
    {
      onRequest,
      schema: { querystring: listReceivablesQuery, response: { 200: receivableListResponse } },
    },
    (request) =>
      listReceivables(
        app.prisma,
        request.userId,
        request.query.status,
        request.query.direction === 'payable' ? 'PAYABLE' : 'RECEIVABLE',
      ),
  );

  routes.post(
    '/receivables',
    { onRequest, schema: { body: createReceivableBody, response: { 201: receivableResponse } } },
    async (request, reply) =>
      reply.status(201).send(await createReceivable(app.prisma, request.userId, request.body)),
  );

  routes.patch(
    '/receivables/:id',
    {
      onRequest,
      schema: {
        params: idParams,
        body: updateReceivableBody,
        response: { 200: receivableResponse },
      },
    },
    (request) => updateReceivable(app.prisma, request.userId, request.params.id, request.body),
  );

  routes.delete(
    '/receivables/:id',
    { onRequest, schema: { params: idParams } },
    async (request, reply) => {
      await deleteReceivable(app.prisma, request.userId, request.params.id);
      return reply.status(204).send();
    },
  );

  routes.patch(
    '/receivables/debtors/:debtorId',
    {
      onRequest,
      schema: {
        params: debtorParams,
        body: updateDebtorBody,
        response: { 200: receivableResponse },
      },
    },
    (request) => updateDebtor(app.prisma, request.userId, request.params.debtorId, request.body),
  );

  routes.post(
    '/receivables/debtors/:debtorId/payments',
    {
      onRequest,
      schema: { params: debtorParams, body: payBody, response: { 201: receivableResponse } },
    },
    async (request, reply) =>
      reply
        .status(201)
        .send(await payDebtor(app.prisma, request.userId, request.params.debtorId, request.body)),
  );
}
