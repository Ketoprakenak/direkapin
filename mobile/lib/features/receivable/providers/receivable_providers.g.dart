// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'receivable_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(receivableApi)
final receivableApiProvider = ReceivableApiProvider._();

final class ReceivableApiProvider
    extends $FunctionalProvider<ReceivableApi, ReceivableApi, ReceivableApi>
    with $Provider<ReceivableApi> {
  ReceivableApiProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'receivableApiProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$receivableApiHash();

  @$internal
  @override
  $ProviderElement<ReceivableApi> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ReceivableApi create(Ref ref) {
    return receivableApi(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ReceivableApi value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ReceivableApi>(value),
    );
  }
}

String _$receivableApiHash() => r'ec811496be97f30f12c1fa64eeaaf0afaa1100d6';

/// [all] = false hanya catatan yang masih ada orang belum lunas.

@ProviderFor(receivables)
final receivablesProvider = ReceivablesFamily._();

/// [all] = false hanya catatan yang masih ada orang belum lunas.

final class ReceivablesProvider
    extends
        $FunctionalProvider<
          AsyncValue<({List<Receivable> items, int totalRemaining})>,
          ({List<Receivable> items, int totalRemaining}),
          FutureOr<({List<Receivable> items, int totalRemaining})>
        >
    with
        $FutureModifier<({List<Receivable> items, int totalRemaining})>,
        $FutureProvider<({List<Receivable> items, int totalRemaining})> {
  /// [all] = false hanya catatan yang masih ada orang belum lunas.
  ReceivablesProvider._({
    required ReceivablesFamily super.from,
    required ({bool all, ReceivableDirection direction}) super.argument,
  }) : super(
         retry: null,
         name: r'receivablesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$receivablesHash();

  @override
  String toString() {
    return r'receivablesProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<({List<Receivable> items, int totalRemaining})>
  $createElement($ProviderPointer pointer) => $FutureProviderElement(pointer);

  @override
  FutureOr<({List<Receivable> items, int totalRemaining})> create(Ref ref) {
    final argument =
        this.argument as ({bool all, ReceivableDirection direction});
    return receivables(ref, all: argument.all, direction: argument.direction);
  }

  @override
  bool operator ==(Object other) {
    return other is ReceivablesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$receivablesHash() => r'44113a690b8397ed2d41473310232e12909b375f';

/// [all] = false hanya catatan yang masih ada orang belum lunas.

final class ReceivablesFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<({List<Receivable> items, int totalRemaining})>,
          ({bool all, ReceivableDirection direction})
        > {
  ReceivablesFamily._()
    : super(
        retry: null,
        name: r'receivablesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// [all] = false hanya catatan yang masih ada orang belum lunas.

  ReceivablesProvider call({
    bool all = false,
    ReceivableDirection direction = ReceivableDirection.receivable,
  }) => ReceivablesProvider._(
    argument: (all: all, direction: direction),
    from: this,
  );

  @override
  String toString() => r'receivablesProvider';
}
