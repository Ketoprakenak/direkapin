import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/api/api_client.dart';
import '../data/invite_api.dart';
import '../data/invite_models.dart';

part 'invite_providers.g.dart';

@riverpod
InviteApi inviteApi(Ref ref) => InviteApi(ref.watch(apiClientProvider));

@riverpod
Future<List<Invite>> invites(Ref ref) => ref.watch(inviteApiProvider).list();
