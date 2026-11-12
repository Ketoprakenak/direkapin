import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/api/api_client.dart';
import '../data/recurring_api.dart';
import '../data/recurring_models.dart';

part 'recurring_providers.g.dart';

@riverpod
RecurringApi recurringApi(Ref ref) =>
    RecurringApi(ref.watch(apiClientProvider));

@riverpod
Future<List<Recurring>> recurringList(Ref ref) =>
    ref.watch(recurringApiProvider).list();

@riverpod
Future<List<RecurringDue>> recurringDue(Ref ref) =>
    ref.watch(recurringApiProvider).due();
