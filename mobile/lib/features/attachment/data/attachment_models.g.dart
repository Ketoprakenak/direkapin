// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attachment_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Attachment _$AttachmentFromJson(Map<String, dynamic> json) => _Attachment(
  id: json['id'] as String,
  thumbUrl: json['thumbUrl'] as String,
  fullUrl: json['fullUrl'] as String?,
  isArchived: json['isArchived'] as bool,
  archiveMonth: json['archiveMonth'] as String?,
  width: (json['width'] as num).toInt(),
  height: (json['height'] as num).toInt(),
  sizeBytes: (json['sizeBytes'] as num).toInt(),
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$AttachmentToJson(_Attachment instance) =>
    <String, dynamic>{
      'id': instance.id,
      'thumbUrl': instance.thumbUrl,
      'fullUrl': instance.fullUrl,
      'isArchived': instance.isArchived,
      'archiveMonth': instance.archiveMonth,
      'width': instance.width,
      'height': instance.height,
      'sizeBytes': instance.sizeBytes,
      'createdAt': instance.createdAt.toIso8601String(),
    };
