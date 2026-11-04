import type { FastifyInstance } from 'fastify';
import type { ZodTypeProvider } from 'fastify-type-provider-zod';
import { idParams } from '../../lib/schemas.js';
import {
  categoryListResponse,
  categoryResponse,
  createCategoryBody,
  listCategoriesQuery,
  updateCategoryBody,
} from './categories.schemas.js';
import {
  createCategory,
  deleteCategory,
  listCategories,
  updateCategory,
} from './categories.service.js';

export function categoryRoutes(app: FastifyInstance) {
  const routes = app.withTypeProvider<ZodTypeProvider>();
  const onRequest = [app.authenticate];

  routes.get(
    '/categories',
    {
      onRequest,
      schema: { querystring: listCategoriesQuery, response: { 200: categoryListResponse } },
    },
    (request) => listCategories(app.prisma, request.userId, request.query),
  );

  routes.post(
    '/categories',
    { onRequest, schema: { body: createCategoryBody, response: { 201: categoryResponse } } },
    async (request, reply) =>
      reply.status(201).send(await createCategory(app.prisma, request.userId, request.body)),
  );

  routes.patch(
    '/categories/:id',
    {
      onRequest,
      schema: { params: idParams, body: updateCategoryBody, response: { 200: categoryResponse } },
    },
    (request) => updateCategory(app.prisma, request.userId, request.params.id, request.body),
  );

  routes.delete(
    '/categories/:id',
    { onRequest, schema: { params: idParams } },
    async (request, reply) => {
      await deleteCategory(app.prisma, request.userId, request.params.id);
      return reply.status(204).send();
    },
  );
}
