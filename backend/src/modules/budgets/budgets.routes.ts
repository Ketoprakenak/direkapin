import type { FastifyInstance } from 'fastify';
import type { ZodTypeProvider } from 'fastify-type-provider-zod';
import { idParams } from '../../lib/schemas.js';
import {
  budgetListResponse,
  budgetMonthQuery,
  budgetResponse,
  createBudgetBody,
  updateBudgetBody,
} from './budgets.schemas.js';
import { createBudget, deleteBudget, listBudgets, updateBudget } from './budgets.service.js';

export function budgetRoutes(app: FastifyInstance) {
  const routes = app.withTypeProvider<ZodTypeProvider>();
  const onRequest = [app.authenticate];

  routes.get(
    '/budgets',
    {
      onRequest,
      schema: {
        querystring: budgetMonthQuery,
        response: { 200: budgetListResponse },
      },
    },
    (request) => listBudgets(app.prisma, request.userId, request.query.month),
  );

  routes.post(
    '/budgets',
    {
      onRequest,
      schema: { body: createBudgetBody, response: { 201: budgetResponse } },
    },
    async (request, reply) =>
      reply.status(201).send(await createBudget(app.prisma, request.userId, request.body)),
  );

  routes.patch(
    '/budgets/:id',
    {
      onRequest,
      schema: {
        params: idParams,
        body: updateBudgetBody,
        response: { 200: budgetResponse },
      },
    },
    (request) => updateBudget(app.prisma, request.userId, request.params.id, request.body),
  );

  routes.delete(
    '/budgets/:id',
    { onRequest, schema: { params: idParams, querystring: budgetMonthQuery } },
    async (request, reply) => {
      await deleteBudget(app.prisma, request.userId, request.params.id, request.query.month);
      return reply.status(204).send();
    },
  );
}
