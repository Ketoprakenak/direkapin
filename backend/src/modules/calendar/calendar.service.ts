import type { PrismaClient } from '@prisma/client';
import { dateRange, firstOfNextMonth, monthRange, toDbDate } from '../../lib/dates.js';
import { toNumber } from '../../lib/money.js';
import { activityOrder, toActivityResponse } from '../activities/activities.service.js';
import { getTimezone } from '../me/me.service.js';
import {
  toTransactionResponse,
  transactionInclude,
} from '../transactions/transactions.service.js';
import { toTransferResponse, transferInclude } from '../transfers/transfers.service.js';

export async function getCalendar(prisma: PrismaClient, userId: string, month: string) {
  const timezone = await getTimezone(prisma, userId);
  const first = `${month}-01`;
  const range = monthRange(first, timezone);

  const [totals, activities] = await Promise.all([
    prisma.$queryRaw<{ day: string; income: bigint; expense: bigint }[]>`
      SELECT to_char("occurredAt" AT TIME ZONE ${timezone}::text, 'YYYY-MM-DD') AS day,
             COALESCE(SUM("amount") FILTER (WHERE "type" = 'INCOME'), 0)::bigint AS income,
             COALESCE(SUM("amount") FILTER (WHERE "type" = 'EXPENSE'), 0)::bigint AS expense
      FROM transactions
      WHERE "userId" = ${userId}::uuid AND "occurredAt" >= ${range.gte} AND "occurredAt" < ${range.lt}
      GROUP BY 1`,
    prisma.activity.findMany({
      where: {
        userId,
        date: { gte: toDbDate(first), lt: toDbDate(firstOfNextMonth(first)) },
      },
      select: { date: true, isImportant: true },
    }),
  ]);

  const days = new Map<
    string,
    { date: string; income: number; expense: number; activityCount: number; hasImportant: boolean }
  >();
  const dayOf = (date: string) => {
    const existing = days.get(date);
    if (existing) return existing;
    const created = { date, income: 0, expense: 0, activityCount: 0, hasImportant: false };
    days.set(date, created);
    return created;
  };

  for (const row of totals) {
    const day = dayOf(row.day);
    day.income = toNumber(row.income);
    day.expense = toNumber(row.expense);
  }
  for (const activity of activities) {
    const day = dayOf(activity.date.toISOString().slice(0, 10));
    day.activityCount++;
    day.hasImportant ||= activity.isImportant;
  }

  return {
    month,
    days: [...days.values()].sort((a, b) => a.date.localeCompare(b.date)),
  };
}

export async function getDay(prisma: PrismaClient, userId: string, date: string) {
  const timezone = await getTimezone(prisma, userId);
  const occurredAt = dateRange(date, date, timezone);

  const [transactions, transfers, activities, note] = await Promise.all([
    prisma.transaction.findMany({
      where: { userId, occurredAt },
      include: transactionInclude,
      orderBy: [{ occurredAt: 'desc' }, { id: 'desc' }],
    }),
    prisma.transfer.findMany({
      where: { userId, occurredAt },
      include: transferInclude,
      orderBy: [{ occurredAt: 'desc' }, { id: 'desc' }],
    }),
    prisma.activity.findMany({
      where: { userId, date: toDbDate(date) },
      orderBy: activityOrder,
    }),
    prisma.dailyNote.findFirst({ where: { userId, date: toDbDate(date) } }),
  ]);

  const total = (type: string) =>
    toNumber(
      transactions
        .filter((transaction) => transaction.type === type)
        .reduce((sum, transaction) => sum + transaction.amount, 0n),
    );

  return {
    date,
    income: total('INCOME'),
    expense: total('EXPENSE'),
    transactions: transactions.map(toTransactionResponse),
    transfers: transfers.map(toTransferResponse),
    activities: activities.map(toActivityResponse),
    note: note && { date, mood: note.mood, note: note.note },
  };
}
