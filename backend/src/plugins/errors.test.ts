import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import type { ZodTypeProvider } from 'fastify-type-provider-zod';
import { z } from 'zod';
import { buildTestApp } from '../../test/helpers.js';
import { AppError } from '../lib/app-error.js';

const app = buildTestApp();

beforeAll(async () => {
  const routes = app.withTypeProvider<ZodTypeProvider>();
  routes.post(
    '/validate',
    { schema: { body: z.object({ amount: z.number({ error: 'Nominal harus lebih dari 0' }) }) } },
    () => ({}),
  );
  routes.post('/validate-default', { schema: { body: z.object({ name: z.string() }) } }, () => ({}));
  routes.get('/app-error', () => {
    throw new AppError('WALLET_IN_USE', 409, 'Dompet masih dipakai');
  });
  routes.get('/boom', () => {
    throw new Error('detail rahasia');
  });
  await app.ready();
});
afterAll(() => app.close());

describe('format error', () => {
  it('route tidak ada menjadi NOT_FOUND', async () => {
    const res = await app.inject({ url: '/tidak-ada' });
    expect(res.statusCode).toBe(404);
    expect(res.json()).toEqual({ error: { code: 'NOT_FOUND', message: 'Data tidak ditemukan' } });
  });

  it('validasi gagal menjadi VALIDATION_ERROR dengan details per field', async () => {
    const res = await app.inject({ method: 'POST', url: '/validate', payload: {} });
    expect(res.statusCode).toBe(400);
    expect(res.json()).toEqual({
      error: {
        code: 'VALIDATION_ERROR',
        message: 'Data belum valid',
        details: { amount: 'Nominal harus lebih dari 0' },
      },
    });
  });

  it('pesan bawaan zod berbahasa Indonesia', async () => {
    const res = await app.inject({ method: 'POST', url: '/validate-default', payload: {} });
    expect(res.statusCode).toBe(400);
    expect(res.json().error.details.name).toMatch(/tidak valid/i);
  });

  it('JSON rusak menjadi VALIDATION_ERROR', async () => {
    const res = await app.inject({
      method: 'POST',
      url: '/validate',
      headers: { 'content-type': 'application/json' },
      payload: '{rusak',
    });
    expect(res.statusCode).toBe(400);
    expect(res.json().error.code).toBe('VALIDATION_ERROR');
  });

  it('AppError memakai code dan status miliknya', async () => {
    const res = await app.inject({ url: '/app-error' });
    expect(res.statusCode).toBe(409);
    expect(res.json().error.code).toBe('WALLET_IN_USE');
  });

  it('error tak terduga menjadi INTERNAL_ERROR tanpa membocorkan detail', async () => {
    const res = await app.inject({ url: '/boom' });
    expect(res.statusCode).toBe(500);
    expect(res.json()).toEqual({
      error: { code: 'INTERNAL_ERROR', message: 'Terjadi kesalahan di server' },
    });
  });
});
