import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../../core/home_widget/today_widget.dart';
import '../../../core/theme/tokens.dart';

/// Atur bagian foto yang tampil di widget 2×2 (D-85). Bawaan foto utuh, sisa ruang
/// diisi foto yang diblur; zoom in berhenti sebelum gambar di widget pecah. Mengembalikan potongan
/// dalam piksel foto, atau null kalau ditutup. [image] dibuang editor.
Future<Rect?> showWidgetPhotoEditor(BuildContext context, ui.Image image) =>
    Navigator.of(context, rootNavigator: true).push<Rect>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => WidgetPhotoEditor(image: image),
      ),
    );

class WidgetPhotoEditor extends StatefulWidget {
  const WidgetPhotoEditor({super.key, required this.image});

  final ui.Image image;

  @override
  State<WidgetPhotoEditor> createState() => _WidgetPhotoEditorState();
}

class _WidgetPhotoEditorState extends State<WidgetPhotoEditor> {
  late final _size = Size(
    widget.image.width.toDouble(),
    widget.image.height.toDouble(),
  );
  late final _maxZoom = maxWidgetZoom(_size);
  late Rect _crop = widgetCrop(
    _size,
    zoom: 1,
    center: _size.center(Offset.zero),
  );
  var _startZoom = 1.0;

  // Editor yang memiliki foto: masih dilukis selama animasi tutup.
  @override
  void dispose() {
    widget.image.dispose();
    super.dispose();
  }

  double get _zoom => _size.longestSide / _crop.width;

  void _update({double? zoom, Offset? center}) => setState(
    () => _crop = widgetCrop(
      _size,
      zoom: zoom ?? _zoom,
      center: center ?? _crop.center,
    ),
  );

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final canZoom = _maxZoom > 1;
    final atLimit = canZoom && _zoom >= _maxZoom - 1e-6;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          tooltip: 'Tutup',
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Atur foto widget'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, _crop),
            child: const Text('Pakai'),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: LayoutBuilder(
                builder: (context, box) {
                  final frame = Rect.fromCenter(
                    center: box.biggest.center(Offset.zero),
                    width: box.biggest.shortestSide - Spacing.lg * 2,
                    height: box.biggest.shortestSide - Spacing.lg * 2,
                  );
                  return GestureDetector(
                    key: const Key('widget-photo-stage'),
                    onScaleStart: (_) => _startZoom = _zoom,
                    onScaleUpdate: (d) => _update(
                      zoom: _startZoom * d.scale,
                      // Layar → piksel foto: foto ikut jari.
                      center:
                          _crop.center -
                          d.focalPointDelta * (_crop.width / frame.width),
                    ),
                    child: CustomPaint(
                      size: box.biggest,
                      painter: _StagePainter(
                        image: widget.image,
                        crop: _crop,
                        frame: frame,
                        dim: scheme.scrim.withValues(alpha: 0.6),
                        line: scheme.surface,
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
              child: Row(
                children: [
                  const Icon(Icons.zoom_out_rounded),
                  Expanded(
                    child: Slider(
                      // Pembulatan float bisa sedikit keluar [min, max] → assertion Slider.
                      value: canZoom ? _zoom.clamp(1.0, _maxZoom) : 1,
                      min: 1,
                      max: canZoom ? _maxZoom : 2,
                      onChanged: canZoom ? (z) => _update(zoom: z) : null,
                    ),
                  ),
                  const Icon(Icons.zoom_in_rounded),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                Spacing.md,
                0,
                Spacing.md,
                Spacing.md,
              ),
              child: Text(
                atLimit
                    ? 'Batas zoom: lebih dari ini foto pecah di widget.'
                    : canZoom
                    ? 'Geser dan cubit untuk atur bagian yang tampil.'
                    : 'Foto terlalu kecil untuk di-zoom.',
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StagePainter extends CustomPainter {
  _StagePainter({
    required this.image,
    required this.crop,
    required this.frame,
    required this.dim,
    required this.line,
  });

  final ui.Image image;
  final Rect crop;
  final Rect frame;
  final Color dim;
  final Color line;

  @override
  void paint(Canvas canvas, Size size) {
    final k = frame.width / crop.width;
    final source = Rect.fromLTWH(
      0,
      0,
      image.width.toDouble(),
      image.height.toDouble(),
    );
    canvas
      ..clipRect(Offset.zero & size)
      ..drawImageRect(
        image,
        source,
        Rect.fromLTWH(
          frame.left - crop.left * k,
          frame.top - crop.top * k,
          image.width * k,
          image.height * k,
        ),
        Paint()..filterQuality = FilterQuality.medium,
      );
    // Isi bingkai persis seperti di widget (sisa ruang = foto diblur).
    paintWidgetPhoto(canvas, image, crop, frame);
    final window = RRect.fromRectAndRadius(
      frame,
      const Radius.circular(Spacing.md),
    );
    canvas
      ..drawPath(
        Path()
          ..fillType = PathFillType.evenOdd
          ..addRect(Offset.zero & size)
          ..addRRect(window),
        Paint()..color = dim,
      )
      ..drawRRect(
        window,
        Paint()
          ..color = line
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
  }

  @override
  bool shouldRepaint(_StagePainter old) =>
      old.crop != crop || old.frame != frame || old.image != image;
}
