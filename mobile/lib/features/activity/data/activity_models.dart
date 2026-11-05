import 'package:freezed_annotation/freezed_annotation.dart';

import '../../attachment/data/attachment_models.dart';

part 'activity_models.freezed.dart';
part 'activity_models.g.dart';

@freezed
abstract class Activity with _$Activity {
  const factory Activity({
    required String id,
    required String title,
    required String date,
    String? time,
    String? location,
    String? description,
    required bool isImportant,
    required List<Attachment> attachments,
  }) = _Activity;

  factory Activity.fromJson(Map<String, dynamic> json) =>
      _$ActivityFromJson(json);
}
