// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attendances.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Attendance _$AttendanceFromJson(Map<String, dynamic> json) => Attendance(
      id: json['id'] as int,
      lessonNo: json['lessonNo'] as int,
      lesson: TimetableLesson.fromJson(json['lesson'] as Map<String, dynamic>),
      date: DateTime.parse(json['date'] as String),
      addDate: DateTime.parse(json['addDate'] as String),
      type: $enumDecode(_$AttendanceTypeEnumMap, json['type']),
      teacher: json['teacher'] == null
          ? null
          : Teacher.fromJson(json['teacher'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AttendanceToJson(Attendance instance) {
  final val = <String, dynamic>{
    'id': instance.id,
    'lessonNo': instance.lessonNo,
    'lesson': instance.lesson,
    'date': instance.date.toIso8601String(),
    'addDate': instance.addDate.toIso8601String(),
    'type': _$AttendanceTypeEnumMap[instance.type]!,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('teacher', instance.teacher);
  return val;
}

const _$AttendanceTypeEnumMap = {
  AttendanceType.absent: 'absent',
  AttendanceType.late: 'late',
  AttendanceType.excused: 'excused',
  AttendanceType.duty: 'duty',
  AttendanceType.present: 'present',
  AttendanceType.other: 'other',
};
