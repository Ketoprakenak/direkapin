import type { FastifyInstance, FastifyRequest } from 'fastify';
import jwt from 'jsonwebtoken';
import { AppError } from '../lib/app-error.js';

declare module 'fastify' {
  interface FastifyInstance {
    authenticate: (request: FastifyRequest) => Promise<void>;
  }
  interface FastifyRequest {
    userId: string;
  }
}

export function setupAuth(app: FastifyInstance, jwtSecret: string) {
  app.decorateRequest('userId', '');
  app.decorate('authenticate', async (request: FastifyRequest) => {
    const header = request.headers.authorization;
    try {
      if (!header?.startsWith('Bearer ')) throw new Error('no token');
      const { sub } = jwt.verify(header.slice(7), jwtSecret, { algorithms: ['HS256'] });
      if (typeof sub !== 'string') throw new Error('no subject');
      request.userId = sub;
    } catch {
      throw new AppError('UNAUTHORIZED', 401, 'Sesi berakhir. Silakan masuk lagi.');
    }
  });
}
