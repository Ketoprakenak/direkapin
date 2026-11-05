import 'dart:typed_data';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/api/api_client.dart';
import '../data/attachment_api.dart';

part 'attachment_providers.g.dart';

@riverpod
AttachmentApi attachmentApi(Ref ref) =>
    AttachmentApi(ref.watch(apiClientProvider));

@riverpod
Future<Uint8List> attachmentImage(
  Ref ref,
  String id, {
  required bool thumb,
}) async {
  final bytes = await ref.watch(attachmentApiProvider).bytes(id, thumb: thumb);
  // shortcut: thumbnail menetap di memori selama aplikasi hidup (±30 KB per foto), batasi kalau foto sudah ribuan.
  if (thumb) ref.keepAlive();
  return bytes;
}
