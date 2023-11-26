// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notifications.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TimelineNotification _$TimelineNotificationFromJson(
        Map<String, dynamic> json) =>
    TimelineNotification(
      data: json['data'],
      sessionGuid: json['sessionGuid'] as String?,
      type:
          $enumDecodeNullable(_$TimelineNotificationTypeEnumMap, json['type']),
    );

Map<String, dynamic> _$TimelineNotificationToJson(
    TimelineNotification instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('type', _$TimelineNotificationTypeEnumMap[instance.type]);
  val['sessionGuid'] = instance.sessionGuid;
  writeNotNull('data', instance.data);
  return val;
}

const _$TimelineNotificationTypeEnumMap = {
  TimelineNotificationType.grade: 'grade',
  TimelineNotificationType.timetable: 'timetable',
  TimelineNotificationType.event: 'event',
  TimelineNotificationType.message: 'message',
  TimelineNotificationType.attendance: 'attendance',
  TimelineNotificationType.announcement: 'announcement',
};
