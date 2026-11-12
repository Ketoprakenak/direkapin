import 'package:direkapin/core/theme/app_theme.dart';
import 'package:direkapin/core/theme/app_themes.dart';
import 'package:direkapin/core/widgets/frame.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _pump(WidgetTester tester, AppThemeData t, Widget child) =>
    tester.pumpWidget(
      MaterialApp(
        theme: buildTheme(t),
        home: Scaffold(
          body: Align(alignment: Alignment.topLeft, child: child),
        ),
      ),
    );

BoxDecoration _decoOf(WidgetTester tester, Type frame) {
  final box = tester.widget<DecoratedBox>(
    find.descendant(
      of: find.byType(frame),
      matching: find.byType(DecoratedBox),
    ),
  );
  return box.decoration as BoxDecoration;
}

void main() {
  for (final t in [appThemes.first, themeById('dark')]) {
    group('Frame ${t.id}', () {
      testWidgets('FrameCard menggambar garis 2 dan bayangan keras (4,4)', (
        tester,
      ) async {
        await _pump(tester, t, const FrameCard(child: Text('x')));
        final d = _decoOf(tester, FrameCard);
        final border = d.border! as Border;
        expect(border.top.width, 2);
        expect(border.top.color, t.scheme.onSurface);
        expect(d.boxShadow!.single.blurRadius, 0);
        expect(d.boxShadow!.single.offset, const Offset(4, 4));
        expect(d.boxShadow!.single.color, t.scheme.onSurface);
        expect(d.borderRadius, BorderRadius.circular(t.style.cardRadius));
        expect(d.color, t.scheme.surface);
      });

      testWidgets('FrameCard menyisakan ruang bayangan', (tester) async {
        await _pump(
          tester,
          t,
          const FrameCard(
            padding: EdgeInsets.zero,
            child: SizedBox(width: 100, height: 50),
          ),
        );
        // isi 100x50 + 4 ruang bayangan kanan/bawah
        expect(tester.getSize(find.byType(FrameCard)), const Size(104, 54));
      });

      testWidgets('FrameCard onTap dipanggil', (tester) async {
        var n = 0;
        await _pump(
          tester,
          t,
          FrameCard(onTap: () => n++, child: const Text('x')),
        );
        await tester.tap(find.text('x'));
        expect(n, 1);
      });

      testWidgets('FrameBox tanpa bayangan, radius setengah', (tester) async {
        await _pump(tester, t, const FrameBox(child: Text('x')));
        final d = _decoOf(tester, FrameBox);
        expect(d.boxShadow, anyOf(isNull, isEmpty));
        expect((d.border! as Border).top.width, 2);
        expect(d.borderRadius, BorderRadius.circular(t.style.cardRadius / 2));
      });
    });
  }
}
