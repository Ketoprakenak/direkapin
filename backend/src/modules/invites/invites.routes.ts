import type { FastifyInstance } from 'fastify';
import type { ZodTypeProvider } from 'fastify-type-provider-zod';
import type { Config } from '../../config.js';
import { inviteListResponse, inviteResponse } from './invites.schemas.js';
import { createInvite, listInvites } from './invites.service.js';

/** Kode undangan dari aplikasi, khusus owner (AUTH-07). */
export function inviteRoutes(app: FastifyInstance, config: Config) {
  app.register(async (scoped) => scopedInviteRoutes(scoped, config));
}

function scopedInviteRoutes(app: FastifyInstance, config: Config) {
  // Cloudflare Tunnel mengubah POST kosong dari app jadi body chunked tanpa Content-Type,
  // yang ditolak Fastify (415). Endpoint ini tanpa body, jadi isi apa pun dibuang.
  // Dibatasi ke modul ini supaya route lain tetap menolak format yang tidak didukung.
  app.addContentTypeParser('*', { parseAs: 'buffer' }, (_request, _body, done) =>
    done(null, undefined),
  );
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
