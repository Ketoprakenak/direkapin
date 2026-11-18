// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invite_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(inviteApi)
final inviteApiProvider = InviteApiProvider._();

final class InviteApiProvider
    extends $FunctionalProvider<InviteApi, InviteApi, InviteApi>
    with $Provider<InviteApi> {
  InviteApiProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'inviteApiProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$inviteApiHash();

  @$internal
  @override
  $ProviderElement<InviteApi> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  InviteApi create(Ref ref) {
    return inviteApi(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(InviteApi value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<InviteApi>(value),
    );
  }
}

String _$inviteApiHash() => r'd4a39c82f3f77504aca591aaae6e25558f323253';

@ProviderFor(invites)
final invitesProvider = InvitesProvider._();

final class InvitesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Invite>>,
          List<Invite>,
          FutureOr<List<Invite>>
        >
    with $FutureModifier<List<Invite>>, $FutureProvider<List<Invite>> {
  InvitesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'invitesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$invitesHash();

  @$internal
  @override
  $FutureProviderElement<List<Invite>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Invite>> create(Ref ref) {
    return invites(ref);
  }
}

String _$invitesHash() => r'47c2df30ec6f612970a62be96e0fe21c2d34c130';
