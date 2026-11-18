// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'today_widget.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(todayWidgetService)
final todayWidgetServiceProvider = TodayWidgetServiceProvider._();

final class TodayWidgetServiceProvider
    extends
        $FunctionalProvider<
          TodayWidgetService,
          TodayWidgetService,
          TodayWidgetService
        >
    with $Provider<TodayWidgetService> {
  TodayWidgetServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'todayWidgetServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$todayWidgetServiceHash();

  @$internal
  @override
  $ProviderElement<TodayWidgetService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  TodayWidgetService create(Ref ref) {
    return todayWidgetService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TodayWidgetService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TodayWidgetService>(value),
    );
  }
}

String _$todayWidgetServiceHash() =>
    r'b913bcf2210cb7401dee684cd4cc27674ef968dd';

/// Path foto latar widget, null = maskot tema.

@ProviderFor(widgetPhoto)
final widgetPhotoProvider = WidgetPhotoProvider._();

/// Path foto latar widget, null = maskot tema.

final class WidgetPhotoProvider
    extends $FunctionalProvider<AsyncValue<String?>, String?, FutureOr<String?>>
    with $FutureModifier<String?>, $FutureProvider<String?> {
  /// Path foto latar widget, null = maskot tema.
  WidgetPhotoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'widgetPhotoProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$widgetPhotoHash();

  @$internal
  @override
  $FutureProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String?> create(Ref ref) {
    return widgetPhoto(ref);
  }
}

String _$widgetPhotoHash() => r'b3c410adfc579446aa4b95a8d39c9505bf7b46ab';
