import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/api/api_client.dart';
import '../../../core/format/dates.dart';
import '../data/activity_api.dart';
import '../data/activity_models.dart';

part 'activity_providers.g.dart';

@riverpod
ActivityApi activityApi(Ref ref) => ActivityApi(ref.watch(apiClientProvider));

/// Kegiatan satu bulan penuh; [month] = `YYYY-MM`.
@riverpod
Future<List<Activity>> monthActivities(Ref ref, String month) {
  final first = DateTime.parse('$month-01');
  final last = DateTime(first.year, first.month + 1, 0);
  return ref.watch(activityApiProvider).list(dateKey(first), dateKey(last));
}
