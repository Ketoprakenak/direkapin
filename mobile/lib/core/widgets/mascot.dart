import 'package:flutter/material.dart';

import '../theme/app_themes.dart';
import '../theme/tokens.dart';

enum MascotExpression { happy, neutral }

/// `peek` = kepala + dua tangan di tepi bawah, seolah melongok dari atas.
enum MascotPose { full, peek }

String animalName(Animal a) => switch (a) {
  Animal.turtle => 'Penyu',
  Animal.chick => 'Anak ayam',
  Animal.whale => 'Paus kecil',
  Animal.cat => 'Kucing',
  Animal.hamster => 'Hamster',
  Animal.frog => 'Katak',
  Animal.owl => 'Burung hantu',
};

/// Maskot hewan tema, digambar dari bentuk sederhana dengan warna tema aktif.
class Mascot extends StatelessWidget {
  const Mascot({
    super.key,
    this.animal,
    this.expression = MascotExpression.neutral,
    this.size = 48,
    this.semanticLabel,
    this.pose = MascotPose.full,
  });

  /// Null = hewan tema aktif.
  final Animal? animal;
  final MascotExpression expression;
  final double size;
  final MascotPose pose;

  /// Null = dekorasi, dikecualikan dari semantics.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final colors = AppColors.of(context);
    final painter = _MascotPainter(
      animal ?? AppStyle.of(context).animal,
      expression,
      pose,
      (
        body: scheme.primary,
        belly: scheme.primaryContainer,
        // onSurface, bukan ink tema: kontras aman juga di tema gelap.
        ink: scheme.onSurface,
        shadow: scheme.shadow,
        blush: colors.expense.withValues(alpha: 0.3),
        accent: colors.important,
        water: colors.activity,
      ),
    );
    final paint = CustomPaint(size: Size.square(size), painter: painter);
    final label = semanticLabel;
    return label == null
        ? ExcludeSemantics(child: paint)
        : Semantics(label: label, image: true, child: paint);
  }
}

typedef _Palette = ({
  Color body,
  Color belly,
  Color ink,
  Color shadow,
  Color blush,
  Color accent,
  Color water,
});

/// Digambar di kotak 100 x 100 lalu diskalakan, jadi tajam di 24–96 px.
class _MascotPainter extends CustomPainter {
  _MascotPainter(this.animal, this.expression, this.pose, this.colors);

  final Animal animal;
  final MascotExpression expression;
  final MascotPose pose;
  final _Palette colors;

  static const _white = Color(0xFFFFFFFF);

  Color get _shade =>
      Color.alphaBlend(colors.ink.withValues(alpha: 0.15), colors.body);

  Paint _fill(Color c) => Paint()..color = c;

  Paint _stroke(Color c, [double width = 2]) => Paint()
    ..color = c
    ..style = PaintingStyle.stroke
    ..strokeWidth = width
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  Paint get _outline => _stroke(colors.ink.withValues(alpha: 0.6));

  Path _oval(double x, double y, double w, double h) =>
      Path()
        ..addOval(Rect.fromCenter(center: Offset(x, y), width: w, height: h));

  Path _poly(List<(double, double)> points) =>
      Path()..addPolygon([for (final (x, y) in points) Offset(x, y)], true);

  /// Isi + garis tepi tipis.
  void _shape(Canvas canvas, Path path, Color fill) {
    canvas
      ..drawPath(path, _fill(fill))
      ..drawPath(path, _outline);
  }

  /// Gambar bagian kiri lalu cerminkan ke kanan.
  void _mirrored(Canvas canvas, void Function() draw) {
    draw();
    canvas
      ..save()
      ..translate(100, 0)
      ..scale(-1, 1);
    draw();
    canvas.restore();
  }

  /// Posisi wajah: tinggi mata, jarak mata dari tengah, tinggi & lebar mulut
  /// (lebar 0 = paruh).
  ({double y, double dx, double mouthY, double mouth}) get _face =>
      switch (animal) {
        Animal.turtle => (y: 27, dx: 8, mouthY: 35, mouth: 8),
        Animal.frog => (y: 30, dx: 14, mouthY: 48, mouth: 26),
        Animal.chick || Animal.owl => (y: 52, dx: 13, mouthY: 57, mouth: 0),
        _ => (y: 54, dx: 12, mouthY: 63, mouth: 10),
      };

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 100, size.height / 100);
    if (_peek) {
      // Badan turun melewati tepi bawah; yang tampak kepala + tangan.
      canvas
        ..clipRect(const Rect.fromLTWH(0, 0, 100, 100))
        ..translate(0, 12);
    } else {
      canvas.drawPath(
        _oval(50, 93, 60, 8),
        _fill(colors.shadow.withValues(alpha: 0.15)),
      );
    }
    _parts(canvas, front: false);
    _shape(
      canvas,
      _oval(50, 60, 76, 62),
      animal == Animal.turtle ? _shade : colors.body,
    );
    if (animal != Animal.turtle && !_peek) {
      canvas.drawPath(_oval(50, 72, 42, 28), _fill(colors.belly));
    }
    canvas.drawPath(_oval(32, 42, 12, 7), _fill(_white.withValues(alpha: 0.5)));
    _parts(canvas, front: true);
    _drawFace(canvas);
    if (_peek) _drawPaws(canvas);
  }

  bool get _peek => pose == MascotPose.peek;

  /// Dua tangan bertumpu di tepi bawah kanvas.
  void _drawPaws(Canvas canvas) {
    _mirrored(canvas, () {
      _shape(canvas, _oval(33, 82, 22, 14), colors.body);
      canvas
        ..drawLine(const Offset(30, 78), const Offset(30, 83), _outline)
        ..drawLine(const Offset(36, 78), const Offset(36, 83), _outline);
    });
  }

  /// Ciri khas tiap hewan; `front` = di atas badan, selain itu di belakangnya.
  void _parts(Canvas canvas, {required bool front}) {
    final c = colors;
    switch ((animal, front)) {
      case (Animal.turtle, false):
        if (_peek) break;
        _mirrored(canvas, () {
          _shape(canvas, _oval(22, 84, 22, 13), c.body);
          _shape(canvas, _oval(15, 56, 16, 22), c.body);
        });
      case (Animal.turtle, true):
        final plate = _fill(c.belly.withValues(alpha: 0.7));
        canvas.drawPath(_oval(50, 66, 24, 18), plate);
        _mirrored(canvas, () {
          canvas
            ..drawPath(_oval(30, 54, 14, 12), plate)
            ..drawPath(_oval(31, 77, 14, 11), plate);
        });
        _shape(canvas, _oval(50, 30, 40, 36), c.body);
      case (Animal.chick, false):
        for (final (x, y, h) in [(44.0, 29.0, 14.0), (56.0, 29.0, 14.0)]) {
          _shape(canvas, _oval(x, y, 8, h), c.body);
        }
        _shape(canvas, _oval(50, 25, 9, 18), c.body);
        if (_peek) break;
        _mirrored(canvas, () {
          final foot = Path()
            ..moveTo(40, 88)
            ..lineTo(40, 96)
            ..moveTo(40, 94)
            ..lineTo(35, 98)
            ..moveTo(40, 94)
            ..lineTo(45, 98);
          canvas.drawPath(foot, _stroke(c.accent, 3));
        });
      case (Animal.chick, true):
        if (_peek) break;
        _mirrored(canvas, () => _shape(canvas, _oval(15, 64, 14, 24), c.body));
      case (Animal.whale, false):
        final tail = Path()
          ..moveTo(74, 48)
          ..quadraticBezierTo(86, 42, 87, 30)
          ..quadraticBezierTo(78, 26, 75, 17)
          ..quadraticBezierTo(85, 18, 89, 25)
          ..quadraticBezierTo(93, 16, 99, 15)
          ..quadraticBezierTo(98, 27, 90, 33)
          ..quadraticBezierTo(89, 46, 80, 58)
          ..close();
        _shape(canvas, tail, c.body);
        final water = _fill(c.water.withValues(alpha: 0.8));
        canvas
          ..drawLine(
            const Offset(50, 26),
            const Offset(50, 17),
            _stroke(c.water, 2.5),
          )
          ..drawPath(_oval(50, 13, 8, 8), water)
          ..drawPath(_oval(42, 18, 6, 6), water)
          ..drawPath(_oval(58, 18, 6, 6), water);
      case (Animal.whale, true):
        if (_peek) break;
        _mirrored(canvas, () => _shape(canvas, _oval(17, 74, 16, 10), c.body));
      case (Animal.cat, false):
        _mirrored(canvas, () {
          _shape(canvas, _poly([(17, 46), (22, 14), (44, 32)]), c.body);
          canvas.drawPath(
            _poly([(24, 38), (25, 23), (36, 32)]),
            _fill(c.belly),
          );
        });
      case (Animal.cat, true):
        final stripe = _stroke(_shade, 3);
        canvas.drawLine(const Offset(50, 32), const Offset(50, 39), stripe);
        _mirrored(canvas, () {
          canvas
            ..drawLine(const Offset(43, 33), const Offset(44, 39), stripe)
            ..drawLine(const Offset(28, 61), const Offset(16, 58), _outline)
            ..drawLine(const Offset(28, 65), const Offset(15, 66), _outline);
        });
      case (Animal.hamster, false):
        _mirrored(canvas, () {
          _shape(canvas, _oval(25, 33, 19, 19), c.body);
          canvas.drawPath(_oval(25, 33, 10, 10), _fill(c.belly));
        });
      case (Animal.hamster, true):
        _mirrored(
          canvas,
          () => canvas.drawPath(_oval(27, 66, 24, 18), _fill(c.belly)),
        );
      case (Animal.frog, false):
        break;
      case (Animal.frog, true):
        _mirrored(canvas, () {
          _shape(canvas, _oval(36, 30, 24, 22), c.body);
          canvas.drawPath(_oval(36, 30, 15, 15), _fill(c.belly));
        });
      case (Animal.owl, false):
        _mirrored(
          canvas,
          () => _shape(canvas, _poly([(20, 42), (17, 16), (39, 32)]), c.body),
        );
      case (Animal.owl, true):
        _mirrored(canvas, () {
          if (!_peek) _shape(canvas, _oval(14, 66, 14, 28), _shade);
          _shape(canvas, _oval(37, 52, 24, 24), c.belly);
        });
    }
  }

  void _drawFace(Canvas canvas) {
    final f = _face;
    final ink = colors.ink;
    // Melongok ke bawah: pupil turun sedikit.
    final look = _peek ? 1.5 : 0.0;
    for (final side in [-1.0, 1.0]) {
      final x = 50 + side * f.dx;
      canvas.drawPath(
        _oval(50 + side * (f.dx + 9), f.mouthY - 1, 10, 6),
        _fill(colors.blush),
      );
      if (expression == MascotExpression.happy) {
        final eye = Path()
          ..moveTo(x - 4.5, f.y + 1.5)
          ..quadraticBezierTo(x, f.y - 4.5, x + 4.5, f.y + 1.5);
        canvas.drawPath(eye, _stroke(ink, 2.6));
      } else {
        canvas
          ..drawCircle(Offset(x, f.y + look), 4.2, _fill(ink))
          ..drawCircle(Offset(x - 1.4, f.y - 1.5 + look), 1.4, _fill(_white));
      }
    }
    if (f.mouth == 0) {
      final y = f.mouthY;
      _shape(
        canvas,
        _poly([(45, y - 3), (55, y - 3), (50, y + 4)]),
        colors.accent,
      );
      return;
    }
    final w = expression == MascotExpression.happy ? f.mouth : f.mouth * 0.5;
    final depth = expression == MascotExpression.happy ? w * 0.5 : w * 0.3;
    final mouth = Path()
      ..moveTo(50 - w / 2, f.mouthY)
      ..quadraticBezierTo(50, f.mouthY + depth, 50 + w / 2, f.mouthY);
    canvas.drawPath(mouth, _stroke(ink, 2.2));
  }

  @override
  bool shouldRepaint(_MascotPainter old) =>
      old.animal != animal ||
      old.expression != expression ||
      old.pose != pose ||
      old.colors != colors;
}
