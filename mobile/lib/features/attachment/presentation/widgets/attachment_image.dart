import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/router.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/widgets/state_views.dart';
import '../../data/attachment_models.dart';
import '../../providers/attachment_providers.dart';
import '../photo_viewer_screen.dart';

const _brokenImageIcon = Icons.broken_image_rounded;

/// Mengisi ruang dari induknya: skeleton saat memuat, tombol muat ulang saat gagal.
class AttachmentImage extends ConsumerWidget {
  const AttachmentImage({
    super.key,
    required this.id,
    required this.thumb,
    this.fit = BoxFit.cover,
  });

  final String id;
  final bool thumb;
  final BoxFit fit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = attachmentImageProvider(id, thumb: thumb);
    return ref
        .watch(provider)
        .when(
          loading: () =>
              const Skeleton(height: double.infinity, width: double.infinity),
          error: (_, _) => IconButton(
            tooltip: 'Muat ulang foto',
            icon: const Icon(_brokenImageIcon),
            onPressed: () => ref.invalidate(provider),
          ),
          data: (bytes) => Image.memory(
            bytes,
            fit: fit,
            semanticLabel: 'Foto',
            errorBuilder: (_, _, _) => const Icon(_brokenImageIcon),
          ),
        );
  }
}

void _openViewer(
  BuildContext context,
  List<Attachment> attachments,
  int index,
) {
  context.pushNamed(
    Routes.photoViewer,
    extra: PhotoViewerArgs(attachments: attachments, initialIndex: index),
  );
}

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({
    required this.attachments,
    required this.index,
    required this.imageSize,
    required this.touchSize,
  });

  final List<Attachment> attachments;
  final int index;
  final double imageSize;
  final double touchSize;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Lihat foto ${index + 1} dari ${attachments.length}',
      excludeSemantics: true,
      child: InkWell(
        borderRadius: BorderRadius.circular(Radii.sm),
        onTap: () => _openViewer(context, attachments, index),
        child: SizedBox.square(
          dimension: touchSize,
          child: Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(Radii.sm),
              child: SizedBox.square(
                dimension: imageSize,
                child: AttachmentImage(id: attachments[index].id, thumb: true),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Thumbnail 32 di list item; area sentuh tetap 48 (DESIGN.md).
class ListThumbnail extends StatelessWidget {
  const ListThumbnail(this.attachments, {super.key});

  final List<Attachment> attachments;

  @override
  Widget build(BuildContext context) => _Thumbnail(
    attachments: attachments,
    index: 0,
    imageSize: Spacing.xxl,
    touchSize: Spacing.xxl + Spacing.lg,
  );
}

/// Semua foto satu item di layar Detail.
class PhotoGallery extends StatelessWidget {
  const PhotoGallery(this.attachments, {super.key});

  static const _size = Spacing.xxl * 3;

  final List<Attachment> attachments;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: Spacing.sm,
      runSpacing: Spacing.sm,
      children: [
        for (var index = 0; index < attachments.length; index++)
          _Thumbnail(
            attachments: attachments,
            index: index,
            imageSize: _size,
            touchSize: _size,
          ),
      ],
    );
  }
}
