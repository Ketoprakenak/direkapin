import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/api/api_client.dart';
import '../../../core/theme/app_themes.dart';
import '../../auth/data/auth_models.dart';
import '../data/settings_api.dart';

part 'settings_providers.g.dart';

@riverpod
SettingsApi settingsApi(Ref ref) => SettingsApi(ref.watch(apiClientProvider));

@riverpod
Future<User> me(Ref ref) => ref.watch(settingsApiProvider).me();

/// Hanya dipakai saat `User.hasAvatar` true; di-invalidate setelah unggah/hapus.
@riverpod
Future<Uint8List> avatar(Ref ref) =>
    ref.watch(settingsApiProvider).avatarBytes();

const _themeKey = 'theme';
const _legacyThemeModeKey = 'themeMode';

/// Disimpan di HP (D-50), dan tetap ada setelah keluar akun.
@Riverpod(keepAlive: true)
class AppThemeChoice extends _$AppThemeChoice {
  static const _storage = FlutterSecureStorage();

  @override
  Future<AppThemeData> build() async {
    var id = await _storage.read(key: _themeKey);
    // Migrasi sekali: pilihan lama "Gelap" jadi tema Gelap; lainnya Teal.
    if (id == null && await _storage.read(key: _legacyThemeModeKey) == 'dark') {
      id = 'dark';
    }
    return themeById(id);
  }

  Future<void> set(AppThemeData t) async {
    state = AsyncData(t);
    try {
      await _storage.write(key: _themeKey, value: t.id);
    } catch (e) {
      // Gagal simpan: tema tetap berlaku di sesi ini, kembali ke bawaan saat dibuka ulang.
      debugPrint('Gagal menyimpan tema: $e');
    }
  }
}
