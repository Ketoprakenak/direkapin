import 'package:direkapin/core/theme/app_theme.dart';
import 'package:direkapin/core/theme/app_themes.dart';
import 'package:direkapin/core/widgets/mascot.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_server.dart';

Widget _host(Widget child, {ThemeData? theme}) => MaterialApp(
  theme: theme ?? testTheme,
  home: Scaffold(
    body: Center(child: SizedBox(width: 64, height: 64, child: child)),
  ),
);

void main() {
  testWidgets('semua hewan dan ekspresi tergambar tanpa error', (tester) async {
    for (final animal in Animal.values) {
      for (final expression in MascotExpression.values) {
        await tester.pumpWidget(
          _host(Mascot(animal: animal, expression: expression, size: 64)),
        );
        expect(
          find.descendant(
            of: find.byType(Mascot),
            matching: find.byType(CustomPaint),
          ),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
      }
    }
  });

  testWidgets('pose peek tergambar untuk semua hewan tanpa error', (
    tester,
  ) async {
    for (final animal in Animal.values) {
      await tester.pumpWidget(
        _host(Mascot(animal: animal, pose: MascotPose.peek, size: 64)),
      );
      final paint = tester.widget<CustomPaint>(
        find.descendant(
          of: find.byType(Mascot),
          matching: find.byType(CustomPaint),
        ),
      );
      expect((paint.painter! as dynamic).pose, MascotPose.peek);
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('tanpa animal pakai hewan tema', (tester) async {
    await tester.pumpWidget(
      _host(const Mascot(), theme: buildTheme(themeById('peach'))),
    );
    final paint = tester.widget<CustomPaint>(
      find.descendant(
        of: find.byType(Mascot),
        matching: find.byType(CustomPaint),
      ),
    );
    expect((paint.painter! as dynamic).animal, Animal.hamster);
  });

  testWidgets('semanticLabel muncul, tanpa label dikecualikan', (tester) async {
    await tester.pumpWidget(_host(const Mascot(semanticLabel: 'Maskot penyu')));
    expect(find.bySemanticsLabel('Maskot penyu'), findsOneWidget);

    final handle = tester.ensureSemantics();
    await tester.pumpWidget(_host(const Mascot()));
    expect(find.bySemanticsLabel(RegExp('Maskot')), findsNothing);
    handle.dispose();
  });

  test('animalName', () {
    expect(Animal.values.map(animalName), [
      'Penyu',
      'Anak ayam',
      'Paus kecil',
      'Kucing',
      'Hamster',
      'Katak',
      'Burung hantu',
    ]);
  });
}
