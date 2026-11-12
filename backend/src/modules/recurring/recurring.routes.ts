import type { FastifyInstance } from 'fastify';
import type { ZodTypeProvider } from 'fastify-type-provider-zod';
import { idParams } from '../../lib/schemas.js';
import { transactionResponse } from '../transactions/transactions.schemas.js';
import {
  createRecurringBody,
  dueResponse,
  recordBody,
  recurringListResponse,
  recurringResponse,
  skipBody,
  updateRecurringBody,
} from './recurring.schemas.js';
import {
  createRecurring,
  deleteRecurring,
  listDue,
  listRecurring,
  recordRecurring,
  skipRecurring,
  updateRecurring,
} from './recurring.service.js';

export function recurringRoutes(app: FastifyInstance) {
  const routes = app.withTypeProvider<ZodTypeProvider>();
  const onRequest = [app.authenticate];

  routes.get(
    '/recurring',
    { onRequest, schema: { response: { 200: recurringListResponse } } },
    (request) => listRecurring(app.prisma, request.userId),
  );

  routes.get(
    '/recurring/due',
    { onRequest, schema: { response: { 200: dueResponse } } },
    (request) => listDue(app.prisma, request.userId),
  );

  routes.post(
    '/recurring/:id/record',
    {
      onRequest,
      schema: { params: idParams, body: recordBody, response: { 201: transactionResponse } },
    },
    async (request, reply) =>
      reply
        .status(201)
        .send(await recordRecurring(app.prisma, request.userId, request.params.id, request.body)),
  );

  routes.post(
    '/recurring/:id/skip',
    { onRequest, schema: { params: idParams, body: skipBody } },
    async (request, reply) => {
      await skipRecurring(app.prisma, request.userId, request.params.id, request.body.month);
      return reply.status(204).send();
    },
  );

  routes.post(
    '/recurring',
    { onRequest, schema: { body: createRecurringBody, response: { 201: recurringResponse } } },
    async (request, reply) =>
      reply.status(201).send(await createRecurring(app.prisma, request.userId, request.body)),
  );

  routes.patch(
    '/recurring/:id',
    {
      onRequest,
      schema: {
        params: idParams,
        body: updateRecurringBody,
        response: { 200: recurringResponse },
      },
    },
    (request) => updateRecurring(app.prisma, request.userId, request.params.id, request.body),
  );

  routes.delete(
    '/recurring/:id',
    { onRequest, schema: { params: idParams } },
    async (request, reply) => {
      await deleteRecurring(app.prisma, request.userId, request.params.id);
      return reply.status(204).send();
    },
  );
}
