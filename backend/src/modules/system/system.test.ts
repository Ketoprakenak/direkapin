import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { buildTestApp } from '../../../test/helpers.js';

const app = buildTestApp();

beforeAll(() => app.ready());
afterAll(() => app.close());

describe('system', () => {
  it('GET /api/v1/health', async () => {
    const res = await app.inject({ url: '/api/v1/health' });
    expect(res.statusCode).toBe(200);
    expect(res.json()).toEqual({ status: 'ok' });
  });

  it('GET /api/v1/version', async () => {
    const res = await app.inject({ url: '/api/v1/version' });
    expect(res.statusCode).toBe(200);
    expect(res.json()).toEqual({
      latestVersion: process.env.LATEST_APK_VERSION,
      downloadUrl: process.env.LATEST_APK_URL,
    });
  });

  it('path tanpa prefix /api/v1 tidak ada', async () => {
    const res = await app.inject({ url: '/health' });
    expect(res.statusCode).toBe(404);
  });
});
