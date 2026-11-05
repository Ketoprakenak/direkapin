// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reminder_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(reminderService)
final reminderServiceProvider = ReminderServiceProvider._();

final class ReminderServiceProvider
    extends
        $FunctionalProvider<ReminderService, ReminderService, ReminderService>
    with $Provider<ReminderService> {
  ReminderServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'reminderServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$reminderServiceHash();

  @$internal
  @override
  $ProviderElement<ReminderService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ReminderService create(Ref ref) {
    return reminderService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ReminderService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ReminderService>(value),
    );
  }
}

String _$reminderServiceHash() => r'd069071a3c1ecfd3b56fb444132415b9e0cde5c9';

@ProviderFor(notificationsEnabled)
final notificationsEnabledProvider = NotificationsEnabledProvider._();

final class NotificationsEnabledProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  NotificationsEnabledProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationsEnabledProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationsEnabledHash();

  @$internal
  @override
  $FutureProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<bool> create(Ref ref) {
    return notificationsEnabled(ref);
  }
}

String _$notificationsEnabledHash() =>
    r'd845ebeb5cfd274010a1d1d533903d911ccf6bed';
