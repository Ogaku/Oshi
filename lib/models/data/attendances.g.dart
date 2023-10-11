// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attendances.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Attendance _$AttendanceFromJson(Map<String, dynamic> json) => Attendance(
      id: json['id'] as int? ?? -1,
      lessonNo: json['lessonNo'] as int? ?? -1,
      lesson: json['lesson'] == null
          ? null
          : TimetableLesson.fromJson(json['lesson'] as Map<String, dynamic>),
      date:
          json['date'] == null ? null : DateTime.parse(json['date'] as String),
      addDate: json['addDate'] == null
          ? null
          : DateTime.parse(json['addDate'] as String),
      type: $enumDecodeNullable(_$AttendanceTypeEnumMap, json['type']),
      teacher: json['teacher'] == null
          ? null
          : Teacher.fromJson(json['teacher'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AttendanceToJson(Attendance instance) =>
    <String, dynamic>{
      'id': instance.id,
      'lessonNo': instance.lessonNo,
      'lesson': instance.lesson,
      'date': instance.date.toIso8601String(),
      'addDate': instance.addDate.toIso8601String(),
      'type': _$AttendanceTypeEnumMap[instance.type]!,
      'teacher': instance.teacher,
    };

const _$AttendanceTypeEnumMap = {
  AttendanceType.absent: 'absent',
  AttendanceType.late: 'late',
  AttendanceType.excused: 'excused',
  AttendanceType.duty: 'duty',
  AttendanceType.present: 'present',
  AttendanceType.other: 'other',
};
