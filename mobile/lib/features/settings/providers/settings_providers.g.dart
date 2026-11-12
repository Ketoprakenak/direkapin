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

/// Hanya dipakai saat `User.hasAvatar` true; di-invalidate setelah unggah/hapus.

@ProviderFor(avatar)
final avatarProvider = AvatarProvider._();

/// Hanya dipakai saat `User.hasAvatar` true; di-invalidate setelah unggah/hapus.

final class AvatarProvider
    extends
        $FunctionalProvider<
          AsyncValue<Uint8List>,
          Uint8List,
          FutureOr<Uint8List>
        >
    with $FutureModifier<Uint8List>, $FutureProvider<Uint8List> {
  /// Hanya dipakai saat `User.hasAvatar` true; di-invalidate setelah unggah/hapus.
  AvatarProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'avatarProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$avatarHash();

  @$internal
  @override
  $FutureProviderElement<Uint8List> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Uint8List> create(Ref ref) {
    return avatar(ref);
  }
}

String _$avatarHash() => r'8403472904a6fd6203ad276f2c68392fe2bae4a8';

/// Disimpan di HP (D-50), dan tetap ada setelah keluar akun.

@ProviderFor(AppThemeChoice)
final appThemeChoiceProvider = AppThemeChoiceProvider._();

/// Disimpan di HP (D-50), dan tetap ada setelah keluar akun.
final class AppThemeChoiceProvider
    extends $AsyncNotifierProvider<AppThemeChoice, AppThemeData> {
  /// Disimpan di HP (D-50), dan tetap ada setelah keluar akun.
  AppThemeChoiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appThemeChoiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appThemeChoiceHash();

  @$internal
  @override
  AppThemeChoice create() => AppThemeChoice();
}

String _$appThemeChoiceHash() => r'121b8cff10d4a9e4fc4cdde0df4853ffff1c1f17';

/// Disimpan di HP (D-50), dan tetap ada setelah keluar akun.

abstract class _$AppThemeChoice extends $AsyncNotifier<AppThemeData> {
  FutureOr<AppThemeData> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<AppThemeData>, AppThemeData>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<AppThemeData>, AppThemeData>,
              AsyncValue<AppThemeData>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
