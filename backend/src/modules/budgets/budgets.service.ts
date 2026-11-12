import type { Prisma, PrismaClient } from '@prisma/client';
import type { z } from 'zod';
import { AppError } from '../../lib/app-error.js';
import { monthRange, shiftMonth } from '../../lib/dates.js';
import { toBigInt, toNumber } from '../../lib/money.js';
import { getTimezone } from '../me/me.service.js';
import type { createBudgetBody, updateBudgetBody } from './budgets.schemas.js';

const budgetInclude = {
  categories: {
    include: {
      category: { select: { id: true, name: true, icon: true, color: true } },
    },
  },
} satisfies Prisma.BudgetInclude;

type BudgetRow = Prisma.BudgetGetPayload<{ include: typeof budgetInclude }>;

function notFound() {
  return new AppError('NOT_FOUND', 404, 'Data tidak ditemukan');
}

/** Budget berlaku di [month]: startMonth <= month <= endMonth (null = terus). */
function activeIn(month: string) {
  return {
    startMonth: { lte: month },
    OR: [{ endMonth: null }, { endMonth: { gte: month } }],
  } satisfies Prisma.BudgetWhereInput;
}

async function findActive(prisma: PrismaClient, userId: string, id: string, month: string) {
  const budget = await prisma.budget.findFirst({
    where: { id, userId, ...activeIn(month) },
    include: budgetInclude,
  });
  if (!budget) throw notFound();
  return budget;
}

/** Pengeluaran bulan itu per kategori; transfer dan biaya admin transfer tidak dihitung (D-60). */
async function spentByCategory(
  prisma: PrismaClient,
  userId: string,
  month: string,
  categoryIds: string[],
) {
  if (categoryIds.length === 0) return new Map<string, number>();
  const timezone = await getTimezone(prisma, userId);
  const rows = await prisma.transaction.groupBy({
    by: ['categoryId'],
    where: {
      userId,
      type: 'EXPENSE',
      categoryId: { in: categoryIds },
      occurredAt: monthRange(`${month}-01`, timezone),
      feeOf: { is: null },
    },
    _sum: { amount: true },
  });
  return new Map(rows.map((row) => [row.categoryId, toNumber(row._sum.amount ?? 0n)]));
}

async function toResponses(
  prisma: PrismaClient,
  userId: string,
  month: string,
  budgets: BudgetRow[],
) {
  const ids = [...new Set(budgets.flatMap((b) => b.categories.map((c) => c.categoryId)))];
  const spent = await spentByCategory(prisma, userId, month, ids);
  return budgets.map((budget) => ({
    id: budget.id,
    name: budget.name,
    limitAmount: toNumber(budget.limitAmount),
    startMonth: budget.startMonth,
    endMonth: budget.endMonth,
    categories: budget.categories.map((c) => c.category),
    spent: budget.categories.reduce((sum, c) => sum + (spent.get(c.categoryId) ?? 0), 0),
  }));
}

/** Semua kategori harus milik user (lain → 404) dan berjenis pengeluaran. */
async function checkCategories(prisma: PrismaClient, userId: string, ids: string[]) {
  const found = await prisma.category.findMany({
    where: { userId, id: { in: ids } },
    select: { type: true },
  });
  if (found.length !== ids.length) throw notFound();
  if (found.some((category) => category.type !== 'EXPENSE')) {
    const message = 'Budget hanya untuk kategori pengeluaran';
    throw new AppError('VALIDATION_ERROR', 400, message, {
      categoryIds: message,
    });
  }
}

export async function listBudgets(prisma: PrismaClient, userId: string, month: string) {
  const budgets = await prisma.budget.findMany({
    where: { userId, ...activeIn(month) },
    include: budgetInclude,
    orderBy: [{ startMonth: 'asc' }, { name: 'asc' }],
  });
  return { items: await toResponses(prisma, userId, month, budgets) };
}

export async function createBudget(
  prisma: PrismaClient,
  userId: string,
  input: z.infer<typeof createBudgetBody>,
) {
  await checkCategories(prisma, userId, input.categoryIds);
  const budget = await prisma.budget.create({
    data: {
      userId,
      name: input.name,
      limitAmount: toBigInt(input.limitAmount),
      startMonth: input.month,
      categories: {
        create: input.categoryIds.map((categoryId) => ({ categoryId })),
      },
    },
    include: budgetInclude,
  });
  const [response] = await toResponses(prisma, userId, input.month, [budget]);
  return response!;
}

/**
 * Ubah mulai [input.month]. Budget yang mulai lebih awal ditutup di bulan sebelumnya dan
 * diganti budget baru, supaya bulan-bulan lama tetap memakai nilai lama.
 */
export async function updateBudget(
  prisma: PrismaClient,
  userId: string,
  id: string,
  input: z.infer<typeof updateBudgetBody>,
) {
  const { month, categoryIds } = input;
  const budget = await findActive(prisma, userId, id, month);
  if (categoryIds) await checkCategories(prisma, userId, categoryIds);
  const limitAmount = input.limitAmount === undefined ? undefined : toBigInt(input.limitAmount);

  const updatedId = await prisma.$transaction(async (tx) => {
    if (budget.startMonth === month) {
      await tx.budget.update({
        where: { id },
        data: { name: input.name, limitAmount },
      });
      if (categoryIds) {
        await tx.budgetCategory.deleteMany({ where: { budgetId: id } });
        await tx.budgetCategory.createMany({
          data: categoryIds.map((categoryId) => ({ budgetId: id, categoryId })),
        });
      }
      return id;
    }
    await tx.budget.update({
      where: { id },
      data: { endMonth: shiftMonth(month, -1) },
    });
    const created = await tx.budget.create({
      data: {
        userId,
        name: input.name ?? budget.name,
        limitAmount: limitAmount ?? budget.limitAmount,
        startMonth: month,
        endMonth: budget.endMonth,
        categories: {
          create: (categoryIds ?? budget.categories.map((c) => c.categoryId)).map((categoryId) => ({
            categoryId,
          })),
        },
      },
    });
    return created.id;
  });

  const [response] = await toResponses(prisma, userId, month, [
    await findActive(prisma, userId, updatedId, month),
  ]);
  return response!;
}

/** Hentikan mulai [month]: dihapus jika baru mulai bulan itu, selain itu ditutup bulan sebelumnya. */
export async function deleteBudget(
  prisma: PrismaClient,
  userId: string,
  id: string,
  month: string,
) {
  const budget = await findActive(prisma, userId, id, month);
  if (budget.startMonth === month) {
    await prisma.budget.delete({ where: { id } });
  } else {
    await prisma.budget.update({
      where: { id },
      data: { endMonth: shiftMonth(month, -1) },
    });
  }
}
