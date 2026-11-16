# Tabungan (FIN-18) — design

Status: disetujui owner 2026-11-16 (+ target nominal); perubahan `schema.prisma` menunggu izin.

Mockup: bottom sheet Saldo total + menu ⋮ + form Buat tabungan (ditunjukkan di chat 2026-11-16).

## Kebutuhan owner (2026-11-16)

- **Saldo total = Saldo bisa digunakan + saldo tabungan A + saldo tabungan B + …**
- Membuat/menyetor tabungan **mengurangi saldo dompet di Direkapin** (uang aslinya tetap di bank; ini pencatatan saja).
- Setor bisa berkali-kali. **Tidak ada tarik** balik ke dompet biasa.
- Tabungan bisa dipakai langsung untuk **pengeluaran** (dicatat seperti transaksi biasa). "Seperti dompet, tapi tidak masuk menu Dompet."
- Pengeluaran dari tabungan **masuk laporan, budget, heatmap** seperti pengeluaran biasa.
- Tabungan bisa **dihapus**: sisa saldo dikembalikan ke dompet yang dipilih; riwayat pengeluaran tetap ada.
- **Target nominal opsional** per tabungan, bisa diubah/dihapus; progress bar di sheet (owner, 2026-11-16).
- UI: di Beranda, tap kartu **Total saldo** → bottom sheet ±setengah layar berisi rincian yang membentuk Saldo total.

## Model

Tabungan = baris `Wallet` dengan `type = SAVINGS` (enum baru) dan kolom baru `targetAmount BigInt?` (null = tanpa target; hanya dipakai SAVINGS). Alasannya: saldo, transaksi, laporan, budget, heatmap, streak semua sudah bekerja per dompet, jadi tidak perlu logika baru.

| Aksi | Dicatat sebagai | Efek |
|---|---|---|
| Buat tabungan + setoran awal | `Wallet` SAVINGS + `Transfer` dompet → tabungan | Saldo dompet turun, saldo tabungan naik; tidak masuk laporan (transfer) |
| Setor | `Transfer` dompet → tabungan | sama |
| Pengeluaran dari tabungan | `Transaction` EXPENSE, `walletId` = tabungan | Masuk laporan/budget/heatmap/streak |
| Hapus | `Transfer` sisa tabungan → dompet pilihan (kalau sisa ≠ 0), lalu `isArchived = true` | Sisa balik; riwayat tetap |

Aturan:

- `Saldo bisa digunakan` = total saldo dompet aktif non-SAVINGS. `Saldo total` = itu + total saldo tabungan aktif.
- Transfer **dari** tabungan ditolak lewat API (400, `fromWalletId: "Tabungan tidak bisa ditarik"`). Transfer internal saat hapus dibuat oleh server.
- Sisa negatif (pengeluaran melebihi setoran; tidak diblokir, sama seperti dompet biasa) → saat hapus dibuat transfer dompet pilihan → tabungan sebesar kekurangannya.
- Tabungan tidak bisa dibuat/diubah lewat `/wallets` (enum body tetap CASH/BANK/EWALLET).

## Kompatibilitas APK lama (≤1.3.0)

APK lama gagal parse `type: "SAVINGS"`. Karena itu:

- `GET /wallets` **tidak** mengembalikan SAVINGS kecuali `?includeSavings=true`.
- `GET /dashboard` `wallets` tetap tanpa SAVINGS; `totalBalance` sudah termasuk tabungan (sesuai definisi Saldo total).
- Transaksi/transfer memakai `WalletRef` (tanpa `type`), jadi aman.

## API

- `GET /wallets?includeSavings=true` — ikut SAVINGS (untuk pemilih dompet di form transaksi).
- `POST /savings` `{ name, targetAmount?, initialAmount?, fromWalletId? }` (`targetAmount` 1..999.999.999) → 201 `Wallet`. `initialAmount > 0` wajib `fromWalletId` (dompet aktif non-SAVINGS). Ikon tetap `savings_rounded`; warna tidak dipilih (tampilan ikut tema, server isi warna tetap). Wallet + transfer dibuat atomik.
- Setor = `POST /transfers` biasa dengan `toWalletId` = tabungan.
- `DELETE /savings/{id}?toWalletId=` → 204. Sisa ≠ 0 tanpa `toWalletId` → 400 `toWalletId: "Pilih dompet untuk sisa saldo"`. Bukan tabungan / milik user lain / sudah dihapus → 404.
- `PATCH /savings/{id}` `{ targetAmount: int | null }` → 200 `Wallet`.
- `Wallet` respons tambah `targetAmount: int | null` (APK lama mengabaikan field tak dikenal).
- `GET /dashboard` tambah `availableBalance: int` dan `savings: Wallet[]` (urut `sortOrder`, `createdAt`).

## UI (mobile)

- Kartu Total saldo di Beranda bisa di-tap → `SavingsSheet` (DraggableScrollableSheet, awal 0.55):
  - Header "Saldo total" + nominal (ikut mode sembunyikan saldo).
  - Baris "Bisa digunakan" + nominal.
  - Bagian "Tabungan": tiap item ikon, nama, saldo, menu ⋮ (Setor, Catat pengeluaran, Ubah target, Hapus). Ada target: progress bar + "N% dari Rp…" + "Kurang Rp…"; saldo ≥ target: bar penuh + "Tercapai"; tanpa target: "Tanpa target". Kosong: "Belum ada tabungan".
  - Tombol "Buat tabungan".
- Buat: nama, target (opsional), setoran awal (opsional), dari dompet. Semua kartu neubrutalism (`FrameCard`/`FrameBox`), warna ikut tema.
- Ubah target: satu field nominal; kosong = hapus target.
- Setor: nominal, dari dompet → `POST /transfers`.
- Catat pengeluaran: buka form transaksi dengan dompet = tabungan, jenis Keluar.
- Hapus: konfirmasi; kalau sisa ≠ 0, pilih dompet tujuan sisa.
- Form transaksi: pemilih dompet ikut menampilkan tabungan.
- Menu Dompet, filter laporan/cari, transaksi berulang: tetap tanpa tabungan.

## Riwayat (owner, 2026-11-16)

Tap kartu tabungan atau menu ⋮ → Riwayat: layar `/tabungan/:id` berisi saldo, progres target, total Disetor/Dipakai, dan daftar setoran (transfer masuk) + transaksi + transfer tutup, dikelompokkan per bulan, tap = detail. Data gabungan `GET /transfers?wallet=` dan `GET /transactions?wallet=` (masing-masing 100 terbaru); tanpa perubahan backend.

## Di luar cakupan

Ubah nama/warna tabungan, tarik dana, riwayat per tabungan di sheet, tabungan di filter laporan/cari, notifikasi.
