/**
 * Catatan update per versi APK, terbaru di atas. Tambah entri baru setiap rilis.
 * Aplikasi hanya menampilkan versi yang lebih baru dari versi terpasang
 * dan tidak lebih baru dari `LATEST_APK_VERSION`.
 */
export const releaseNotes: { version: string; items: string[] }[] = [
  {
    version: '1.3.0',
    items: [
      'Kalender punya tab Pengeluaran: hari paling boros kelihatan dari warnanya',
      'Skala warna heatmap bisa Otomatis atau Nominal tetap (Profil > Skala heatmap)',
      'Rekap bulanan ala wrapped dari Laporan Bulanan',
      'Export laporan ke CSV atau PDF',
      'Galeri Kenangan + kartu foto bulanan di Beranda',
      'Notif di hari transaksi berulang jatuh tempo',
      'Lupa password? Reset lewat kode di email',
      'Pilihan mood di Halaman Hari rapi satu baris',
      'Notif update sekarang menampilkan isi update',
    ],
  },
  {
    version: '1.2.0',
    items: [
      'Budget per kategori dengan peringatan 80% dan 100%',
      'Tema aplikasi bisa diganti',
      'Laporan rentang tanggal sendiri',
      'Foto profil',
      'Transaksi berulang',
    ],
  },
];
