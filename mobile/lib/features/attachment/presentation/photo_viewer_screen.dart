import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_error.dart';
import '../../../core/format/dates.dart';
import '../../../core/media/gallery_saver.dart';
import '../../../core/theme/tokens.dart';
import '../data/attachment_models.dart';
import '../providers/attachment_providers.dart';
import 'widgets/attachment_image.dart';

class PhotoViewerArgs {
  const PhotoViewerArgs({required this.attachments, this.initialIndex = 0});

  final List<Attachment> attachments;
  final int initialIndex;
}

class PhotoViewerScreen extends ConsumerStatefulWidget {
  const PhotoViewerScreen({super.key, required this.args});

  final PhotoViewerArgs args;

  @override
  ConsumerState<PhotoViewerScreen> createState() => _PhotoViewerScreenState();
}

class _PhotoViewerScreenState extends ConsumerState<PhotoViewerScreen> {
  late final _controller = PageController(
    initialPage: widget.args.initialIndex,
  );
  late int _index = widget.args.initialIndex;
  bool _saving = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _archivedMessage(String? month) {
    final name = month == null
        ? null
        : formatMonth(DateTime.parse('$month-01'));
    return 'Foto asli sudah pindah ke arsip${name == null ? '' : ' $name'}. '
        'Yang tampil ini versi kecilnya.';
  }

  Future<void> _saveToGallery(Attachment attachment) async {
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _saving = true);
    String message;
    try {
      final bytes = await ref.read(
        attachmentImageProvider(attachment.id, thumb: false).future,
      );
      await saveJpegToGallery(bytes, 'direkapin_${attachment.id}.jpg');
      message = 'Foto tersimpan di galeri';
    } on ApiException catch (e) {
      message = e.message;
    } on PlatformException catch (e) {
      message = e.code == 'permission_denied'
          ? 'Izin penyimpanan ditolak. Izinkan dulu di pengaturan HP, ya.'
          : 'Foto gagal disimpan. Coba lagi, ya.';
    }
    messenger.showSnackBar(SnackBar(content: Text(message)));
    if (mounted) setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    final attachments = widget.args.attachments;
    final current = attachments[_index];
    return Scaffold(
      appBar: AppBar(
        title: Text('Foto ${_index + 1} dari ${attachments.length}'),
        actions: [
          // Foto yang diarsip hanya punya thumbnail di server; aslinya ada di ZIP arsip.
          if (current.fullUrl != null)
            IconButton(
              tooltip: 'Simpan ke galeri',
              icon: _saving
                  ? const SizedBox.square(
                      dimension: Spacing.xl,
                      child: CircularProgressIndicator(),
                    )
                  : const Icon(Icons.download_rounded),
              onPressed: _saving ? null : () => _saveToGallery(current),
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _controller,
              itemCount: attachments.length,
              onPageChanged: (index) => setState(() => _index = index),
              itemBuilder: (context, index) {
                final attachment = attachments[index];
                return InteractiveViewer(
                  maxScale: 4,
                  child: Center(
                    child: AttachmentImage(
                      id: attachment.id,
                      thumb: attachment.fullUrl == null,
                      fit: BoxFit.contain,
                    ),
                  ),
                );
              },
            ),
          ),
          if (current.fullUrl == null)
            Padding(
              padding: const EdgeInsets.all(Spacing.lg),
              child: Text(
                _archivedMessage(current.archiveMonth),
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }
}
