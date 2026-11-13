// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_User _$UserFromJson(Map<String, dynamic> json) => _User(
  id: json['id'] as String,
  name: json['name'] as String,
  email: json['email'] as String,
  timezone: json['timezone'] as String,
  reminderTime: json['reminderTime'] as String,
  hasAvatar: json['hasAvatar'] as bool,
  heatmap: json['heatmap'] == null
      ? const HeatmapSetting()
      : HeatmapSetting.fromJson(json['heatmap'] as Map<String, dynamic>),
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$UserToJson(_User instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'email': instance.email,
  'timezone': instance.timezone,
  'reminderTime': instance.reminderTime,
  'hasAvatar': instance.hasAvatar,
  'heatmap': instance.heatmap,
  'createdAt': instance.createdAt.toIso8601String(),
};

_HeatmapSetting _$HeatmapSettingFromJson(Map<String, dynamic> json) =>
    _HeatmapSetting(
      mode:
          $enumDecodeNullable(_$HeatmapModeEnumMap, json['mode']) ??
          HeatmapMode.auto,
      thresholds:
          (json['thresholds'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          const [50000, 100000, 200000],
    );

Map<String, dynamic> _$HeatmapSettingToJson(_HeatmapSetting instance) =>
    <String, dynamic>{
      'mode': _$HeatmapModeEnumMap[instance.mode]!,
      'thresholds': instance.thresholds,
    };

const _$HeatmapModeEnumMap = {
  HeatmapMode.auto: 'AUTO',
  HeatmapMode.fixed: 'FIXED',
};

_AuthTokens _$AuthTokensFromJson(Map<String, dynamic> json) => _AuthTokens(
  accessToken: json['accessToken'] as String,
  refreshToken: json['refreshToken'] as String,
  expiresIn: (json['expiresIn'] as num).toInt(),
  user: User.fromJson(json['user'] as Map<String, dynamic>),
);

Map<String, dynamic> _$AuthTokensToJson(_AuthTokens instance) =>
    <String, dynamic>{
      'accessToken': instance.accessToken,
      'refreshToken': instance.refreshToken,
      'expiresIn': instance.expiresIn,
      'user': instance.user,
    };
