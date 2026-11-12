// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(transactionApi)
final transactionApiProvider = TransactionApiProvider._();

final class TransactionApiProvider
    extends $FunctionalProvider<TransactionApi, TransactionApi, TransactionApi>
    with $Provider<TransactionApi> {
  TransactionApiProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'transactionApiProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$transactionApiHash();

  @$internal
  @override
  $ProviderElement<TransactionApi> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  TransactionApi create(Ref ref) {
    return transactionApi(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TransactionApi value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TransactionApi>(value),
    );
  }
}

String _$transactionApiHash() => r'03c80eaabb4ef2dcf7633a37601a24a262cee0f8';

@ProviderFor(walletTransactions)
final walletTransactionsProvider = WalletTransactionsFamily._();

final class WalletTransactionsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Transaction>>,
          List<Transaction>,
          FutureOr<List<Transaction>>
        >
    with
        $FutureModifier<List<Transaction>>,
        $FutureProvider<List<Transaction>> {
  WalletTransactionsProvider._({
    required WalletTransactionsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'walletTransactionsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$walletTransactionsHash();

  @override
  String toString() {
    return r'walletTransactionsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<Transaction>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Transaction>> create(Ref ref) {
    final argument = this.argument as String;
    return walletTransactions(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is WalletTransactionsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$walletTransactionsHash() =>
    r'96ba3083c1fa9ad066369452bd70c19d98eb5a87';

final class WalletTransactionsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<Transaction>>, String> {
  WalletTransactionsFamily._()
    : super(
        retry: null,
        name: r'walletTransactionsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  WalletTransactionsProvider call(String walletId) =>
      WalletTransactionsProvider._(argument: walletId, from: this);

  @override
  String toString() => r'walletTransactionsProvider';
}

/// Cari & filter transaksi (FIN-11). [type] = `INCOME`/`EXPENSE`, tanggal `YYYY-MM-DD`.

@ProviderFor(searchTransactions)
final searchTransactionsProvider = SearchTransactionsFamily._();

/// Cari & filter transaksi (FIN-11). [type] = `INCOME`/`EXPENSE`, tanggal `YYYY-MM-DD`.

final class SearchTransactionsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Transaction>>,
          List<Transaction>,
          FutureOr<List<Transaction>>
        >
    with
        $FutureModifier<List<Transaction>>,
        $FutureProvider<List<Transaction>> {
  /// Cari & filter transaksi (FIN-11). [type] = `INCOME`/`EXPENSE`, tanggal `YYYY-MM-DD`.
  SearchTransactionsProvider._({
    required SearchTransactionsFamily super.from,
    required ({
      String? query,
      String? walletId,
      String? categoryId,
      String? type,
      String? from,
      String? to,
    })
    super.argument,
  }) : super(
         retry: null,
         name: r'searchTransactionsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$searchTransactionsHash();

  @override
  String toString() {
    return r'searchTransactionsProvider'
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
            as ({
              String? query,
              String? walletId,
              String? categoryId,
              String? type,
              String? from,
              String? to,
            });
    return searchTransactions(
      ref,
      query: argument.query,
      walletId: argument.walletId,
      categoryId: argument.categoryId,
      type: argument.type,
      from: argument.from,
      to: argument.to,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is SearchTransactionsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$searchTransactionsHash() =>
    r'390142ac2bc753f42d0f0e5d1070f28e21d6e42c';

/// Cari & filter transaksi (FIN-11). [type] = `INCOME`/`EXPENSE`, tanggal `YYYY-MM-DD`.

final class SearchTransactionsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<Transaction>>,
          ({
            String? query,
            String? walletId,
            String? categoryId,
            String? type,
            String? from,
            String? to,
          })
        > {
  SearchTransactionsFamily._()
    : super(
        retry: null,
        name: r'searchTransactionsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Cari & filter transaksi (FIN-11). [type] = `INCOME`/`EXPENSE`, tanggal `YYYY-MM-DD`.

  SearchTransactionsProvider call({
    String? query,
    String? walletId,
    String? categoryId,
    String? type,
    String? from,
    String? to,
  }) => SearchTransactionsProvider._(
    argument: (
      query: query,
      walletId: walletId,
      categoryId: categoryId,
      type: type,
      from: from,
      to: to,
    ),
    from: this,
  );

  @override
  String toString() => r'searchTransactionsProvider';
}

/// 3 transaksi terbaru untuk Beranda (DSH-04).

@ProviderFor(recentTransactions)
final recentTransactionsProvider = RecentTransactionsProvider._();

/// 3 transaksi terbaru untuk Beranda (DSH-04).

final class RecentTransactionsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Transaction>>,
          List<Transaction>,
          FutureOr<List<Transaction>>
        >
    with
        $FutureModifier<List<Transaction>>,
        $FutureProvider<List<Transaction>> {
  /// 3 transaksi terbaru untuk Beranda (DSH-04).
  RecentTransactionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'recentTransactionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$recentTransactionsHash();

  @$internal
  @override
  $FutureProviderElement<List<Transaction>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Transaction>> create(Ref ref) {
    return recentTransactions(ref);
  }
}

String _$recentTransactionsHash() =>
    r'9ab9b69eecbb1d5b12759e2d4b8dbb9dd329985b';

/// Dompet transaksi terakhir, untuk pilihan awal di form (D-31).

@ProviderFor(lastUsedWalletId)
final lastUsedWalletIdProvider = LastUsedWalletIdProvider._();

/// Dompet transaksi terakhir, untuk pilihan awal di form (D-31).

final class LastUsedWalletIdProvider
    extends $FunctionalProvider<AsyncValue<String?>, String?, FutureOr<String?>>
    with $FutureModifier<String?>, $FutureProvider<String?> {
  /// Dompet transaksi terakhir, untuk pilihan awal di form (D-31).
  LastUsedWalletIdProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'lastUsedWalletIdProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$lastUsedWalletIdHash();

  @$internal
  @override
  $FutureProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String?> create(Ref ref) {
    return lastUsedWalletId(ref);
  }
}

String _$lastUsedWalletIdHash() => r'f0ff7edce69271fba92caf8ace51bc700506188d';
