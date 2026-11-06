import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:intl/intl.dart';

part 'archive_models.freezed.dart';
part 'archive_models.g.dart';

@JsonEnum(fieldRename: FieldRename.screamingSnake)
enum ArchiveStatus { ready, downloaded, expired, failed }

@freezed
abstract class Archive with _$Archive {
  const factory Archive({
    required String id,
    required String month,
    required int sizeBytes,
    required int photoCount,
    required ArchiveStatus status,
    required DateTime createdAt,
    required DateTime expiresAt,
    DateTime? downloadedAt,
  }) = _Archive;

  factory Archive.fromJson(Map<String, dynamic> json) =>
      _$ArchiveFromJson(json);
}

/// Sisa hari sampai [expiresAt], dibulatkan ke atas. Tidak pernah negatif.
int daysUntil(DateTime expiresAt, DateTime now) {
  final seconds = expiresAt.difference(now).inSeconds;
  return seconds <= 0 ? 0 : (seconds / Duration.secondsPerDay).ceil();
}

/// `340 KB`, `3,4 MB`
String formatSize(int bytes) {
  const kb = 1024;
  if (bytes < kb * kb) return '${(bytes / kb).ceil()} KB';
  final mb = NumberFormat('0.#', 'id_ID').format(bytes / (kb * kb));
  return '$mb MB';
}
