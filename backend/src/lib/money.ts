export function toNumber(amount: bigint): number {
  const value = Number(amount);
  if (!Number.isSafeInteger(value)) throw new RangeError('Nominal di luar batas aman');
  return value;
}

export function toBigInt(amount: number): bigint {
  return BigInt(amount);
}

/** "Rp30.000" untuk pesan error ke user. */
export function formatRupiah(amount: bigint): string {
  return `Rp${toNumber(amount).toLocaleString('id-ID')}`;
}
