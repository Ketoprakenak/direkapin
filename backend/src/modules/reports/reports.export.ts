import type { PrismaClient } from '@prisma/client';
import PDFDocument from 'pdfkit';
import { csv, csvText } from '../../lib/csv.js';
import { dateRange, localDate } from '../../lib/dates.js';
import { toNumber } from '../../lib/money.js';
import { getTimezone } from '../me/me.service.js';
import { getRangeReport } from './reports.service.js';

type Row = {
  date: string;
  time: string;
  type: string;
  wallet: string;
  category: string;
  amount: number;
  note: string | null;
};

/** Laporan rentang [from, to] sebagai file (FIN-14, D-70). Transfer tidak ikut. */
export async function exportReport(
  prisma: PrismaClient,
  userId: string,
  from: string,
  to: string,
  walletId: string | undefined,
  format: 'csv' | 'pdf',
) {
  const timeZone = await getTimezone(prisma, userId);
  const transactions = await prisma.transaction.findMany({
    where: {
      userId,
      occurredAt: dateRange(from, to, timeZone),
      ...(walletId && { walletId }),
    },
    include: { wallet: { select: { name: true } }, category: { select: { name: true } } },
    orderBy: { occurredAt: 'asc' },
  });
  const time = new Intl.DateTimeFormat('en-GB', { timeZone, hour: '2-digit', minute: '2-digit' });
  const rows: Row[] = transactions.map((tx) => ({
    date: localDate(tx.occurredAt, timeZone),
    time: time.format(tx.occurredAt),
    type: tx.type === 'INCOME' ? 'Pemasukan' : 'Pengeluaran',
    wallet: tx.wallet.name,
    category: tx.category.name,
    amount: toNumber(tx.amount),
    note: tx.note,
  }));
  const fileName = `direkapin-laporan-${from}_${to}.${format}`;

  if (format === 'csv') {
    return {
      fileName,
      contentType: 'text/csv; charset=utf-8',
      body: csv([
        ['tanggal', 'jam', 'jenis', 'dompet', 'kategori', 'nominal', 'catatan'],
        ...rows.map((row) => [
          row.date,
          row.time,
          row.type,
          csvText(row.wallet),
          csvText(row.category),
          row.amount,
          csvText(row.note),
        ]),
      ]),
    };
  }
  const report = await getRangeReport(prisma, userId, from, to, walletId);
  return {
    fileName,
    contentType: 'application/pdf',
    body: await renderPdf(from, to, report, rows),
  };
}

const rupiah = (amount: number) =>
  `${amount < 0 ? '-' : ''}Rp${Math.abs(amount).toLocaleString('id-ID')}`;

/** shortcut: font standar PDF hanya Latin-1; emoji/aksara lain dibuang, embed font TTF jika perlu. */
const latin1 = (text: string | null) => (text ?? '').replace(/[^\x20-\x7E\xA0-\xFF]/g, '').trim();

type RangeReport = Awaited<ReturnType<typeof getRangeReport>>;

function renderPdf(from: string, to: string, report: RangeReport, rows: Row[]) {
  const doc = new PDFDocument({ size: 'A4', margin: 40 });
  const chunks: Buffer[] = [];
  doc.on('data', (chunk: Buffer) => chunks.push(chunk));
  const done = new Promise<Buffer>((resolve, reject) => {
    doc.on('end', () => resolve(Buffer.concat(chunks)));
    doc.on('error', reject);
  });

  const left = doc.page.margins.left;
  const width = doc.page.width - left - doc.page.margins.right;
  const bottom = () => doc.page.height - doc.page.margins.bottom;

  doc.font('Helvetica-Bold').fontSize(16).text('Laporan Direkapin');
  doc.font('Helvetica').fontSize(10).text(`${from} s.d. ${to}`).moveDown();

  const { totals } = report;
  doc.font('Helvetica-Bold').fontSize(11).text('Ringkasan');
  doc.font('Helvetica').fontSize(10);
  doc.text(`Pemasukan: ${rupiah(totals.income)}`);
  doc.text(`Pengeluaran: ${rupiah(totals.expense)}`);
  doc.text(`Selisih: ${rupiah(totals.net)}`);
  doc.text(`Jumlah transaksi: ${totals.transactionCount}`).moveDown();

  if (report.byCategory.length > 0) {
    doc.font('Helvetica-Bold').fontSize(11).text('Pengeluaran per kategori');
    doc.font('Helvetica').fontSize(10);
    for (const item of report.byCategory) {
      doc.text(
        `${latin1(item.category.name)}: ${rupiah(item.amount)} (${Math.round(item.share * 100)}%)`,
      );
    }
    doc.moveDown();
  }

  // Lebar kolom (pt) untuk A4 margin 40 = 515; catatan mengambil sisa.
  const columns = [
    { title: 'Tanggal', width: 58 },
    { title: 'Jam', width: 32 },
    { title: 'Jenis', width: 62 },
    { title: 'Dompet', width: 70 },
    { title: 'Kategori', width: 80 },
    { title: 'Nominal', width: 78, right: true },
  ];
  const noteWidth = width - columns.reduce((sum, column) => sum + column.width, 0) - 6;
  const rowHeight = 14;
  let y = doc.y;

  const line = (cells: string[], bold = false) => {
    if (y + rowHeight > bottom()) {
      doc.addPage();
      y = doc.page.margins.top;
    }
    doc.font(bold ? 'Helvetica-Bold' : 'Helvetica').fontSize(8);
    let x = left;
    columns.forEach((column, i) => {
      doc.text(cells[i] ?? '', x, y, {
        width: column.width - 4,
        align: column.right ? 'right' : 'left',
        height: rowHeight - 4,
        ellipsis: true,
      });
      x += column.width;
    });
    doc.text(cells[columns.length] ?? '', x + 6, y, { width: noteWidth, height: rowHeight - 4, ellipsis: true });
    y += rowHeight;
  };

  doc.font('Helvetica-Bold').fontSize(11).text('Transaksi', left, y);
  y = doc.y + 4;
  if (rows.length === 0) {
    doc.font('Helvetica').fontSize(10).text('Tidak ada transaksi di rentang ini.', left, y);
  } else {
    line([...columns.map((column) => column.title), 'Catatan'], true);
    for (const row of rows) {
      line([
        row.date,
        row.time,
        row.type,
        latin1(row.wallet),
        latin1(row.category),
        rupiah(row.type === 'Pemasukan' ? row.amount : -row.amount),
        latin1(row.note),
      ]);
    }
  }
  doc.end();
  return done;
}
