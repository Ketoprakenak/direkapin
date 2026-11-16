# Utang (FIN-20) — design

Status: draft, menunggu persetujuan owner (termasuk perubahan `schema.prisma`).

Lanjutan Piutang talangan (FIN-19, D-77). Arah sebaliknya: **owner yang berutang ke orang lain**.

## Kebutuhan owner (2026-11-16)

- Dua jenis utang:
  - **Ditalangin**: teman bayarin owner (mis. makan Rp50.000). Saat dicatat **tidak ada uang masuk**; saldo tidak berubah.
  - **Pinjam tunai**: owner pinjam uang; uang **masuk ke dompet pilihan** saat dicatat, dicatat sebagai pemasukan **"Pinjaman diterima"**.
- Owner bisa **mencicil**. Tiap cicilan = **pengeluaran** dari dompet pilihan dengan **kategori pilihan owner** (mis. Makan), jadi masuk laporan dan budget sesuai pemakaiannya.
- **Saldo total** tidak dihitung ulang: pinjam tunai menaikkannya lewat saldo dompet, cicilan menurunkannya lewat saldo dompet. Talangan tidak menaikkan Saldo total.
- Sheet Saldo total menampilkan baris **Utang** `+Rp<sisa semua utang>` sebagai info (tidak dijumlahkan), di bawah baris Piutang.
- Satu menu digabung: **Utang & Piutang** dengan toggle `Piutang` / `Utang`.

## Model (reuse tabel FIN-19)

Tambahan di `schema.prisma`:

| Perubahan | Isi |
|---|---|
| enum baru `ReceivableDirection` | `RECEIVABLE`, `PAYABLE` |
| `Receivable.direction` | `ReceivableDirection @default(RECEIVABLE)` — data piutang lama otomatis `RECEIVABLE` |
| `Receivable.loanTransactionId` | `String? @unique @db.Uuid` → `Transaction` `onDelete: SetNull` (pemasukan "Pinjaman diterima") |
| relasi balik | `Transaction.receivableLoan Receivable?` |

- Utang = `Receivable` `PAYABLE` dengan **tepat 1 orang** di `receivable_debtors` (orang yang dihutangi). Lebih dari 1 → 400 `debtors: "Utang hanya untuk 1 orang"`.
- Cicilan utang = transaksi `EXPENSE` biasa (kategori pilihan, `EXPENSE`, milik user) di dompet pilihan, ditautkan lewat `receivable_payments` yang sama. Catatan `Bayar utang <nama> · <judul>`.
- Pinjam tunai (`loanWalletId` saat create) = transaksi `INCOME` kategori bawaan `{ name: 'Pinjaman diterima', type: 'INCOME', icon: 'handshake_rounded', color: '#64748B' }` (upsert pola D-56), nominal = nominal utang, `occurredAt` = sekarang, catatan `Pinjam <nama> · <judul>`.
- `paid`, `remaining`, lunas, kunci `FOR UPDATE`, melebihi sisa → 400, hapus transaksi cicilan = cicilan batal: **sama persis dengan FIN-19**.
- Hapus utang: orang + tautan cicilan terhapus; **transaksi pemasukan pinjaman dan pengeluaran cicilan tetap**.
- Ubah nominal orang tidak mengubah transaksi pinjaman (owner ubah sendiri di transaksi kalau perlu).

## API (perubahan dari FIN-19)

- `GET /receivables?status=open|all&direction=receivable|payable` (default `receivable`) → `{ items, totalRemaining }` per arah.
- `Receivable` tambah `direction: 'RECEIVABLE'|'PAYABLE'` dan `loan: { transactionId, amount, wallet: WalletRef } | null`.
- `POST /receivables` tambah `direction?` (default `RECEIVABLE`) dan `loanWalletId?` (hanya `PAYABLE`; dompet aktif, tabungan boleh; selain itu 400 `loanWalletId`).
- `POST /receivables/debtors/{debtorId}/payments` tambah `categoryId?`: **wajib** untuk `PAYABLE` (400 `categoryId: "Pilih kategori"`), diabaikan untuk `RECEIVABLE`.
- `GET /dashboard` tambah `payableRemaining: int`; `receivableRemaining` kini hanya menjumlah `RECEIVABLE`.

## UI (neubrutalism, warna ikut tema)

- **Layar `Utang & Piutang`** (`/piutang`, judul AppBar baru; menu Profil ganti label): toggle atas `Piutang` / `Utang`, lalu toggle `Belum lunas` / `Semua`. Kartu total: `Total belum dibayar` (Piutang, minus) / `Total utang` (Utang, plus). FAB `Catat piutang` / `Catat utang`. Kosong: `Belum ada piutang` / `Belum ada utang`.
- **Form Catat utang**: Judul, Tanggal, Catatan, **Utang ke** (nama), Nominal, pilihan `Ditalangin` / `Pinjam tunai`; Pinjam tunai → dropdown `Masuk ke dompet`. Mode ubah: jenis dan dompet tidak bisa diubah.
- **Detail utang**: satu kartu orang (sama dengan piutang), baris `Pinjaman masuk ke <dompet>` jika `loan`. Sheet `Bayar`: Nominal default sisa, `Dari dompet`, **Kategori** (EXPENSE). Riwayat: `<tgl> · Rp… dari <dompet>`.
- **Sheet Saldo total**: baris `Utang` (ikon `payments_rounded`) `AmountText(payableRemaining)` di bawah Piutang, ikut mode sembunyi; tap → layar dengan tab Utang.

## Di luar cakupan

Utang ke beberapa orang dalam satu catatan, bunga, jatuh tempo/pengingat, ubah jenis utang setelah dibuat, cicilan sebagai transfer tanpa laporan.
