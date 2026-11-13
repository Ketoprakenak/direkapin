const BOM = '﻿';

/** Teks dari user yang diawali tanda ini dijalankan sebagai formula oleh Excel. */
export function csvText(value: string | null) {
  const text = value ?? '';
  return /^[=+\-@\t\r]/.test(text) ? `'${text}` : text;
}

/** CSV dengan BOM (Excel membaca UTF-8), semua sel dikutip, baris CRLF. */
export function csv(rows: (string | number)[][]) {
  const lines = rows.map((row) =>
    row.map((cell) => `"${String(cell).replaceAll('"', '""')}"`).join(','),
  );
  return `${BOM}${lines.join('\r\n')}\r\n`;
}
