# Widget "Hari ini": tema + gambar penyemangat Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Widget mengikuti 7 tema app dengan latar pudar berupa maskot tema (pose luwes) atau foto penyemangat pilihan owner.

**Architecture:** Dibangun di atas `docs/superpowers/plans/2026-11-17-widget-hari-ini.md` (dikerjakan dulu). Dart menambah kunci `theme` dan path gambar ke penyimpanan widget; maskot pose `wave` digambar dengan `CustomPainter` yang ada lalu dirender ke PNG; foto disimpan lokal 640×320. Dart membakar saturasi 35% ke file gambar. Kotlin memilih drawable bingkai per tema, memuat bitmap latar dari path, dan menumpuk lapisan `surface` 55%.

**Tech Stack:** Flutter (`home_widget.renderFlutterWidget`, `flutter_image_compress`, `path_provider` — keduanya sudah terpasang), Kotlin RemoteViews.

**Spec:** `docs/superpowers/specs/2026-11-17-widget-tema-design.md`

## Global Constraints

- Tanpa dependency baru selain `home_widget` (plan widget dasar). Foto disimpan di `getApplicationDocumentsDirectory()/widget/`.
- Kunci tambahan: `theme` (`teal|kuning|biru|lavender|peach|mint|gelap`), `image` (path PNG/JPEG absolut), `imageKind` (`mascot|photo`).
- Gambar = latar penuh widget (semua ukuran). Maskot PNG 640×320 px; foto JPEG 640×320 px (potong tengah 2:1) kualitas 85. Saturasi 35% dibakar di Dart; lapisan `surface` 55% di Kotlin.
- Foto tidak pernah dikirim ke server.
- Copy persis: `Gambar widget`, `Maskot tema`, `Foto dari galeri`.
- Warna drawable per tema = tabel DESIGN.md (`background`/`surface`, teks, masuk/keluar); maskot pakai warna `primary` tema seperti di app.
- Commit hanya jika owner minta.

## Review Focus

1. Ganti tema saat widget terpasang → latar, teks, dan maskot ikut berubah tanpa membuka ulang app → test Task 1 (update dipanggil saat tema berubah).
2. Foto sangat besar / HEIC → tetap tampil, bitmap 640×320 (aman untuk batas memori RemoteViews) → test Task 2 (ukuran file hasil).
3. File foto terhapus/hilang (HP dibersihkan) → widget kembali ke maskot, tidak kosong → cek Kotlin Task 3 + test Task 2 (path tidak ada → `imageKind` mascot).
4. Pilih foto lalu batal di galeri → pilihan tetap seperti sebelumnya → test Task 2.
5. Maskot 7 hewan pose `wave` render tanpa overflow di 640×320 dan teks tetap kebaca di atas latar → smoke test Task 1 + cek manual Task 3.

---

### Task 1: Maskot full badan + tema ke widget (Dart)

> Sebelum mulai: owner setuju mockup `widget_latar_maskot_pudar_mockup` (pose luwes, latar pudar).

**Files:**
- Modify: `mobile/lib/core/widgets/mascot.dart` (`MascotPose.wave`: badan miring, satu sirip/sayap/kaki melambai, kaki tidak simetris, pipi merah), `mobile/lib/core/home_widget/today_widget.dart` (kunci `theme`, render maskot 640×320 di kanan-bawah dibungkus `ColorFiltered` saturasi 0.35), pemicu ganti tema (provider tema di `core/theme/`)
- Test: `mobile/test/core/widgets/mascot_test.dart` (atau file maskot yang ada), `mobile/test/core/home_widget/today_widget_test.dart`

**Interfaces:**
- Produces: `String widgetThemeKey(AppThemeId id)` → salah satu 7 kunci; `List<double> saturationMatrix(double s)` (matriks 4×5 standar luminans Rec.709); `TodayWidgetService.updateImage({required String path, required String kind})`.

- [ ] **Step 1: Test gagal:** `Mascot(pose: MascotPose.wave)` untuk tiap `Animal` render tanpa overflow dalam `SizedBox(640, 320)`; `saturationMatrix(1)` = identitas, `saturationMatrix(0)` baris R=G=B (`tester.takeException()` null); `widgetThemeKey` memetakan 7 tema; ganti tema → `FakeTodayWidgetService.updates.last['theme']` = kunci baru dan `renderCount` bertambah (maskot) hanya bila `imageKind` = `mascot`.
- [ ] **Step 2:** `flutter test test/core` → FAIL.
- [ ] **Step 3:** Implement. Ekspresi `happy` bila `today.hasEntry`.
- [ ] **Step 4:** test → PASS.

### Task 2: Pilihan gambar widget (Dart)

**Files:**
- Create: `mobile/lib/core/home_widget/widget_image.dart` — `Future<String?> prepareWidgetPhoto(File picked)` (potong tengah 2:1 → 640×320, saturasi 35% lewat `dart:ui` canvas + `saturationMatrix`, simpan JPEG 85), simpan path & jenis di penyimpanan lokal (pola pengaturan tema yang sudah ada).
- Modify: `mobile/lib/features/settings/presentation/profile_screen.dart` (baris `Gambar widget` → sheet `Maskot tema` / `Foto dari galeri`)
- Test: `mobile/test/core/home_widget/widget_image_test.dart`, `test/features/settings/` (sheet)

- [ ] **Step 1: Test gagal:** foto 3000×2000 → hasil 640×320 JPEG, piksel merah murni jadi tidak murni (saturasi turun); batal pilih → tidak ada update; pilih `Maskot tema` → file foto lama dihapus, `imageKind` `mascot`; path tersimpan tidak ada di disk saat sinkron → kembali ke maskot.
- [ ] **Step 2:** `flutter test test/core/home_widget test/features/settings` → FAIL.
- [ ] **Step 3:** Implement memakai `PhotoService` untuk memilih (galeri, satu foto), `flutter_image_compress` untuk perkecil awal, lalu `dart:ui` untuk crop + pudar + encode.
- [ ] **Step 4:** test → PASS; `flutter analyze` bersih.

### Task 3: Android — latar per tema + gambar

**Files:**
- Create: `mobile/android/app/src/main/res/drawable/today_widget_bg_{teal,kuning,biru,lavender,peach,mint,gelap}.xml`
- Modify: `TodayWidgetProvider.kt`, `res/layout/today_widget.xml` (FrameLayout root `clipToOutline`: ImageView latar `match_parent` `centerCrop` → View lapisan → isi teks + tombol; bingkai = drawable per tema di atas), hapus `values-night` warna widget dari plan dasar.

- [ ] **Step 1:** Kotlin: `setInt(R.id.root, "setBackgroundResource", bgFor(theme))`; `setTextColor` dari kunci warna; `setInt(R.id.scrim, "setBackgroundColor", surface dengan alpha 0x8C)`; `BitmapFactory.decodeFile(image)` → `setImageViewBitmap`; file tidak ada → ImageView latar `GONE` (latar polos tema).
- [ ] **Step 2:** `flutter build apk --debug` sukses; `flutter analyze` dan `flutter test` bersih.
- [ ] **Step 3:** Uji manual: 7 tema, maskot vs foto, ganti tema dengan widget terpasang, hapus foto, ukuran 2×1/4×1/4×2.

### Task 4: Dokumen

- [ ] `docs/PRD.md` (ENG-05 tambahan), `docs/DECISIONS.md` (D-83: tema widget lewat drawable statis + warna dari app; gambar = latar pudar saturasi 35%; foto lokal 640×320 tidak diupload), `docs/DESIGN.md` (pose maskot `wave`, widget latar pudar), `docs/TASKS.md` (Slice 24 diperluas).
