# Tema penuh + maskot + transisi halus — desain

Tanggal: 2026-11-11 · Ref: ENG-03 · Menggantikan rencana "warna aksen" (D-63 versi pertama, belum di-commit)

## Maksud

Owner ingin pilihan tampilan yang terasa sebagai **tema utuh**, bukan sekadar warna tombol. Tema mengubah
seluruh app: warna semua layar (termasuk chart Laporan, kalender, budget), bentuk kartu dan simbol kalender,
gaya menu bawah, dan maskot hewan chubby. Perpindahan layar dan tab dibuat halus dan horizontal.
Tujuannya app terasa personal dan "adem", tanpa mengorbankan kejelasan arti warna (masuk vs keluar).

## Tujuan

- 7 tema bawaan: **Teal** (bawaan), **Kuning pastel**, **Biru langit**, **Lavender**, **Peach**, **Mint**, **Gelap**.
- Tiap tema mengatur: warna layar, warna penanda (masuk, keluar, kegiatan, penting), warna mood kalender,
  sudut kartu, bentuk tanggal kalender, gaya penanda kalender, gaya penanda tab aktif, dan maskot.
- Menu Tema = satu baris di Profil yang membuka layar Tema berisi kartu pratinjau.
- Maskot hewan chubby per tema, digambar dengan kode (CustomPainter), detail sedang.
- Transisi horizontal: antar tab bawah dan saat membuka layar dalam.

## Bukan tujuan

- Upload / impor tema buatan user (di-skip owner).
- Versi terang + gelap per tema; pilihan Sistem/Terang/Gelap dihapus. Gelap adalah satu tema sendiri.
- Mengubah warna kategori dan dompet (pilihan user, disimpan di server).
- Ganti set ikon menu per tema; font atau gambar latar per tema.
- Maskot PNG (bisa menyusul; desain menyiapkan titik tukarnya).
- Maskot bereaksi ke budget lewat batas.

## Anti-tujuan (gagal walau "jalan")

- Masuk dan keluar sulit dibedakan di salah satu tema.
- Teks atau angka sulit dibaca (kontras rendah), terutama di tema pastel.
- Pindah tab kehilangan posisi scroll / state layar (saat ini `StatefulShellRoute.indexedStack` menjaganya).
- Animasi tetap jalan saat HP disetel "kurangi animasi".

## Batasan

- Tanpa dependency baru (CLAUDE.md aturan 3). Semua pakai Flutter SDK + paket yang sudah ada.
- Tidak menyentuh backend, `openapi.yaml`, atau `schema.prisma`. Tema disimpan di HP (pola D-50).
- Widget tidak boleh hardcode warna/ukuran; semua dari tema (mobile/CLAUDE.md).
- Kerjakan hanya bagian ini; jangan rapikan layar lain di luar yang perlu membaca tema.

## Pendekatan (sudah dipilih owner)

**Cara tema sampai ke layar**
1. **Dipilih — satu paket spesifikasi tema sebagai `ThemeExtension`**, menggantikan/memperluas `AppColors`
   yang sudah ada. Widget membaca `AppTheme.of(context)`; tidak perlu jadi ConsumerWidget.
2. Ditolak — tiap widget membaca provider Riverpod: diff besar (banyak widget diubah jadi Consumer) tanpa untung.

**Cara gambar maskot**
1. **Dipilih — satu badan chubby dasar + ciri khas per hewan, CustomPainter, detail sedang** (garis tepi tipis,
   bayangan lembut, kilau, perut/pipi beda warna, motif). Warna dari tema. Dibungkus satu widget `Mascot` sehingga
   kelak bisa ditukar ke PNG tanpa mengubah pemanggil.
2. Ditolak — 7 painter terpisah penuh: ~7× kode, gaya mudah tak seragam.
3. Ditunda — PNG dari owner (detail ilustrator); butuh aset dari owner.

## Yang sudah diputuskan

### Daftar tema

| Tema | Maskot | Sudut kartu | Bentuk tanggal | Penanda kalender | Tab aktif |
|---|---|---|---|---|---|
| Teal | Penyu | 16 | bulat | ikon panah/kalender/bintang | kapsul |
| Kuning pastel | Anak ayam | 22 | kotak-bulat | titik | kapsul |
| Biru langit | Paus kecil | 12 | bulat | garis pendek | garis bawah |
| Lavender | Kucing | 20 | kotak-bulat | titik | kapsul |
| Peach | Hamster | 24 | bulat | ikon | kapsul |
| Mint | Katak | 14 | kotak-bulat kecil | garis pendek | garis bawah |
| Gelap | Burung hantu | 16 | bulat | ikon | kapsul |

Warna awal (dari mockup yang owner setujui; builder boleh menyetel nada demi kontras, lihat aturan kontras):

| Tema | latar | permukaan | teks | teks sekunder | garis | primary / on | container | ink (teks tombol) | masuk | keluar | kegiatan | penting |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| Teal | #FAFAF9 | #FFFFFF | #1C1917 | #78716C | #E7E5E4 | #0F766E / #FFFFFF | #CCFBF1 | #0F766E | #15803D | #DC2626 | #2563EB | #F59E0B |
| Kuning pastel | #FFFBEF | #FFFFFF | #3B3218 | #8A7E5C | #F1E8C8 | #F5DE8C / #3B3218 | #FBF3D5 | #6B5410 | #4E9A6A | #D0705F | #7FA6C9 | #D9A92E |
| Biru langit | #F5F9FD | #FFFFFF | #16263A | #6B7F96 | #DCE7F3 | #A7C7E7 / #16263A | #E3EEF8 | #1E4A75 | #3F9A78 | #CF6464 | #5B82CF | #E2AC45 |
| Lavender | #FAF8FD | #FFFFFF | #2A2140 | #7C7393 | #E9E3F3 | #C3B1E1 / #2A2140 | #EEE8F7 | #4B3478 | #4A9A7E | #CF6488 | #8776D2 | #E2AC45 |
| Peach | #FFF8F5 | #FFFFFF | #3A221B | #93766C | #F4E2DB | #F7C5B5 / #3A221B | #FDECE6 | #7A3B28 | #4E9A6A | #D35B45 | #7FA6C9 | #DFA13F |
| Mint | #F5FBF8 | #FFFFFF | #15302A | #6A8A80 | #DCEFE7 | #A8D8C8 / #15302A | #E3F3EE | #1F5C4A | #2C8C67 | #CF6464 | #5E92CF | #E2AC45 |
| Gelap | #0C0A09 | #1C1917 | #FAFAF9 | #A8A29E | #44403C | #2DD4BF / #042F2E | #134E4A | #2DD4BF | #4ADE80 | #F87171 | #60A5FA | #FBBF24 |

Teal dan Gelap = nilai `lightScheme`/`darkScheme`/`AppColors` yang sekarang, supaya user lama tidak melihat perubahan.

### Aturan warna

- Masuk = nada hijau, keluar = nada merah/koral di semua tema; nada boleh ikut tema, arah tidak.
- Kontras: nominal masuk/keluar dan teks ≥ 4.5:1 terhadap permukaan; teks di atas primary memakai `on`.
  Teks tombol (TextButton/OutlinedButton) di tema terang memakai `ink`.
- Warna mood kalender per tema (5 mood), dipakai transparan seperti sekarang (`moodTints`, 35%).
- Chart Laporan (garis harian, batang 7 hari Beranda) memakai warna keluar tema. Donut tetap warna kategori.
- Bar budget: normal = primary, peringatan = penting, lewat = keluar (tema).
- DESIGN.md aturan "hijau/merah hanya untuk arah uang" diganti: "warna masuk/keluar tema hanya untuk arah uang".

### Layar Tema

- Profil: baris "Tema" (nama tema aktif + maskot kecil) → layar Tema (route di bawah `/profil`).
- Layar Tema: grid kartu pratinjau 2 kolom, tiap kartu: maskot, nama, contoh latar + permukaan + primary,
  contoh `+Rp` dan `−Rp`. Tap = langsung pakai (tema berganti beranimasi), tanda centang di kartu aktif.
- Pilihan Sistem/Terang/Gelap (`_ThemeTile`) dan pilihan aksen (`_AccentTile`) dihapus.

### Penyimpanan & migrasi

- Disimpan di `flutter_secure_storage` kunci `theme` (id tema), tetap ada setelah keluar akun.
- Migrasi sekali: kunci `themeMode` = `dark` → Gelap; lainnya → Teal. Kunci `accent` (hanya di build debug) diabaikan.
- Id tak dikenal → Teal.

### Maskot

- Widget `Mascot(theme, expression, size)`; ekspresi: `happy`, `neutral`.
- Muncul di: Beranda di sebelah sapaan (happy jika `today.hasEntry`, selain itu neutral), `EmptyState`
  (menggantikan ikon, neutral), kartu pratinjau & baris Profil.
- Semantics: label "Maskot {hewan}" atau dikecualikan jika dekoratif (di EmptyState dekoratif).

### Transisi

- Layar dalam (push): geser horizontal dari kanan + fade, lewat `pageTransitionsTheme` di `buildTheme`
  supaya semua `GoRoute` ikut tanpa diubah satu per satu.
- Tab bawah: geser horizontal sesuai arah index (ke tab kanan → konten bergeser ke kiri) + fade, durasi ±250 ms;
  state & scroll tiap tab tetap terjaga (container cabang kustom pada `StatefulShellRoute`).
- Penanda tab aktif beranimasi (bawaan NavigationBar untuk kapsul; garis bawah dianimasikan posisinya).
- `MediaQuery.disableAnimations` = true → tanpa animasi.

## Diserahkan ke builder

- Struktur kelas spesifikasi tema (nama field, apakah `AppColors` diperluas atau diganti), selama satu sumber.
- Detail bentuk tiap maskot, selama satu keluarga gaya (badan chubby dasar sama, mata/blush seragam).
- Implementasi container animasi tab, selama state cabang terjaga.
- Penyetelan nada warna untuk lolos aturan kontras; catat perubahan nilai di DESIGN.md.
- Test: (1) tiap tema lolos cek kontras masuk/keluar/teks terhadap permukaan (unit test hitung rasio);
  (2) pilih tema di layar Tema → tersimpan + diterapkan; (3) migrasi `themeMode=dark` → Gelap; id asing → Teal;
  (4) sel kalender menggambar penanda sesuai gaya tema; (5) disableAnimations → tanpa transisi;
  (6) pindah tab menjaga state; (7) test yang ada tetap lolos.
- Docs: tulis ulang D-63, DESIGN.md (tabel tema, aturan warna, layar Tema, transisi), PRD ENG-03, TASKS.

## Keputusan yang diambil Claude (cek ulang)

- Hewan per tema (tabel di atas), owner sudah setuju.
- Teal & Gelap memakai nilai sekarang persis.
- Ekspresi maskot hanya happy/neutral (sedih ditunda bersama reaksi budget).
- Mood kalender ikut nada tema.
- Bar budget peringatan pakai warna "penting" tema.
