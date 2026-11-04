import rateLimit from '@fastify/rate-limit';
import type { FastifyInstance, FastifyRequest } from 'fastify';
import { AppError } from '../lib/app-error.js';

export function setupRateLimit(app: FastifyInstance) {
  app.register(rateLimit, { global: false });
}

// Di balik tunnel semua koneksi datang dari cloudflared, jadi IP asli hanya ada di header ini.
// Aman dipercaya karena port API tidak dibuka ke mana pun selain tunnel (D-24).
function clientIp(request: FastifyRequest) {
  const header = request.headers['cf-connecting-ip'];
  return typeof header === 'string' ? header : request.ip;
}

export const loginRateLimit = {
  max: 10,
  timeWindow: '15 minutes',
  keyGenerator: clientIp,
  errorResponseBuilder: (_request: FastifyRequest, context: { ttl: number }) => {
    const minutes = Math.ceil(context.ttl / 60_000);
    return new AppError(
      'RATE_LIMITED',
      429,
      `Terlalu banyak percobaan. Coba lagi dalam ${minutes} menit.`,
    );
  },
};
