import { Prisma, type PrismaClient, type Wallet } from '@prisma/client';
import type { z } from 'zod';
import { AppError } from '../../lib/app-error.js';
import { toBigInt, toNumber } from '../../lib/money.js';
import { isUniqueViolation } from '../../lib/schemas.js';
import type { createWalletBody, updateWalletBody } from './wallets.schemas.js';

function nameTaken() {
  return new AppError('NAME_TAKEN', 409, 'Nama sudah dipakai');
}

async function findOwned(prisma: PrismaClient, userId: string, id: string) {
  const wallet = await prisma.wallet.findFirst({ where: { id, userId } });
  if (!wallet) throw new AppError('NOT_FOUND', 404, 'Data tidak ditemukan');
  return wallet;
}

/** Pergerakan saldo per dompet: pemasukan − pengeluaran ± transfer. */
async function movements(prisma: PrismaClient, userId: string) {
  const [transactions, sent, received] = await Promise.all([
    prisma.transaction.groupBy({
      by: ['walletId', 'type'],
      where: { userId },
      _sum: { amount: true },
    }),
    prisma.transfer.groupBy({
      by: ['fromWalletId'],
      where: { userId },
      _sum: { amount: true },
    }),
    prisma.transfer.groupBy({
      by: ['toWalletId'],
      where: { userId },
      _sum: { amount: true },
    }),
  ]);

  const result = new Map<string, bigint>();
  const add = (walletId: string, value: bigint) =>
    result.set(walletId, (result.get(walletId) ?? 0n) + value);

  for (const row of transactions) {
    const value = row._sum.amount ?? 0n;
    add(row.walletId, row.type === 'INCOME' ? value : -value);
  }
  for (const row of sent) add(row.fromWalletId, -(row._sum.amount ?? 0n));
  for (const row of received) add(row.toWalletId, row._sum.amount ?? 0n);
  return result;
}

function toResponse(wallet: Wallet, balance: bigint) {
  return {
    id: wallet.id,
    name: wallet.name,
    type: wallet.type,
    initialBalance: toNumber(wallet.initialBalance),
    balance: toNumber(balance),
    icon: wallet.icon,
    color: wallet.color,
    isArchived: wallet.isArchived,
    sortOrder: wallet.sortOrder,
  };
}

async function withBalance(prisma: PrismaClient, userId: string, wallet: Wallet) {
  const moved = (await movements(prisma, userId)).get(wallet.id) ?? 0n;
  return toResponse(wallet, wallet.initialBalance + moved);
}

export async function listWallets(
  prisma: PrismaClient,
  userId: string,
  includeArchived: boolean,
) {
  const [wallets, moved] = await Promise.all([
    prisma.wallet.findMany({
      where: { userId, ...(includeArchived ? {} : { isArchived: false }) },
      orderBy: [{ sortOrder: 'asc' }, { createdAt: 'asc' }],
    }),
    movements(prisma, userId),
  ]);

  let total = 0n;
  const items = wallets.map((wallet) => {
    const balance = wallet.initialBalance + (moved.get(wallet.id) ?? 0n);
    total += balance;
    return toResponse(wallet, balance);
  });
  return { items, totalBalance: toNumber(total) };
}

export async function createWallet(
  prisma: PrismaClient,
  userId: string,
  input: z.infer<typeof createWalletBody>,
) {
  try {
    const wallet = await prisma.wallet.create({
      data: { ...input, userId, initialBalance: toBigInt(input.initialBalance) },
    });
    return toResponse(wallet, wallet.initialBalance);
  } catch (error) {
    if (isUniqueViolation(error)) throw nameTaken();
    throw error;
  }
}

export async function updateWallet(
  prisma: PrismaClient,
  userId: string,
  id: string,
  input: z.infer<typeof updateWalletBody>,
) {
  await findOwned(prisma, userId, id);
  try {
    const wallet = await prisma.wallet.update({
      where: { id },
      data: {
        ...input,
        ...(input.initialBalance !== undefined && {
          initialBalance: toBigInt(input.initialBalance),
        }),
      },
    });
    return await withBalance(prisma, userId, wallet);
  } catch (error) {
    if (isUniqueViolation(error)) throw nameTaken();
    throw error;
  }
}

export async function deleteWallet(prisma: PrismaClient, userId: string, id: string) {
  await findOwned(prisma, userId, id);
  try {
    await prisma.wallet.delete({ where: { id } });
  } catch (error) {
    // FK Restrict menolak langsung, jadi tidak ada celah antara cek dan hapus.
    if (error instanceof Prisma.PrismaClientKnownRequestError && error.code === 'P2003') {
      throw new AppError('WALLET_IN_USE', 409, 'Dompet masih punya transaksi atau aturan berulang. Arsipkan saja.');
    }
    throw error;
  }
}

/** Dompet di body harus milik user dan aktif (D-27). */
export async function assertActiveWallet(
  prisma: PrismaClient,
  userId: string,
  id: string,
  field: string,
) {
  const wallet = await prisma.wallet.findFirst({ where: { id, userId, isArchived: false } });
  if (!wallet) {
    throw new AppError('VALIDATION_ERROR', 400, 'Data belum valid', { [field]: 'Pilih dompet' });
  }
}
