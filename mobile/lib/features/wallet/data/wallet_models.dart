import 'package:freezed_annotation/freezed_annotation.dart';

part 'wallet_models.freezed.dart';
part 'wallet_models.g.dart';

@JsonEnum(fieldRename: FieldRename.screamingSnake)
enum WalletType {
  cash('Cash', 'account_balance_wallet_rounded'),
  bank('Bank', 'account_balance_rounded'),
  ewallet('E-wallet', 'phone_iphone_rounded');

  const WalletType(this.label, this.icon);

  final String label;
  final String icon;

  String get apiValue => name.toUpperCase();
}

@freezed
abstract class Wallet with _$Wallet {
  const factory Wallet({
    required String id,
    required String name,
    required WalletType type,
    required int initialBalance,
    required int balance,
    required String icon,
    required String color,
    required bool isArchived,
    required int sortOrder,
  }) = _Wallet;

  factory Wallet.fromJson(Map<String, dynamic> json) => _$WalletFromJson(json);
}

@freezed
abstract class WalletRef with _$WalletRef {
  const factory WalletRef({
    required String id,
    required String name,
    required String icon,
    required String color,
  }) = _WalletRef;

  factory WalletRef.fromJson(Map<String, dynamic> json) =>
      _$WalletRefFromJson(json);
}

@freezed
abstract class Transfer with _$Transfer {
  const factory Transfer({
    required String id,
    required WalletRef fromWallet,
    required WalletRef toWallet,
    required int amount,
    required DateTime occurredAt,
    String? note,
  }) = _Transfer;

  factory Transfer.fromJson(Map<String, dynamic> json) =>
      _$TransferFromJson(json);
}
