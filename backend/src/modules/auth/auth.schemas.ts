import { z } from 'zod';
import { nameSchema, userResponse } from '../me/me.schemas.js';

const PASSWORD_ERROR = 'Password minimal 8 karakter dengan huruf dan angka';

const emailSchema = z.email({ error: 'Email tidak valid' }).toLowerCase();

export const registerBody = z.object({
  name: nameSchema,
  email: emailSchema,
  password: z
    .string({ error: PASSWORD_ERROR })
    .min(8, PASSWORD_ERROR)
    .regex(/[A-Za-z]/, PASSWORD_ERROR)
    .regex(/\d/, PASSWORD_ERROR),
  inviteCode: z.string({ error: 'Kode undangan tidak valid' }).trim(),
});

export const loginBody = z.object({
  email: emailSchema,
  password: z.string({ error: 'Password wajib diisi' }),
});

export const refreshTokenBody = z.object({
  refreshToken: z.string({ error: 'Refresh token wajib diisi' }),
});

export const authTokensResponse = z.object({
  accessToken: z.string(),
  refreshToken: z.string(),
  expiresIn: z.number().int(),
  user: userResponse,
});
