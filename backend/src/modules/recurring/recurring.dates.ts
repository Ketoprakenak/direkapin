import { shiftMonth } from '../../lib/dates.js';

export interface RecurringSchedule {
  dayOfMonth: number;
  startMonth: string;
  endMonth: string | null;
  lastHandledMonth: string | null;
}

/** Kejadian tertua yang belum ditangani; null bila sudah melewati endMonth. YYYY-MM bisa dibandingkan sebagai string. */
export function nextOccurrence(rule: RecurringSchedule): { month: string; dueDate: string } | null {
  const afterHandled = rule.lastHandledMonth ? shiftMonth(rule.lastHandledMonth, 1) : rule.startMonth;
  const month = afterHandled > rule.startMonth ? afterHandled : rule.startMonth;
  if (rule.endMonth && month > rule.endMonth) return null;
  const [year, mon] = month.split('-').map(Number) as [number, number];
  const lastDay = new Date(Date.UTC(year, mon, 0)).getUTCDate();
  const day = String(Math.min(rule.dayOfMonth, lastDay)).padStart(2, '0');
  return { month, dueDate: `${month}-${day}` };
}

/** Jatuh tempo bila tanggalnya <= hari ini (keduanya YYYY-MM-DD, zona waktu user). */
export function isDue(dueDate: string, today: string): boolean {
  return dueDate <= today;
}
