import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../activity/data/activity_models.dart';
import '../../attachment/data/attachment_models.dart';

part 'memory_providers.g.dart';

/// Bulan yang kartu Kenangannya tampil di Beranda pada [now] (ACT-06, D-73),
/// `YYYY-MM`, atau null di luar jendela. Jendela: 3 hari terakhir bulan itu
/// sampai tanggal 7 bulan berikutnya.
String? memoryMonth(DateTime now) {
  String key(DateTime d) => '${d.year}-${d.month.toString().padLeft(2, '0')}';
  final lastDay = DateTime(now.year, now.month + 1, 0).day;
  if (now.day > lastDay - 3) return key(now);
  if (now.day <= 7) return key(DateTime(now.year, now.month - 1));
  return null;
}

/// Satu kegiatan berfoto di galeri.
typedef MemoryGroup = ({Activity activity, List<Attachment> photos});

/// Kegiatan berfoto, terbaru dulu; tanggal sama = urut judul.
List<MemoryGroup> memoryGroups(List<Activity> activities) =>
    [
      for (final activity in activities)
        if (activity.attachments.isNotEmpty)
          (activity: activity, photos: activity.attachments),
    ]..sort((a, b) {
      final byDate = b.activity.date.compareTo(a.activity.date);
      return byDate != 0
          ? byDate
          : a.activity.title.compareTo(b.activity.title);
    });

/// Tanggal palsu untuk uji kartu Kenangan di HP, `YYYY-MM-DD`; hanya build debug.
const _debugDate = String.fromEnvironment('MEMORY_DATE');

/// Jam sekarang; diganti di test, atau lewat `--dart-define=MEMORY_DATE` di build debug.
@riverpod
DateTime memoryNow(Ref ref) => kDebugMode && _debugDate.isNotEmpty
    ? DateTime.parse(_debugDate)
    : DateTime.now();

/// Bulan (`YYYY-MM`) yang kartu Kenangannya sudah ditutup user. Disimpan di HP.
@Riverpod(keepAlive: true)
class MemoryDismissed extends _$MemoryDismissed {
  static const _storage = FlutterSecureStorage();
  static const _key = 'memoryDismissed';

  @override
  Future<String?> build() => _storage.read(key: _key);

  Future<void> dismiss(String month) async {
    state = AsyncData(month);
    try {
      await _storage.write(key: _key, value: month);
    } catch (e) {
      // Gagal simpan: kartu tetap tertutup di sesi ini, muncul lagi saat dibuka ulang.
      debugPrint('Gagal menyimpan kartu Kenangan: $e');
    }
  }
}
