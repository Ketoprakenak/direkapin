import type { FastifyInstance } from 'fastify';
import type { ZodTypeProvider } from 'fastify-type-provider-zod';
import type { Config } from '../../config.js';
import { loginRateLimit } from '../../plugins/rate-limit.js';
import { authTokensResponse, loginBody, refreshTokenBody, registerBody } from './auth.schemas.js';
import { login, logout, refresh, register } from './auth.service.js';

export function authRoutes(app: FastifyInstance, config: Config) {
  const routes = app.withTypeProvider<ZodTypeProvider>();

  routes.post(
    '/auth/register',
    { schema: { body: registerBody, response: { 201: authTokensResponse } } },
    async (request, reply) => {
      const tokens = await register(app.prisma, config, request.body);
      return reply.status(201).send(tokens);
    },
  );

  routes.post(
    '/auth/login',
    {
      config: { rateLimit: loginRateLimit },
      schema: { body: loginBody, response: { 200: authTokensResponse } },
    },
    (request) => login(app.prisma, config, request.body),
  );

  routes.post(
    '/auth/refresh',
    { schema: { body: refreshTokenBody, response: { 200: authTokensResponse } } },
    (request) => refresh(app.prisma, config, request.body.refreshToken),
  );

  routes.post('/auth/logout', { schema: { body: refreshTokenBody } }, async (request, reply) => {
    await logout(app.prisma, request.body.refreshToken);
    return reply.status(204).send();
  });
}
