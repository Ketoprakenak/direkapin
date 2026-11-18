import type { FastifyInstance } from 'fastify';
import type { ZodTypeProvider } from 'fastify-type-provider-zod';
import type { Config } from '../../config.js';
import { inviteListResponse, inviteResponse } from './invites.schemas.js';
import { createInvite, listInvites } from './invites.service.js';

/** Kode undangan dari aplikasi, khusus owner (AUTH-07). */
export function inviteRoutes(app: FastifyInstance, config: Config) {
  const routes = app.withTypeProvider<ZodTypeProvider>();
  const onRequest = [app.authenticate];

  routes.get(
    '/invites',
    { onRequest, schema: { response: { 200: inviteListResponse } } },
    (request) => listInvites(app.prisma, request.userId, config.OWNER_EMAIL),
  );

  routes.post(
    '/invites',
    { onRequest, schema: { response: { 201: inviteResponse } } },
    async (request, reply) =>
      reply.status(201).send(await createInvite(app.prisma, request.userId, config.OWNER_EMAIL)),
  );
}
