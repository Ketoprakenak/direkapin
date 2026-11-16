import 'package:freezed_annotation/freezed_annotation.dart';

import '../../wallet/data/wallet_models.dart';

part 'receivable_models.freezed.dart';
part 'receivable_models.g.dart';

/// receivable = piutang (FIN-19); payable = utang owner ke 1 orang (FIN-20).
enum ReceivableDirection {
  @JsonValue('RECEIVABLE')
  receivable,
  @JsonValue('PAYABLE')
  payable;

  bool get isPayable => this == payable;
}

/// Talangan berisi beberapa orang yang berutang ke owner (FIN-19, D-77),
/// atau utang owner ke 1 orang (FIN-20, D-78).
@freezed
abstract class Receivable with _$Receivable {
  const factory Receivable({
    required String id,
    @Default(ReceivableDirection.receivable) ReceivableDirection direction,
    required String title,
    required String date,
    String? note,
    required int total,
    required int remaining,
    ReceivableLoan? loan,
    ReceivableSourceRef? source,
    required List<Debtor> debtors,
  }) = _Receivable;

  factory Receivable.fromJson(Map<String, dynamic> json) =>
      _$ReceivableFromJson(json);
}

/// Pengeluaran asal piutang hasil "Bagi ke teman" (FIN-21, D-79).
@freezed
abstract class ReceivableSourceRef with _$ReceivableSourceRef {
  const factory ReceivableSourceRef({
    required String transactionId,
    required int amount,
    required String categoryName,
  }) = _ReceivableSourceRef;

  factory ReceivableSourceRef.fromJson(Map<String, dynamic> json) =>
      _$ReceivableSourceRefFromJson(json);
}

/// Argumen form "Bagi ke teman": pengeluaran yang akan dibagi.
class ReceivableSource {
  const ReceivableSource({
    required this.transactionId,
    required this.amount,
    required this.categoryName,
    required this.date,
  });

  final String transactionId;
  final int amount;
  final String categoryName;

  /// `YYYY-MM-DD` lokal tanggal pengeluaran.
  final String date;
}

/// Pemasukan pinjam tunai yang menyertai utang (D-78).
@freezed
abstract class ReceivableLoan with _$ReceivableLoan {
  const factory ReceivableLoan({
    required String transactionId,
    required int amount,
    required WalletRef wallet,
  }) = _ReceivableLoan;

  factory ReceivableLoan.fromJson(Map<String, dynamic> json) =>
      _$ReceivableLoanFromJson(json);
}

@freezed
abstract class Debtor with _$Debtor {
  const factory Debtor({
    required String id,
    required String name,
    required int amount,
    required int paid,
    required int remaining,
    required List<DebtorPayment> payments,
  }) = _Debtor;

  factory Debtor.fromJson(Map<String, dynamic> json) => _$DebtorFromJson(json);
}

@freezed
abstract class DebtorPayment with _$DebtorPayment {
  const factory DebtorPayment({
    required String transactionId,
    required int amount,
    required DateTime occurredAt,
    required WalletRef wallet,
  }) = _DebtorPayment;

  factory DebtorPayment.fromJson(Map<String, dynamic> json) =>
      _$DebtorPaymentFromJson(json);
}
