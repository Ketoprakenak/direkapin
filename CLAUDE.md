# Direkapin — panduan untuk Claude Code

Aplikasi Android pencatat keuangan harian + catatan kegiatan dalam satu kalender.
Maks. 4 user, self-hosted di mini PC rumah (Docker) dan diakses lewat Cloudflare Tunnel.

## Baca dulu sebelum mengerjakan apa pun

| File | Kapan dibaca |
|---|---|
| `docs/PRD.md` | Sumber kebutuhan. Fitur dirujuk pakai ID (FIN-01, US-03, dst.) |
| `docs/TASKS.md` | Slice yang sedang dikerjakan + statusnya |
| `docs/DECISIONS.md` | Keputusan teknis yang sudah final. Jangan diubah tanpa izin |
| `docs/openapi.yaml` | Kontrak API. Backend dan mobile wajib mengikutinya |
| `backend/prisma/schema.prisma` | Model data. Jangan ubah tanpa izin |
| `docs/DESIGN.md` | Token UI dan aturan tampilan (wajib untuk kerja di `mobile/`) |
| `backend/CLAUDE.md`, `mobile/CLAUDE.md` | Konvensi khusus tiap bagian |

## Stack

- Mobile: Flutter 3 (Dart), Android saja (minSdk 26)
- Backend: Node.js 22 LTS + TypeScript + Fastify 5 + Prisma 6
- Database: PostgreSQL 16
- Infra: Docker Compose (`api`, `db`, `cloudflared`) di mini PC
- CI: GitHub Actions → APK di GitHub Releases

## Struktur repo

```
direkapin/
├── mobile/            # Flutter app
├── backend/           # Fastify API + Prisma + job terjadwal
├── docs/              # PRD, kontrak API, design, keputusan, tasks
├── docker-compose.yml
└── .env.example
```

## Perintah

```bash
# Backend (dari backend/)
npm run dev                  # jalankan API lokal (butuh PostgreSQL 16 di laptop)
npm test                     # vitest
npm run lint                 # eslint + tsc --noEmit
npx prisma migrate dev       # buat & jalankan migrasi (dev)
npx prisma db seed           # seed kode undangan awal

# Mobile (dari mobile/)
flutter pub get
flutter test
flutter analyze
dart run build_runner build --delete-conflicting-outputs
flutter build apk --release --dart-define=API_URL=https://api.direkapin.my.id

# Infra (dari root, di mini PC; laptop tidak butuh Docker)
docker compose up -d --build     # semua service
docker compose logs -f api
```

## Aturan kerja (wajib)

1. **Kerjakan hanya slice yang diminta.** Jangan refactor, rename, atau "rapikan" bagian di luar slice.
2. **Rencanakan dulu.** Sebelum coding, tulis rencana singkat: file yang diubah, endpoint, layar, test. Tunggu persetujuan.
3. **Jangan tambah dependency** di luar yang tercantum di `docs/DECISIONS.md` tanpa izin.
4. **Ikuti kontrak.** Endpoint, field, dan format error harus sama persis dengan `docs/openapi.yaml`. Kalau kontrak perlu berubah, usulkan dulu.
5. **Jangan ubah `schema.prisma`** tanpa izin. Kalau perlu, usulkan perubahan + alasan.
6. **Kalau ambigu, tanya.** Jangan menebak kebutuhan yang tidak tertulis di PRD.
7. **Selesai = Definition of Done lolos** (lihat di bawah), lalu centang slice di `docs/TASKS.md`.

## Aturan data (tidak boleh dilanggar)

- Setiap query data user **wajib** difilter `userId` dari token. Data milik user lain → balas **404**, bukan 403.
- Nominal uang = **BigInt Rupiah** (tanpa desimal). Di JSON dikirim sebagai **integer**, bukan string/float.
- Saldo dompet **tidak disimpan**; selalu dihitung: saldo awal + pemasukan − pengeluaran ± transfer.
- Waktu disimpan **UTC** (`timestamptz`); konversi ke zona waktu user (default `Asia/Jakarta`) di batas tampilan/laporan.
- Tanggal tanpa jam (kegiatan, laporan) pakai format `YYYY-MM-DD`; bulan pakai `YYYY-MM`.
- Minggu = Senin–Minggu.
- Transfer tidak pernah masuk laporan pemasukan/pengeluaran.
- Foto **selalu** dikompres di HP sebelum upload (maks. 1600 px, target ≤ 400 KB). Server menolak > 2 MB.
- Jangan pernah commit `.env`, keystore, atau secret apa pun.

## Definition of Done

- [ ] Semua acceptance criteria user story terkait lolos
- [ ] Endpoint: validasi input, cek kepemilikan `userId`, test integrasi (1 sukses + 1 gagal minimal)
- [ ] Layar: state loading, kosong, error/offline ditangani
- [ ] `npm run lint`, `npm test`, `flutter analyze`, `flutter test` bersih
- [ ] Migrasi Prisma (jika ada) ter-commit dan jalan di database kosong
- [ ] `docs/TASKS.md` diperbarui
- [ ] Ringkasan di akhir: apa yang dibuat, cara mencoba, hal yang belum/ditunda

## Gaya commit

Conventional Commits, bahasa Inggris, scope = modul. Contoh: `feat(transactions): add wallet filter`, `fix(mobile): keep form state on upload error`.
