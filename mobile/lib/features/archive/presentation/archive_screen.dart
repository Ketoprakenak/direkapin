import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_error.dart';
import '../../../core/format/dates.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/state_views.dart';
import '../data/archive_models.dart';
import '../providers/archive_providers.dart';

class ArchiveScreen extends ConsumerWidget {
  const ArchiveScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final archives = ref.watch(archivesProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Arsip foto')),
      body: archives.when(
        loading: () => const ListSkeleton(),
        error: (error, _) => ErrorState(
          error: error,
          onRetry: () => ref.invalidate(archivesProvider),
        ),
        data: (items) => RefreshIndicator(
          onRefresh: () => ref.refresh(archivesProvider.future),
          child: items.isEmpty
              ? ListView(
                  children: const [
                    SizedBox(height: Spacing.xxl * 2),
                    EmptyState(
                      message:
                          'Belum ada arsip. Foto diarsipkan otomatis setelah dua bulan.',
                    ),
                  ],
                )
              : ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) => _ArchiveTile(items[index]),
                ),
        ),
      ),
    );
  }
}

class _ArchiveTile extends ConsumerWidget {
  const _ArchiveTile(this.archive);

  final Archive archive;

  String _statusText(DateTime now) {
    final days = daysUntil(archive.expiresAt, now);
    return switch (archive.status) {
      ArchiveStatus.ready => 'Foto asli dihapus dalam $days hari',
      ArchiveStatus.downloaded =>
        'Sudah di-download. Bisa di-download lagi $days hari ke depan',
      ArchiveStatus.expired => 'Sudah lewat 30 hari, ZIP sudah dihapus',
      ArchiveStatus.failed => 'Gagal dibuat, dicoba lagi besok. Foto asli aman',
    };
  }

  Future<void> _download(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    String message;
    try {
      await ref.read(archiveDownloadsProvider.notifier).start(archive);
      message = 'Arsip tersimpan di Download/Direkapin';
    } on ApiException catch (e) {
      message = e.message;
    } on PlatformException catch (e) {
      message = e.code == 'permission_denied'
          ? 'Izin penyimpanan ditolak. Aktifkan di pengaturan HP.'
          : 'Arsip gagal disimpan. Coba lagi.';
    } on FileSystemException {
      message = 'Arsip gagal disimpan. Coba lagi.';
    }
    messenger.showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(
      archiveDownloadsProvider.select((state) => state[archive.id]),
    );
    final hasFile =
        archive.status == ArchiveStatus.ready ||
        archive.status == ArchiveStatus.downloaded;
    final details = archive.status == ArchiveStatus.failed
        ? null
        : '${archive.photoCount} foto · ${formatSize(archive.sizeBytes)}';
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.lg,
        vertical: Spacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            formatMonth(DateTime.parse('${archive.month}-01')),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          if (details != null) Text(details),
          Text(
            _statusText(DateTime.now()),
            style: TextStyle(
              color: Theme.of(context).extension<AppColors>()!.textSecondary,
            ),
          ),
          if (hasFile) ...[
            const SizedBox(height: Spacing.sm),
            if (progress != null)
              LinearProgressIndicator(
                value: progress,
                semanticsLabel: 'Progress download',
              )
            else
              OutlinedButton(
                onPressed: () => _download(context, ref),
                child: Text(
                  archive.status == ArchiveStatus.ready
                      ? 'Download arsip'
                      : 'Download lagi',
                ),
              ),
          ],
        ],
      ),
    );
  }
}
