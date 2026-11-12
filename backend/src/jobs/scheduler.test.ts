import { describe, expect, it, vi } from 'vitest';
import { archiveGate } from './scheduler.js';

const usage = (percent: number) => () => Promise.resolve(percent);

describe('archiveGate', () => {
  it('dua panggilan bersamaan hanya menjalankan job sekali', async () => {
    let release!: () => void;
    const run = vi.fn(() => new Promise<void>((resolve) => (release = resolve)));
    const gate = archiveGate(run, usage(95));
    const first = gate.daily();
    await Promise.all([gate.daily(), gate.hourly()]);
    expect(run).toHaveBeenCalledTimes(1);
    release();
    await first;
  });

  it('cek per jam hanya menjalankan job saat disk > 80% dan meneruskan angkanya', async () => {
    const run = vi.fn(async (read: () => Promise<number>) => void (await read()));
    await archiveGate(run, usage(80)).hourly();
    expect(run).not.toHaveBeenCalled();

    const high = archiveGate(run, usage(81));
    await high.hourly();
    expect(run).toHaveBeenCalledTimes(1);
    expect(await run.mock.calls[0]![0]()).toBe(81);
  });

  it('kunci dilepas setelah job gagal', async () => {
    const run = vi.fn().mockRejectedValueOnce(new Error('gagal')).mockResolvedValue(undefined);
    const gate = archiveGate(run, usage(10));
    await expect(gate.daily()).rejects.toThrow('gagal');
    await gate.daily();
    expect(run).toHaveBeenCalledTimes(2);
  });
});
