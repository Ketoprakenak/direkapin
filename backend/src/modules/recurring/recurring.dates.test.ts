import { describe, expect, it } from 'vitest';
import { isDue, nextOccurrence } from './recurring.dates.js';

const rule = (over: Partial<Parameters<typeof nextOccurrence>[0]> = {}) => ({
  dayOfMonth: 31,
  startMonth: '2026-01',
  endMonth: null,
  lastHandledMonth: null,
  ...over,
});

describe('nextOccurrence', () => {
  it('mulai dari startMonth, tanggal 31 di bulan 31 hari', () => {
    expect(nextOccurrence(rule())).toEqual({ month: '2026-01', dueDate: '2026-01-31' });
  });
  it('setelah bulan terakhir ditangani, maju ke bulan berikutnya (Februari = 28)', () => {
    expect(nextOccurrence(rule({ lastHandledMonth: '2026-01' }))).toEqual({
      month: '2026-02',
      dueDate: '2026-02-28',
    });
  });
  it('tahun kabisat: 29 Februari', () => {
    expect(nextOccurrence(rule({ startMonth: '2028-02' }))).toEqual({
      month: '2028-02',
      dueDate: '2028-02-29',
    });
  });
  it('bulan 30 hari dan pergantian tahun', () => {
    expect(nextOccurrence(rule({ startMonth: '2026-04' }))?.dueDate).toBe('2026-04-30');
    expect(nextOccurrence(rule({ lastHandledMonth: '2026-12' }))?.month).toBe('2027-01');
  });
  it('lewat endMonth = null', () => {
    expect(nextOccurrence(rule({ endMonth: '2026-01', lastHandledMonth: '2026-01' }))).toBeNull();
  });
  it('endMonth sama dengan bulan berikutnya masih dikembalikan', () => {
    expect(nextOccurrence(rule({ endMonth: '2026-02', lastHandledMonth: '2026-01' }))?.month).toBe(
      '2026-02',
    );
  });
  it('lastHandled sebelum startMonth tidak memundurkan', () => {
    expect(nextOccurrence(rule({ startMonth: '2026-06', lastHandledMonth: '2026-01' }))?.month).toBe(
      '2026-06',
    );
  });
  it('startMonth di masa depan tetap dikembalikan', () => {
    expect(nextOccurrence(rule({ startMonth: '2030-03', dayOfMonth: 5 }))).toEqual({
      month: '2030-03',
      dueDate: '2030-03-05',
    });
  });
});

describe('isDue', () => {
  it('jatuh tempo pada hari-H dan sesudahnya, bukan sebelumnya', () => {
    expect(isDue('2026-11-05', '2026-11-05')).toBe(true);
    expect(isDue('2026-11-05', '2026-12-01')).toBe(true);
    expect(isDue('2026-11-06', '2026-11-05')).toBe(false);
  });
});
