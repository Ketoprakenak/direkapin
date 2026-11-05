import type { Prisma, PrismaClient } from '@prisma/client';
import type { z } from 'zod';
import { AppError } from '../../lib/app-error.js';
import { occurredAtFilter } from '../../lib/dates.js';
import { toBigInt, toNumber } from '../../lib/money.js';
import { toPage } from '../../lib/schemas.js';
import { getTimezone } from '../me/me.service.js';
import { assertActiveWallet } from '../wallets/wallets.service.js';
import {
  SAME_WALLET_ERROR,
  type createTransferBody,
  type listTransfersQuery,
  type updateTransferBody,
} from './transfers.schemas.js';

export const transferInclude = { fromWallet: true, toWallet: true } satisfies Prisma.TransferInclude;
type TransferRow = Prisma.TransferGetPayload<{ include: typeof transferInclude }>;

function ref(wallet: TransferRow['fromWallet']) {
  return { id: wallet.id, name: wallet.name, icon: wallet.icon, color: wallet.color };
}

export function toTransferResponse(transfer: TransferRow) {
  return {
    id: transfer.id,
    fromWallet: ref(transfer.fromWallet),
    toWallet: ref(transfer.toWallet),
    amount: toNumber(transfer.amount),
    occurredAt: transfer.occurredAt.toISOString(),
    note: transfer.note,
  };
}

async function findOwned(prisma: PrismaClient, userId: string, id: string) {
  const transfer = await prisma.transfer.findFirst({ where: { id, userId } });
  if (!transfer) throw new AppError('NOT_FOUND', 404, 'Data tidak ditemukan');
  return transfer;
}

export async function listTransfers(
  prisma: PrismaClient,
  userId: string,
  query: z.infer<typeof listTransfersQuery>,
) {
  const timezone = await getTimezone(prisma, userId);
  const rows = await prisma.transfer.findMany({
    where: {
      userId,
      occurredAt: occurredAtFilter(query.from, query.to, timezone),
      ...(query.wallet && { OR: [{ fromWalletId: query.wallet }, { toWalletId: query.wallet }] }),
    },
    include: transferInclude,
    orderBy: [{ occurredAt: 'desc' }, { id: 'desc' }],
    take: query.limit + 1,
    ...(query.cursor && { cursor: { id: query.cursor }, skip: 1 }),
  });
  const page = toPage(rows, query.limit);
  return { items: page.items.map(toTransferResponse), nextCursor: page.nextCursor };
}

export async function createTransfer(
  prisma: PrismaClient,
  userId: string,
  input: z.infer<typeof createTransferBody>,
) {
  await assertActiveWallet(prisma, userId, input.fromWalletId, 'fromWalletId');
  await assertActiveWallet(prisma, userId, input.toWalletId, 'toWalletId');
  const transfer = await prisma.transfer.create({
    data: { ...input, userId, amount: toBigInt(input.amount) },
    include: transferInclude,
  });
  return toTransferResponse(transfer);
}

export async function updateTransfer(
  prisma: PrismaClient,
  userId: string,
  id: string,
  input: z.infer<typeof updateTransferBody>,
) {
  const existing = await findOwned(prisma, userId, id);
  const fromWalletId = input.fromWalletId ?? existing.fromWalletId;
  const toWalletId = input.toWalletId ?? existing.toWalletId;
  if (fromWalletId === toWalletId) {
    throw new AppError('VALIDATION_ERROR', 400, 'Data belum valid', {
      toWalletId: SAME_WALLET_ERROR,
    });
  }
  // Dompet lama boleh sudah diarsipkan; hanya dompet baru yang harus aktif (D-29).
  if (fromWalletId !== existing.fromWalletId) {
    await assertActiveWallet(prisma, userId, fromWalletId, 'fromWalletId');
  }
  if (toWalletId !== existing.toWalletId) {
    await assertActiveWallet(prisma, userId, toWalletId, 'toWalletId');
  }

  const transfer = await prisma.transfer.update({
    where: { id },
    data: {
      ...input,
      ...(input.amount !== undefined && { amount: toBigInt(input.amount) }),
    },
    include: transferInclude,
  });
  return toTransferResponse(transfer);
}

export async function deleteTransfer(prisma: PrismaClient, userId: string, id: string) {
  await findOwned(prisma, userId, id);
  await prisma.transfer.delete({ where: { id } });
}
