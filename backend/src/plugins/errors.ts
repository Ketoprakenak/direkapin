import type { FastifyError, FastifyInstance, FastifyReply } from 'fastify';
import { hasZodFastifySchemaValidationErrors } from 'fastify-type-provider-zod';
import { AppError, type ErrorCode } from '../lib/app-error.js';

function send(
  reply: FastifyReply,
  status: number,
  code: ErrorCode,
  message: string,
  details?: Record<string, string>,
) {
  return reply.status(status).send({ error: { code, message, details } });
}

export function setupErrors(app: FastifyInstance) {
  app.setNotFoundHandler((_request, reply) =>
    send(reply, 404, 'NOT_FOUND', 'Data tidak ditemukan'),
  );

  app.setErrorHandler((error: FastifyError, request, reply) => {
    if (error instanceof AppError) {
      return send(reply, error.httpStatus, error.code, error.message, error.details);
    }
    if (hasZodFastifySchemaValidationErrors(error)) {
      const details: Record<string, string> = {};
      for (const issue of error.validation) {
        const field = issue.instancePath.replace(/^\//, '').replaceAll('/', '.');
        details[field || 'body'] ??= issue.message ?? 'Nilai tidak valid';
      }
      return send(reply, 400, 'VALIDATION_ERROR', 'Data belum valid', details);
    }
    if (error.statusCode === 413) {
      return send(reply, 413, 'FILE_TOO_LARGE', 'Ukuran data terlalu besar');
    }
    if (error.statusCode === 415) {
      return send(reply, 415, 'UNSUPPORTED_MEDIA', 'Format data tidak didukung');
    }
    if (error.statusCode === 429) {
      return send(reply, 429, 'RATE_LIMITED', 'Terlalu banyak percobaan. Coba lagi nanti.');
    }
    if (error.statusCode && error.statusCode >= 400 && error.statusCode < 500) {
      return send(reply, 400, 'VALIDATION_ERROR', 'Data belum valid');
    }

    request.log.error({ err: error }, 'unexpected error');
    return send(reply, 500, 'INTERNAL_ERROR', 'Terjadi kesalahan di server');
  });
}
