import 'package:direkapin/core/theme/app_theme.dart';
import 'package:direkapin/core/theme/app_themes.dart';
import 'package:direkapin/core/theme/tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

double contrast(Color a, Color b) {
  final l1 = a.computeLuminance();
  final l2 = b.computeLuminance();
  final hi = l1 > l2 ? l1 : l2;
  final lo = l1 > l2 ? l2 : l1;
  return (hi + 0.05) / (lo + 0.05);
}

void main() {
  test('7 tema, id unik, urutan sesuai spec', () {
    expect(appThemes.map((t) => t.id).toList(), [
      'teal',
      'yellow',
      'sky',
      'lavender',
      'peach',
      'mint',
      'dark',
    ]);
  });

  test('Teal dan Gelap = warna lama', () {
    final teal = themeById('teal');
    expect(teal.scheme.primary, lightScheme.primary);
    expect(teal.colors.expense, const Color(0xFFDC2626));
    final dark = themeById('dark');
    expect(dark.brightness, Brightness.dark);
    expect(dark.colors.income, const Color(0xFF4ADE80));
  });

  test('kontras tiap tema', () {
    for (final t in appThemes) {
      final s = t.scheme;
      for (final bg in [s.surface, t.colors.background]) {
        expect(
          contrast(s.onSurface, bg),
          greaterThanOrEqualTo(4.5),
          reason: t.id,
        );
        expect(
          contrast(t.colors.income, bg),
          greaterThanOrEqualTo(4.5),
          reason: t.id,
        );
        expect(
          contrast(t.colors.expense, bg),
          greaterThanOrEqualTo(4.5),
          reason: t.id,
        );
        expect(
          contrast(t.colors.textSecondary, bg),
          greaterThanOrEqualTo(3),
          reason: t.id,
        );
      }
      expect(
        contrast(s.onPrimary, s.primary),
        greaterThanOrEqualTo(4.5),
        reason: t.id,
      );
      expect(
        contrast(t.colors.ink, t.colors.background),
        greaterThanOrEqualTo(3),
        reason: t.id,
      );
      expect(
        contrast(t.ink, s.surface),
        greaterThanOrEqualTo(4.5),
        reason: t.id,
      );
    }
  });

  test('frame: token sama, garis kontras, tint kotak ringkasan terbaca', () {
    for (final t in appThemes) {
      final s = t.scheme;
      expect(t.style.frameWidth, 2, reason: t.id);
      expect(t.style.frameOffset, 4, reason: t.id);
      expect(
        contrast(s.onSurface, t.colors.background),
        greaterThanOrEqualTo(3),
        reason: t.id,
      );
      expect(
        contrast(s.onSurface, s.surface),
        greaterThanOrEqualTo(3),
        reason: t.id,
      );
      expect(
        contrast(s.onSurface, t.colors.incomeTint),
        greaterThanOrEqualTo(4.5),
        reason: t.id,
      );
      expect(
        contrast(s.onSurface, t.colors.expenseTint),
        greaterThanOrEqualTo(4.5),
        reason: t.id,
      );
      expect(
        contrast(s.onSurface, t.colors.importantTint),
        greaterThanOrEqualTo(4.5),
        reason: t.id,
      );
    }
  });

  testWidgets('tab dan kursor memakai ink, bukan primary pastel', (
    tester,
  ) async {
    final t = themeById('yellow');
    await tester.pumpWidget(
      MaterialApp(
        theme: buildTheme(t),
        home: const DefaultTabController(
          length: 2,
          child: Scaffold(
            body: Column(
              children: [
                TabBar(
                  tabs: [
                    Tab(text: 'A'),
                    Tab(text: 'B'),
                  ],
                ),
                TextField(autofocus: true),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    expect(t.ink, isNot(t.scheme.primary));
    final tabText = tester.widget<DefaultTextStyle>(
      find
          .ancestor(of: find.text('A'), matching: find.byType(DefaultTextStyle))
          .first,
    );
    expect(tabText.style.color, t.ink);
    final field = tester.widget<EditableText>(find.byType(EditableText));
    expect(field.cursorColor, t.ink);
  });

  test('masuk hijau, keluar merah', () {
    for (final t in appThemes) {
      final inc = HSVColor.fromColor(t.colors.income).hue;
      final exp = HSVColor.fromColor(t.colors.expense).hue;
      expect(inc, inInclusiveRange(90, 170), reason: t.id);
      expect(exp < 20 || exp > 330, isTrue, reason: '${t.id} $exp');
    }
  });

  test('id asing → Teal', () {
    expect(themeById('merah').id, 'teal');
    expect(themeById(null).id, 'teal');
  });

  test('buildTheme memasang extension, ink, radius kartu', () {
    final theme = buildTheme(themeById('peach'));
    expect(theme.extension<AppStyle>()!.animal, Animal.hamster);
    expect(
      theme.textButtonTheme.style!.foregroundColor!.resolve({}),
      themeById('peach').ink,
    );
    final shape = theme.cardTheme.shape! as RoundedRectangleBorder;
    expect(shape.borderRadius, BorderRadius.circular(24));
  });
}
