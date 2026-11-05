import 'package:flutter/foundation.dart';

import '../../../core/api/api_error.dart';
import '../data/attachment_api.dart';
import '../data/attachment_models.dart';

/// Foto baru di form, sudah dikompres, menunggu itemnya tersimpan.
class PhotoDraft {
  PhotoDraft(this.path);

  final String path;
  double? progress;
  bool uploading = false;
  bool uploaded = false;
  bool failed = false;
}

/// Perubahan foto di form. Baru dikirim ke server setelah itemnya tersimpan.
class PhotoEdits extends ChangeNotifier {
  PhotoEdits(List<Attachment> existing) : existing = [...existing];

  final List<Attachment> existing;
  final drafts = <PhotoDraft>[];
  final _removed = <Attachment>[];
  bool picking = false;
  String? error;
  String? status;
  bool _disposed = false;

  void _changed() {
    if (!_disposed) notifyListeners();
  }

  void setPicking(bool value) {
    picking = value;
    _changed();
  }

  void addDraft(String path) {
    drafts.add(PhotoDraft(path));
    _changed();
  }

  void removeDraft(PhotoDraft draft) {
    drafts.remove(draft);
    _changed();
  }

  void removeExisting(Attachment attachment) {
    existing.remove(attachment);
    _removed.add(attachment);
    _changed();
  }

  /// Hapus dulu supaya slot foto kosong, lalu upload berurutan (D-38).
  /// Yang gagal tetap tersisa untuk "Coba lagi"; itemnya sudah aman.
  /// [subject] = nama item di pesan error, mis. `Transaksi`.
  Future<bool> sync(
    AttachmentApi api, {
    String? transactionId,
    String? activityId,
    required String subject,
  }) async {
    String? failure;
    error = null;
    _changed();

    for (final attachment in [..._removed]) {
      try {
        await api.delete(attachment.id);
        _removed.remove(attachment);
      } on ApiException {
        failure = 'Foto lama gagal dihapus. $subject tetap tersimpan.';
      }
    }

    final pending = drafts.where((draft) => !draft.uploaded).toList();
    for (final (index, draft) in pending.indexed) {
      draft
        ..uploading = true
        ..failed = false
        ..progress = null;
      status = 'Mengupload foto ${index + 1} dari ${pending.length}';
      _changed();
      try {
        await api.upload(
          draft.path,
          transactionId: transactionId,
          activityId: activityId,
          onProgress: (progress) {
            draft.progress = progress;
            _changed();
          },
        );
        draft.uploaded = true;
      } on ApiException catch (e) {
        draft.failed = true;
        failure = e.code == 'PHOTO_LIMIT_REACHED'
            ? e.message
            : 'Foto gagal diupload. $subject tetap tersimpan.';
      } finally {
        draft.uploading = false;
      }
    }

    error = failure;
    status = null;
    _changed();
    return failure == null;
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
