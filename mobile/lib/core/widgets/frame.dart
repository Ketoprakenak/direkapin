import 'dart:math';

import 'package:flutter/material.dart';

import '../theme/app_themes.dart';
import '../theme/tokens.dart';

BoxDecoration _frame(
  BuildContext context,
  double radius,
  Color? color, {
  required bool shadow,
}) {
  final scheme = Theme.of(context).colorScheme;
  final style = AppStyle.of(context);
  return BoxDecoration(
    color: color ?? scheme.surface,
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: scheme.onSurface, width: style.frameWidth),
    boxShadow: shadow
        ? [
            BoxShadow(
              color: scheme.onSurface,
              blurRadius: 0,
              offset: Offset(style.frameOffset, style.frameOffset),
            ),
          ]
        : null,
  );
}

/// Frame luar: garis tebal + bayangan keras ke kanan bawah. Menyisakan ruang
/// bayangan di kanan/bawah supaya tidak terpotong.
class FrameCard extends StatelessWidget {
  const FrameCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(Spacing.md),
    this.color,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final style = AppStyle.of(context);
    final content = Padding(padding: padding, child: child);
    return Padding(
      padding: EdgeInsets.only(
        right: style.frameOffset,
        bottom: style.frameOffset,
      ),
      child: DecoratedBox(
        decoration: _frame(context, style.cardRadius, color, shadow: true),
        // Material transparan: ListTile/InkWell di dalam frame melukis di atas
        // dekorasi, bukan tersembunyi di belakangnya.
        child: Material(
          type: MaterialType.transparency,
          // Radius dalam = radius frame dikurangi tebal garis.
          borderRadius: BorderRadius.circular(
            max(0, style.cardRadius - style.frameWidth),
          ),
          clipBehavior: Clip.antiAlias,
          child: onTap == null
              ? content
              : InkWell(
                  borderRadius: BorderRadius.circular(style.cardRadius),
                  onTap: onTap,
                  child: content,
                ),
        ),
      ),
    );
  }
}

/// Frame dalam: garis yang sama, tanpa bayangan, radius setengah frame luar.
class FrameBox extends StatelessWidget {
  const FrameBox({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.symmetric(
      horizontal: Spacing.sm,
      vertical: Spacing.xs,
    ),
    this.color,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: _frame(
      context,
      AppStyle.of(context).cardRadius / 2,
      color,
      shadow: false,
    ),
    child: Padding(padding: padding, child: child),
  );
}
