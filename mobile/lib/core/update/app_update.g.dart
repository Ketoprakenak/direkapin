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
          AsyncValue<AppUpdate?>,
          AppUpdate?,
          FutureOr<AppUpdate?>
        >
    with $FutureModifier<AppUpdate?>, $FutureProvider<AppUpdate?> {
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
  $FutureProviderElement<AppUpdate?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<AppUpdate?> create(Ref ref) {
    return availableUpdate(ref);
  }
}

String _$availableUpdateHash() => r'8fb357f78392bb0025d20999d4db3c6c00ea38d4';
