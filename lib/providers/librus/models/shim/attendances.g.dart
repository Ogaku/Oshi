// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attendances.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Attendances _$AttendancesFromJson(Map<String, dynamic> json) => Attendances(
      attendances: (json['Attendances'] as List<dynamic>?)
          ?.map((e) => DataAttendance.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$AttendancesToJson(Attendances instance) =>
    <String, dynamic>{
      'Attendances': instance.attendances,
    };

DataAttendance _$DataAttendanceFromJson(Map<String, dynamic> json) =>
    DataAttendance(
      lesson: json['Lesson'] == null
          ? null
          : Link.fromJson(json['Lesson'] as Map<String, dynamic>),
      student: json['Student'] == null
          ? null
          : Link.fromJson(json['Student'] as Map<String, dynamic>),
      date:
          json['Date'] == null ? null : DateTime.parse(json['Date'] as String),
      addDate: json['AddDate'] == null
          ? null
          : DateTime.parse(json['AddDate'] as String),
      lessonNo: json['LessonNo'] as int,
      semester: json['Semester'] as int,
      type: json['Type'] == null
          ? null
          : Link.fromJson(json['Type'] as Map<String, dynamic>),
      addedBy: json['AddedBy'] == null
          ? null
          : Link.fromJson(json['AddedBy'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$DataAttendanceToJson(DataAttendance instance) =>
    <String, dynamic>{
      'Lesson': instance.lesson,
      'Student': instance.student,
      'Date': instance.date?.toIso8601String(),
      'AddDate': instance.addDate?.toIso8601String(),
      'LessonNo': instance.lessonNo,
      'Semester': instance.semester,
      'Type': instance.type,
      'AddedBy': instance.addedBy,
    };

Link _$LinkFromJson(Map<String, dynamic> json) => Link(
      id: json['Id'] as int,
      url: json['Url'] as String,
    );

Map<String, dynamic> _$LinkToJson(Link instance) => <String, dynamic>{
      'Id': instance.id,
      'Url': instance.url,
    };
