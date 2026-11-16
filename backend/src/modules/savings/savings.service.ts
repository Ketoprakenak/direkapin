import type { PrismaClient } from '@prisma/client';
import type { z } from 'zod';
import { AppError } from '../../lib/app-error.js';
import { toBigInt } from '../../lib/money.js';
import { isUniqueViolation } from '../../lib/schemas.js';
import {
  assertActiveWallet,
  assertNotSavings,
  movements,
  toResponse,
} from '../wallets/wallets.service.js';
import type { createSavingsBody, updateSavingsBody } from './savings.schemas.js';

// Tabungan ikut warna tema di HP; kolom color tetap wajib di DB.
const SAVINGS_COLOR = '#00897B';

function invalid(field: string, message: string) {
  return new AppError('VALIDATION_ERROR', 400, 'Data belum valid', { [field]: message });
}

async function findSavings(prisma: PrismaClient, userId: string, id: string) {
  const wallet = await prisma.wallet.findFirst({
    where: { id, userId, type: 'SAVINGS', isArchived: false },
  });
  if (!wallet) throw new AppError('NOT_FOUND', 404, 'Data tidak ditemukan');
  return wallet;
}

/** Dompet sumber/tujuan: milik user, aktif, bukan tabungan. */
async function assertPlainWallet(prisma: PrismaClient, userId: string, id: string, field: string) {
  await assertActiveWallet(prisma, userId, id, field);
  await assertNotSavings(prisma, userId, id, field);
}

export async function listSavings(prisma: PrismaClient, userId: string) {
  const [wallets, moved] = await Promise.all([
    prisma.wallet.findMany({
      where: { userId, type: 'SAVINGS', isArchived: false },
      orderBy: [{ sortOrder: 'asc' }, { createdAt: 'asc' }],
    }),
    movements(prisma, userId),
  ]);
  return wallets.map((w) => toResponse(w, w.initialBalance + (moved.get(w.id) ?? 0n)));
}

export async function createSavings(
  prisma: PrismaClient,
  userId: string,
  input: z.infer<typeof createSavingsBody>,
) {
  const { initialAmount, fromWalletId } = input;
  if (initialAmount > 0) {
    if (!fromWalletId) throw invalid('fromWalletId', 'Pilih dompet');
    await assertPlainWallet(prisma, userId, fromWalletId, 'fromWalletId');
  }
  try {
    const wallet = await prisma.$transaction(async (tx) => {
      const row = await tx.wallet.create({
        data: {
          userId,
          name: input.name,
          type: 'SAVINGS',
          icon: 'savings_rounded',
          color: SAVINGS_COLOR,
          targetAmount: input.targetAmount === undefined ? null : toBigInt(input.targetAmount),
        },
      });
      if (initialAmount > 0) {
        await tx.transfer.create({
          data: {
            userId,
            fromWalletId: fromWalletId!,
            toWalletId: row.id,
            amount: toBigInt(initialAmount),
            occurredAt: new Date(),
          },
        });
      }
      return row;
    });
    return toResponse(wallet, toBigInt(initialAmount));
  } catch (error) {
    if (isUniqueViolation(error)) throw new AppError('NAME_TAKEN', 409, 'Nama sudah dipakai');
    throw error;
  }
}

export async function updateSavings(
  prisma: PrismaClient,
  userId: string,
  id: string,
  input: z.infer<typeof updateSavingsBody>,
) {
  await findSavings(prisma, userId, id);
  const wallet = await prisma.wallet.update({
    where: { id },
    data: { targetAmount: input.targetAmount === null ? null : toBigInt(input.targetAmount) },
  });
  const moved = (await movements(prisma, userId)).get(id) ?? 0n;
  return toResponse(wallet, wallet.initialBalance + moved);
}

/** Sisa saldo dipindah ke dompet pilihan (minus = ditutup dari dompet itu), lalu tabungan diarsip. */
export async function deleteSavings(
  prisma: PrismaClient,
  userId: string,
  id: string,
  toWalletId: string | undefined,
) {
  const wallet = await findSavings(prisma, userId, id);
  const rest = wallet.initialBalance + ((await movements(prisma, userId)).get(id) ?? 0n);
  if (rest !== 0n) {
    if (!toWalletId) throw invalid('toWalletId', 'Pilih dompet untuk sisa saldo');
    await assertPlainWallet(prisma, userId, toWalletId, 'toWalletId');
  }
  await prisma.$transaction(async (tx) => {
    if (rest !== 0n) {
      await tx.transfer.create({
        data: {
          userId,
          fromWalletId: rest > 0n ? id : toWalletId!,
          toWalletId: rest > 0n ? toWalletId! : id,
          amount: rest > 0n ? rest : -rest,
          occurredAt: new Date(),
          note: `Tutup tabungan ${wallet.name}`,
        },
      });
    }
    // Syarat isArchived=false: hapus bersamaan tidak membuat transfer sisa dua kali.
    const { count } = await tx.wallet.updateMany({
      where: { id, userId, isArchived: false },
      data: { isArchived: true },
    });
    if (count === 0) throw new AppError('NOT_FOUND', 404, 'Data tidak ditemukan');
  });
}
