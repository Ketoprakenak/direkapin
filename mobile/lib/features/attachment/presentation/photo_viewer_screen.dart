import 'package:flutter/material.dart';

import '../../../core/format/dates.dart';
import '../../../core/theme/tokens.dart';
import '../data/attachment_models.dart';
import 'widgets/attachment_image.dart';

class PhotoViewerArgs {
  const PhotoViewerArgs({required this.attachments, this.initialIndex = 0});

  final List<Attachment> attachments;
  final int initialIndex;
}

class PhotoViewerScreen extends StatefulWidget {
  const PhotoViewerScreen({super.key, required this.args});

  final PhotoViewerArgs args;

  @override
  State<PhotoViewerScreen> createState() => _PhotoViewerScreenState();
}

class _PhotoViewerScreenState extends State<PhotoViewerScreen> {
  late final _controller = PageController(
    initialPage: widget.args.initialIndex,
  );
  late int _index = widget.args.initialIndex;

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

  @override
  Widget build(BuildContext context) {
    final attachments = widget.args.attachments;
    final current = attachments[_index];
    return Scaffold(
      appBar: AppBar(
        title: Text('Foto ${_index + 1} dari ${attachments.length}'),
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
