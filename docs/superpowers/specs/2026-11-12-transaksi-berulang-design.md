# Transaksi berulang (FIN-15) — desain

Tanggal: 2026-11-12 · Ref: FIN-15 (P2)

## Maksud

Pengeluaran/pemasukan rutin bulanan (kos, cicilan, langganan, gaji) tidak perlu diketik ulang tiap bulan.
Owner memilih **konfirmasi dulu**: tidak ada transaksi yang tercatat tanpa persetujuan user; saat jatuh tempo,
app menampilkan daftar "Jatuh tempo" dan user menekan **Catat** (boleh ubah nominal/tanggal) atau **Lewati**.

## Keputusan owner

- Pencatatan: konfirmasi dulu (bukan otomatis).
- Frekuensi: **bulanan saja**, pada tanggal tertentu (1–31). Tanggal 29–31 jatuh ke hari terakhir bulan yang lebih pendek.
- Jenis: **pemasukan dan pengeluaran**. Transfer tidak termasuk.

## Bukan tujuan

- Frekuensi harian/mingguan/tahunan; transfer berulang; pencatatan otomatis tanpa konfirmasi.
- Notifikasi lokal saat jatuh tempo (bisa menyusul; daftar Jatuh tempo di Beranda sudah cukup untuk v1).
- Foto lampiran pada aturan berulang.

## Anti-tujuan

- Satu kejadian (aturan + bulan) tercatat dua kali (tap ganda, dua HP, kirim ulang).
- Transaksi tercatat tanpa user menekan Catat.
- Data user lain terlihat atau bisa dicatat (404 untuk milik user lain).
- Bulan yang terlewat hilang diam-diam: kejadian lama tetap muncul sampai dicatat atau dilewati.

## Model

Tabel baru `recurring_transactions` (perubahan `schema.prisma` disetujui bersama dokumen ini):
`id, userId, walletId, categoryId, type (INCOME|EXPENSE), amount BigInt > 0, note?, dayOfMonth 1–31,
startMonth YYYY-MM, endMonth YYYY-MM? (null = terus), lastHandledMonth YYYY-MM? (bulan terakhir yang sudah
dicatat/dilewati), createdAt, updatedAt`. Wallet/Category `onDelete: Restrict` seperti `Transaction`.

**Kejadian berikutnya** sebuah aturan = bulan pertama ≥ `max(startMonth, lastHandledMonth + 1)`, selama ≤ `endMonth`.
Tanggal jatuh temponya = `min(dayOfMonth, hari terakhir bulan itu)`. Kejadian **jatuh tempo** bila tanggal itu
≤ hari ini (zona waktu user). Satu aturan hanya menampilkan satu kejadian (yang tertua); setelah dicatat/dilewati,
kejadian berikutnya muncul bila juga sudah jatuh tempo.

## API (ditambahkan ke `openapi.yaml`)

- `GET /recurring` → daftar aturan (+ `nextMonth`, `nextDueDate` atau null jika selesai).
- `POST /recurring`, `PATCH /recurring/:id`, `DELETE /recurring/:id` (hapus aturan; transaksi yang sudah tercatat tetap).
- `GET /recurring/due` → kejadian yang jatuh tempo: `[{ recurring, month, dueDate }]`, urut `dueDate`.
- `POST /recurring/:id/record` `{ month, amount?, occurredAt?, walletId?, note? }` → 201 `Transaction`.
  `month` harus sama dengan kejadian berikutnya yang sudah jatuh tempo, selain itu 409 `CONFLICT`.
  Dicatat atomik: transaksi dibuat dan `lastHandledMonth` dimajukan dalam satu transaksi DB dengan syarat
  `lastHandledMonth` belum berubah (tap ganda → yang kedua 409).
- `POST /recurring/:id/skip` `{ month }` → 204, aturan sama untuk `month`.
- Validasi dompet aktif & kategori sesuai jenis memakai pemeriksaan yang sudah ada di modul transaksi.

## Mobile

- Profil → baris **Transaksi berulang** → layar daftar aturan (FrameCard) + FAB tambah → form
  (jenis, nominal, kategori, dompet, tanggal tiap bulan, mulai bulan, berakhir opsional, catatan) memakai
  komponen form transaksi yang sudah ada. Ketuk aturan = ubah; hapus dengan konfirmasi.
- Beranda: kartu **Jatuh tempo** (FrameCard) di atas "Hari ini" bila ada kejadian; tiap baris: kategori, nominal,
  tanggal jatuh tempo, tombol **Catat** dan **Lewati**. Catat → sheet berisi nominal & tanggal (default = aturan &
  tanggal jatuh tempo) → simpan. Setelah catat/lewati: refresh dashboard, kalender, laporan, budget seperti
  transaksi biasa.
- Kosong/loading/error ditangani sesuai pola layar lain.

## Diserahkan ke builder

Nama file/kelas, susunan form, salinan teks pendek (ikuti DESIGN.md), bentuk respons `nextMonth/nextDueDate`.

## Keputusan Claude (cek ulang)

- Status per aturan cukup `lastHandledMonth` (tanpa tabel riwayat kejadian).
- Satu kejadian per aturan tampil sekaligus (tertua dulu).
- Ubah nominal/tanggal saat Catat tidak mengubah aturannya.
- Tanpa job terjadwal: jatuh tempo dihitung saat diminta.
