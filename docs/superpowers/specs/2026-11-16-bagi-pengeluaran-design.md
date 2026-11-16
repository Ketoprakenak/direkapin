# Bagi pengeluaran ke teman (FIN-21) — design

Status: draft, menunggu persetujuan owner (termasuk perubahan `schema.prisma` dan kontrak API).

Lanjutan FIN-19 (D-77). Supaya talangan tidak perlu dicatat dua kali: pengeluaran dulu, lalu piutang manual.

## Kebutuhan owner (2026-11-16)

- Dari pengeluaran (mis. Makan Rp200.000) owner bisa **"Bagi ke teman"**; hasilnya **otomatis jadi piutang** di menu Utang & Piutang, tanpa input ulang judul/tanggal.
- Tersedia saat **catat pengeluaran baru** dan dari **detail pengeluaran lama** yang belum pernah dibagi.
- Nominal per orang **manual**, plus tombol **"Bagi rata"**: total dibagi rata ke semua teman **termasuk owner**. Total bagian teman **tidak boleh melebihi** nominal pengeluaran.
- Piutang **berdiri sendiri**: pengeluaran diubah/dihapus → piutang tetap; detail piutang menampilkan info asal "Dari pengeluaran <kategori> Rp…" (tap = detail transaksi). Pengeluaran dihapus → info asal hilang.

## Model

| Perubahan | Isi |
|---|---|
| `Receivable.sourceTransactionId` | `String? @unique @db.Uuid` → `Transaction` `onDelete: SetNull` (relasi `"ReceivableSource"`) |
| relasi balik | `Transaction.receivableSource Receivable? @relation("ReceivableSource")` |

`@unique` = satu pengeluaran hanya bisa dibagi sekali.

## API

- `POST /receivables` tambah `sourceTransactionId?` (hanya `RECEIVABLE`):
  - harus transaksi `EXPENSE` milik user → selain itu 400 `sourceTransactionId: "Pilih pengeluaran"`;
  - sudah pernah dibagi → 400 `sourceTransactionId: "Pengeluaran ini sudah dibagi"` (kecuali kiriman ulang `clientId` sama = 201 catatan yang sama, D-58);
  - Σ nominal orang > nominal pengeluaran → 400 `debtors: "Melebihi nominal pengeluaran Rp…"`;
  - dengan `direction: PAYABLE` → 400 `sourceTransactionId: "Hanya untuk piutang"`.
- `Receivable` tambah `source: { transactionId, amount, categoryName } | null`.
- `Transaction` (semua respons transaksi) tambah `receivableId: string | null` = piutang hasil bagi.

## Bagi rata

`n` teman + owner: tiap teman `floor(total / (n + 1))`; sisa pembulatan jadi bagian owner (tidak masuk piutang). Contoh Rp200.000, 2 teman → Rp66.666 tiap teman.

## UI (neubrutalism, warna ikut tema)

- **Form pengeluaran baru**: `SwitchListTile` **"Bagi ke teman"** (hanya mode Keluar, hanya catat baru). Simpan berhasil → layar diganti form **"Bagi ke teman"** (bukan kembali ke Beranda).
- **Form "Bagi ke teman"** = form Catat piutang dengan sumber: Judul terisi nama kategori (boleh diubah), Tanggal = tanggal pengeluaran, kartu info "Dari pengeluaran Makan Rp200.000", baris orang, tombol **"Bagi rata"**, total + "Bagian kamu Rp…" (= pengeluaran − total teman).
- **Detail pengeluaran**: belum dibagi → tombol `OutlinedButton` **"Bagi ke teman"**; sudah → baris **"Dibagi ke teman"** (tap = detail piutang).
- **Detail piutang**: baris "Dari pengeluaran <kategori> Rp…" (tap = detail transaksi).

## Di luar cakupan

Bagi pemasukan, bagi transfer, ubah tautan setelah dibuat, bagi pengeluaran dari layar Cari, sinkron otomatis saat nominal pengeluaran berubah.
