import 'package:flutter/material.dart';

import '../format/money.dart';
import '../icons.dart';
import '../theme/tokens.dart';

/// Nominal: negatif selalu merah. Dengan [signed], positif jadi `+` hijau.
class AmountText extends StatelessWidget {
  const AmountText(this.amount, {super.key, this.signed = false, this.large = false});

  final int amount;
  final bool signed;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = AppColors.of(context);
    final color = amount < 0
        ? colors.expense
        : (signed && amount > 0 ? colors.income : theme.colorScheme.onSurface);
    final style = large ? theme.textTheme.displayMedium : theme.textTheme.titleSmall;
    return Text(
      formatRupiah(amount, showPlus: signed),
      style: style?.copyWith(color: color),
    );
  }
}

/// Ikon dalam lingkaran warna kategori/dompet 15%.
class IconCircle extends StatelessWidget {
  const IconCircle({super.key, required this.icon, required this.color});

  final String icon;
  final String color;

  @override
  Widget build(BuildContext context) {
    final tint = colorFromHex(color);
    return Container(
      width: Spacing.xl + Spacing.lg,
      height: Spacing.xl + Spacing.lg,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: tint.withValues(alpha: 0.15),
      ),
      child: Icon(iconFor(icon), color: tint),
    );
  }
}

/// Pilihan warna dari palet kategori/dompet.
class ColorPicker extends StatelessWidget {
  const ColorPicker({super.key, required this.selected, required this.onChanged});

  final String selected;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final outline = Theme.of(context).colorScheme.primary;
    return Wrap(
      spacing: Spacing.xs,
      children: [
        for (final color in categoryPalette)
          InkResponse(
            onTap: () => onChanged(colorToHex(color)),
            child: SizedBox.square(
              dimension: Spacing.xxl + Spacing.lg,
              child: Center(
                child: Container(
                  width: Spacing.xxl,
                  height: Spacing.xxl,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: colorToHex(color) == selected
                        ? Border.all(color: outline, width: 2)
                        : null,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

Future<bool> confirmDialog(
  BuildContext context, {
  required String message,
  required String confirmLabel,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Batal'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}
