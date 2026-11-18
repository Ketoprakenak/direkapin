# Widget layar utama "Hari ini" (ENG-05) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Widget Android yang menampilkan Keluar/Masuk hari ini, dengan tombol + yang langsung membuka form Catat.

**Architecture:** App (Dart) menulis teks siap tampil ke penyimpanan widget lewat `home_widget` setiap data dashboard baru; `AppWidgetProvider` Kotlin hanya membaca dan menampilkannya (RemoteViews). Tombol + membuka app dengan URI `direkapin://catat` yang diterjemahkan router ke form transaksi.

**Tech Stack:** Flutter 3 + `home_widget` (baru); Kotlin `HomeWidgetProvider`; Android XML (layout, drawable, appwidget-provider).

**Spec:** `docs/superpowers/specs/2026-11-17-widget-hari-ini-design.md`

## Global Constraints

- Satu dependency baru: `home_widget` (versi stabil terbaru yang mendukung Flutter 3.47); dicatat di `docs/DECISIONS.md` D-82 atas izin owner (2026-11-17).
- Tanpa perubahan backend, `schema.prisma`, atau kontrak API.
- Kunci data widget: `date`, `expense`, `income`, `status` (string). Nama provider Android: `TodayWidgetProvider`. URI tombol +: `direkapin://catat`.
- Copy persis: `Hari ini`, `Keluar`, `Masuk`, `Belum dicatat hari ini`, `Sudah dicatat`, `Masuk dulu di Direkapin`.
- Saldo tidak pernah ditulis ke penyimpanan widget.
- Format uang hanya lewat `core/format/money.dart` (di Dart). Commit hanya jika owner minta.

## Review Focus

1. App belum dibuka sejak kemarin → widget tidak menampilkan angka kemarin sebagai "hari ini" → test Task 1 (`date` ditulis) + cek manual Task 2 (Kotlin membandingkan tanggal).
2. Logout → angka hilang dari layar utama → test Task 1.
3. Tap + saat belum login → Login, bukan crash → test Task 1 (router).
4. Lebar widget 2×1 → teks tidak terpotong jadi "Rp4…" → cek manual Task 2.
5. Sinkron gagal (plugin error di HP lama) → app tetap jalan, hanya di-log → test Task 1.

---

### Task 1: Dart — tulis data + rute dari widget

**Files:**
- Modify: `mobile/pubspec.yaml` (+`home_widget`), `mobile/lib/features/shell/presentation/app_shell.dart` (panggil sinkron setelah `_syncReminders`), sesi logout (tempat `_tokens.clear()` / `sessionProvider` keluar), `mobile/lib/core/router/router.dart` (rute/redirect untuk `direkapin://catat`)
- Create: `mobile/lib/core/home_widget/today_widget.dart` — `TodayWidgetService` (interface tipis di atas `HomeWidget`, di-provide lewat Riverpod supaya bisa dipalsukan di test) dan fungsi murni `Map<String, String> todayWidgetData(Dashboard d)`.
- Test: `mobile/test/core/home_widget/today_widget_test.dart`, tambahan di `test/features/shell/app_shell_test.dart`; `FakeTodayWidgetService` di `test/helpers/fake_server.dart` (override default di `pumpRoutedApp`, pola `FakeReminderService`).

**Interfaces:**
- Produces: `todayWidgetData(Dashboard d) → {'date': d.today.date, 'expense': '−Rp45.000', 'income': '+Rp0', 'status': 'Belum dicatat hari ini' | 'Sudah dicatat'}`.
- Produces: `TodayWidgetService.update(Map<String,String>)`, `.clear()`; implementasi asli memanggil `HomeWidget.saveWidgetData` per kunci lalu `HomeWidget.updateWidget(androidName: 'TodayWidgetProvider')`, semua dalam `try` (gagal = `debugPrint`).

- [ ] **Step 1: Test gagal:**
  - unit: dashboard `last7Days.last = {income: 0, expense: 45000}`, `hasEntry: true`, `date: '2026-11-17'` → map persis `{'date':'2026-11-17','expense':'−Rp45.000','income':'+Rp0','status':'Sudah dicatat'}`; `hasEntry: false` → `status` `Belum dicatat hari ini`.
  - shell: Beranda dimuat → `FakeTodayWidgetService.updates` berisi satu map dengan `date` hari ini; Keluar → `clears == 1`.
  - service melempar → Beranda tetap tampil.
  - router: buka `direkapin://catat` (lewat `HomeWidget.widgetClicked` palsu / `initiallyLaunchedFromHomeWidget`) saat login → form Catat tampil; tanpa token → Login.
- [ ] **Step 2:** `flutter test test/core/home_widget test/features/shell` → FAIL.
- [ ] **Step 3:** Implement; `flutter pub get`.
- [ ] **Step 4:** test → PASS; `flutter analyze` bersih.

### Task 2: Android native — widget

> Sebelum mulai: mockup (show_widget) widget ukuran 2×1, 4×1, 4×2 terang/gelap, tunggu "gas".

**Files:**
- Create: `mobile/android/app/src/main/kotlin/id/my/direkapin/app/TodayWidgetProvider.kt`, `res/layout/today_widget.xml`, `res/xml/today_widget_info.xml` (`minWidth` 110dp/2 sel, `targetCellWidth 4`, `targetCellHeight 1`, `resizeMode horizontal|vertical`, `updatePeriodMillis 0`), `res/drawable/today_widget_bg.xml` (stroke 2dp, radius 16dp), `res/values/today_widget_colors.xml` + `res/values-night/…`
- Modify: `AndroidManifest.xml` (receiver `TodayWidgetProvider` + `APPWIDGET_UPDATE`, intent-filter `VIEW` scheme `direkapin` host `catat` di MainActivity), `res/values/strings.xml` (label widget `Direkapin · Hari ini`)

- [ ] **Step 1:** Implement `TodayWidgetProvider : HomeWidgetProvider`: baca 4 kunci; jika `date` ≠ tanggal lokal hari ini → `Rp0`/`Rp0`/`Belum dicatat hari ini`; tanpa data → `Masuk dulu di Direkapin`; `onAppWidgetOptionsChanged` sembunyikan baris Masuk bila `OPTION_APPWIDGET_MIN_WIDTH < 180`. Tombol + → `HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java, Uri.parse("direkapin://catat"))`; root → buka MainActivity.
- [ ] **Step 2:** `flutter build apk --debug` sukses; `flutter analyze`, `flutter test` bersih.
- [ ] **Step 3:** Uji manual di HP: tambah widget, ubah ukuran 2×1/4×1/4×2, catat transaksi lalu kembali ke layar utama (angka berubah), tap + (form Catat), mode gelap, keluar akun.

### Task 3: Dokumen

- [ ] `docs/PRD.md` (ENG-05), `docs/DECISIONS.md` (D-82: `home_widget`, data didorong app, tanpa saldo), `docs/TASKS.md` (Slice 24).
