import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/media/photo_service.dart';
import '../../../../core/theme/tokens.dart';
import '../photo_edits.dart';
import 'attachment_image.dart';

/// Foto lama + foto baru + tombol tambah, untuk form transaksi dan kegiatan.
class PhotoPickerRow extends ConsumerWidget {
  const PhotoPickerRow({
    super.key,
    required this.edits,
    required this.label,
    required this.limit,
    required this.locked,
  });

  static const _tileSize = Spacing.xxl * 2 + Spacing.xl;

  final PhotoEdits edits;
  final String label;
  final int limit;

  /// Item sudah tersimpan: foto tidak bisa diubah lagi dari form ini.
  final bool locked;

  Future<void> _add(BuildContext context, WidgetRef ref) async {
    final service = ref.read(photoServiceProvider);
    final remaining = limit - edits.existing.length - edits.drafts.length;
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_rounded),
              title: const Text('Kamera'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded),
              title: const Text('Galeri'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null || !context.mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    edits.setPicking(true);
    try {
      final result = await service.pick(source, limit: remaining);
      result.paths.forEach(edits.addDraft);
      if (result.skipped > 0) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              '${result.skipped} foto nggak ikut ditambahkan. '
              'Sudah lewat batas $limit foto, atau filenya rusak.',
            ),
          ),
        );
      }
    } on Exception {
      messenger.showSnackBar(
        const SnackBar(
          content: Text(
            'Foto nggak bisa diambil. Cek izin kamera atau coba foto lain.',
          ),
        ),
      );
    } finally {
      edits.setPicking(false);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label (maks. $limit)', style: theme.textTheme.bodyMedium),
        const SizedBox(height: Spacing.sm),
        Wrap(
          spacing: Spacing.sm,
          runSpacing: Spacing.sm,
          children: [
            for (final attachment in edits.existing)
              _Tile(
                onRemove: locked
                    ? null
                    : () => edits.removeExisting(attachment),
                child: AttachmentImage(id: attachment.id, thumb: true),
              ),
            for (final draft in edits.drafts)
              _Tile(
                onRemove: locked ? null : () => edits.removeDraft(draft),
                overlay: _overlay(context, draft),
                child: Image.file(
                  File(draft.path),
                  fit: BoxFit.cover,
                  semanticLabel: 'Foto baru',
                  errorBuilder: (_, _, _) =>
                      const Icon(Icons.broken_image_rounded),
                ),
              ),
            if (!locked && edits.existing.length + edits.drafts.length < limit)
              _AddTile(picking: edits.picking, onTap: () => _add(context, ref)),
          ],
        ),
      ],
    );
  }

  Widget? _overlay(BuildContext context, PhotoDraft draft) {
    final colors = Theme.of(context).colorScheme;
    if (draft.uploading) {
      return Center(
        child: CircularProgressIndicator(
          value: draft.progress,
          semanticsLabel: 'Mengupload foto',
        ),
      );
    }
    if (draft.failed) {
      return Center(
        child: Icon(
          Icons.error_rounded,
          color: colors.error,
          semanticLabel: 'Foto gagal diupload',
        ),
      );
    }
    return null;
  }
}

class _Tile extends StatelessWidget {
  const _Tile({required this.child, this.overlay, this.onRemove});

  final Widget child;
  final Widget? overlay;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: PhotoPickerRow._tileSize,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(Radii.md),
        child: Stack(
          fit: StackFit.expand,
          children: [
            child,
            if (overlay != null)
              ColoredBox(
                color: Theme.of(context).colorScheme.surface
                    .withValues(alpha: 0.7),
                child: overlay,
              ),
            if (onRemove != null)
              Positioned(
                top: 0,
                right: 0,
                child: IconButton(
                  tooltip: 'Hapus foto',
                  icon: CircleAvatar(
                    radius: Spacing.md,
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    child: Icon(
                      Icons.close_rounded,
                      size: Spacing.lg,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  onPressed: onRemove,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _AddTile extends StatelessWidget {
  const _AddTile({required this.picking, required this.onTap});

  final bool picking;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox.square(
      dimension: PhotoPickerRow._tileSize,
      child: OutlinedButton(
        onPressed: picking ? null : onTap,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.all(Spacing.xs),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Radii.md),
          ),
        ),
        child: picking
            ? const SizedBox.square(
                dimension: Spacing.xl,
                child: CircularProgressIndicator(
                  semanticsLabel: 'Mengompres foto',
                ),
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.add_a_photo_rounded),
                  const SizedBox(height: Spacing.xs),
                  Text(
                    'Tambah foto',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.labelSmall,
                  ),
                ],
              ),
      ),
    );
  }
}

/// Status upload + Simpan; setelah foto gagal: "Coba lagi" dan "Lewati".
class PhotoSaveButtons extends StatelessWidget {
  const PhotoSaveButtons({
    super.key,
    required this.edits,
    required this.busy,
    required this.onSave,
    required this.onRetry,
    required this.onSkip,
  });

  final PhotoEdits edits;
  final bool busy;
  final VoidCallback onSave;
  final VoidCallback onRetry;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final error = edits.error;
    final status = edits.status;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (error != null) ...[
          const SizedBox(height: Spacing.sm),
          Text(
            error,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
        ],
        if (status != null) ...[
          const SizedBox(height: Spacing.sm),
          Text(status, style: theme.textTheme.bodyMedium),
        ],
        const SizedBox(height: Spacing.md),
        if (error != null) ...[
          FilledButton(onPressed: onRetry, child: const Text('Coba lagi')),
          const SizedBox(height: Spacing.sm),
          TextButton(onPressed: onSkip, child: const Text('Lewati')),
        ] else
          FilledButton(
            onPressed: busy || edits.picking ? null : onSave,
            child: busy
                ? const SizedBox.square(
                    dimension: Spacing.xl,
                    child: CircularProgressIndicator(),
                  )
                : const Text('Simpan'),
          ),
      ],
    );
  }
}
