import type { FastifyInstance } from 'fastify';
import type { ZodTypeProvider } from 'fastify-type-provider-zod';
import type { Config } from '../../config.js';
import { releaseNotes } from './release-notes.js';
import { healthResponse, versionResponse } from './system.schemas.js';

export function systemRoutes(app: FastifyInstance, config: Config) {
  const routes = app.withTypeProvider<ZodTypeProvider>();

  routes.get('/health', { schema: { response: { 200: healthResponse } } }, () => ({
    status: 'ok' as const,
  }));

  routes.get('/version', { schema: { response: { 200: versionResponse } } }, () => ({
    latestVersion: config.LATEST_APK_VERSION,
    downloadUrl: config.LATEST_APK_URL,
    releaseNotes,
  }));
}
