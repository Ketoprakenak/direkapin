import 'package:flutter/material.dart';

import '../../../../core/format/money.dart';
import '../../../../core/theme/tokens.dart';
import '../../data/calendar_models.dart';

/// Sel kalender: angka tanggal, maks. 3 titik, bintang, dan total keluar ringkas.
class CalendarCell extends StatelessWidget {
  const CalendarCell({
    super.key,
    required this.day,
    required this.isToday,
    this.data,
  });

  final int day;
  final bool isToday;
  final CalendarDay? data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = AppColors.of(context);
    final data = this.data;
    final labelSmall = theme.textTheme.labelSmall;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: Spacing.xl,
          height: Spacing.xl,
          alignment: Alignment.center,
          decoration: isToday
              ? BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: theme.colorScheme.primary),
                )
              : null,
          child: Text('$day', style: labelSmall),
        ),
        const SizedBox(height: Spacing.xs),
        SizedBox(
          height: Spacing.md,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (data != null && data.income > 0) _Dot(colors.income),
              if (data != null && data.expense > 0) _Dot(colors.expense),
              if (data != null && data.activityCount > 0) _Dot(colors.activity),
              if (data != null && data.hasImportant)
                Icon(
                  Icons.star_rounded,
                  size: Spacing.md,
                  color: colors.important,
                ),
            ],
          ),
        ),
        if (data != null && data.expense > 0)
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              formatCompact(data.expense),
              style: labelSmall?.copyWith(color: colors.textSecondary),
            ),
          ),
      ],
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot(this.color);

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 6,
      height: 6,
      margin: const EdgeInsets.symmetric(horizontal: 1),
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
