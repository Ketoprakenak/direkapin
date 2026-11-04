import { describe, expect, it } from 'vitest';
import { addDays, dateRange, localDate, monthRange, startOfDay } from './dates.js';

const JAKARTA = 'Asia/Jakarta';

describe('dates', () => {
  it('awal hari Jakarta adalah 17.00 UTC hari sebelumnya', () => {
    expect(startOfDay('2026-11-04', JAKARTA).toISOString()).toBe('2026-11-03T17:00:00.000Z');
  });

  it('zona lain ikut benar, termasuk saat DST', () => {
    expect(startOfDay('2026-11-04', 'Asia/Makassar').toISOString()).toBe('2026-11-03T16:00:00.000Z');
    expect(startOfDay('2026-07-01', 'America/New_York').toISOString()).toBe('2026-07-01T04:00:00.000Z');
    expect(startOfDay('2026-12-01', 'America/New_York').toISOString()).toBe('2026-12-01T05:00:00.000Z');
  });

  it('23.30 dan 00.30 WIB jatuh di tanggal yang benar', () => {
    expect(localDate(new Date('2026-11-04T16:30:00Z'), JAKARTA)).toBe('2026-11-04');
    expect(localDate(new Date('2026-11-04T17:30:00Z'), JAKARTA)).toBe('2026-11-05');
  });

  it('addDays melewati akhir bulan dan tahun', () => {
    expect(addDays('2026-12-31', 1)).toBe('2027-01-01');
    expect(addDays('2026-03-01', -1)).toBe('2026-02-28');
  });

  it('rentang tanggal inklusif', () => {
    const range = dateRange('2026-11-04', '2026-11-04', JAKARTA);
    expect(range.gte.toISOString()).toBe('2026-11-03T17:00:00.000Z');
    expect(range.lt.toISOString()).toBe('2026-11-04T17:00:00.000Z');
  });

  it('rentang bulan melewati akhir tahun', () => {
    const range = monthRange('2026-12-15', JAKARTA);
    expect(range.gte.toISOString()).toBe('2026-11-30T17:00:00.000Z');
    expect(range.lt.toISOString()).toBe('2026-12-31T17:00:00.000Z');
  });
});
