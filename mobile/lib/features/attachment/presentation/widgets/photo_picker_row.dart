import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../core/theme/tokens.dart';
import '../../data/attachment_models.dart';
import 'attachment_image.dart';

/// Foto baru di form, sudah dikompres, menunggu transaksinya tersimpan.
class PhotoDraft {
  PhotoDraft(this.path);

  final String path;
  double? progress;
  bool uploading = false;
  bool uploaded = false;
  bool failed = false;
}

/// Foto lama + foto baru + tombol tambah, untuk form transaksi.
class PhotoPickerRow extends StatelessWidget {
  const PhotoPickerRow({
    super.key,
    required this.existing,
    required this.drafts,
    required this.limit,
    required this.picking,
    required this.locked,
    required this.onAdd,
    required this.onRemoveExisting,
    required this.onRemoveDraft,
  });

  static const _tileSize = Spacing.xxl * 2 + Spacing.xl;

  final List<Attachment> existing;
  final List<PhotoDraft> drafts;
  final int limit;
  final bool picking;

  /// Transaksi sudah tersimpan: foto tidak bisa diubah lagi dari form ini.
  final bool locked;
  final VoidCallback onAdd;
  final void Function(Attachment attachment) onRemoveExisting;
  final void Function(PhotoDraft draft) onRemoveDraft;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Foto struk (maks. $limit)', style: theme.textTheme.bodyMedium),
        const SizedBox(height: Spacing.sm),
        Wrap(
          spacing: Spacing.sm,
          runSpacing: Spacing.sm,
          children: [
            for (final attachment in existing)
              _Tile(
                onRemove: locked ? null : () => onRemoveExisting(attachment),
                child: AttachmentImage(id: attachment.id, thumb: true),
              ),
            for (final draft in drafts)
              _Tile(
                onRemove: locked ? null : () => onRemoveDraft(draft),
                overlay: _overlay(context, draft),
                child: Image.file(
                  File(draft.path),
                  fit: BoxFit.cover,
                  semanticLabel: 'Foto struk baru',
                  errorBuilder: (_, _, _) =>
                      const Icon(Icons.broken_image_rounded),
                ),
              ),
            if (!locked && existing.length + drafts.length < limit)
              _AddTile(picking: picking, onTap: onAdd),
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
