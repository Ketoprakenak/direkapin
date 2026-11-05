import { fileURLToPath } from 'node:url';
import multipart from '@fastify/multipart';
import Fastify from 'fastify';
import { serializerCompiler, validatorCompiler } from 'fastify-type-provider-zod';
import { z } from 'zod';
import { loadConfig, type Config } from './config.js';
import { activityRoutes } from './modules/activities/activities.routes.js';
import { attachmentRoutes } from './modules/attachments/attachments.routes.js';
import { authRoutes } from './modules/auth/auth.routes.js';
import { calendarRoutes } from './modules/calendar/calendar.routes.js';
import { categoryRoutes } from './modules/categories/categories.routes.js';
import { dashboardRoutes } from './modules/dashboard/dashboard.routes.js';
import { meRoutes } from './modules/me/me.routes.js';
import { systemRoutes } from './modules/system/system.routes.js';
import { transactionRoutes } from './modules/transactions/transactions.routes.js';
import { transferRoutes } from './modules/transfers/transfers.routes.js';
import { walletRoutes } from './modules/wallets/wallets.routes.js';
import { setupAuth } from './plugins/auth.js';
import { setupErrors } from './plugins/errors.js';
import { setupPrisma } from './plugins/prisma.js';
import { setupRateLimit } from './plugins/rate-limit.js';

// Pesan error ke user wajib bahasa Indonesia, termasuk pesan bawaan zod.
z.config(z.locales.id());

export function buildApp(config: Config) {
  const app = Fastify({
    logger:
      config.NODE_ENV === 'test'
        ? false
        : {
            level: config.LOG_LEVEL,
            ...(config.NODE_ENV === 'development' && { transport: { target: 'pino-pretty' } }),
          },
  });

  app.setValidatorCompiler(validatorCompiler);
  app.setSerializerCompiler(serializerCompiler);
  setupErrors(app);
  setupPrisma(app, config.DATABASE_URL);
  setupAuth(app, config.JWT_SECRET);
  setupRateLimit(app);
  app.register(multipart, {
    limits: { fileSize: config.MAX_UPLOAD_BYTES, files: 1, fields: 2 },
  });

  app.register(
    async (api) => {
      systemRoutes(api, config);
      authRoutes(api, config);
      meRoutes(api);
      walletRoutes(api);
      transferRoutes(api);
      categoryRoutes(api);
      transactionRoutes(api, config);
      attachmentRoutes(api, config);
      activityRoutes(api, config);
      dashboardRoutes(api);
      calendarRoutes(api);
    },
    { prefix: '/api/v1' },
  );

  return app;
}

if (process.argv[1] === fileURLToPath(import.meta.url)) {
  const config = loadConfig(process.env);
  await buildApp(config).listen({ port: config.PORT, host: '0.0.0.0' });
}
