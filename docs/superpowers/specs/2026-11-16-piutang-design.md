# Piutang talangan (FIN-19) — design

Status: draft, menunggu persetujuan owner (termasuk tabel baru di `schema.prisma`).

## Kebutuhan owner (2026-11-16)

- Dipakai mostly untuk mencatat **utang teman saat owner nalangin** (mis. bayar makan beberapa orang).
- Pengeluaran asli dicatat seperti biasa (mis. Makan Rp200.000). Menu piutang **terpisah**: owner sendiri memasukkan bagian yang jadi utang teman (mis. Rp150.000 dari 200 rb itu).
- Satu piutang = satu talangan dengan **beberapa orang**; nominal tiap orang **diisi manual**.
- Nama teman **diketik manual**, tidak ada daftar teman tersimpan.
- Teman bisa **mencicil**. Tiap pembayaran **masuk ke dompet yang dipilih** dan menambah saldo.
- Di bottom sheet **Saldo total** ada baris **Piutang** bertanda minus (sisa yang belum dibayar). Saat teman bayar, angka piutang mendekati 0 dan saldo dompet bertambah.

## Model

| Tabel | Isi |
|---|---|
| `receivables` | `id, userId, title (≤60), date (YYYY-MM-DD), note? (≤1000), createdAt, updatedAt` |
| `receivable_debtors` | `id, receivableId (cascade), name (≤30), amount BigInt (1..999.999.999), sortOrder` |
| `receivable_payments` | `id, debtorId (cascade), transactionId @unique (cascade dari transactions)` |

- Pembayaran = **transaksi `INCOME` biasa** di dompet pilihan, kategori bawaan **"Piutang dibayar"** (dibuat otomatis saat pertama dipakai, pola D-56), catatan `Bayar <nama> · <judul>`. Jadi saldo dompet naik tanpa logika saldo baru.
- `paid` orang = jumlah nominal transaksi pembayarannya; `remaining = amount − paid`. Lunas saat `remaining = 0`; talangan lunas saat semua orang lunas.
- Pembayaran melebihi sisa → 400 `amount: "Melebihi sisa utang Rp…"`.
- Hapus pembayaran = hapus transaksinya (`DELETE /transactions/{id}`); link ikut terhapus (cascade), sisa kembali naik.
- Hapus talangan: orang + link pembayaran terhapus, **transaksi pemasukan tetap** (uang memang sudah diterima).
- Ubah orang: nama/nominal; nominal baru tidak boleh < yang sudah dibayar (400).

**Catatan laporan:** pengeluaran Makan Rp200.000 tetap penuh di laporan; pembayaran teman masuk laporan sebagai pemasukan "Piutang dibayar". Selisih bersihnya = porsi owner.

**Saldo total tidak berubah oleh piutang.** Saldo total = Bisa digunakan + tabungan (D-76). Baris Piutang di sheet hanya informasi: `−Rp<sisa semua piutang>`.

## API

- `GET /receivables?status=open|all` (default `open`) → `{ items: Receivable[], totalRemaining }`, urut `date` desc.
  `Receivable = { id, title, date, note, total, remaining, debtors: [{ id, name, amount, paid, remaining, payments: [{ transactionId, amount, occurredAt, wallet: WalletRef }] }] }`
- `POST /receivables` `{ title, date, note?, debtors: [{ name, amount }] (1..20) }` → 201.
- `PATCH /receivables/{id}` `{ title?, date?, note? }` → 200.
- `DELETE /receivables/{id}` → 204.
- `PATCH /receivables/debtors/{debtorId}` `{ name?, amount? }` → 200 `Receivable`.
- `POST /receivables/debtors/{debtorId}/payments` `{ amount, walletId, occurredAt, clientId? }` → 201 `Receivable`. `walletId` = dompet aktif (tabungan boleh).
- `GET /dashboard` tambah `receivableRemaining: int`.

## UI (mobile, neubrutalism, warna ikut tema)

- **Sheet Saldo total**: baris baru `Piutang` di bawah `Bisa digunakan`, nominal `−Rp…` (ikut mode sembunyikan), tap → layar Piutang.
- **Layar Piutang** (`/piutang`, juga dari Profil): toggle `Belum lunas` / `Semua`; kartu per talangan: judul, tanggal, progres terbayar, chip tiap orang + sisa; FAB `Catat piutang`. Kosong: "Belum ada piutang".
- **Form Catat piutang**: Judul, Tanggal, Catatan (opsional), baris orang (Nama + Nominal, tombol tambah/hapus baris, min. 1), total otomatis.
- **Detail talangan**: tiap orang: sisa, tombol `Bayar` (sheet: Nominal default = sisa, Dari dompet → wallet tujuan, tanggal = sekarang), riwayat pembayaran (tap = detail transaksi); menu Ubah / Hapus.

## Di luar cakupan

Utang owner ke orang lain, daftar teman tersimpan, pengingat tagih, tautan ke transaksi pengeluaran asal, bagi rata otomatis.
