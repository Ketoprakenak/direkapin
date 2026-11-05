import type { FastifyInstance } from 'fastify';
import type { ZodTypeProvider } from 'fastify-type-provider-zod';
import type { Config } from '../../config.js';
import { idParams } from '../../lib/schemas.js';
import {
  activityListResponse,
  activityResponse,
  createActivityBody,
  listActivitiesQuery,
  updateActivityBody,
} from './activities.schemas.js';
import {
  createActivity,
  deleteActivity,
  getActivity,
  listActivities,
  updateActivity,
} from './activities.service.js';

export function activityRoutes(app: FastifyInstance, config: Config) {
  const routes = app.withTypeProvider<ZodTypeProvider>();
  const onRequest = [app.authenticate];

  routes.get(
    '/activities',
    {
      onRequest,
      schema: { querystring: listActivitiesQuery, response: { 200: activityListResponse } },
    },
    (request) => listActivities(app.prisma, request.userId, request.query),
  );

  routes.post(
    '/activities',
    { onRequest, schema: { body: createActivityBody, response: { 201: activityResponse } } },
    async (request, reply) =>
      reply.status(201).send(await createActivity(app.prisma, request.userId, request.body)),
  );

  routes.get(
    '/activities/:id',
    { onRequest, schema: { params: idParams, response: { 200: activityResponse } } },
    (request) => getActivity(app.prisma, request.userId, request.params.id),
  );

  routes.patch(
    '/activities/:id',
    {
      onRequest,
      schema: { params: idParams, body: updateActivityBody, response: { 200: activityResponse } },
    },
    (request) => updateActivity(app.prisma, request.userId, request.params.id, request.body),
  );

  routes.delete(
    '/activities/:id',
    { onRequest, schema: { params: idParams } },
    async (request, reply) => {
      await deleteActivity(
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
