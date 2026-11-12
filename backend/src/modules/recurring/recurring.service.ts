import type { Prisma, PrismaClient } from '@prisma/client';
import type { z } from 'zod';
import { AppError } from '../../lib/app-error.js';
import { localDate, startOfDay } from '../../lib/dates.js';
import { toBigInt, toNumber } from '../../lib/money.js';
import { assertCategory } from '../categories/categories.service.js';
import { getTimezone } from '../me/me.service.js';
import { toTransactionResponse, transactionInclude } from '../transactions/transactions.service.js';
import { assertActiveWallet } from '../wallets/wallets.service.js';
import { isDue, nextOccurrence } from './recurring.dates.js';
import { END_BEFORE_START, endNotBeforeStart } from './recurring.schemas.js';
import type {
  createRecurringBody,
  recordBody,
  updateRecurringBody,
} from './recurring.schemas.js';

export const recurringInclude = {
  wallet: { select: { id: true, name: true, icon: true, color: true } },
  category: { select: { id: true, name: true, icon: true, color: true } },
} satisfies Prisma.RecurringTransactionInclude;
type RecurringRow = Prisma.RecurringTransactionGetPayload<{ include: typeof recurringInclude }>;

export function toRecurringResponse(row: RecurringRow) {
  return {
    id: row.id,
    type: row.type,
    amount: toNumber(row.amount),
    note: row.note,
    dayOfMonth: row.dayOfMonth,
    startMonth: row.startMonth,
    endMonth: row.endMonth,
    lastHandledMonth: row.lastHandledMonth,
    wallet: row.wallet,
    category: row.category,
    next: nextOccurrence(row),
  };
}

async function findOwned(prisma: PrismaClient, userId: string, id: string) {
  const row = await prisma.recurringTransaction.findFirst({
    where: { id, userId },
    include: recurringInclude,
  });
  if (!row) throw new AppError('NOT_FOUND', 404, 'Data tidak ditemukan');
  return row;
}

export async function listRecurring(prisma: PrismaClient, userId: string) {
  const rows = await prisma.recurringTransaction.findMany({
    where: { userId },
    include: recurringInclude,
    orderBy: [{ dayOfMonth: 'asc' }, { createdAt: 'asc' }],
  });
  return { items: rows.map(toRecurringResponse) };
}

export async function createRecurring(
  prisma: PrismaClient,
  userId: string,
  input: z.infer<typeof createRecurringBody>,
) {
  await assertActiveWallet(prisma, userId, input.walletId, 'walletId');
  await assertCategory(prisma, userId, input.categoryId, input.type);
  const row = await prisma.recurringTransaction.create({
    data: { ...input, userId, amount: toBigInt(input.amount) },
    include: recurringInclude,
  });
  return toRecurringResponse(row);
}

export async function updateRecurring(
  prisma: PrismaClient,
  userId: string,
  id: string,
  input: z.infer<typeof updateRecurringBody>,
) {
  const existing = await findOwned(prisma, userId, id);
  const startMonth = input.startMonth ?? existing.startMonth;
  const endMonth = input.endMonth === undefined ? existing.endMonth : input.endMonth;
  if (!endNotBeforeStart({ startMonth, endMonth })) {
    throw new AppError('VALIDATION_ERROR', 400, 'Data belum valid', { endMonth: END_BEFORE_START });
  }
  // Dompet lama boleh sudah diarsipkan; hanya dompet baru yang harus aktif (seperti transaksi).
  if (input.walletId && input.walletId !== existing.walletId) {
    await assertActiveWallet(prisma, userId, input.walletId, 'walletId');
  }
  const type = input.type ?? existing.type;
  const categoryId = input.categoryId ?? existing.categoryId;
  if (type !== existing.type || categoryId !== existing.categoryId) {
    await assertCategory(prisma, userId, categoryId, type);
  }
  const row = await prisma.recurringTransaction.update({
    where: { id },
    data: { ...input, ...(input.amount !== undefined && { amount: toBigInt(input.amount) }) },
    include: recurringInclude,
  });
  return toRecurringResponse(row);
}

export async function deleteRecurring(prisma: PrismaClient, userId: string, id: string) {
  await findOwned(prisma, userId, id);
  await prisma.recurringTransaction.delete({ where: { id } });
}

const conflict = () => new AppError('CONFLICT', 409, 'Kejadian ini sudah dicatat atau belum jatuh tempo');

/** Kejadian [month] harus kejadian berikutnya aturan dan sudah jatuh tempo (hari ini zona waktu user). */
function assertClaimable(rule: RecurringRow, month: string, today: string) {
  const next = nextOccurrence(rule);
  if (!next || next.month !== month || !isDue(next.dueDate, today)) throw conflict();
  return next;
}

export async function listDue(prisma: PrismaClient, userId: string, now = new Date()) {
  const today = localDate(now, await getTimezone(prisma, userId));
  const rows = await prisma.recurringTransaction.findMany({ where: { userId }, include: recurringInclude });
  const items = rows.flatMap((row) => {
    const next = nextOccurrence(row);
    return next && isDue(next.dueDate, today)
      ? [{ recurring: toRecurringResponse(row), month: next.month, dueDate: next.dueDate }]
      : [];
  });
  return { items: items.sort((a, b) => a.dueDate.localeCompare(b.dueDate)) };
}

// Klaim atomik: updateMany bersyarat pada lastHandledMonth lama, jadi panggilan bersamaan hanya satu yang menang.
async function claim(tx: Prisma.TransactionClient, rule: RecurringRow, month: string) {
  const { count } = await tx.recurringTransaction.updateMany({
    where: { id: rule.id, userId: rule.userId, lastHandledMonth: rule.lastHandledMonth },
    data: { lastHandledMonth: month },
  });
  if (count === 0) throw conflict();
}

export async function skipRecurring(
  prisma: PrismaClient,
  userId: string,
  id: string,
  month: string,
  now = new Date(),
) {
  const rule = await findOwned(prisma, userId, id);
  assertClaimable(rule, month, localDate(now, await getTimezone(prisma, userId)));
  await prisma.$transaction((tx) => claim(tx, rule, month));
}

export async function recordRecurring(
  prisma: PrismaClient,
  userId: string,
  id: string,
  input: z.infer<typeof recordBody>,
  now = new Date(),
) {
  const rule = await findOwned(prisma, userId, id);
  const timezone = await getTimezone(prisma, userId);
  const { dueDate } = assertClaimable(rule, input.month, localDate(now, timezone));
  const walletId = input.walletId ?? rule.walletId;
  await assertActiveWallet(prisma, userId, walletId, 'walletId');
  await assertCategory(prisma, userId, rule.categoryId, rule.type);
  // Default pukul 12:00 waktu user pada tanggal jatuh tempo.
  const occurredAt = input.occurredAt ?? new Date(startOfDay(dueDate, timezone).getTime() + 12 * 3_600_000);
  const row = await prisma.$transaction(async (tx) => {
    await claim(tx, rule, input.month);
    return tx.transaction.create({
      data: {
        userId,
        walletId,
        categoryId: rule.categoryId,
        type: rule.type,
        amount: input.amount === undefined ? rule.amount : toBigInt(input.amount),
        note: input.note === undefined ? rule.note : input.note,
        occurredAt,
      },
      include: transactionInclude,
    });
  });
  return toTransactionResponse(row);
}
