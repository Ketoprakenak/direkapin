import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_models.freezed.dart';
part 'auth_models.g.dart';

@freezed
abstract class User with _$User {
  const factory User({
    required String id,
    required String name,
    required String email,
    required String timezone,
    required String reminderTime,
    required bool hasAvatar,
    @Default(HeatmapSetting()) HeatmapSetting heatmap,
    required DateTime createdAt,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}

enum HeatmapMode {
  @JsonValue('AUTO')
  auto,
  @JsonValue('FIXED')
  fixed,
}

/// Skala heatmap pengeluaran kalender (D-71). Bawaan sama dengan server.
@freezed
abstract class HeatmapSetting with _$HeatmapSetting {
  const factory HeatmapSetting({
    @Default(HeatmapMode.auto) HeatmapMode mode,
    @Default([50000, 100000, 200000]) List<int> thresholds,
  }) = _HeatmapSetting;

  factory HeatmapSetting.fromJson(Map<String, dynamic> json) =>
      _$HeatmapSettingFromJson(json);
}

@freezed
abstract class AuthTokens with _$AuthTokens {
  const factory AuthTokens({
    required String accessToken,
    required String refreshToken,
    required int expiresIn,
    required User user,
  }) = _AuthTokens;

  factory AuthTokens.fromJson(Map<String, dynamic> json) =>
      _$AuthTokensFromJson(json);
}
