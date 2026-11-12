import type { Prisma, PrismaClient } from '@prisma/client';
import type { FastifyBaseLogger } from 'fastify';
import type { z } from 'zod';
import { AppError } from '../../lib/app-error.js';
import { occurredAtFilter } from '../../lib/dates.js';
import { toBigInt, toNumber } from '../../lib/money.js';
import { createOnce, toPage } from '../../lib/schemas.js';
import { removeUploads } from '../../lib/storage.js';
import {
  attachmentFiles,
  attachmentsInclude,
  toAttachmentResponse,
} from '../attachments/attachments.service.js';
import { assertCategory } from '../categories/categories.service.js';
import { getTimezone } from '../me/me.service.js';
import { assertActiveWallet } from '../wallets/wallets.service.js';
import type {
  createTransactionBody,
  listTransactionsQuery,
  updateTransactionBody,
} from './transactions.schemas.js';

export const transactionInclude = {
  wallet: true,
  category: true,
  attachments: attachmentsInclude,
} satisfies Prisma.TransactionInclude;
type TransactionRow = Prisma.TransactionGetPayload<{ include: typeof transactionInclude }>;

export function toTransactionResponse(row: TransactionRow) {
  return {
    id: row.id,
    type: row.type,
    amount: toNumber(row.amount),
    occurredAt: row.occurredAt.toISOString(),
    note: row.note,
    wallet: {
      id: row.wallet.id,
      name: row.wallet.name,
      icon: row.wallet.icon,
      color: row.wallet.color,
    },
    category: {
      id: row.category.id,
      name: row.category.name,
      icon: row.category.icon,
      color: row.category.color,
    },
    attachments: row.attachments.map(toAttachmentResponse),
    createdAt: row.createdAt.toISOString(),
    updatedAt: row.updatedAt.toISOString(),
  };
}

async function findOwned(prisma: PrismaClient, userId: string, id: string) {
  const row = await prisma.transaction.findFirst({ where: { id, userId }, include: transactionInclude });
  if (!row) throw new AppError('NOT_FOUND', 404, 'Data tidak ditemukan');
  return row;
}

export async function listTransactions(
  prisma: PrismaClient,
  userId: string,
  query: z.infer<typeof listTransactionsQuery>,
) {
  const timezone = await getTimezone(prisma, userId);
  const rows = await prisma.transaction.findMany({
    where: {
      userId,
      occurredAt: occurredAtFilter(query.from, query.to, timezone),
      ...(query.wallet && { walletId: query.wallet }),
      ...(query.category && { categoryId: query.category }),
      ...(query.type && { type: query.type }),
      ...(query.q && { note: { contains: query.q, mode: 'insensitive' as const } }),
    },
    include: transactionInclude,
    orderBy: [{ occurredAt: 'desc' }, { id: 'desc' }],
    take: query.limit + 1,
    ...(query.cursor && { cursor: { id: query.cursor }, skip: 1 }),
  });
  const page = toPage(rows, query.limit);
  return { items: page.items.map(toTransactionResponse), nextCursor: page.nextCursor };
}

export async function getTransaction(prisma: PrismaClient, userId: string, id: string) {
  return toTransactionResponse(await findOwned(prisma, userId, id));
}

export async function createTransaction(
  prisma: PrismaClient,
  userId: string,
  input: z.infer<typeof createTransactionBody>,
) {
  await assertActiveWallet(prisma, userId, input.walletId, 'walletId');
  await assertCategory(prisma, userId, input.categoryId, input.type);
  const row = await createOnce(
    input.clientId,
    () =>
      prisma.transaction.findFirst({
        where: { userId, clientId: input.clientId },
        include: transactionInclude,
      }),
    () =>
      prisma.transaction.create({
        data: { ...input, userId, amount: toBigInt(input.amount) },
        include: transactionInclude,
      }),
  );
  return toTransactionResponse(row);
}

export async function updateTransaction(
  prisma: PrismaClient,
  userId: string,
  id: string,
  input: z.infer<typeof updateTransactionBody>,
) {
  const existing = await findOwned(prisma, userId, id);
  // Dompet lama boleh sudah diarsipkan; hanya dompet baru yang harus aktif (D-29).
  if (input.walletId && input.walletId !== existing.walletId) {
    await assertActiveWallet(prisma, userId, input.walletId, 'walletId');
  }
  const type = input.type ?? existing.type;
  const categoryId = input.categoryId ?? existing.categoryId;
  if (type !== existing.type || categoryId !== existing.categoryId) {
    await assertCategory(prisma, userId, categoryId, type);
  }

  const row = await prisma.transaction.update({
    where: { id },
    data: {
      ...input,
      ...(input.amount !== undefined && { amount: toBigInt(input.amount) }),
    },
    include: transactionInclude,
  });
  return toTransactionResponse(row);
}

export async function deleteTransaction(
  prisma: PrismaClient,
  userId: string,
  id: string,
  uploadDir: string,
  log: FastifyBaseLogger,
) {
  const row = await findOwned(prisma, userId, id);
  await prisma.transaction.delete({ where: { id } });
  await removeUploads(uploadDir, row.attachments.flatMap(attachmentFiles), log);
}
