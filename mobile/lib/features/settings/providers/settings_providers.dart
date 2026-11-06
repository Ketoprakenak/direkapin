import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/api/api_client.dart';
import '../../auth/data/auth_models.dart';
import '../data/settings_api.dart';

part 'settings_providers.g.dart';

@riverpod
SettingsApi settingsApi(Ref ref) => SettingsApi(ref.watch(apiClientProvider));

@riverpod
Future<User> me(Ref ref) => ref.watch(settingsApiProvider).me();

const _themeKey = 'themeMode';

/// Disimpan di HP (D-50), dan tetap ada setelah keluar akun.
@Riverpod(keepAlive: true)
class AppThemeMode extends _$AppThemeMode {
  static const _storage = FlutterSecureStorage();

  @override
  Future<ThemeMode> build() async {
    final saved = await _storage.read(key: _themeKey);
    return ThemeMode.values.asNameMap()[saved] ?? ThemeMode.system;
  }

  Future<void> set(ThemeMode mode) async {
    state = AsyncData(mode);
    await _storage.write(key: _themeKey, value: mode.name);
  }
}
