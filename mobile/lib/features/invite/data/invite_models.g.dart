// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invite_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Invite _$InviteFromJson(Map<String, dynamic> json) => _Invite(
  code: json['code'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  expiresAt: DateTime.parse(json['expiresAt'] as String),
  usedAt: json['usedAt'] == null
      ? null
      : DateTime.parse(json['usedAt'] as String),
  usedByName: json['usedByName'] as String?,
);

Map<String, dynamic> _$InviteToJson(_Invite instance) => <String, dynamic>{
  'code': instance.code,
  'createdAt': instance.createdAt.toIso8601String(),
  'expiresAt': instance.expiresAt.toIso8601String(),
  'usedAt': instance.usedAt?.toIso8601String(),
  'usedByName': instance.usedByName,
};
