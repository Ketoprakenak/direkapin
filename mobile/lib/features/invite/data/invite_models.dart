import 'package:freezed_annotation/freezed_annotation.dart';

part 'invite_models.freezed.dart';
part 'invite_models.g.dart';

/// Kode undangan buatan owner (AUTH-07).
@freezed
abstract class Invite with _$Invite {
  const Invite._();

  const factory Invite({
    required String code,
    required DateTime createdAt,
    required DateTime expiresAt,
    DateTime? usedAt,
    String? usedByName,
  }) = _Invite;

  factory Invite.fromJson(Map<String, dynamic> json) => _$InviteFromJson(json);

  bool isExpired(DateTime now) => usedAt == null && !expiresAt.isAfter(now);
}
