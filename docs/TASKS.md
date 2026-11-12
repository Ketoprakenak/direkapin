# Progres pengerjaan

Satu slice per sesi Claude Code. Centang item saat selesai dan ubah status slice.
Status: `Belum mulai` · `Sedang dikerjakan` · `Selesai`

**Slice aktif:** 10

---

## Slice 0 — Fondasi · Status: Selesai
Ref: PRD bagian 8, 16; `docs/DECISIONS.md`
- [x] `git init` + `.gitignore` (`.env`, keystore, `data/`), monorepo `mobile/`, `backend/`, `docs/`, `docker-compose.yml`, `.env.example`
- [x] Backend: Fastify + TypeScript + zod type provider, struktur `src/modules`, plugin error handler sesuai format error di `openapi.yaml`
- [x] Prisma 6 (D-18), migrasi awal dari `schema.prisma` + CHECK constraint attachment, seed 1 kode undangan owner, template kategori di `src/lib/default-categories.ts` (D-20)
- [x] `GET /api/v1/health` + `GET /api/v1/version`
- [x] Vitest + database test di PostgreSQL laptop berjalan (D-19)
- [x] Flutter: tema dari `docs/DESIGN.md`, `go_router` dengan 4 tab kosong, API client `dio` + interceptor token, format Rupiah & tanggal
- [x] README: cara menjalankan dev

## Slice 1 — Auth · Status: Selesai
Ref: AUTH-01–04, US-01, US-02
- [x] `POST /auth/register` (kode undangan, buat dompet "Cash" + salin kategori bawaan)
- [x] `POST /auth/login`, `/auth/refresh` (rotasi), `/auth/logout`
- [x] Rate limit login 10 / 15 menit / IP
- [x] `GET/PATCH /me`
- [x] Mobile: Splash (S-01), Login (S-02), Daftar (S-03), auto refresh token, logout
- [x] Uji daftar, login, dan logout di HP asli

## Slice 2 — Dompet, kategori, transaksi + dashboard dasar · Status: Selesai
Ref: FIN-01, 03–05, 09–10, DSH-01, 02, 03, 05, 06, US-03, US-06
- [x] API wallets (saldo dihitung), transfers, categories, transactions (tanpa foto)
- [x] `GET /dashboard` lengkap sesuai kontrak (saldo, masuk/keluar bulan ini, ringkasan hari ini, 7 hari terakhir, streak)
- [x] Mobile: Beranda (S-04), Form transaksi (S-08) termasuk mode Transfer, Dompet (S-12), Kategori (S-11)
- [x] Uji catat pengeluaran, transfer, dompet, dan kategori di HP asli

## Slice 3 — Kalender + Halaman Hari · Status: Selesai
Ref: CAL-01, 03–05, US-05
- [x] `GET /calendar?month=`, `GET /days/{date}`
- [x] Mobile: Kalender (S-05), Halaman Hari (S-06), Detail item (S-07), edit/hapus/pindah tanggal
- [x] Uji kalender, edit, hapus, dan pindah tanggal di HP asli

## Slice 4 — Foto · Status: Selesai
Ref: FIN-02, FIN-13, US-04
- [x] `POST /attachments` (multipart, tolak > 2 MB, `sharp` resize ulang > 1 MB, buat thumbnail)
- [x] `GET /attachments/{id}?size=thumb|full` ber-token, `DELETE`
- [x] Mobile: ambil kamera/galeri → kompres otomatis → upload dengan progress → retry jika gagal; thumbnail + viewer
- [x] Simpan foto ke galeri dari viewer (FIN-16, permintaan owner setelah slice ditutup)
- Uji HP lolos. Upload gagal setelah transaksi tersimpan hanya teruji lewat widget test: upload di WiFi lokal terlalu cepat untuk diputus tangan.

## Slice 5 — Kegiatan · Status: Selesai
Ref: ACT-01–04, US-08
- [x] API activities
- [x] Mobile: Form kegiatan (S-09), tampil di Halaman Hari & kalender (bintang untuk penting)

## Slice 6 — Laporan · Status: Selesai
Ref: FIN-06–08, US-07
- [x] `GET /reports/daily|weekly|monthly` (filter dompet, transfer tidak dihitung)
- [x] Mobile: Laporan (S-10) dengan grafik `fl_chart`

## Slice 7 — Reminder, versi, CI APK · Status: Selesai
Ref: ENG-01, US-09, D-21
- [x] Notifikasi harian lokal: jadwal 30 hari ke depan (jam dari `/me`), dipasang ulang saat aplikasi dibuka, catatan disimpan, atau jam diubah; hari ini dilewati jika sudah mencatat
- [x] Banner update dari `/version`
- [x] GitHub Actions: build APK release bertanda tangan saat push tag `v*` → GitHub Releases

## Slice 8 — Backup, arsip, deploy · Status: Selesai
Ref: ARC-01–05, US-10, PRD bagian 10, D-21–D-23
- [x] Job `pg_dump` harian (simpan 14 hari)
- [x] Job arsip harian idempoten (D-23) + `GET /archives`, `GET /archives/{id}/download`, penghapusan foto asli (D-22)
- [x] Mobile: Arsip (S-13), Profil & Pengaturan (S-14), notifikasi arsip lokal (saat terdeteksi, hari ke-7, ke-25, tanggal 1)
- [x] Uji Profil dan daftar Arsip kosong di HP asli lewat APK `v0.8.0` menurut owner; download ZIP diuji di checklist rilis
- [x] Uji `Dockerfile` dan `docker-compose.yml` di mini PC (ditunda dari Slice 0)
- [x] Deploy: `cloudflared` di compose, panduan setup di README
- [x] Checklist rilis PRD bagian 17 lolos → tag `v1.0.0`

## Slice 9 — Biaya admin transfer · Status: Selesai
Ref: FIN-17, D-56 (permintaan owner setelah `v1.0.0`)
- [x] Schema `transfers.feeTransactionId` + migrasi `20261109000000_transfer_fee`, kontrak `fee` / `feePaidBy` di `openapi.yaml`
- [x] API transfers: buat, edit, hapus ikut mengurus transaksi biaya; kategori "Biaya Admin" otomatis
- [x] Mobile: field biaya admin + pilihan dompet yang dipotong di form transfer, biaya tampil di detail dan riwayat transfer
- [x] Uji di HP asli lewat APK `v1.1.0`

## Slice 10 — Anti dobel + paket P1 kecil · Status: Sedang dikerjakan
Ref: D-58, D-59, D-60, D-61, D-62, D-63, D-64, FIN-06, ENG-03, FIN-11, FIN-12, CAL-02, DSH-04, ENG-02, ACT-05, AUTH-05, ARC-06, D-66, D-65 (permintaan owner, selama gate 3 hari D-57)
- [x] `clientId` di transaksi dan transfer (migrasi `20261110000000_client_id`), form mengirim ulang dengan `clientId` sama
- [x] `PUT /days/{date}/note` untuk mood harian
- [x] Mobile: layar cari & filter transaksi dari Beranda (FIN-11), top 3 kategori bulan ini (DSH-04), badge streak 7/30/100 dari streak terpanjang (ENG-02), pilihan mood di Halaman Hari (ACT-05)
- [x] Beranda & Laporan dirampingkan setelah uji debug (D-59)
- [x] Beranda: 3 transaksi terakhir, masuk hari ini, badge di judul; Laporan: grafik garis harian, toggle donut Semua/Top 3 (D-62)
- [x] Tema penuh: 7 tema, maskot, transisi horizontal, layar Tema (ENG-03, D-63)
- [x] Budget multi kategori (FIN-12, D-60): migrasi `20261111000000_budget_groups`, `GET/POST /budgets`, `PATCH/DELETE /budgets/{id}`, bagian Budget di Laporan Bulanan + layar Kelola budget, peringatan 80%/100% (snackbar + notifikasi)
- [x] Ikon + warna mood di sel kalender (D-61); mode Minggu/Agenda (CAL-02) dibatalkan owner
- [x] Frame luar/dalam bergaya tebal di kartu dan kotak ringkasan Laporan (D-64)
- [x] Laporan Custom menggantikan Harian: `GET /reports/range`, pemilih rentang maks. 366 hari (FIN-06, D-64)
- [x] Maskot ngintip di atas tab bawah aktif (D-64)
- [x] Foto profil (AUTH-05, D-65): `PUT/GET/DELETE /me/avatar`, `User.hasAvatar`, avatar + sheet di Profil
- [x] Arsip lebih awal saat disk > 80% (ARC-06, D-66): cek `statfs` tiap jam + job 02:00, cutoff M-1
- [ ] Uji di HP asli lewat build debug, lalu commit dan rilis

---

## Slice 11 — Transaksi berulang (FIN-15) · Status: Sedang dikerjakan
Ref: FIN-15, D-67
- [x] Migrasi tabel `recurring_transactions` (`lastHandledMonth`, tanpa job)
- [x] Backend: `GET/POST /recurring`, `PATCH/DELETE /recurring/{id}`, `GET /recurring/due`, `POST /recurring/{id}/record`, `POST /recurring/{id}/skip` (klaim atomik, 409 `CONFLICT`)
- [x] Hapus kategori memindahkan aturan ke "Lainnya"; hapus dompet yang dipakai aturan = 409 `WALLET_IN_USE`
- [x] Mobile: layar Transaksi berulang (Profil), form aturan, kartu "Jatuh tempo" di Beranda, sheet Catat, dialog Lewati
- [x] Docs: D-67, PRD FIN-15, DESIGN, openapi
- [ ] Uji di HP asli lewat build debug, lalu commit

---

## Log
| Tanggal | Slice | Catatan |
|---|---|---|
| 2026-11-04 | — | Revisi dokumen sebelum Slice 0: D-18–D-23, `totalBalance` boleh negatif, `Archive.zipPath` nullable, streak dan grafik 7 hari pindah ke Slice 2 |
| 2026-11-04 | 0 | Backend selesai: lint, 17 test, dan build lolos. Belum dites: `Dockerfile` dan `docker-compose.yml` (butuh mini PC). Sisa: mobile (menunggu Flutter) |
| 2026-11-04 | 0 | Mobile selesai: `flutter analyze` bersih, 16 test lolos. Slice belum ditutup: build APK dan uji di HP menunggu Android SDK; compose dan `Dockerfile` menunggu mini PC |
| 2026-11-04 | 0 | APK release ter-build (47,9 MB, masih bertanda tangan debug sampai Slice 7). Slice belum ditutup: uji di HP asli dan uji compose + `Dockerfile` di mini PC |
| 2026-11-04 | 0 | APK release jalan di HP asli menurut owner. Sisa: uji compose + `Dockerfile` di mini PC |
| 2026-11-04 | 0 | Ditutup atas persetujuan owner; uji compose + `Dockerfile` pindah ke Slice 8 |
| 2026-11-04 | 1 | Kode selesai: backend 47 test, mobile 37 test, lint dan analyze bersih. Sisa: uji di HP asli |
| 2026-11-04 | 1 | Daftar, login, tetap login, dan logout jalan di HP asli menurut owner. Refresh token saat access token kedaluwarsa baru teruji otomatis |
| 2026-11-04 | 2 | Kode selesai: backend 96 test, mobile 55 test, lint dan analyze bersih. Sisa: uji di HP asli. Edit dan hapus transaksi di aplikasi menyusul di Slice 3 |
| 2026-11-05 | 2 | Aman di HP asli menurut owner |
| 2026-11-05 | 3 | Kode selesai: backend 113 test, mobile 71 test. Jalan di HP asli menurut owner |
| 2026-11-05 | 4 | Kode selesai: backend 133 test, mobile 87 test, lint dan analyze bersih. `.gitignore` `data/` ternyata menyembunyikan `mobile/lib/features/*/data`, sudah diperbaiki |
| 2026-11-05 | 4 | Aman di HP asli menurut owner. Upload gagal setelah transaksi tersimpan hanya teruji lewat widget test |
| 2026-11-05 | 4 | Tambahan FIN-16: simpan foto ke galeri, menunggu uji HP |
| 2026-11-05 | 4 | FIN-16 aman di HP asli menurut owner |
| 2026-11-05 | 5 | Kode selesai: backend 151 test, mobile 105 test, lint dan analyze bersih. Sisa: uji di HP asli |
| 2026-11-05 | 5 | Tambahan permintaan owner: galeri bisa pilih banyak foto. Sisa: uji di HP asli |
| 2026-11-05 | 5 | Aman di HP asli menurut owner, termasuk pilih banyak foto. Slice ditutup |
| 2026-11-05 | 6 | Kode selesai: backend 170 test, mobile 123 test, lint dan analyze bersih. Sisa: uji di HP asli |
| 2026-11-05 | 6 | Aman di HP asli menurut owner. Slice ditutup |
| 2026-11-05 | 7 | Kode selesai: mobile 142 test, analyze bersih, backend tidak berubah. Sisa: uji di HP asli; uji workflow CI menunggu repo GitHub dan keystore dari owner |
| 2026-11-05 | 7 | Reminder dan banner aman di HP asli menurut owner. Sisa: uji workflow CI, menunggu repo GitHub dan keystore dari owner |
| 2026-11-06 | 7 | Workflow `v0.7.0` sukses, APK terpasang di HP asli menurut owner. Login dengan APK ini belum bisa sampai deploy Slice 8; tanda tangan APK tidak diverifikasi terpisah. Slice ditutup |
| 2026-11-06 | 8 | Kode selesai: backend 187 test, mobile 164 test, lint dan analyze bersih. `Dockerfile`, compose, dan tunnel belum dicoba. Sisa: uji Arsip dan Profil di HP asli, lalu deploy dan checklist rilis di mini PC |
| 2026-11-06 | 8 | Deploy jalan: `/health` dan `/version` lolos lewat tunnel. Seed, job backup, dan reboot lolos menurut owner. Workflow `v0.8.0` sukses, APK belum dites di HP. Backend 186 lolos + 1 dilewati, mobile 164 lolos. Sisa: uji HP, job arsip di container, restore backup, salinan mingguan, checklist PRD bagian 17 (butuh kode undangan kedua dan foto uji bertanggal M-2) |
| 2026-11-07 | 8 | Job arsip dan ZIP gagal lalu pulih lolos di mini PC menurut owner. Hasil restore backup dan putus download belum dilaporkan. Atas keputusan owner, sisa uji manual ditunda sampai ada HP kedua karena baru ada 1 HP. Slice tetap aktif, `v1.0.0` belum di-tag |
| 2026-11-07 | 8 | Restore backup baru ke database kosong cocok dengan database asli (3 transaksi, 5 foto, 1 user). Salinan pertama `data/` dan `.env` ke disk laptop selesai menurut owner. Job otomatis 01.00 belum terbukti. Satu akun di server hanya untuk uji, dihapus setelah uji selesai |
| 2026-11-08 | 8 | Uji akses silang lolos: akun A mendapat 404 untuk transaksi, foto, dan download arsip milik akun B; `/me` 200. Diuji lewat `http://localhost:3000` di dalam container `api`, karena FortiGate di jaringan mini PC mencegat HTTPS ke `api.appdirekapin.my.id` (sertifikat ditandatangani ulang). HP di WiFi itu kemungkinan juga gagal konek, belum dicek |
| 2026-11-08 | 8 | Kompres foto lolos di HP asli: foto kamera 9 MB tersimpan 291.879 byte, 1200×1600 |
| 2026-11-08 | 8 | Upload gagal: transaksi tetap tersimpan dan app tidak crash saat offline. Upload foto selesai sebelum sempat diputus, jadi tombol "Coba lagi" hanya teruji lewat widget test; owner menerimanya sebagai lolos. Batasan diketahui: jika koneksi putus saat transaksi dikirim, transaksi bisa tersimpan di server tetapi app menampilkan error dan foto tidak di-upload; Simpan ulang membuat transaksi dobel. Perbaikan butuh idempotency key (ubah kontrak), ditunda |
| 2026-11-08 | 8 | Laporan bulanan November 2026 di app cocok dengan hitungan SQL (masuk 500.000, keluar 155.000 per kategori) menurut owner |
| 2026-11-09 | 8 | Saldo setelah 50 transaksi + 5 transfer (skrip lewat API di container, catatan `UJI-SALDO`): saldo API dua dompet sama dengan hitungan skrip. Tampilan saldo di app belum dikonfirmasi |
| 2026-11-09 | 8 | Menurut owner: saldo di app sama dengan API; pindah tanggal transaksi memindahkan item di kalender dan laporan harian, saldo tetap; job backup otomatis jalan, sudah ada 3 file backup |
| 2026-11-09 | 8 | Notifikasi pengingat jam 09.00 muncul setiap hari yang belum ada catatan sejak APK terpasang, menurut owner. Sisa checklist PRD bagian 17 yang butuh HP kedua ditunda sampai HP tersedia |
| 2026-11-09 | 8 | Menurut owner: download arsip diputus di tengah, status tetap `READY`, download ulang berhasil dan tersimpan di HP; pengingat tidak muncul di hari yang sudah ada catatan; uji di HP kedua (install APK, kamera, upload, notifikasi) dicek satu per satu dan lancar. Semua skenario PRD bagian 17 lolos; tinggal merge ke `main` dan tag `v1.0.0` |
| 2026-11-09 | 8 | Data uji dibersihkan atas permintaan owner: 2 akun uji dan semua datanya dihapus (users, dompet, kategori, foto, arsip = 0), folder `uploads`, `archives`, dan backup lama dikosongkan. Owner daftar ulang dengan kode undangan baru |
| 2026-11-09 | 8 | Tag `v1.0.0` di `c4f162d`: workflow sukses, `direkapin-1.0.0.apk` (62,6 MB) terbit di GitHub Releases. Slice ditutup. Sisa owner: `LATEST_APK_VERSION=1.0.0` di `.env` mini PC |
| 2026-11-09 | — | Coverage backend diukur (v8, `--no-save`): statements 91,9%, lines 92,8%; modul inti ≥ 87%. `backup.job.ts` 33% karena test restore dilewati tanpa `pg_dump` di laptop, sudah diuji manual di mini PC. `npm audit`: 3 high + 3 moderate dari `deepmerge-ts` (lewat Prisma CLI, hanya membaca config sendiri) dan `minimatch` (lewat `archiver` glob, tidak dipakai). Tidak bisa dicapai input user; perbaikan butuh Prisma 7 / downgrade `archiver`, ditunda |
| 2026-11-09 | 9 | Kode selesai: backend 192 lolos + 1 dilewati (6 test baru biaya admin), mobile 165 lolos, lint dan analyze bersih. Migrasi jalan di database test kosong. Sisa: deploy ke mini PC, tag `v1.1.0`, uji HP asli |
| 2026-11-09 | 9 | Tag `v1.1.0` di `04b52b2`: workflow sukses, `direkapin-1.1.0.apk` (62,6 MB) terbit. Sisa: deploy `api` di mini PC, `LATEST_APK_VERSION=1.1.0`, uji HP asli |
| 2026-11-09 | 9 | Biaya admin dari dompet asal dan tujuan serta keterangan saldo sesuai di HP asli lewat APK `v1.1.0` menurut owner. Slice ditutup. WiFi kantor owner (FortiGate SSL inspection) memblokir API; owner memakai data seluler, pengecualian domain di FortiGate tidak dikejar |
| 2026-11-09 | — | Gate sebelum mengundang teman dipersingkat jadi 3 hari atas keputusan owner (D-57). Job arsip pergantian bulan dan rotasi backup 14 hari dicek saat terjadi |
| 2026-11-10 | 10 | Kode selesai, belum di-commit: backend 196 lolos + 1 dilewati, mobile 170 lolos, lint dan analyze bersih. Sisa: uji HP lewat build debug ke backend laptop, lalu commit, deploy, rilis `v1.2.0` |
