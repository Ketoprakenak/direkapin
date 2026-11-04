import { describe, expect, it } from 'vitest';
import { toBigInt, toNumber } from './money.js';

describe('money', () => {
  it('mengubah bolak-balik tanpa kehilangan nilai, termasuk negatif', () => {
    expect(toNumber(toBigInt(999_999_999))).toBe(999_999_999);
    expect(toNumber(-25_000n)).toBe(-25_000);
  });

  it('menolak nilai di luar batas aman', () => {
    expect(() => toNumber(2n ** 60n)).toThrow(RangeError);
  });
});
