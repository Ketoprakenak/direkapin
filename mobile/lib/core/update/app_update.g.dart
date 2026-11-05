// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_update.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Versi baru dari `/version`, atau `null` jika tidak ada atau gagal dicek.

@ProviderFor(availableUpdate)
final availableUpdateProvider = AvailableUpdateProvider._();

/// Versi baru dari `/version`, atau `null` jika tidak ada atau gagal dicek.

final class AvailableUpdateProvider
    extends
        $FunctionalProvider<
          AsyncValue<({String url, String version})?>,
          ({String url, String version})?,
          FutureOr<({String url, String version})?>
        >
    with
        $FutureModifier<({String url, String version})?>,
        $FutureProvider<({String url, String version})?> {
  /// Versi baru dari `/version`, atau `null` jika tidak ada atau gagal dicek.
  AvailableUpdateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'availableUpdateProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$availableUpdateHash();

  @$internal
  @override
  $FutureProviderElement<({String url, String version})?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<({String url, String version})?> create(Ref ref) {
    return availableUpdate(ref);
  }
}

String _$availableUpdateHash() => r'87bf835d9356025c946c6d2d3cd8655479a64f31';
