import 'package:freezed_annotation/freezed_annotation.dart';

part 'attachment_models.freezed.dart';
part 'attachment_models.g.dart';

@freezed
abstract class Attachment with _$Attachment {
  const factory Attachment({
    required String id,
    required String thumbUrl,
    String? fullUrl,
    required bool isArchived,
    String? archiveMonth,
    required int width,
    required int height,
    required int sizeBytes,
    required DateTime createdAt,
  }) = _Attachment;

  factory Attachment.fromJson(Map<String, dynamic> json) =>
      _$AttachmentFromJson(json);
}
