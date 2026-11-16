// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wallet_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(walletApi)
final walletApiProvider = WalletApiProvider._();

final class WalletApiProvider
    extends $FunctionalProvider<WalletApi, WalletApi, WalletApi>
    with $Provider<WalletApi> {
  WalletApiProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'walletApiProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$walletApiHash();

  @$internal
  @override
  $ProviderElement<WalletApi> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  WalletApi create(Ref ref) {
    return walletApi(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WalletApi value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WalletApi>(value),
    );
  }
}

String _$walletApiHash() => r'8002aa173536ce0156e24fc3a974365909cb7e46';

@ProviderFor(wallets)
final walletsProvider = WalletsFamily._();

final class WalletsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Wallet>>,
          List<Wallet>,
          FutureOr<List<Wallet>>
        >
    with $FutureModifier<List<Wallet>>, $FutureProvider<List<Wallet>> {
  WalletsProvider._({
    required WalletsFamily super.from,
    required ({bool includeArchived, bool includeSavings}) super.argument,
  }) : super(
         retry: null,
         name: r'walletsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$walletsHash();

  @override
  String toString() {
    return r'walletsProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<List<Wallet>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Wallet>> create(Ref ref) {
    final argument =
        this.argument as ({bool includeArchived, bool includeSavings});
    return wallets(
      ref,
      includeArchived: argument.includeArchived,
      includeSavings: argument.includeSavings,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is WalletsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$walletsHash() => r'858eef972e9e094964b11f102af33f50767d9247';

final class WalletsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<Wallet>>,
          ({bool includeArchived, bool includeSavings})
        > {
  WalletsFamily._()
    : super(
        retry: null,
        name: r'walletsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  WalletsProvider call({
    bool includeArchived = false,
    bool includeSavings = false,
  }) => WalletsProvider._(
    argument: (
      includeArchived: includeArchived,
      includeSavings: includeSavings,
    ),
    from: this,
  );

  @override
  String toString() => r'walletsProvider';
}

@ProviderFor(transfers)
final transfersProvider = TransfersProvider._();

final class TransfersProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Transfer>>,
          List<Transfer>,
          FutureOr<List<Transfer>>
        >
    with $FutureModifier<List<Transfer>>, $FutureProvider<List<Transfer>> {
  TransfersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'transfersProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$transfersHash();

  @$internal
  @override
  $FutureProviderElement<List<Transfer>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Transfer>> create(Ref ref) {
    return transfers(ref);
  }
}

String _$transfersHash() => r'af06924b0836e9fd4ce41d9967166bbad808991b';
