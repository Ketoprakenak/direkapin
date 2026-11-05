import type { FastifyInstance } from 'fastify';
import type { ZodTypeProvider } from 'fastify-type-provider-zod';
import type { Config } from '../../config.js';
import { AppError } from '../../lib/app-error.js';
import { idParams } from '../../lib/schemas.js';
import { attachmentQuery, attachmentResponse, uploadFields } from './attachments.schemas.js';
import { createAttachment, deleteAttachment, readAttachment } from './attachments.service.js';

export function attachmentRoutes(app: FastifyInstance, config: Config) {
  const routes = app.withTypeProvider<ZodTypeProvider>();
  const onRequest = [app.authenticate];

  routes.post(
    '/attachments',
    { onRequest, schema: { response: { 201: attachmentResponse } } },
    async (request, reply) => {
      // Semua part dibaca dulu supaya urutan field dari client tidak berpengaruh.
      let data: Buffer | undefined;
      const values: Record<string, unknown> = {};
      for await (const part of request.parts()) {
        if (part.type === 'field') values[part.fieldname] = part.value;
        else if (part.fieldname === 'file') data = await part.toBuffer();
        else part.file.resume();
      }

      const fields = uploadFields.safeParse(values);
      if (!fields.success) {
        const message = fields.error.issues[0]?.message ?? 'Nilai tidak valid';
        throw new AppError('VALIDATION_ERROR', 400, 'Data belum valid', { body: message });
      }
      if (!data) {
        throw new AppError('VALIDATION_ERROR', 400, 'Data belum valid', { file: 'Pilih foto' });
      }

      const attachment = await createAttachment(
        app.prisma,
        request.userId,
        { data, ...fields.data },
        config.UPLOAD_DIR,
        request.log,
      );
      return reply.status(201).send(attachment);
    },
  );

  routes.get(
    '/attachments/:id',
    { onRequest, schema: { params: idParams, querystring: attachmentQuery } },
    async (request, reply) => {
      const { data, mimeType } = await readAttachment(
        app.prisma,
        request.userId,
        request.params.id,
        request.query.size,
        config.UPLOAD_DIR,
      );
      return reply.type(mimeType).send(data);
    },
  );

  routes.delete(
    '/attachments/:id',
    { onRequest, schema: { params: idParams } },
    async (request, reply) => {
      await deleteAttachment(
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
