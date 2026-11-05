// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// [key] = tanggal (harian), Senin awal minggu (mingguan), atau `YYYY-MM` (bulanan).

@ProviderFor(report)
final reportProvider = ReportFamily._();

/// [key] = tanggal (harian), Senin awal minggu (mingguan), atau `YYYY-MM` (bulanan).

final class ReportProvider
    extends $FunctionalProvider<AsyncValue<Report>, Report, FutureOr<Report>>
    with $FutureModifier<Report>, $FutureProvider<Report> {
  /// [key] = tanggal (harian), Senin awal minggu (mingguan), atau `YYYY-MM` (bulanan).
  ReportProvider._({
    required ReportFamily super.from,
    required (ReportType, String, {String? walletId}) super.argument,
  }) : super(
         retry: null,
         name: r'reportProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$reportHash();

  @override
  String toString() {
    return r'reportProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<Report> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Report> create(Ref ref) {
    final argument = this.argument as (ReportType, String, {String? walletId});
    return report(ref, argument.$1, argument.$2, walletId: argument.walletId);
  }

  @override
  bool operator ==(Object other) {
    return other is ReportProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$reportHash() => r'6cc25732e52f984a4305d5b629befbdc7df4e050';

/// [key] = tanggal (harian), Senin awal minggu (mingguan), atau `YYYY-MM` (bulanan).

final class ReportFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<Report>,
          (ReportType, String, {String? walletId})
        > {
  ReportFamily._()
    : super(
        retry: null,
        name: r'reportProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// [key] = tanggal (harian), Senin awal minggu (mingguan), atau `YYYY-MM` (bulanan).

  ReportProvider call(ReportType type, String key, {String? walletId}) =>
      ReportProvider._(argument: (type, key, walletId: walletId), from: this);

  @override
  String toString() => r'reportProvider';
}

@ProviderFor(periodTransactions)
final periodTransactionsProvider = PeriodTransactionsFamily._();

final class PeriodTransactionsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Transaction>>,
          List<Transaction>,
          FutureOr<List<Transaction>>
        >
    with
        $FutureModifier<List<Transaction>>,
        $FutureProvider<List<Transaction>> {
  PeriodTransactionsProvider._({
    required PeriodTransactionsFamily super.from,
    required (String, String, {String? walletId, String? categoryId})
    super.argument,
  }) : super(
         retry: null,
         name: r'periodTransactionsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$periodTransactionsHash();

  @override
  String toString() {
    return r'periodTransactionsProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<List<Transaction>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Transaction>> create(Ref ref) {
    final argument =
        this.argument
            as (String, String, {String? walletId, String? categoryId});
    return periodTransactions(
      ref,
      argument.$1,
      argument.$2,
      walletId: argument.walletId,
      categoryId: argument.categoryId,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is PeriodTransactionsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$periodTransactionsHash() =>
    r'b5816e596890c480bcb42085da4e1d0f81d7f8aa';

final class PeriodTransactionsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<Transaction>>,
          (String, String, {String? walletId, String? categoryId})
        > {
  PeriodTransactionsFamily._()
    : super(
        retry: null,
        name: r'periodTransactionsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  PeriodTransactionsProvider call(
    String from,
    String to, {
    String? walletId,
    String? categoryId,
  }) => PeriodTransactionsProvider._(
    argument: (from, to, walletId: walletId, categoryId: categoryId),
    from: this,
  );

  @override
  String toString() => r'periodTransactionsProvider';
}
