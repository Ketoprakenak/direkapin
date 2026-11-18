import { randomBytes } from 'node:crypto';
import type { PrismaClient } from '@prisma/client';
import { AppError } from '../../lib/app-error.js';

const VALID_MS = 7 * 86_400_000;
const LIST_LIMIT = 20;

/** Owner = email sama dengan `OWNER_EMAIL`, tanpa beda huruf besar/kecil (AUTH-07, D-80). */
export function isOwner(email: string, ownerEmail?: string) {
  return !!ownerEmail && email.toLowerCase() === ownerEmail.toLowerCase();
}

/** Selain owner endpoint ini dianggap tidak ada (404, bukan 403). */
async function assertOwner(prisma: PrismaClient, userId: string, ownerEmail?: string) {
  const user = await prisma.user.findFirst({ where: { id: userId }, select: { email: true } });
  if (!user || !isOwner(user.email, ownerEmail)) {
    throw new AppError('NOT_FOUND', 404, 'Data tidak ditemukan');
  }
}

type InviteRow = {
  code: string;
  createdAt: Date;
  expiresAt: Date | null;
  usedAt: Date | null;
  usedBy: { name: string } | null;
};

function toInviteResponse(row: InviteRow) {
  return {
    code: row.code,
    createdAt: row.createdAt.toISOString(),
    // Kode buatan app selalu punya expiresAt; kode seed lama tidak tampil di daftar ini.
    expiresAt: (row.expiresAt ?? row.createdAt).toISOString(),
    usedAt: row.usedAt?.toISOString() ?? null,
    usedByName: row.usedBy?.name ?? null,
  };
}

const inviteSelect = {
  code: true,
  createdAt: true,
  expiresAt: true,
  usedAt: true,
  usedBy: { select: { name: true } },
} as const;

export async function listInvites(prisma: PrismaClient, userId: string, ownerEmail?: string) {
  await assertOwner(prisma, userId, ownerEmail);
  const rows = await prisma.inviteCode.findMany({
    where: { createdById: userId },
    select: inviteSelect,
    orderBy: { createdAt: 'desc' },
    take: LIST_LIMIT,
  });
  return { items: rows.map(toInviteResponse) };
}

export async function createInvite(
  prisma: PrismaClient,
  userId: string,
  ownerEmail?: string,
  now = new Date(),
) {
  await assertOwner(prisma, userId, ownerEmail);
  const row = await prisma.inviteCode.create({
    data: {
      code: randomBytes(8).toString('hex').toUpperCase(),
      createdById: userId,
      createdAt: now,
      expiresAt: new Date(now.getTime() + VALID_MS),
    },
    select: inviteSelect,
  });
  return toInviteResponse(row);
}
