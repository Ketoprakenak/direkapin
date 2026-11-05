# Progres pengerjaan

Satu slice per sesi Claude Code. Centang item saat selesai dan ubah status slice.
Status: `Belum mulai` · `Sedang dikerjakan` · `Selesai`

**Slice aktif:** 7

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

## Slice 7 — Reminder, versi, CI APK · Status: Sedang dikerjakan
Ref: ENG-01, US-09, D-21
- [x] Notifikasi harian lokal: jadwal 30 hari ke depan (jam dari `/me`), dipasang ulang saat aplikasi dibuka, catatan disimpan, atau jam diubah; hari ini dilewati jika sudah mencatat
- [x] Banner update dari `/version`
- [ ] GitHub Actions: build APK release bertanda tangan saat push tag `v*` → GitHub Releases

## Slice 8 — Backup, arsip, deploy · Status: Belum mulai
Ref: ARC-01–05, US-10, PRD bagian 10, D-21–D-23
- [ ] Job `pg_dump` harian (simpan 14 hari)
- [ ] Job arsip harian idempoten (D-23) + `GET /archives`, `GET /archives/{id}/download`, penghapusan foto asli (D-22)
- [ ] Mobile: Arsip (S-13), Profil & Pengaturan (S-14), notifikasi arsip lokal (saat terdeteksi, hari ke-7, ke-25, tanggal 1)
- [ ] Uji `Dockerfile` dan `docker-compose.yml` di mini PC (ditunda dari Slice 0)
- [ ] Deploy: `cloudflared` di compose, panduan setup di README
- [ ] Checklist rilis PRD bagian 17 lolos → tag `v1.0.0`

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
