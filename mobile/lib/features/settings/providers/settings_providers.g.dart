// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(settingsApi)
final settingsApiProvider = SettingsApiProvider._();

final class SettingsApiProvider
    extends $FunctionalProvider<SettingsApi, SettingsApi, SettingsApi>
    with $Provider<SettingsApi> {
  SettingsApiProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'settingsApiProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$settingsApiHash();

  @$internal
  @override
  $ProviderElement<SettingsApi> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SettingsApi create(Ref ref) {
    return settingsApi(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SettingsApi value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SettingsApi>(value),
    );
  }
}

String _$settingsApiHash() => r'bed3b51a1aa4f2f87efb21b46d1088d6dc772f12';

@ProviderFor(me)
final meProvider = MeProvider._();

final class MeProvider
    extends $FunctionalProvider<AsyncValue<User>, User, FutureOr<User>>
    with $FutureModifier<User>, $FutureProvider<User> {
  MeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'meProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$meHash();

  @$internal
  @override
  $FutureProviderElement<User> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<User> create(Ref ref) {
    return me(ref);
  }
}

String _$meHash() => r'7edcf29d5facef5e8a43b91a4d729fdf020c237f';
