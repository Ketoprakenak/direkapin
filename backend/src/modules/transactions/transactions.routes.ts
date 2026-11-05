import type { FastifyInstance } from 'fastify';
import type { ZodTypeProvider } from 'fastify-type-provider-zod';
import type { Config } from '../../config.js';
import { idParams } from '../../lib/schemas.js';
import {
  createTransactionBody,
  listTransactionsQuery,
  transactionListResponse,
  transactionResponse,
  updateTransactionBody,
} from './transactions.schemas.js';
import {
  createTransaction,
  deleteTransaction,
  getTransaction,
  listTransactions,
  updateTransaction,
} from './transactions.service.js';

export function transactionRoutes(app: FastifyInstance, config: Config) {
  const routes = app.withTypeProvider<ZodTypeProvider>();
  const onRequest = [app.authenticate];

  routes.get(
    '/transactions',
    {
      onRequest,
      schema: { querystring: listTransactionsQuery, response: { 200: transactionListResponse } },
    },
    (request) => listTransactions(app.prisma, request.userId, request.query),
  );

  routes.post(
    '/transactions',
    { onRequest, schema: { body: createTransactionBody, response: { 201: transactionResponse } } },
    async (request, reply) =>
      reply.status(201).send(await createTransaction(app.prisma, request.userId, request.body)),
  );

  routes.get(
    '/transactions/:id',
    { onRequest, schema: { params: idParams, response: { 200: transactionResponse } } },
    (request) => getTransaction(app.prisma, request.userId, request.params.id),
  );

  routes.patch(
    '/transactions/:id',
    {
      onRequest,
      schema: {
        params: idParams,
        body: updateTransactionBody,
        response: { 200: transactionResponse },
      },
    },
    (request) => updateTransaction(app.prisma, request.userId, request.params.id, request.body),
  );

  routes.delete(
    '/transactions/:id',
    { onRequest, schema: { params: idParams } },
    async (request, reply) => {
      await deleteTransaction(
        app.prisma,
        request.userId,
        request.params.id,
        config.UPLOAD_DIR,
        request.log,
      );
      return reply.status(204).send();
    },
  );
}
