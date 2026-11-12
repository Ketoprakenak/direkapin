import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_error.dart';
import '../data/calendar_models.dart';

part 'calendar_providers.g.dart';

@riverpod
Future<List<CalendarDay>> calendarMonth(Ref ref, String month) async {
  final dio = ref.watch(apiClientProvider);
  return apiCall(() async {
    final response = await dio.get<Map<String, dynamic>>(
      '/calendar',
      queryParameters: {'month': month},
    );
    return (response.data!['days'] as List)
        .map((item) => CalendarDay.fromJson(item as Map<String, dynamic>))
        .toList();
  });
}

/// Simpan mood hari [date]; `null` menghapusnya.
Future<void> saveMood(Dio dio, String date, String? mood) =>
    apiCall(() => dio.put<void>('/days/$date/note', data: {'mood': mood}));

@riverpod
Future<DayDetail> dayDetail(Ref ref, String date) async {
  final dio = ref.watch(apiClientProvider);
  return apiCall(() async {
    final response = await dio.get<Map<String, dynamic>>('/days/$date');
    return DayDetail.fromJson(response.data!);
  });
}
