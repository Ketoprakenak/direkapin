# Tema penuh + maskot + transisi halus — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 7 tema bawaan yang mengubah warna, bentuk, penanda kalender, gaya tab, dan maskot seluruh app, dipilih dari layar Tema, dengan transisi horizontal halus.

**Architecture:** Satu daftar `appThemes` (data murni) di `core/theme/app_themes.dart`. `buildTheme(AppThemeData)` memasang `ColorScheme` + dua `ThemeExtension` (`AppColors` warna, `AppStyle` bentuk/penanda/maskot) + transisi halaman. Widget membaca `AppColors.of` / `AppStyle.of`. Pilihan tema = notifier Riverpod yang menyimpan id di secure storage.

**Tech Stack:** Flutter 3, Riverpod generator, go_router `StatefulShellRoute`, `CustomPainter`, flutter_secure_storage. Tanpa dependency baru.

**Spec:** `docs/superpowers/specs/2026-11-11-tema-penuh-design.md`

## Global Constraints

- Tanpa dependency baru; tidak menyentuh backend, `openapi.yaml`, `schema.prisma`.
- Widget tanpa warna/ukuran hardcode; semua dari tema/tokens.
- Teal dan Gelap = nilai `lightScheme`/`darkScheme`/`AppColors.light`/`AppColors.dark` sekarang, persis.
- Kontras: teks, masuk, keluar ≥ 4.5:1 terhadap `surface` dan `background`; `onPrimary` vs `primary` ≥ 4.5:1; `ink` vs `surface` ≥ 4.5:1. Nilai tabel spec boleh digelapkan seperlunya untuk lolos.
- Masuk = nada hijau, keluar = nada merah/koral di semua tema.
- Warna kategori/dompet tidak ikut tema.
- `MediaQuery.disableAnimations` → tanpa animasi transisi.
- Tidak ada commit; owner commit setelah uji HP. Format: `dart format <file yang diubah>` saja (jangan `dart format lib`).
- Setelah ubah provider: `dart run build_runner build --delete-conflicting-outputs`.

## Review Focus

1. Pindah tab cepat berkali-kali (tap sebelum animasi selesai) → tidak ada tab kosong/tertumpuk, tab terakhir yang tampil. Test di Task 6.
2. User lama dengan `themeMode=dark` tersimpan → app dibuka langsung Gelap, tanpa kedip Teal yang lama. Test di Task 2 (migrasi) + `app.dart` memakai `value ?? appThemes.first`.
3. Tema pastel + teks sekunder/nominal kecil di kartu → tetap terbaca. Test kontras di Task 1 mencakup `textSecondary` ≥ 3:1.
4. Back dari layar dalam (detail transaksi) → geser balik ke kanan, state form/tab tidak hilang. Dicek di Task 6 via test yang ada + uji HP.
5. Ganti tema saat sedang di layar Tema → seluruh app ikut, termasuk tab lain dan kalender, tanpa restart. Test di Task 5.

---

### Task 1: Data tema + `buildTheme`

**Files:**
- Create: `mobile/lib/core/theme/app_themes.dart`
- Modify: `mobile/lib/core/theme/tokens.dart` (hapus `Accent`, `accents`, `_pastelOn`, top-level `moodTints`; tambah field `moodTints` di `AppColors`)
- Modify: `mobile/lib/core/theme/app_theme.dart`
- Modify: `mobile/test/helpers/fake_server.dart:144` (`testTheme`)
- Test: `mobile/test/core/theme/app_themes_test.dart`

**Interfaces:**
- Produces:
  - `enum MarkerStyle { icon, dot, bar }`, `enum NavStyle { pill, line }`, `enum Animal { turtle, chick, whale, cat, hamster, frog, owl }`
  - `class AppStyle extends ThemeExtension<AppStyle>` { `double cardRadius`, `double dateRadius` (radius px untuk kotak tanggal 24 px; bulat = 12), `MarkerStyle marker`, `NavStyle nav`, `Animal animal`; `static AppStyle of(BuildContext)` }
  - `AppColors` + `final Map<String, Color> moodTints` (kunci 5 emoji mood yang ada)
  - `class AppThemeData` { `String id`, `String name`, `Brightness brightness`, `ColorScheme scheme`, `AppColors colors`, `AppStyle style`, `Color ink` }
  - `const List<AppThemeData> appThemes` urut: `teal`, `yellow`, `sky`, `lavender`, `peach`, `mint`, `dark`
  - `AppThemeData themeById(String? id)` (tak dikenal → `appThemes.first`)
  - `ThemeData buildTheme(AppThemeData t)`

- [ ] **Step 1: Tulis test gagal** `app_themes_test.dart`:
  - `'7 tema, id unik, urutan sesuai spec'` → ids == `['teal','yellow','sky','lavender','peach','mint','dark']`.
  - `'Teal dan Gelap = warna lama'` → `themeById('teal').scheme.primary == lightScheme.primary`, `.colors.expense == Color(0xFFDC2626)`; `themeById('dark').brightness == Brightness.dark`, `.colors.income == Color(0xFF4ADE80)`.
  - `'kontras tiap tema'` → untuk tiap tema dan tiap bg di `[scheme.surface, colors.background]`: rasio(`scheme.onSurface`) ≥ 4.5, rasio(`colors.income`) ≥ 4.5, rasio(`colors.expense`) ≥ 4.5, rasio(`colors.textSecondary`) ≥ 3; rasio(`onPrimary`,`primary`) ≥ 4.5; rasio(`ink`, `surface`) ≥ 4.5. Helper test `double contrast(Color a, Color b)` = (L1+0.05)/(L2+0.05) via `computeLuminance()`.
  - `'masuk hijau, keluar merah'` → `HSVColor.fromColor(income).hue` di 90–170; `expense` hue < 20 atau > 330.
  - `'id asing → Teal'` → `themeById('merah').id == 'teal'`, `themeById(null).id == 'teal'`.
  - `'buildTheme memasang extension, ink, radius kartu'` → `buildTheme(themeById('peach'))`: `extension<AppStyle>()!.animal == Animal.hamster`; textButton foreground == `ink`; `cardTheme.shape` radius == 24.
- [ ] **Step 2:** `flutter test test/core/theme/app_themes_test.dart` → FAIL (file belum ada).
- [ ] **Step 3: Implementasi.** Nilai warna, sudut, bentuk tanggal, penanda, tab, hewan = tabel spec. `dateRadius`: bulat 12, kotak-bulat 8, kotak-bulat kecil 6. `moodTints` per tema: Teal/Gelap = nilai sekarang; tema pastel = 5 mood dengan hue sama tapi lebih lembut (builder pilih). Gelapkan nilai pastel yang gagal kontras (catat untuk Task 7). `buildTheme`: `colorScheme` = `t.scheme`, extensions `[t.colors, t.style]`, card radius `t.style.cardRadius`, text/outlined button foreground `t.ink`, `navigationBarTheme` indicator: pill → `indicatorColor: scheme.primaryContainer`; line → `indicatorColor: Colors.transparent` + `indicatorShape: UnderlineInputBorder(borderSide: BorderSide(color: t.ink, width: 2))`; `pageTransitionsTheme` diisi di Task 6 (sementara bawaan). `testTheme` = `buildTheme(appThemes.first)`.
- [ ] **Step 4:** test file ini PASS; `flutter analyze` hanya error di pemakai lama `accents`/`moodTints` (diselesaikan Task 2 & 4).

### Task 2: Pilihan tema tersimpan + `app.dart`

**Files:**
- Modify: `mobile/lib/features/settings/providers/settings_providers.dart` (hapus `AppThemeMode`, `AppAccent`)
- Modify: `mobile/lib/app.dart`
- Modify: `mobile/test/features/archive/archive_test.dart` (ganti test tema & aksen lama)

**Interfaces:**
- Consumes: `appThemes`, `themeById`, `buildTheme` (Task 1)
- Produces: `@Riverpod(keepAlive: true) class AppThemeChoice` → `Future<AppThemeData> build()`, `Future<void> set(AppThemeData t)`; provider `appThemeChoiceProvider`. Kunci storage `theme`.

- [ ] **Step 1: Test gagal** (unit, `ProviderContainer`, `FlutterSecureStorage.setMockInitialValues`):
  - `'tanpa simpanan → Teal'`; `'theme=mint → Mint'`; `'migrasi themeMode=dark → Gelap'`; `'themeMode=light → Teal'`; `'theme=merah → Teal'`; `'set() menulis kunci theme'` (baca storage == `'lavender'`).
- [ ] **Step 2:** jalankan → FAIL.
- [ ] **Step 3:** `build()`: baca `theme`; jika null baca `themeMode` (`dark` → `'dark'`); `themeById`. `app.dart`: `final t = ref.watch(appThemeChoiceProvider).value ?? appThemes.first;` `theme: buildTheme(t)`, `themeMode: t.brightness == Brightness.dark ? ThemeMode.dark : ThemeMode.light`, `darkTheme` dihapus. build_runner.
- [ ] **Step 4:** test PASS.

### Task 3: Maskot

**Files:**
- Create: `mobile/lib/core/widgets/mascot.dart`
- Test: `mobile/test/core/widgets/mascot_test.dart`

**Interfaces:**
- Consumes: `Animal`, `AppStyle` (Task 1)
- Produces: `enum MascotExpression { happy, neutral }`; `class Mascot extends StatelessWidget { const Mascot({super.key, this.animal, this.expression = MascotExpression.neutral, this.size = 48, this.semanticLabel}); }` — `animal` null = `AppStyle.of(context).animal`; `semanticLabel` null = dikecualikan dari semantics. `String animalName(Animal a)` → 'Penyu','Anak ayam','Paus kecil','Kucing','Hamster','Katak','Burung hantu'.

- [ ] **Step 1: Test gagal:** `'semua hewan dan ekspresi tergambar tanpa error'` (pump tiap kombinasi di `SizedBox(64)` dengan `testTheme`, cek `find.byType(CustomPaint)` ada, tanpa exception); `'tanpa animal pakai hewan tema'` (tema peach → painter animal == hamster; ekspos `animal` lewat getter painter atau `Semantics` label); `'semanticLabel muncul'`.
- [ ] **Step 2:** FAIL.
- [ ] **Step 3:** satu `CustomPainter` `_MascotPainter(animal, expression, colors)`: badan chubby dasar (oval) + ciri khas per hewan (penyu: cangkang bermotif + kepala; ayam: paruh, jambul, sayap; paus: sirip ekor, semburan; kucing: kuping, kumis, corak dahi; hamster: kuping bulat, pipi besar, perut; katak: mata di atas kepala, mulut lebar; burung hantu: tanduk bulu, mata besar, sayap). Detail sedang: garis tepi tipis (ink, alpha 0.6), bayangan lembut di bawah badan, kilau kecil, perut/pipi warna container. Warna: badan `scheme.primary`, perut `primaryContainer`, garis & mata `ink`, blush `colors.expense` alpha 0.3. Ekspresi: happy = mata lengkung + senyum, neutral = mata bulat + mulut kecil. Semua ukuran relatif terhadap `size`.
- [ ] **Step 4:** PASS.

### Task 4: Tema dipakai di layar (kalender, Beranda, EmptyState, chart)

**Files:**
- Modify: `mobile/lib/features/calendar/presentation/widgets/calendar_cell.dart`
- Modify: `mobile/lib/core/widgets/state_views.dart` (`EmptyState`: hapus param `icon`, ganti ikon dengan `Mascot(size: Spacing.xxl * 2)`)
- Modify: `mobile/lib/features/budget/presentation/budget_screen.dart:91` (hapus `icon:`)
- Modify: `mobile/lib/features/dashboard/presentation/dashboard_screen.dart` (Mascot di judul: `size: Spacing.xl`, happy jika `today.hasEntry`)
- Test: `mobile/test/features/calendar/calendar_screens_test.dart`, `mobile/test/features/money/money_screens_test.dart`

**Interfaces:**
- Consumes: `AppStyle`, `AppColors.moodTints`, `Mascot` (Task 1, 3)

- [ ] **Step 1: Test gagal:** sel kalender dipump dengan `buildTheme(themeById(id))`:
  - `teal` → ikon `south_west_rounded`/`north_east_rounded` ada (perilaku lama).
  - `yellow` (dot) → tidak ada ikon panah; ada 2 `Container` lingkaran penanda berwarna income/expense.
  - `sky` (bar) → penanda persegi panjang (lebar > tinggi) berwarna income/expense.
  - mood tint memakai `AppColors.of(context).moodTints['😢']` alpha 0.35 (ganti test lama baris 180); kotak tanggal `borderRadius` == `AppStyle.dateRadius`.
  - Beranda: `find.byType(Mascot)` ada di AppBar; dengan `hasEntry: true` expression == happy.
  - EmptyState menampilkan `Mascot`.
- [ ] **Step 2:** FAIL.
- [ ] **Step 3:** `calendar_cell`: kotak tanggal pakai `BorderRadius.circular(style.dateRadius)` (bukan `BoxShape.circle`), penanda via switch `style.marker` (icon = perilaku sekarang; dot = lingkaran `Spacing.xs + 2`; bar = `Spacing.sm × 3`), warna dari `AppColors`. Chart (`expense_bar_chart`, `_DailyLineChart`) dan bar budget sudah membaca `AppColors`/scheme — cukup verifikasi, tanpa ubah.
- [ ] **Step 4:** `flutter test` penuh PASS, `flutter analyze` bersih.

### Task 5: Layar Tema + baris Profil

**Files:**
- Create: `mobile/lib/features/settings/presentation/theme_screen.dart`
- Modify: `mobile/lib/features/settings/presentation/profile_screen.dart` (hapus `_ThemeTile`, `_AccentTile`; tambah `ListTile` "Tema")
- Modify: `mobile/lib/core/router/router.dart` (`Routes.themes = 'themes'`, `GoRoute(path: '/tema')` top-level seperti `/kategori`)
- Test: `mobile/test/features/settings/theme_screen_test.dart`; perbarui `mobile/test/features/shell/app_shell_test.dart` jika perlu `ensureVisible`

**Interfaces:**
- Consumes: `appThemeChoiceProvider`, `appThemes`, `Mascot`, `animalName`

- [ ] **Step 1: Test gagal:**
  - `'Profil: baris Tema menampilkan nama tema aktif dan membuka layar Tema'` → teks 'Tema' + 'Teal'; tap → `find.text('Kuning pastel')` ada.
  - `'layar Tema: 7 kartu, tap Lavender → tersimpan, centang pindah'` → 7 `Mascot`; tap 'Lavender'; storage `theme == 'lavender'`; `find.byIcon(Icons.check_circle_rounded)` 1, berada di kartu Lavender.
  - `'ganti tema mengubah Theme app'` → setelah tap 'Gelap', `Theme.of(context).brightness == Brightness.dark` (pakai `pumpRoutedApp` dengan override `theme` dari provider — helper perlu membaca `appThemeChoiceProvider`; ubah helper `pumpRoutedApp` agar `theme: buildTheme(ref.watch(appThemeChoiceProvider).value ?? appThemes.first)`, hapus `testTheme` jika tak dipakai lagi).
- [ ] **Step 2:** FAIL.
- [ ] **Step 3:** grid 2 kolom kartu: radius `t.style.cardRadius`, latar `t.colors.background`, isi `Mascot(animal: t.style.animal, size: 56)`, nama, 3 swatch (surface, primary, container), `+Rp25.000` (income) dan `−Rp25.000` (expense) via `formatRupiah`; kartu aktif border 2 px `ink` + `check_circle_rounded`. `Semantics(selected:, label: t.name)`. Tap → `set(t)`.
- [ ] **Step 4:** PASS.

### Task 6: Transisi horizontal

**Files:**
- Create: `mobile/lib/features/shell/presentation/animated_branch_container.dart`
- Modify: `mobile/lib/core/router/router.dart` (`StatefulShellRoute.indexedStack` → `StatefulShellRoute(navigatorContainerBuilder: ...)`)
- Modify: `mobile/lib/core/theme/app_theme.dart` (`pageTransitionsTheme`)
- Test: `mobile/test/features/shell/app_shell_test.dart`

**Interfaces:**
- Produces: `class AnimatedBranchContainer extends StatefulWidget { const AnimatedBranchContainer({super.key, required this.currentIndex, required this.children}); }`; `class HorizontalPageTransitionsBuilder extends PageTransitionsBuilder`.

- [ ] **Step 1: Test gagal:**
  - `'pindah tab menjaga posisi scroll Beranda'` → scroll Beranda 300, tap Kalender, settle, tap Beranda, settle → offset tetap 300.
  - `'tap tab cepat berturut-turut → tab terakhir tampil'` → tap Kalender, `pump(50ms)`, tap Laporan, `pump(50ms)`, tap Profil, settle → hanya konten Profil yang hit-testable (`find.text('Keluar')` visible) dan konten tab lain `Offstage`/tidak terlihat.
  - `'disableAnimations: pindah tab tanpa animasi'` → `MediaQuery(data: …copyWith(disableAnimations: true))`; tap Kalender; satu `pump()` → judul 'Kalender' tampil penuh (tidak ada `SlideTransition` dengan offset ≠ 0).
- [ ] **Step 2:** FAIL.
- [ ] **Step 3:** `AnimatedBranchContainer`: `Stack` semua `children`; cabang non-aktif & non-keluar dibungkus `Offstage` + `TickerMode(enabled: false)`; saat index berubah, satu `AnimationController` (250 ms, `Curves.easeOutCubic`) menggeser cabang baru dari `±0.15` lebar ke 0 + fade 0→1, dan cabang lama ke `∓0.15` + fade 1→0; arah = tanda `(new - old)`; perubahan saat animasi berjalan → reset controller dari kondisi sekarang ke target baru; cabang lama `IgnorePointer`. `disableAnimations` → durasi nol. `HorizontalPageTransitionsBuilder`: `SlideTransition` (0.15,0)→0 + `FadeTransition`, `secondaryAnimation` geser halaman bawah ke (-0.1,0); `disableAnimations` → return `child`. Pasang di `pageTransitionsTheme` untuk `TargetPlatform.android`.
- [ ] **Step 4:** test baru + seluruh suite PASS.

### Task 7: Docs + build

**Files:**
- Modify: `docs/DECISIONS.md` (tulis ulang D-63: tema penuh, 7 tema, simpan `theme` + migrasi `themeMode`, maskot kode, transisi; D-50 ditandai digantikan D-63)
- Modify: `docs/DESIGN.md` (ganti blok "Warna aksen" dengan tabel tema final — nilai setelah penyetelan kontras; aturan warna masuk/keluar per tema; sel kalender per gaya penanda; layar Tema; maskot; transisi)
- Modify: `docs/PRD.md` (ENG-03 → "Tema penuh 7 pilihan + maskot (D-63)")
- Modify: `docs/TASKS.md` (ganti baris "Warna aksen" dengan "Tema penuh + maskot + transisi (ENG-03, D-63)")

- [ ] **Step 1:** perbarui docs sesuai nilai akhir kode.
- [ ] **Step 2:** `flutter analyze` → `No issues found!`; `flutter test` → `All tests passed!`.
- [ ] **Step 3:** `flutter build apk --debug --dart-define=API_URL=http://192.168.53.6:3000` → `√ Built build\app\outputs\flutter-apk\app-debug.apk`.
