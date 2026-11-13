// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'memory_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Jam sekarang; diganti di test, atau lewat `--dart-define=MEMORY_DATE` di build debug.

@ProviderFor(memoryNow)
final memoryNowProvider = MemoryNowProvider._();

/// Jam sekarang; diganti di test, atau lewat `--dart-define=MEMORY_DATE` di build debug.

final class MemoryNowProvider
    extends $FunctionalProvider<DateTime, DateTime, DateTime>
    with $Provider<DateTime> {
  /// Jam sekarang; diganti di test, atau lewat `--dart-define=MEMORY_DATE` di build debug.
  MemoryNowProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'memoryNowProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$memoryNowHash();

  @$internal
  @override
  $ProviderElement<DateTime> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DateTime create(Ref ref) {
    return memoryNow(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DateTime value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DateTime>(value),
    );
  }
}

String _$memoryNowHash() => r'93b7ac24982f041618dfbb068c5f96a13db9802a';

/// Bulan (`YYYY-MM`) yang kartu Kenangannya sudah ditutup user. Disimpan di HP.

@ProviderFor(MemoryDismissed)
final memoryDismissedProvider = MemoryDismissedProvider._();

/// Bulan (`YYYY-MM`) yang kartu Kenangannya sudah ditutup user. Disimpan di HP.
final class MemoryDismissedProvider
    extends $AsyncNotifierProvider<MemoryDismissed, String?> {
  /// Bulan (`YYYY-MM`) yang kartu Kenangannya sudah ditutup user. Disimpan di HP.
  MemoryDismissedProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'memoryDismissedProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$memoryDismissedHash();

  @$internal
  @override
  MemoryDismissed create() => MemoryDismissed();
}

String _$memoryDismissedHash() => r'd4dc976da5fae55635aa80bfbd26f3f3287e42fa';

/// Bulan (`YYYY-MM`) yang kartu Kenangannya sudah ditutup user. Disimpan di HP.

abstract class _$MemoryDismissed extends $AsyncNotifier<String?> {
  FutureOr<String?> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<String?>, String?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<String?>, String?>,
              AsyncValue<String?>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
