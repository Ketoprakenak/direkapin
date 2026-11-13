import type { FastifyInstance } from 'fastify';
import type { ZodTypeProvider } from 'fastify-type-provider-zod';
import type { Config } from '../../config.js';
import { loginRateLimit } from '../../plugins/rate-limit.js';
import type { SendMail } from '../../lib/mailer.js';
import {
  authTokensResponse,
  forgotPasswordBody,
  loginBody,
  refreshTokenBody,
  registerBody,
  resetPasswordBody,
} from './auth.schemas.js';
import {
  forgotPassword,
  login,
  logout,
  refresh,
  register,
  resetPassword,
} from './auth.service.js';

export function authRoutes(app: FastifyInstance, config: Config, sendMail: SendMail) {
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

  routes.post(
    '/auth/forgot-password',
    { config: { rateLimit: loginRateLimit }, schema: { body: forgotPasswordBody } },
    async (request) => {
      await forgotPassword(app.prisma, sendMail, request.body.email, request.log);
      // Sama untuk email terdaftar atau tidak, supaya tidak bisa dipakai menebak akun.
      return { message: 'Kalau email itu terdaftar, kode reset sudah dikirim.' };
    },
  );

  routes.post(
    '/auth/reset-password',
    { config: { rateLimit: loginRateLimit }, schema: { body: resetPasswordBody } },
    async (request, reply) => {
      await resetPassword(app.prisma, request.body);
      return reply.status(204).send();
    },
  );

  routes.post('/auth/logout', { schema: { body: refreshTokenBody } }, async (request, reply) => {
    await logout(app.prisma, request.body.refreshToken);
    return reply.status(204).send();
  });
}
