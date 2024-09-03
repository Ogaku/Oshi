// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'teacher_free_days.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TeacherFreeDays _$TeacherFreeDaysFromJson(Map<String, dynamic> json) =>
    TeacherFreeDays(
      teacherFreeDays: (json['TeacherFreeDays'] as List<dynamic>?)
          ?.map((e) => TeacherFreeDay.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$TeacherFreeDaysToJson(TeacherFreeDays instance) =>
    <String, dynamic>{
      'TeacherFreeDays': instance.teacherFreeDays,
    };

TeacherFreeDay _$TeacherFreeDayFromJson(Map<String, dynamic> json) =>
    TeacherFreeDay(
      id: (json['Id'] as num?)?.toInt() ?? -1,
      teacher: json['Teacher'] == null
          ? null
          : Teacher.fromJson(json['Teacher'] as Map<String, dynamic>),
      dateFrom: json['DateFrom'] == null
          ? null
          : DateTime.parse(json['DateFrom'] as String),
      dateTo: json['DateTo'] == null
          ? null
          : DateTime.parse(json['DateTo'] as String),
      timeFrom: json['TimeFrom'] as String?,
      timeTo: json['TimeTo'] as String?,
    );

Map<String, dynamic> _$TeacherFreeDayToJson(TeacherFreeDay instance) {
  final val = <String, dynamic>{
    'Id': instance.id,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('Teacher', instance.teacher);
  writeNotNull('DateFrom', instance.dateFrom?.toIso8601String());
  writeNotNull('DateTo', instance.dateTo?.toIso8601String());
  writeNotNull('TimeFrom', instance.timeFrom);
  writeNotNull('TimeTo', instance.timeTo);
  return val;
}

Teacher _$TeacherFromJson(Map<String, dynamic> json) => Teacher(
      id: (json['Id'] as num?)?.toInt() ?? -1,
      url: json['Url'] as String? ?? '',
    );

Map<String, dynamic> _$TeacherToJson(Teacher instance) => <String, dynamic>{
      'Id': instance.id,
      'Url': instance.url,
    };
