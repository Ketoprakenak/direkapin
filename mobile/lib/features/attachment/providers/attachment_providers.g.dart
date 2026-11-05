// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attachment_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(attachmentApi)
final attachmentApiProvider = AttachmentApiProvider._();

final class AttachmentApiProvider
    extends $FunctionalProvider<AttachmentApi, AttachmentApi, AttachmentApi>
    with $Provider<AttachmentApi> {
  AttachmentApiProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'attachmentApiProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$attachmentApiHash();

  @$internal
  @override
  $ProviderElement<AttachmentApi> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AttachmentApi create(Ref ref) {
    return attachmentApi(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AttachmentApi value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AttachmentApi>(value),
    );
  }
}

String _$attachmentApiHash() => r'3603fa84d96f9025ba60d5675b1741de8f2b51fc';

@ProviderFor(attachmentImage)
final attachmentImageProvider = AttachmentImageFamily._();

final class AttachmentImageProvider
    extends
        $FunctionalProvider<
          AsyncValue<Uint8List>,
          Uint8List,
          FutureOr<Uint8List>
        >
    with $FutureModifier<Uint8List>, $FutureProvider<Uint8List> {
  AttachmentImageProvider._({
    required AttachmentImageFamily super.from,
    required (String, {bool thumb}) super.argument,
  }) : super(
         retry: null,
         name: r'attachmentImageProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$attachmentImageHash();

  @override
  String toString() {
    return r'attachmentImageProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<Uint8List> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Uint8List> create(Ref ref) {
    final argument = this.argument as (String, {bool thumb});
    return attachmentImage(ref, argument.$1, thumb: argument.thumb);
  }

  @override
  bool operator ==(Object other) {
    return other is AttachmentImageProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$attachmentImageHash() => r'a3005ba635e04baa92467dad9c8bee9eb740dae3';

final class AttachmentImageFamily extends $Family
    with
        $FunctionalFamilyOverride<FutureOr<Uint8List>, (String, {bool thumb})> {
  AttachmentImageFamily._()
    : super(
        retry: null,
        name: r'attachmentImageProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  AttachmentImageProvider call(String id, {required bool thumb}) =>
      AttachmentImageProvider._(argument: (id, thumb: thumb), from: this);

  @override
  String toString() => r'attachmentImageProvider';
}
