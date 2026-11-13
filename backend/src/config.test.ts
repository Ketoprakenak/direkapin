import { describe, expect, it } from 'vitest';
import { loadConfig } from './config.js';

describe('loadConfig', () => {
  it('menerima env lengkap', () => {
    expect(loadConfig(process.env).PORT).toBeGreaterThan(0);
  });

  it('gagal jika env kurang, tanpa membocorkan nilai', () => {
    const env = { ...process.env, JWT_SECRET: 'rahasia-pendek', DATABASE_URL: undefined };
    expect(() => loadConfig(env)).toThrow(/DATABASE_URL, JWT_SECRET/);
    expect(() => loadConfig(env)).not.toThrow(/rahasia-pendek/);
  });

  it('production wajib SMTP untuk email reset password (D-75)', () => {
    const env = { ...process.env, NODE_ENV: 'production', SMTP_HOST: undefined };
    expect(() => loadConfig(env)).toThrow(/SMTP_HOST/);
  });
});
