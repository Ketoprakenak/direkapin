import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:direkapin/core/theme/app_themes.dart';
import 'package:direkapin/features/settings/providers/settings_providers.dart';

Future<String> _read(Map<String, String> initial) async {
  FlutterSecureStorage.setMockInitialValues(initial);
  final container = ProviderContainer();
  addTearDown(container.dispose);
  return (await container.read(appThemeChoiceProvider.future)).id;
}

void main() {
  test('tanpa simpanan → Teal', () async {
    expect(await _read({}), 'teal');
  });

  test('theme=mint → Mint', () async {
    expect(await _read({'theme': 'mint'}), 'mint');
  });

  test('migrasi themeMode=dark → Gelap', () async {
    expect(await _read({'themeMode': 'dark'}), 'dark');
  });

  test('themeMode=light → Teal', () async {
    expect(await _read({'themeMode': 'light'}), 'teal');
  });

  test('theme=merah → Teal', () async {
    expect(await _read({'theme': 'merah'}), 'teal');
  });

  test('set() menulis kunci theme', () async {
    FlutterSecureStorage.setMockInitialValues({});
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await container.read(appThemeChoiceProvider.future);
    await container
        .read(appThemeChoiceProvider.notifier)
        .set(themeById('lavender'));
    expect(await const FlutterSecureStorage().read(key: 'theme'), 'lavender');
  });
}
