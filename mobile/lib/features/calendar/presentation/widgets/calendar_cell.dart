import 'package:flutter/material.dart';

import '../../../../core/format/money.dart';
import '../../../../core/theme/app_themes.dart';
import '../../../../core/theme/tokens.dart';
import '../../data/calendar_models.dart';

/// Sel kalender: angka tanggal berlatar warna mood, ikon masuk/keluar/kegiatan,
/// dan total keluar ringkas (D-61).
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
    final style = AppStyle.of(context);
    final data = this.data;
    final labelSmall = theme.textTheme.labelSmall;
    final tint = colors.moodTints[data?.mood];
    Widget icon(IconData icon, Color color) =>
        Icon(icon, size: Spacing.md, color: color);
    // Penanda masuk/keluar mengikuti gaya tema; kegiatan tetap ikon.
    Widget marker(IconData iconData, Color color) => switch (style.marker) {
      MarkerStyle.icon => icon(iconData, color),
      MarkerStyle.dot => Container(
        width: Spacing.xs + 2,
        height: Spacing.xs + 2,
        margin: const EdgeInsets.symmetric(horizontal: Spacing.xs / 2),
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      ),
      MarkerStyle.bar => Container(
        width: Spacing.sm,
        height: Spacing.sm / 3,
        margin: const EdgeInsets.symmetric(horizontal: Spacing.xs / 2),
        decoration: BoxDecoration(color: color),
      ),
    };
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: Spacing.xl,
          height: Spacing.xl,
          alignment: Alignment.center,
          decoration: tint == null && !isToday
              ? null
              : BoxDecoration(
                  borderRadius: BorderRadius.circular(style.dateRadius),
                  color: tint?.withValues(alpha: 0.35),
                  border: isToday
                      ? Border.all(color: AppColors.of(context).ink)
                      : null,
                ),
          child: Text('$day', style: labelSmall),
        ),
        const SizedBox(height: Spacing.xs),
        SizedBox(
          height: Spacing.md,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (data != null && data.income > 0)
                marker(Icons.south_west_rounded, colors.income),
              if (data != null && data.expense > 0)
                marker(Icons.north_east_rounded, colors.expense),
              // Kegiatan penting cukup bintang, supaya tidak dua ikon.
              if (data != null && data.hasImportant)
                icon(Icons.star_rounded, colors.important)
              else if (data != null && data.activityCount > 0)
                icon(Icons.event_rounded, colors.activity),
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
