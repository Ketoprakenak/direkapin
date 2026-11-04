import { Prisma } from '@prisma/client';
import { z } from 'zod';

export const idParams = z.object({ id: z.uuid() });

export const hexColor = z.string().regex(/^#[0-9A-Fa-f]{6}$/, 'Warna tidak valid');
export const iconName = z.string().min(1, 'Pilih ikon').max(40, 'Ikon tidak valid');
export const shortName = z
  .string({ error: 'Nama wajib diisi' })
  .trim()
  .min(1, 'Nama wajib diisi')
  .max(30, 'Nama maksimal 30 karakter');

const AMOUNT_ERROR = 'Nominal harus lebih dari 0';
export const amount = z
  .number({ error: AMOUNT_ERROR })
  .int(AMOUNT_ERROR)
  .min(1, AMOUNT_ERROR)
  .max(999_999_999, 'Nominal maksimal Rp999.999.999');

const ONE_YEAR_MS = 365 * 86_400_000;
export const occurredAt = z
  .iso.datetime({ offset: true, error: 'Tanggal tidak valid' })
  .transform((value) => new Date(value))
  .refine((date) => date.getTime() <= Date.now() + ONE_YEAR_MS, 'Tanggal terlalu jauh ke depan');

export const note = z.string().max(1000, 'Catatan terlalu panjang');

export const dateString = z.iso.date('Tanggal tidak valid');

export const pageQuery = {
  limit: z.coerce.number().int().min(1).max(100).default(50),
  cursor: z.uuid().optional(),
};

export const walletRef = z.object({
  id: z.uuid(),
  name: z.string(),
  icon: z.string(),
  color: z.string(),
});

export function isUniqueViolation(error: unknown) {
  return error instanceof Prisma.PrismaClientKnownRequestError && error.code === 'P2002';
}

/** Hasil `take: limit + 1`, dipotong jadi satu halaman plus `nextCursor`. */
export function toPage<T extends { id: string }>(rows: T[], limit: number) {
  const items = rows.slice(0, limit);
  return { items, nextCursor: rows.length > limit ? (items.at(-1)?.id ?? null) : null };
}
