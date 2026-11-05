// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'photo_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(photoService)
final photoServiceProvider = PhotoServiceProvider._();

final class PhotoServiceProvider
    extends $FunctionalProvider<PhotoService, PhotoService, PhotoService>
    with $Provider<PhotoService> {
  PhotoServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'photoServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$photoServiceHash();

  @$internal
  @override
  $ProviderElement<PhotoService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  PhotoService create(Ref ref) {
    return photoService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PhotoService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PhotoService>(value),
    );
  }
}

String _$photoServiceHash() => r'2a252cce538e2915ed0cb5f284a45d04e572111a';
