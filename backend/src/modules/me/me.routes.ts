import type { FastifyInstance } from 'fastify';
import type { ZodTypeProvider } from 'fastify-type-provider-zod';
import type { Config } from '../../config.js';
import { AppError } from '../../lib/app-error.js';
import { updateMeBody, userResponse } from './me.schemas.js';
import { deleteAvatar, getMe, readAvatar, setAvatar, updateMe } from './me.service.js';

export function meRoutes(app: FastifyInstance, config: Config) {
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

  routes.put(
    '/me/avatar',
    {
      onRequest: [app.authenticate],
      schema: { response: { 200: userResponse } },
    },
    async (request) => {
      let data: Buffer | undefined;
      for await (const part of request.parts()) {
        if (part.type === 'file' && part.fieldname === 'file') data = await part.toBuffer();
        else if (part.type === 'file') part.file.resume();
      }
      if (!data) {
        throw new AppError('VALIDATION_ERROR', 400, 'Data belum valid', {
          file: 'Pilih foto',
        });
      }
      return setAvatar(app.prisma, request.userId, data, config.UPLOAD_DIR, request.log);
    },
  );

  routes.get('/me/avatar', { onRequest: [app.authenticate] }, async (request, reply) =>
    reply.type('image/jpeg').send(await readAvatar(app.prisma, request.userId, config.UPLOAD_DIR)),
  );

  routes.delete('/me/avatar', { onRequest: [app.authenticate] }, async (request, reply) => {
    await deleteAvatar(app.prisma, request.userId, config.UPLOAD_DIR, request.log);
    return reply.status(204).send();
  });
}
