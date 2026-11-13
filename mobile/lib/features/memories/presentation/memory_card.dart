import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/format/dates.dart';
import '../../../core/router/router.dart';
import '../../../core/theme/app_themes.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/frame.dart';
import '../../activity/providers/activity_providers.dart';
import '../../attachment/data/attachment_models.dart';
import '../../attachment/presentation/widgets/attachment_image.dart';
import '../providers/memory_providers.dart';

/// Kartu Kenangan di Beranda saat pergantian bulan (ACT-06, D-73).
/// Tidak tampil di luar jendela, jika ditutup, tanpa foto, atau saat data
/// belum/gagal dimuat (tidak boleh mengganggu Beranda).
class MemoryCard extends ConsumerWidget {
  const MemoryCard({super.key});

  static const height = Spacing.xxl * 5;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final month = memoryMonth(ref.watch(memoryNowProvider));
    final dismissed = ref.watch(memoryDismissedProvider);
    if (month == null || !dismissed.hasValue || dismissed.value == month) {
      return const SizedBox.shrink();
    }
    final activities = ref.watch(monthActivitiesProvider(month)).value;
    final photos = [
      for (final activity in activities ?? const []) ...activity.attachments,
    ].cast<Attachment>();
    if (photos.isEmpty) return const SizedBox.shrink();
    final withPhotos = activities!.where((a) => a.attachments.isNotEmpty);
    // Acak tetap per bulan supaya foto tidak berganti tiap Beranda dibangun ulang.
    final picked = (List.of(
      photos,
    )..shuffle(Random(month.hashCode))).take(3).toList();

    final theme = Theme.of(context);
    final colors = AppColors.of(context);
    final ink = theme.colorScheme.onSurface;
    final surface = theme.colorScheme.surface;
    final color = Color.alphaBlend(
      colors.activity.withValues(alpha: 0.3),
      surface,
    );
    final name = formatMonth(DateTime.parse('$month-01')).split(' ').first;

    return Padding(
      padding: const EdgeInsets.only(bottom: Spacing.xl),
      child: Semantics(
        button: true,
        label: 'Buka Kenangan $name',
        child: FrameCard(
          color: color,
          padding: EdgeInsets.zero,
          onTap: () => context.pushNamed(Routes.memories, extra: month),
          child: SizedBox(
            height: height,
            child: LayoutBuilder(
              builder: (context, box) {
                final w = box.maxWidth;
                return Stack(
                  clipBehavior: Clip.hardEdge,
                  children: [
                    Positioned(
                      top: -height * 0.35,
                      right: -w * 0.12,
                      child: Container(
                        width: height * 1.1,
                        height: height * 1.1,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color.alphaBlend(
                            surface.withValues(alpha: 0.45),
                            color,
                          ),
                        ),
                      ),
                    ),
                    _Fan(photos: picked, width: w),
                    Padding(
                      padding: const EdgeInsets.all(Spacing.lg),
                      child: SizedBox(
                        width: w * 0.5,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: Spacing.sm,
                                vertical: Spacing.xs / 2,
                              ),
                              decoration: BoxDecoration(
                                color: surface,
                                border: Border.all(
                                  color: ink,
                                  width: AppStyle.of(context).frameWidth,
                                ),
                                borderRadius: BorderRadius.circular(Spacing.lg),
                              ),
                              child: Text(
                                'Kenangan',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: ink,
                                ),
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '$name kamu',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: ink,
                              ),
                            ),
                            Text(
                              '${photos.length} foto · ${withPhotos.length} kegiatan',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: ink,
                              ),
                            ),
                            const SizedBox(height: Spacing.sm),
                            Row(
                              children: [
                                Text(
                                  'Lihat',
                                  style: theme.textTheme.labelLarge?.copyWith(
                                    color: ink,
                                  ),
                                ),
                                const SizedBox(width: Spacing.xs),
                                Icon(
                                  Icons.arrow_forward_rounded,
                                  size: Spacing.lg,
                                  color: ink,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      top: Spacing.xs,
                      right: Spacing.xs,
                      child: IconButton(
                        tooltip: 'Tutup kartu Kenangan',
                        style: IconButton.styleFrom(
                          backgroundColor: surface,
                          side: BorderSide(
                            color: ink,
                            width: AppStyle.of(context).frameWidth,
                          ),
                        ),
                        visualDensity: VisualDensity.compact,
                        icon: Icon(Icons.close_rounded, color: ink),
                        onPressed: () => ref
                            .read(memoryDismissedProvider.notifier)
                            .dismiss(month),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

/// Polaroid disebar miring di sisi kanan; yang paling kanan terpotong tepi kartu.
/// Menyebar dari tumpukan lurus saat pertama tampil.
class _Fan extends StatelessWidget {
  const _Fan({required this.photos, required this.width});

  final List<Attachment> photos;
  final double width;

  // Posisi (pecahan lebar kartu dari kanan), turun (pecahan tinggi), dan sudut.
  static const _slots = [
    (right: 0.24, top: 0.3, angle: -0.17),
    (right: 0.1, top: 0.24, angle: 0.14),
    (right: -0.06, top: 0.44, angle: 0.42),
  ];

  @override
  Widget build(BuildContext context) {
    final size = MemoryCard.height * 0.36;
    final still = MediaQuery.disableAnimationsOf(context);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: still ? 1 : 0, end: 1),
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOutBack,
      builder: (context, t, _) => Stack(
        children: [
          for (final (i, photo) in photos.indexed)
            Positioned(
              right: width * _slots[i].right,
              top: MemoryCard.height * _slots[i].top,
              child: Transform.rotate(
                angle: _slots[i].angle * t,
                child: _Polaroid(photo: photo, size: size),
              ),
            ),
        ],
      ),
    );
  }
}

class _Polaroid extends StatelessWidget {
  const _Polaroid({required this.photo, required this.size});

  final Attachment photo;
  final double size;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(
        Spacing.xs,
        Spacing.xs,
        Spacing.xs,
        Spacing.md,
      ),
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border.all(
          color: scheme.onSurface,
          width: AppStyle.of(context).frameWidth,
        ),
      ),
      child: SizedBox.square(
        dimension: size,
        child: AttachmentImage(id: photo.id, thumb: true),
      ),
    );
  }
}
