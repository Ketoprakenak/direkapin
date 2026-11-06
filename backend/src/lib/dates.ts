// Tanggal `YYYY-MM-DD` selalu berarti tanggal di zona waktu user (D-08).

function offsetMs(instant: Date, timeZone: string): number {
  const parts = new Intl.DateTimeFormat('en-US', {
    timeZone,
    hourCycle: 'h23',
    year: 'numeric',
    month: 'numeric',
    day: 'numeric',
    hour: 'numeric',
    minute: 'numeric',
    second: 'numeric',
  }).formatToParts(instant);
  const get = (type: string) => Number(parts.find((p) => p.type === type)?.value);
  const wallClock = Date.UTC(
    get('year'),
    get('month') - 1,
    get('day'),
    get('hour'),
    get('minute'),
    get('second'),
  );
  return wallClock - Math.floor(instant.getTime() / 1000) * 1000;
}

/** Awal hari [date] di [timeZone], sebagai waktu UTC. */
export function startOfDay(date: string, timeZone: string): Date {
  const utcMidnight = new Date(`${date}T00:00:00Z`);
  const first = new Date(utcMidnight.getTime() - offsetMs(utcMidnight, timeZone));
  // Dihitung ulang karena offset bisa berbeda di sekitar pergantian DST.
  return new Date(utcMidnight.getTime() - offsetMs(first, timeZone));
}

export function addDays(date: string, days: number): string {
  const result = new Date(`${date}T00:00:00Z`);
  result.setUTCDate(result.getUTCDate() + days);
  return result.toISOString().slice(0, 10);
}

/** Rentang `[from, to]` inklusif dalam tanggal lokal, jadi `{ gte, lt }` UTC. */
export function dateRange(from: string, to: string, timeZone: string) {
  return { gte: startOfDay(from, timeZone), lt: startOfDay(addDays(to, 1), timeZone) };
}

/** Filter `occurredAt` dari `from`/`to` opsional. */
export function occurredAtFilter(from: string | undefined, to: string | undefined, timeZone: string) {
  if (!from && !to) return undefined;
  return {
    ...(from && { gte: startOfDay(from, timeZone) }),
    ...(to && { lt: startOfDay(addDays(to, 1), timeZone) }),
  };
}

/** Tanggal lokal dari sebuah waktu. */
export function localDate(instant: Date, timeZone: string): string {
  return new Intl.DateTimeFormat('en-CA', { timeZone }).format(instant);
}

/** Tanggal 1 bulan berikutnya dari [date]. */
export function firstOfNextMonth(date: string): string {
  const next = new Date(`${date.slice(0, 7)}-01T00:00:00Z`);
  next.setUTCMonth(next.getUTCMonth() + 1);
  return next.toISOString().slice(0, 10);
}

/** Rentang satu bulan yang memuat [date], dalam bentuk `{ gte, lt }` UTC. */
export function monthRange(date: string, timeZone: string) {
  return {
    gte: startOfDay(`${date.slice(0, 7)}-01`, timeZone),
    lt: startOfDay(firstOfNextMonth(date), timeZone),
  };
}

/** Bulan `YYYY-MM` digeser [delta] bulan. */
export function shiftMonth(month: string, delta: number): string {
  const result = new Date(`${month}-01T00:00:00Z`);
  result.setUTCMonth(result.getUTCMonth() + delta);
  return result.toISOString().slice(0, 7);
}

/** Nilai untuk kolom `@db.Date`. */
export function toDbDate(date: string): Date {
  return new Date(`${date}T00:00:00Z`);
}
