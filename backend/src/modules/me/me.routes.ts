import type { FastifyInstance } from 'fastify';
import type { ZodTypeProvider } from 'fastify-type-provider-zod';
import { updateMeBody, userResponse } from './me.schemas.js';
import { getMe, updateMe } from './me.service.js';

export function meRoutes(app: FastifyInstance) {
  const routes = app.withTypeProvider<ZodTypeProvider>();

  routes.get(
    '/me',
    { onRequest: [app.authenticate], schema: { response: { 200: userResponse } } },
    (request) => getMe(app.prisma, request.userId),
  );

  routes.patch(
    '/me',
    {
      onRequest: [app.authenticate],
      schema: { body: updateMeBody, response: { 200: userResponse } },
    },
    (request) => updateMe(app.prisma, request.userId, request.body),
  );
}
