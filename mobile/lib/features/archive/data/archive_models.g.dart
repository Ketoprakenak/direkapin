// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'archive_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Archive _$ArchiveFromJson(Map<String, dynamic> json) => _Archive(
  id: json['id'] as String,
  month: json['month'] as String,
  sizeBytes: (json['sizeBytes'] as num).toInt(),
  photoCount: (json['photoCount'] as num).toInt(),
  status: $enumDecode(_$ArchiveStatusEnumMap, json['status']),
  createdAt: DateTime.parse(json['createdAt'] as String),
  expiresAt: DateTime.parse(json['expiresAt'] as String),
  downloadedAt: json['downloadedAt'] == null
      ? null
      : DateTime.parse(json['downloadedAt'] as String),
);

Map<String, dynamic> _$ArchiveToJson(_Archive instance) => <String, dynamic>{
  'id': instance.id,
  'month': instance.month,
  'sizeBytes': instance.sizeBytes,
  'photoCount': instance.photoCount,
  'status': _$ArchiveStatusEnumMap[instance.status]!,
  'createdAt': instance.createdAt.toIso8601String(),
  'expiresAt': instance.expiresAt.toIso8601String(),
  'downloadedAt': instance.downloadedAt?.toIso8601String(),
};

const _$ArchiveStatusEnumMap = {
  ArchiveStatus.ready: 'READY',
  ArchiveStatus.downloaded: 'DOWNLOADED',
  ArchiveStatus.expired: 'EXPIRED',
  ArchiveStatus.failed: 'FAILED',
};
