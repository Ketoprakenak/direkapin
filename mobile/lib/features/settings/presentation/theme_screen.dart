import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/format/money.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_themes.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/frame.dart';
import '../../../core/widgets/mascot.dart';
import '../providers/settings_providers.dart';

/// Pilih tema (D-63); berlaku langsung ke seluruh aplikasi dan tersimpan.
class ThemeScreen extends ConsumerWidget {
  const ThemeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final active = ref.watch(appThemeChoiceProvider).value ?? appThemes.first;
    return Scaffold(
      appBar: AppBar(title: const Text('Tema')),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(Spacing.lg),
        mainAxisSpacing: Spacing.md,
        crossAxisSpacing: Spacing.md,
        childAspectRatio: 0.78,
        children: [
          for (final t in appThemes)
            _ThemeCard(
              theme: t,
              selected: t.id == active.id,
              onTap: () => ref.read(appThemeChoiceProvider.notifier).set(t),
            ),
        ],
      ),
    );
  }
}

class _ThemeCard extends StatelessWidget {
  const _ThemeCard({
    required this.theme,
    required this.selected,
    required this.onTap,
  });

  final AppThemeData theme;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = theme;
    // Tiap kartu memakai tema-nya sendiri, termasuk maskot.
    final data = buildTheme(t);
    final text = data.textTheme;
    Widget swatch(Color c) => Container(
      width: Spacing.xl,
      height: Spacing.xl,
      decoration: BoxDecoration(
        color: c,
        borderRadius: BorderRadius.circular(Radii.sm),
        border: Border.all(color: t.scheme.outline),
      ),
    );
    return Theme(
      data: data,
      child: Semantics(
        selected: selected,
        button: true,
        label: t.name,
        excludeSemantics: true,
        onTap: onTap,
        child: FrameCard(
          padding: EdgeInsets.zero,
          color: t.colors.background,
          onTap: onTap,
          child: Stack(
            children: [
              if (selected)
                Positioned(
                  top: Spacing.sm,
                  right: Spacing.sm,
                  child: Icon(Icons.check_circle_rounded, color: t.ink),
                ),
              Padding(
                padding: const EdgeInsets.all(Spacing.md),
                // Teks besar mengecil, bukan meluap.
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Mascot(size: Spacing.xxl * 2),
                      const SizedBox(height: Spacing.sm),
                      Text(
                        t.name,
                        style: text.titleSmall?.copyWith(
                          color: t.scheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: Spacing.sm),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          swatch(t.scheme.surface),
                          const SizedBox(width: Spacing.xs),
                          swatch(t.scheme.primary),
                          const SizedBox(width: Spacing.xs),
                          swatch(t.scheme.primaryContainer),
                        ],
                      ),
                      const SizedBox(height: Spacing.sm),
                      Text(
                        formatRupiah(25000, showPlus: true),
                        style: text.bodySmall?.copyWith(color: t.colors.income),
                      ),
                      Text(
                        formatRupiah(-25000),
                        style: text.bodySmall?.copyWith(
                          color: t.colors.expense,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
