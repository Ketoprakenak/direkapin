import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/api/api_client.dart';
import '../data/activity_api.dart';

part 'activity_providers.g.dart';

@riverpod
ActivityApi activityApi(Ref ref) => ActivityApi(ref.watch(apiClientProvider));
