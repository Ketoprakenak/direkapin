import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_themes.dart';
import 'features/settings/providers/settings_providers.dart';

class DirekapinApp extends ConsumerWidget {
  const DirekapinApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(appThemeChoiceProvider).value ?? appThemes.first;
    return MaterialApp.router(
      title: 'Direkapin',
      theme: buildTheme(t),
      locale: const Locale('id', 'ID'),
      supportedLocales: const [Locale('id', 'ID')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      routerConfig: ref.watch(appRouterProvider),
    );
  }
}
