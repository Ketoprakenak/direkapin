import { Prisma, type PrismaClient } from '@prisma/client';
import { addDays, dateRange, firstOfNextMonth } from '../../lib/dates.js';
import { toNumber } from '../../lib/money.js';
import { getTimezone } from '../me/me.service.js';

type Period = { start: string; end: string; walletId: string | undefined; timezone: string };

function periodWhere(userId: string, period: Period) {
  return {
    userId,
    occurredAt: dateRange(period.start, period.end, period.timezone),
    ...(period.walletId && { walletId: period.walletId }),
  };
}

async function getTotals(prisma: PrismaClient, userId: string, period: Period) {
  const rows = await prisma.transaction.groupBy({
    by: ['type'],
    where: periodWhere(userId, period),
    _sum: { amount: true },
    _count: true,
  });
  const total = (type: string) => toNumber(rows.find((row) => row.type === type)?._sum.amount ?? 0n);
  const income = total('INCOME');
  const expense = total('EXPENSE');
  return {
    income,
    expense,
    net: income - expense,
    transactionCount: rows.reduce((sum, row) => sum + row._count, 0),
  };
}

/** Satu titik untuk setiap hari di periode, termasuk hari tanpa transaksi. */
async function getSeries(prisma: PrismaClient, userId: string, period: Period) {
  const { gte, lt } = dateRange(period.start, period.end, period.timezone);
  const wallet = period.walletId
    ? Prisma.sql`AND "walletId" = ${period.walletId}::uuid`
    : Prisma.empty;
  const rows = await prisma.$queryRaw<{ day: string; type: string; total: bigint }[]>`
    SELECT to_char("occurredAt" AT TIME ZONE ${period.timezone}::text, 'YYYY-MM-DD') AS day,
           "type"::text AS type,
           SUM("amount")::bigint AS total
    FROM transactions
    WHERE "userId" = ${userId}::uuid AND "occurredAt" >= ${gte} AND "occurredAt" < ${lt} ${wallet}
    GROUP BY 1, 2`;

  const points = [];
  for (let label = period.start; label <= period.end; label = addDays(label, 1)) {
    const total = (type: string) =>
      toNumber(rows.find((row) => row.day === label && row.type === type)?.total ?? 0n);
    points.push({ label, income: total('INCOME'), expense: total('EXPENSE') });
  }
  return points;
}

async function getByCategory(
  prisma: PrismaClient,
  userId: string,
  period: Period,
  totalExpense: number,
) {
  const rows = await prisma.transaction.groupBy({
    by: ['categoryId'],
    where: { ...periodWhere(userId, period), type: 'EXPENSE' },
    _sum: { amount: true },
    orderBy: { _sum: { amount: 'desc' } },
  });
  const categories = await prisma.category.findMany({
    where: { userId, id: { in: rows.map((row) => row.categoryId) } },
    select: { id: true, name: true, icon: true, color: true },
  });
  return rows.map((row) => {
    const amount = toNumber(row._sum.amount ?? 0n);
    return {
      category: categories.find((category) => category.id === row.categoryId)!,
      amount,
      share: amount / totalExpense,
    };
  });
}

export async function getDailyReport(
  prisma: PrismaClient,
  userId: string,
  date: string,
  walletId: string | undefined,
) {
  const timezone = await getTimezone(prisma, userId);
  const period = { start: date, end: date, walletId, timezone };
  const totals = await getTotals(prisma, userId, period);
  return {
    period: { type: 'daily' as const, start: date, end: date },
    totals,
    series: [],
    byCategory: await getByCategory(prisma, userId, period, totals.expense),
    comparison: null,
  };
}

export async function getWeeklyReport(
  prisma: PrismaClient,
  userId: string,
  start: string,
  walletId: string | undefined,
) {
  const timezone = await getTimezone(prisma, userId);
  const end = addDays(start, 6);
  const period = { start, end, walletId, timezone };
  const totals = await getTotals(prisma, userId, period);
  const [series, byCategory] = await Promise.all([
    getSeries(prisma, userId, period),
    getByCategory(prisma, userId, period, totals.expense),
  ]);
  return {
    period: { type: 'weekly' as const, start, end },
    totals,
    series,
    byCategory,
    comparison: null,
  };
}

export async function getMonthlyReport(
  prisma: PrismaClient,
  userId: string,
  month: string,
  walletId: string | undefined,
) {
  const timezone = await getTimezone(prisma, userId);
  const start = `${month}-01`;
  const end = addDays(firstOfNextMonth(start), -1);
  const period = { start, end, walletId, timezone };
  const previousEnd = addDays(start, -1);
  const previousPeriod = { ...period, start: `${previousEnd.slice(0, 7)}-01`, end: previousEnd };

  const totals = await getTotals(prisma, userId, period);
  const [series, byCategory, previous] = await Promise.all([
    getSeries(prisma, userId, period),
    getByCategory(prisma, userId, period, totals.expense),
    getTotals(prisma, userId, previousPeriod),
  ]);
  const previousExpense = previous.expense;
  return {
    period: { type: 'monthly' as const, start, end },
    totals,
    series,
    byCategory,
    comparison: {
      previousExpense,
      changePct:
        previousExpense === 0
          ? null
          : Math.round(((totals.expense - previousExpense) / previousExpense) * 1000) / 10,
    },
  };
}
