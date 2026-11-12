# Frame kartu + Laporan Custom + maskot ngintip — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Bagian utama tiap menu memakai frame tebal + bayangan keras, Laporan bergaya kapsul + kotak ringkasan dengan tab Custom (rentang tanggal) menggantikan Harian, dan maskot ngintip dari tab aktif di menu bawah.

**Architecture:** Dua widget frame bersama di `core/widgets` membaca nilai dari `AppStyle`/`AppColors` (ThemeExtension yang sudah ada). Backend menambah `GET /reports/range` yang memakai ulang fungsi periode di `reports.service.ts`. Maskot ngintip = lapisan `Stack` di atas `NavigationBar` di `AppShell`, digambar dengan painter maskot yang sudah ada.

**Tech Stack:** Flutter 3 (Riverpod generator, freezed, go_router, fl_chart), Fastify 5 + Zod + Prisma 6, vitest.

**Spec:** `docs/superpowers/specs/2026-11-11-frame-laporan-custom-design.md`

## Global Constraints

- Tanpa dependency baru. Pemilih rentang = `showDateRangePicker` bawaan Flutter.
- Jangan ubah `backend/prisma/schema.prisma`.
- `docs/openapi.yaml` hanya **ditambah** `/reports/range`; endpoint lain tidak berubah. `/reports/daily` tetap ada di backend.
- Widget tidak hardcode warna/ukuran/spacing; semua dari `tokens.dart` / `Theme.of(context)` / `AppStyle` / `AppColors`.
- Format uang/tanggal hanya lewat `core/format/`.
- Frame luar: garis 2 px, bayangan keras `blurRadius: 0` offset (4, 4), sudut `cardRadius` tema. Frame dalam: garis 2 px, tanpa bayangan, sudut `cardRadius / 2`. Warna garis + bayangan = `colorScheme.onSurface` di semua tema.
- Tab Laporan berurutan **Mingguan · Bulanan · Custom**; tidak ada Harian. Bawaan = Bulanan.
- Custom: rentang maks. 366 hari inklusif (`to − from ≤ 365` hari); `to < from` → 400; batas sama di HP; tidak bisa pilih tanggal setelah hari ini; bawaan = tanggal 1 bulan ini s.d. hari ini.
- Isi Custom = isi Bulanan (3 kotak, garis pengeluaran harian, donut Top 3/Semua, filter dompet), **tanpa** bagian Budget (budget per bulan).
- Maskot ngintip: ±30 dp, tidak menerima tap (`IgnorePointer`), dikecualikan dari Semantics, pindah 250 ms `easeOutCubic`, instan saat `MediaQuery.disableAnimations`.
- Jangan reformat file di luar baris yang diubah: jalankan `dart format` hanya pada file yang disentuh task itu.
- Tidak ada commit: owner commit setelah uji HP. Langkah "Commit" di task diganti "cek `git diff --stat` hanya berisi file task ini".

## Review Focus

1. Tema Gelap: garis/bayangan frame dan teks di kotak ringkasan tetap terbaca → test kontras per tema di Task 2.
2. Bayangan frame terpotong di tepi kanan layar atau ditimpa bagian berikutnya → Task 2 test: `FrameCard` menyisakan margin kanan/bawah ≥ offset.
3. Rentang Custom melintasi bulan/tahun (mis. 20 Des – 10 Jan) → backend test Task 1 + label sumbu grafik Task 3 memakai tanggal dari `series[i].label`, bukan nomor hari.
4. Ganti tab Laporan dari Custom ke Bulanan dan kembali: rentang terakhir tetap dipakai, tidak reset → Task 3 test.
5. Maskot menghalangi tap tombol menu atau FAB → Task 5 test: tap di titik maskot tetap memilih tab.

## Keputusan executor (tercatat untuk owner)

- **Dompet milik user lain di laporan**: spec menulis 404, tapi semua endpoint laporan yang ada menghasilkan **laporan kosong** (test `data user lain tidak ikut, dompet asing menghasilkan laporan kosong`). `/reports/range` mengikuti perilaku yang ada supaya konsisten; data user lain tetap tidak pernah ikut.
- Bagian Budget tidak tampil di Custom.

---

### Task 1: Backend `GET /reports/range` + kontrak

**Files:**
- Modify: `backend/src/modules/reports/reports.schemas.ts`, `reports.service.ts`, `reports.routes.ts`
- Modify: `docs/openapi.yaml` (setelah blok `/reports/monthly`; dan enum `period.type` di schema `Report`)
- Test: `backend/src/modules/reports/reports.test.ts` (describe baru `GET /reports/range`)

**Interfaces:**
- Produces: `GET /reports/range?from=YYYY-MM-DD&to=YYYY-MM-DD&wallet=<uuid?>` → `Report` dengan `period: { type: 'range', start: from, end: to }`, `series` per hari dari `from` s.d. `to`, `comparison` = periode sepanjang sama tepat sebelum `from`.
- `rangeReportQuery` (Zod), `getRangeReport(prisma, userId, from, to, walletId)`.

- [ ] **Step 1: Tulis test gagal** di `reports.test.ts`, pola sama dengan describe `monthly` (pakai helper yang ada di file itu):
  - `series per hari sepanjang rentang lintas bulan`: `from=2026-10-30&to=2026-11-02` → 200, `period` = `{type:'range',start:'2026-10-30',end:'2026-11-02'}`, `series.length === 4`, label pertama `2026-10-30`, total sesuai transaksi seed di rentang itu, transfer tidak dihitung.
  - `membandingkan dengan periode sepanjang sama sebelumnya`: pengeluaran di `2026-10-26..2026-10-29` masuk `comparison.previousExpense`; `changePct` null bila sebelumnya 0.
  - `menerima tepat 366 hari`: `from=2025-01-01&to=2026-01-01` → 200 (366 hari inklusif).
  - `menolak lebih dari 366 hari`: `from=2025-01-01&to=2026-01-02` → 400 `VALIDATION_ERROR`.
  - `menolak to sebelum from`: `from=2026-11-10&to=2026-11-09` → 400.
  - `menolak tanggal tidak valid dan tanpa token`: `from=2026-13-01` → 400; tanpa token → 401.
  - `data user lain tidak ikut, dompet asing menghasilkan laporan kosong`: sama dengan test daily yang ada.
- [ ] **Step 2:** `npm test -- reports` → FAIL (404 route).
- [ ] **Step 3:** Implementasi.
  - `rangeReportQuery = z.object({ from: dateString, to: dateString, wallet })` + `.refine` untuk `to >= from` dan selisih hari ≤ 365, pesan error Indonesia (`'Tanggal akhir tidak boleh sebelum tanggal awal'`, `'Rentang maksimal 366 hari'`).
  - `reportResponse.period.type` enum ditambah `'range'`.
  - `getRangeReport` memakai `getTotals`, `getSeries`, `getByCategory` seperti `getMonthlyReport`; periode sebelumnya: `end = addDays(from, -1)`, `start = addDays(from, -(n))` dengan `n` = jumlah hari rentang; `changePct` dihitung dengan cara yang sama seperti bulanan (ekstrak helper kecil hanya bila `getMonthlyReport` sudah punya ekspresi yang sama — jangan ubah perilaku bulanan).
  - Route `/reports/range` di `reports.routes.ts`, pola sama.
  - `openapi.yaml`: path `/reports/range` (summary `Laporan rentang tanggal custom, maks. 366 hari`, param `from`, `to` wajib `Date`, `WalletFilter`, 200 `Report`, 400 `ValidationError`); tambah `range` ke enum `period.type` di schema `Report`.
- [ ] **Step 4:** `npm test` dan `npm run lint` (dari `backend/`) → PASS semua.
- [ ] **Step 5:** `git diff --stat` hanya file di atas.

### Task 2: Token frame + widget `FrameCard` / `FrameBox`

**Files:**
- Modify: `mobile/lib/core/theme/app_themes.dart` (`AppStyle` + nilai per tema), `mobile/lib/core/theme/tokens.dart` (`AppColors`: 3 warna kotak ringkasan + nilai Teal/Gelap)
- Create: `mobile/lib/core/widgets/frame.dart`
- Test: `mobile/test/core/theme/app_themes_test.dart` (tambah), `mobile/test/core/widgets/frame_test.dart` (baru)

**Interfaces:**
- Produces:
  - `AppStyle.frameWidth` (double, 2) dan `AppStyle.frameOffset` (double, 4) — sama untuk semua tema.
  - `AppColors.incomeTint`, `AppColors.expenseTint`, `AppColors.importantTint` (Color): latar muda kotak ringkasan.
  - `class FrameCard extends StatelessWidget { const FrameCard({super.key, required Widget child, EdgeInsetsGeometry padding = const EdgeInsets.all(Spacing.md), Color? color, VoidCallback? onTap}); }` — frame luar. `color` null = `colorScheme.surface`. Membungkus dengan `Padding(right/bottom: frameOffset)` supaya bayangan tidak terpotong. `onTap` → `InkWell` dengan radius yang sama.
  - `class FrameBox extends StatelessWidget { const FrameBox({super.key, required Widget child, EdgeInsetsGeometry padding = const EdgeInsets.symmetric(horizontal: Spacing.sm, vertical: Spacing.xs), Color? color}); }` — frame dalam, tanpa bayangan, radius `cardRadius / 2`.

- [ ] **Step 1: Tulis test gagal.**
  - `frame_test.dart`: `FrameCard menggambar garis 2 dan bayangan keras (4,4) warna onSurface` — cari `DecoratedBox`/`Container` turunan, `BoxDecoration.border` lebar 2 warna `onSurface`, `boxShadow.single` `blurRadius == 0`, `offset == Offset(4,4)`; `FrameCard menyisakan ruang bayangan` — ukuran `FrameCard` = ukuran isi + 4 di kanan dan bawah (pakai `tester.getSize`); `FrameBox tanpa bayangan` — `boxShadow` null/kosong, radius = `cardRadius/2`. Jalankan untuk `appThemes.first` dan tema `dark`.
  - `app_themes_test.dart`: untuk tiap tema — kontras `onSurface` vs `colors.background` dan vs `scheme.surface` ≥ 3; kontras `colors.income` vs `incomeTint`, `expense` vs `expenseTint`, `scheme.onSurface` vs `importantTint` ≥ 4.5.
- [ ] **Step 2:** `flutter test test/core` → FAIL (field/kelas belum ada).
- [ ] **Step 3:** Implementasi field + nilai tint per tema (setel nada sampai test kontras lolos; Gelap pakai tint gelap seperti `#14301F/#3B1A18/#3A2E0C` dari mockup sebagai titik awal) + `frame.dart`.
- [ ] **Step 4:** `flutter test test/core` + `flutter analyze` → PASS.
- [ ] **Step 5:** `git diff --stat` hanya file task ini.

### Task 3: Laporan — tab kapsul, Custom, kotak ringkasan

**Files:**
- Modify: `mobile/lib/features/report/data/report_models.dart` (`ReportType { weekly, monthly, range }`), `mobile/lib/features/report/providers/report_providers.dart` (+ `.g.dart` via build_runner), `mobile/lib/features/report/presentation/report_screen.dart`
- Test: `mobile/test/features/report/report_test.dart`

**Interfaces:**
- Consumes: `FrameCard`, `FrameBox`, `AppColors.*Tint` (Task 2); `/reports/range` (Task 1).
- Produces: `reportProvider(ReportType.range, '<from>_<to>', walletId:)` → GET `/reports/range` dengan `from`/`to` hasil split key pada `_`.

- [ ] **Step 1: Tulis test gagal** (pakai `FakeServer`/`pumpRoutedApp` seperti test laporan yang ada; perbarui test yang memakai `Harian`):
  - `tab laporan Mingguan, Bulanan, Custom tanpa Harian`: tiga teks tab urut sesuai posisi x, `find.text('Harian')` nothing.
  - `Custom memanggil /reports/range dengan rentang bawaan`: tap `Custom` → `server.reads.last` path `/reports/range`, `from` = `YYYY-MM-01` bulan ini, `to` = hari ini.
  - `pilih rentang lewat pemilih`: tap label rentang → `DateRangePickerDialog` muncul; pilih 3 dan 17 → query `from`/`to` sesuai; `lastDate` pemilih = hari ini.
  - `rentang tetap setelah pindah tab`: pilih rentang, tap `Bulanan`, tap `Custom` → query sama dengan rentang terakhir.
  - `Custom tanpa Budget, dengan grafik dan donut`: data range berisi pengeluaran → `Pengeluaran per hari` dan `Pengeluaran per kategori` ada; `Budget` tidak ada.
  - `kotak ringkasan berframe`: tiga `FrameCard` dengan teks `Pemasukan`, `Pengeluaran`, `Selisih`.
- [ ] **Step 2:** `flutter test test/features/report` → FAIL.
- [ ] **Step 3:** Implementasi.
  - Hapus `ReportType.daily`, `_DayTransactions`, cabang daily di `_key`/`_label`/`_shift`/body.
  - State: `_range` (`DateTimeRange`, bawaan tanggal 1 bulan ini s.d. hari ini) terpisah dari `_anchor`.
  - Tab kapsul: widget privat `_PeriodTabs` dalam `FrameBox` berbentuk kapsul (radius penuh); tab aktif = latar `onSurface`, teks `surface`; dibuat dari `InkWell`/`Semantics(selected:)`, bukan `SegmentedButton`.
  - Baris periode: Mingguan/Bulanan = panah kiri/kanan yang ada + label di `FrameBox`; Custom = label `formatShortDate(from) – formatShortDate(to)` di `FrameBox` + ikon kalender, tap → `showDateRangePicker(firstDate: DateTime(2020), lastDate: today, initialDateRange: _range)`; hasil dengan selisih > 365 hari → `SnackBar('Rentang maksimal 366 hari')` dan tidak dipakai.
  - Dompet: `_WalletFilter` dibungkus `FrameBox` (border bawaan input dimatikan).
  - Ringkasan: `Row` 3 `FrameCard(color: *Tint)` berisi label + `AmountText`/nominal ringkas, label `Pemasukan`, `Pengeluaran`, `Selisih`.
  - Grafik garis + donut tampil untuk `monthly` dan `range`; grafik dan donut dibungkus `FrameCard`. `_DailyLineChart` diberi label sumbu dari `points[i].label` (hari dalam bulan untuk monthly seperti sekarang; untuk range tampilkan maks. ±6 label `formatShortDate`, selalu termasuk titik pertama dan terakhir).
  - Teks perbandingan: monthly tetap "bulan lalu"; range memakai "periode sebelumnya".
  - Budget hanya untuk `monthly`.
  - `dart run build_runner build --delete-conflicting-outputs` setelah ubah provider.
- [ ] **Step 4:** `flutter test` (semua) + `flutter analyze` → PASS.
- [ ] **Step 5:** `git diff --stat` hanya file task ini (+ `.g.dart`).

### Task 4: Frame di menu lain

**Files:**
- Modify: `mobile/lib/features/dashboard/presentation/dashboard_screen.dart`, `mobile/lib/features/calendar/presentation/calendar_screen.dart`, `mobile/lib/features/day/presentation/day_screen.dart`, `mobile/lib/features/budget/presentation/budget_screen.dart`, `mobile/lib/features/settings/presentation/profile_screen.dart`, `mobile/lib/features/settings/presentation/theme_screen.dart`
- Test: test layar terkait yang sudah ada (`test/features/money/money_screens_test.dart`, `test/features/calendar/calendar_screens_test.dart`, `test/features/budget/*`, `test/features/settings/theme_screen_test.dart`) + satu test baru per layar `bagian utama memakai FrameCard`.

**Interfaces:**
- Consumes: `FrameCard`, `FrameBox` (Task 2).

Pemetaan (frame luar = `FrameCard`, frame dalam = `FrameBox`):
- Beranda: `_BalanceCard` (ganti dekorasinya dengan `FrameCard`), blok streak (judul + `_StreakBadges`) dalam satu `FrameCard`, chip 7/30/100 di `_StreakBadges` → `FrameBox`; grafik 7 hari (judul + chart) `FrameCard`; `_RecentTransactions` `FrameCard`; blok "Hari ini" `FrameCard`.
- Kalender: `TableCalendar` dibungkus `FrameCard`.
- Hari: total Masuk/Keluar + mood dalam satu `FrameCard`; tiap kelompok (Kegiatan, Transaksi, Transfer) = judul + daftar dalam satu `FrameCard`. Padding horizontal halaman `Spacing.lg`.
- Budget: `BudgetCard` → `FrameCard(onTap:)` menggantikan `Card`.
- Profil: grup 1 = `_ProfileHeader` + `_ReminderTile`; grup 2 = Dompet, Kategori, Tema, Arsip foto; masing-masing satu `FrameCard`. Tombol Keluar tetap di luar.
- Tema: `_ThemeCard` memakai `FrameCard` (garis kartu terpilih tetap `ink` lewat `FrameCard` dengan check yang sudah ada; frame memakai warna tema kartu itu karena dibungkus `Theme`).

- [ ] **Step 1: Tulis test gagal**: per layar, `expect(find.byType(FrameCard), findsAtLeastNWidgets(n))` dengan n = jumlah bagian di atas untuk data contoh test itu; Beranda: chip badge berada di dalam `FrameBox` (`find.ancestor(of: find.text('7 hari'), matching: find.byType(FrameBox))`).
- [ ] **Step 2:** jalankan test layar terkait → FAIL.
- [ ] **Step 3:** Bungkus sesuai pemetaan. Jangan ubah logika/urutan isi. Bila tinggi test berubah sehingga item di luar layar, pakai `ensureVisible`/`scrollUntilVisible` di test, bukan mengubah layar.
- [ ] **Step 4:** `flutter test` + `flutter analyze` → PASS.
- [ ] **Step 5:** `git diff --stat` hanya file task ini.

### Task 5: Maskot ngintip di menu bawah

**Files:**
- Modify: `mobile/lib/core/widgets/mascot.dart` (pose baru), `mobile/lib/features/shell/presentation/app_shell.dart`
- Test: `mobile/test/core/widgets/mascot_test.dart`, `mobile/test/features/shell/app_shell_test.dart`

**Interfaces:**
- Produces: `enum MascotPose { full, peek }`; `Mascot({..., MascotPose pose = MascotPose.full})`. `peek` menggambar kepala + dua tangan di tepi bawah kanvas (badan tidak digambar), memakai palet + ciri hewan yang sama. Widget `NavPeekMascot` privat di `app_shell.dart`.

- [ ] **Step 1: Tulis test gagal.**
  - `mascot_test.dart`: `pose peek tergambar untuk semua hewan tanpa error` (pump tiap `Animal` dengan `pose: MascotPose.peek`, `tester.takeException()` null).
  - `app_shell_test.dart`:
    - `maskot ngintip berada di atas tab aktif`: pusat x maskot (cari via `Key('nav-peek-mascot')`) ≈ pusat x `NavigationDestination` aktif (toleransi 2 px), setelah tap tab Laporan dan `pumpAndSettle`, pindah ke pusat tab Laporan.
    - `maskot tidak menghalangi tap`: `tester.tapAt(pusat maskot)` saat tab Kalender aktif lalu tap tab lain lewat titik maskot setelah pindah — tab yang di bawah titik itu tetap terpilih; maskot di dalam `IgnorePointer` dan `ExcludeSemantics`.
    - `tanpa animasi saat disableAnimations`: `MediaQuery(disableAnimations: true)`, tap tab → setelah satu `pump()` posisi sudah di tab baru.
- [ ] **Step 2:** `flutter test test/core/widgets test/features/shell` → FAIL.
- [ ] **Step 3:** Implementasi.
  - `bottomNavigationBar:` = `Stack(clipBehavior: Clip.none)` berisi `NavigationBar` yang ada (tidak diubah) + `Positioned` maskot ukuran `Spacing.xxl` (≈30 dp sesuai token terdekat) dengan `top: -Spacing.lg` (menonjol ke atas), `left` dihitung dari lebar / 4 × (index + 0,5) − ukuran/2; animasi via `AnimatedPositioned` 250 ms `easeOutCubic`, durasi `Duration.zero` bila `MediaQuery.disableAnimationsOf(context)`.
  - Dibungkus `IgnorePointer` + `ExcludeSemantics`, key `ValueKey('nav-peek-mascot')`.
- [ ] **Step 4:** `flutter test` + `flutter analyze` → PASS.
- [ ] **Step 5:** `git diff --stat` hanya file task ini.

### Task 6: Docs

**Files:**
- Modify: `docs/DESIGN.md` (bagian frame luar/dalam + nilainya, kotak ringkasan + tint per tema, layar Laporan baru, maskot ngintip), `docs/PRD.md` (laporan: Harian diganti Custom maks. 366 hari), `docs/DECISIONS.md` (D-64: frame + laporan custom + maskot nav, termasuk keputusan dompet asing = laporan kosong dan Budget tidak di Custom), `docs/TASKS.md` (Slice 10: item baru dicentang).

- [ ] **Step 1:** Tulis perubahan docs sesuai isi Task 1–5 (nilai persis dari kode).
- [ ] **Step 2:** Verifikasi akhir dari root masing-masing: `backend/`: `npm run lint`, `npm test`; `mobile/`: `flutter analyze`, `flutter test` → semua bersih.
- [ ] **Step 3:** Build APK debug: `flutter build apk --debug --dart-define=API_URL=http://192.168.53.6:3000` → `√ Built`.
