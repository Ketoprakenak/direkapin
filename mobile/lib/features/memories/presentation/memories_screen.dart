import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/format/dates.dart';
import '../../../core/router/router.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/frame.dart';
import '../../../core/widgets/state_views.dart';
import '../../activity/providers/activity_providers.dart';
import '../../attachment/data/attachment_models.dart';
import '../../attachment/presentation/photo_viewer_screen.dart';
import '../../attachment/presentation/widgets/attachment_image.dart';
import '../providers/memory_providers.dart';

/// Galeri Kenangan (ACT-06, D-73): foto kegiatan per bulan.
/// [initialMonth] = `YYYY-MM`; null = bulan ini.
class MemoriesScreen extends ConsumerStatefulWidget {
  const MemoriesScreen({super.key, this.initialMonth});

  final String? initialMonth;

  @override
  ConsumerState<MemoriesScreen> createState() => _MemoriesScreenState();
}

class _MemoriesScreenState extends ConsumerState<MemoriesScreen> {
  late DateTime _month = widget.initialMonth == null
      ? DateTime(DateTime.now().year, DateTime.now().month)
      : DateTime.parse('${widget.initialMonth}-01');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final isCurrent = _month.year == now.year && _month.month == now.month;
    final provider = monthActivitiesProvider(monthKey(_month));
    void shift(int step) =>
        setState(() => _month = DateTime(_month.year, _month.month + step));

    return Scaffold(
      appBar: AppBar(title: const Text('Kenangan')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          Spacing.lg,
          Spacing.sm,
          Spacing.lg,
          Spacing.xxl,
        ),
        children: [
          Row(
            children: [
              IconButton(
                tooltip: 'Bulan sebelumnya',
                icon: const Icon(Icons.chevron_left_rounded),
                onPressed: () => shift(-1),
              ),
              Expanded(
                child: FrameBox(
                  padding: const EdgeInsets.all(Spacing.md),
                  child: Text(
                    formatMonth(_month),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Bulan berikutnya',
                icon: const Icon(Icons.chevron_right_rounded),
                onPressed: isCurrent ? null : () => shift(1),
              ),
            ],
          ),
          const SizedBox(height: Spacing.lg),
          ref
              .watch(provider)
              .when(
                loading: () => GridView.count(
                  crossAxisCount: 3,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: Spacing.xs,
                  crossAxisSpacing: Spacing.xs,
                  children: [
                    for (var i = 0; i < 6; i++)
                      const Skeleton(height: double.infinity),
                  ],
                ),
                error: (error, _) => ErrorState(
                  error: error,
                  onRetry: () => ref.invalidate(provider),
                ),
                data: (activities) {
                  final groups = memoryGroups(activities);
                  if (groups.isEmpty) {
                    return const EmptyState(
                      message: 'Belum ada foto kegiatan bulan ini.',
                    );
                  }
                  // Layar foto bisa digeser ke semua foto bulan ini.
                  final all = [for (final g in groups) ...g.photos];
                  var start = 0;
                  final firsts = [
                    for (final g in groups)
                      (start += g.photos.length) - g.photos.length,
                  ];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final (i, group) in groups.indexed)
                        _Group(group: group, first: firsts[i], all: all),
                    ],
                  );
                },
              ),
        ],
      ),
    );
  }
}

class _Group extends StatelessWidget {
  const _Group({required this.group, required this.first, required this.all});

  final MemoryGroup group;

  /// Indeks foto pertama grup ini di [all], untuk layar foto.
  final int first;
  final List<Attachment> all;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final date = DateTime.parse(group.activity.date);
    return Padding(
      padding: const EdgeInsets.only(bottom: Spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${formatWeekday(date)}, ${formatShortDate(date)} · ${group.activity.title}',
            style: theme.textTheme.labelLarge?.copyWith(
              color: AppColors.of(context).textSecondary,
            ),
          ),
          const SizedBox(height: Spacing.sm),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: Spacing.xs,
            crossAxisSpacing: Spacing.xs,
            children: [
              for (final (i, photo) in group.photos.indexed)
                Semantics(
                  button: true,
                  label: 'Foto ${group.activity.title} ${i + 1}',
                  child: GestureDetector(
                    onTap: () => context.pushNamed(
                      Routes.photoViewer,
                      extra: PhotoViewerArgs(
                        attachments: all,
                        initialIndex: first + i,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(Spacing.sm),
                      child: AttachmentImage(id: photo.id, thumb: true),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
