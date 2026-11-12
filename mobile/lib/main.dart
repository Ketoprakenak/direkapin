import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';
import 'core/theme/app_themes.dart';
import 'features/settings/providers/settings_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID');
  // Retry otomatis dimatikan: layar error sudah punya tombol "Coba lagi".
  final container = ProviderContainer(retry: (_, _) => null);
  // Muat tema dulu agar frame pertama tidak berkedip Teal.
  await container
      .read(appThemeChoiceProvider.future)
      .catchError((_) => appThemes.first);
  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const DirekapinApp(),
    ),
  );
}
