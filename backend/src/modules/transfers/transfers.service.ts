import type { Prisma, PrismaClient } from '@prisma/client';
import type { z } from 'zod';
import { AppError } from '../../lib/app-error.js';
import { occurredAtFilter } from '../../lib/dates.js';
import { toBigInt, toNumber } from '../../lib/money.js';
import { toPage } from '../../lib/schemas.js';
import { getTimezone } from '../me/me.service.js';
import { assertActiveWallet } from '../wallets/wallets.service.js';
import {
  FEE_TOO_BIG_ERROR,
  SAME_WALLET_ERROR,
  type createTransferBody,
  type listTransfersQuery,
  type updateTransferBody,
} from './transfers.schemas.js';

export const transferInclude = {
  fromWallet: true,
  toWallet: true,
  feeTransaction: { select: { amount: true, walletId: true } },
} satisfies Prisma.TransferInclude;
type TransferRow = Prisma.TransferGetPayload<{ include: typeof transferInclude }>;
type FeePaidBy = 'FROM' | 'TO';
type Tx = Prisma.TransactionClient;

const FEE_CATEGORY = {
  name: 'Biaya Admin',
  type: 'EXPENSE',
  icon: 'account_balance_rounded',
  color: '#64748B',
} as const;

/** Siapa yang menanggung, dilihat dari dompet transaksi biayanya (D-56). */
function paidBy(transfer: Pick<TransferRow, 'toWalletId' | 'feeTransaction'>): FeePaidBy | null {
  const fee = transfer.feeTransaction;
  if (!fee) return null;
  return fee.walletId === transfer.toWalletId ? 'TO' : 'FROM';
}

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
    fee: transfer.feeTransaction ? toNumber(transfer.feeTransaction.amount) : 0,
    feePaidBy: paidBy(transfer),
  };
}

async function findOwned(prisma: PrismaClient, userId: string, id: string) {
  const transfer = await prisma.transfer.findFirst({ where: { id, userId }, include: transferInclude });
  if (!transfer) throw new AppError('NOT_FOUND', 404, 'Data tidak ditemukan');
  return transfer;
}

/** Buat, ubah, atau hapus transaksi biaya admin supaya sesuai transfernya. */
async function syncFee(
  tx: Tx,
  userId: string,
  transfer: { id: string; fromWalletId: string; toWalletId: string; occurredAt: Date; feeTransactionId: string | null },
  fee: number,
  feePaidBy: FeePaidBy,
) {
  const existingId = transfer.feeTransactionId;
  if (fee === 0) {
    // FK di transfer otomatis jadi null (onDelete: SetNull).
    if (existingId) await tx.transaction.delete({ where: { id: existingId } });
    return;
  }
  const data = {
    walletId: feePaidBy === 'FROM' ? transfer.fromWalletId : transfer.toWalletId,
    amount: toBigInt(fee),
    occurredAt: transfer.occurredAt,
  };
  if (existingId) {
    await tx.transaction.update({ where: { id: existingId }, data });
    return;
  }
  // shortcut: dicari dari nama; kalau user mengganti namanya, kategori baru dibuat lagi.
  const category = await tx.category.upsert({
    where: { userId_name_type: { userId, name: FEE_CATEGORY.name, type: FEE_CATEGORY.type } },
    update: {},
    create: { ...FEE_CATEGORY, userId, sortOrder: await tx.category.count({ where: { userId } }) },
  });
  const created = await tx.transaction.create({
    data: { ...data, userId, categoryId: category.id, type: 'EXPENSE', note: 'Biaya admin transfer' },
  });
  await tx.transfer.update({ where: { id: transfer.id }, data: { feeTransactionId: created.id } });
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
  const { fee = 0, feePaidBy = 'TO', ...fields } = input;
  const transfer = await prisma.$transaction(async (tx) => {
    const row = await tx.transfer.create({
      data: { ...fields, userId, amount: toBigInt(fields.amount) },
    });
    await syncFee(tx, userId, row, fee, feePaidBy);
    return tx.transfer.findUniqueOrThrow({ where: { id: row.id }, include: transferInclude });
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

  const { fee: feeInput, feePaidBy: paidByInput, ...fields } = input;
  const fee = feeInput ?? (existing.feeTransaction ? toNumber(existing.feeTransaction.amount) : 0);
  const feePaidBy = paidByInput ?? paidBy(existing) ?? 'TO';
  const amount = fields.amount ?? toNumber(existing.amount);
  if (feePaidBy === 'TO' && fee >= amount) {
    throw new AppError('VALIDATION_ERROR', 400, 'Data belum valid', { fee: FEE_TOO_BIG_ERROR });
  }

  const transfer = await prisma.$transaction(async (tx) => {
    const row = await tx.transfer.update({
      where: { id },
      data: {
        ...fields,
        ...(fields.amount !== undefined && { amount: toBigInt(fields.amount) }),
      },
    });
    await syncFee(tx, userId, row, fee, feePaidBy);
    return tx.transfer.findUniqueOrThrow({ where: { id }, include: transferInclude });
  });
  return toTransferResponse(transfer);
}

export async function deleteTransfer(prisma: PrismaClient, userId: string, id: string) {
  const existing = await findOwned(prisma, userId, id);
  await prisma.$transaction(async (tx) => {
    await tx.transfer.delete({ where: { id } });
    if (existing.feeTransactionId) {
      await tx.transaction.delete({ where: { id: existing.feeTransactionId } });
    }
  });
}
