// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'archive_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(archiveApi)
final archiveApiProvider = ArchiveApiProvider._();

final class ArchiveApiProvider
    extends $FunctionalProvider<ArchiveApi, ArchiveApi, ArchiveApi>
    with $Provider<ArchiveApi> {
  ArchiveApiProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'archiveApiProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$archiveApiHash();

  @$internal
  @override
  $ProviderElement<ArchiveApi> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ArchiveApi create(Ref ref) {
    return archiveApi(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ArchiveApi value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ArchiveApi>(value),
    );
  }
}

String _$archiveApiHash() => r'bf6f96d894b34e1732a071044130c16afea68056';

@ProviderFor(archives)
final archivesProvider = ArchivesProvider._();

final class ArchivesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Archive>>,
          List<Archive>,
          FutureOr<List<Archive>>
        >
    with $FutureModifier<List<Archive>>, $FutureProvider<List<Archive>> {
  ArchivesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'archivesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$archivesHash();

  @$internal
  @override
  $FutureProviderElement<List<Archive>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Archive>> create(Ref ref) {
    return archives(ref);
  }
}

String _$archivesHash() => r'c1fe1714c4664b4e4a72af67e4c3ef449f653c96';

@ProviderFor(archiveFiles)
final archiveFilesProvider = ArchiveFilesProvider._();

final class ArchiveFilesProvider
    extends $FunctionalProvider<ArchiveFiles, ArchiveFiles, ArchiveFiles>
    with $Provider<ArchiveFiles> {
  ArchiveFilesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'archiveFilesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$archiveFilesHash();

  @$internal
  @override
  $ProviderElement<ArchiveFiles> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ArchiveFiles create(Ref ref) {
    return archiveFiles(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ArchiveFiles value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ArchiveFiles>(value),
    );
  }
}

String _$archiveFilesHash() => r'4b8d70d601222a29889fff71305dc7598d1a819d';

/// Progress per id arsip. keepAlive: download jalan terus walau layarnya ditinggal.

@ProviderFor(ArchiveDownloads)
final archiveDownloadsProvider = ArchiveDownloadsProvider._();

/// Progress per id arsip. keepAlive: download jalan terus walau layarnya ditinggal.
final class ArchiveDownloadsProvider
    extends $NotifierProvider<ArchiveDownloads, Map<String, double>> {
  /// Progress per id arsip. keepAlive: download jalan terus walau layarnya ditinggal.
  ArchiveDownloadsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'archiveDownloadsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$archiveDownloadsHash();

  @$internal
  @override
  ArchiveDownloads create() => ArchiveDownloads();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<String, double> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<String, double>>(value),
    );
  }
}

String _$archiveDownloadsHash() => r'ba50548613f1cf0b38d8b3cd6f366f09fda583f4';

/// Progress per id arsip. keepAlive: download jalan terus walau layarnya ditinggal.

abstract class _$ArchiveDownloads extends $Notifier<Map<String, double>> {
  Map<String, double> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<Map<String, double>, Map<String, double>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Map<String, double>, Map<String, double>>,
              Map<String, double>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
