import { createReadStream } from 'node:fs';
import type { FastifyInstance } from 'fastify';
import type { ZodTypeProvider } from 'fastify-type-provider-zod';
import type { Config } from '../../config.js';
import { idParams } from '../../lib/schemas.js';
import { archiveListResponse } from './archives.schemas.js';
import { findDownload, listArchives, markDownloaded } from './archives.service.js';

export function archiveRoutes(app: FastifyInstance, config: Config) {
  const routes = app.withTypeProvider<ZodTypeProvider>();
  const onRequest = [app.authenticate];

  routes.get(
    '/archives',
    { onRequest, schema: { response: { 200: archiveListResponse } } },
    (request) => listArchives(app.prisma, request.userId),
  );

  routes.get(
    '/archives/:id/download',
    // HEAD otomatis juga memicu 'finish' tanpa mengirim isi, jadi foto asli bisa terhapus.
    { onRequest, exposeHeadRoute: false, schema: { params: idParams } },
    async (request, reply) => {
      const { id } = request.params;
      const { path, size, month } = await findDownload(
        app.prisma,
        request.userId,
        id,
        config.ARCHIVE_DIR,
      );
      // 'finish' tidak terpicu kalau koneksi putus di tengah (D-22).
      reply.raw.once('finish', () => {
        markDownloaded(app.prisma, request.userId, id, config.UPLOAD_DIR, request.log).catch(
          (err: unknown) => request.log.error({ err, id }, 'gagal menandai arsip ter-download'),
        );
      });
      return reply
        .type('application/zip')
        .header('content-length', size)
        .header('content-disposition', `attachment; filename="direkapin-arsip-${month}.zip"`)
        .send(createReadStream(path));
    },
  );
}
