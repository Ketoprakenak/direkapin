/**
 * Catatan update per versi APK, terbaru di atas. Tambah entri baru setiap rilis.
 * Aplikasi hanya menampilkan versi yang lebih baru dari versi terpasang
 * dan tidak lebih baru dari `LATEST_APK_VERSION`.
 */
export const releaseNotes: { version: string; items: string[] }[] = [
  {
    version: '1.5.0',
    items: [
      'Widget "Hari ini" di layar utama: pengeluaran dan pemasukan hari ini, tombol + langsung Catat',
      'Latar widget pakai maskot tema atau fotomu sendiri, posisinya bisa diatur',
      'Owner bisa bikin kode undangan langsung dari aplikasi',
      'Talangan yang belum lunas ikut memotong saldo Bisa digunakan',
      'Tombol lihat password di layar Masuk dan Daftar',
      'Mood dihapus; kalender selalu menampilkan warna pengeluaran',
    ],
  },
  {
    version: '1.4.0',
    items: [
      'Tabungan: sisihkan saldo dengan target, tap Total saldo di Beranda',
      'Riwayat tabungan: kapan disetor dan kapan dipakai',
      'Utang & Piutang: catat talangan teman dan utangmu, bisa dicicil',
      'Bagi ke teman langsung dari pengeluaran, ada tombol Bagi rata',
      'Cap Lunas terbayar saat utang atau piutang sudah beres',
    ],
  },
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
