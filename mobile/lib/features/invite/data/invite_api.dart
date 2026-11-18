import 'package:dio/dio.dart';

import '../../../core/api/api_error.dart';
import 'invite_models.dart';

class InviteApi {
  const InviteApi(this._dio);

  final Dio _dio;

  Future<List<Invite>> list() => apiCall(() async {
    final response = await _dio.get<Map<String, dynamic>>('/invites');
    return (response.data!['items'] as List)
        .map((item) => Invite.fromJson(item as Map<String, dynamic>))
        .toList();
  });

  Future<void> create() => apiCall(() => _dio.post<void>('/invites'));
}
