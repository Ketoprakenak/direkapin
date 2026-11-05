import type { PrismaClient } from '@prisma/client';
import { addDays, dateRange, localDate, monthRange, toDbDate } from '../../lib/dates.js';
import { toNumber } from '../../lib/money.js';
import { activityInclude, activityOrder, toActivityResponse } from '../activities/activities.service.js';
import { getTimezone } from '../me/me.service.js';
import { listWallets } from '../wallets/wallets.service.js';

/**
 * [days] = tanggal berurutan naik yang punya catatan.
 * Hari ini yang masih kosong belum memutus streak (D-30).
 */
export function computeStreak(days: string[], today: string) {
  const recorded = new Set(days);

  let current = 0;
  let cursor = recorded.has(today) ? today : addDays(today, -1);
  while (recorded.has(cursor)) {
    current++;
    cursor = addDays(cursor, -1);
  }

  let longest = 0;
  let run = 0;
  let previous: string | undefined;
  for (const day of days) {
    run = previous && addDays(previous, 1) === day ? run + 1 : 1;
    longest = Math.max(longest, run);
    previous = day;
  }
  return { current, longest };
}

async function recordedDays(prisma: PrismaClient, userId: string, timezone: string) {
  const rows = await prisma.$queryRaw<{ day: string }[]>`
    SELECT to_char("occurredAt" AT TIME ZONE ${timezone}::text, 'YYYY-MM-DD') AS day
    FROM transactions WHERE "userId" = ${userId}::uuid
    UNION
    SELECT to_char("date", 'YYYY-MM-DD') AS day
    FROM activities WHERE "userId" = ${userId}::uuid
    ORDER BY day`;
  return rows.map((row) => row.day);
}

async function dailySeries(
  prisma: PrismaClient,
  userId: string,
  timezone: string,
  today: string,
) {
  const first = addDays(today, -6);
  const range = dateRange(first, today, timezone);
  const rows = await prisma.$queryRaw<{ day: string; type: string; total: bigint }[]>`
    SELECT to_char("occurredAt" AT TIME ZONE ${timezone}::text, 'YYYY-MM-DD') AS day,
           "type"::text AS type,
           SUM("amount")::bigint AS total
    FROM transactions
    WHERE "userId" = ${userId}::uuid AND "occurredAt" >= ${range.gte} AND "occurredAt" < ${range.lt}
    GROUP BY 1, 2`;

  return Array.from({ length: 7 }, (_, index) => {
    const label = addDays(first, index);
    const total = (type: string) =>
      toNumber(rows.find((row) => row.day === label && row.type === type)?.total ?? 0n);
    return { label, income: total('INCOME'), expense: total('EXPENSE') };
  });
}

export async function getDashboard(prisma: PrismaClient, userId: string, now = new Date()) {
  const timezone = await getTimezone(prisma, userId);
  const today = localDate(now, timezone);

  const [wallets, monthTotals, last7Days, days, activities] = await Promise.all([
    listWallets(prisma, userId, false),
    prisma.transaction.groupBy({
      by: ['type'],
      where: { userId, occurredAt: monthRange(today, timezone) },
      _sum: { amount: true },
    }),
    dailySeries(prisma, userId, timezone, today),
    recordedDays(prisma, userId, timezone),
    prisma.activity.findMany({
      where: { userId, date: toDbDate(today) },
      include: activityInclude,
      orderBy: activityOrder,
    }),
  ]);

  const monthTotal = (type: string) =>
    toNumber(monthTotals.find((row) => row.type === type)?._sum.amount ?? 0n);
  const income = monthTotal('INCOME');
  const expense = monthTotal('EXPENSE');

  return {
    totalBalance: wallets.totalBalance,
    wallets: wallets.items,
    month: { income, expense, net: income - expense },
    today: {
      date: today,
      expense: last7Days.at(-1)?.expense ?? 0,
      activities: activities.map(toActivityResponse),
      hasEntry: days.includes(today),
    },
    last7Days,
    streak: computeStreak(days, today),
  };
}
