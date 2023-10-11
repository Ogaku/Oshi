// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timetables.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Timetables _$TimetablesFromJson(Map<String, dynamic> json) => Timetables(
      timetable: (json['timetable'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(DateTime.parse(k),
            TimetableDay.fromJson(e as Map<String, dynamic>)),
      ),
    );

Map<String, dynamic> _$TimetablesToJson(Timetables instance) =>
    <String, dynamic>{
      'timetable':
          instance.timetable.map((k, e) => MapEntry(k.toIso8601String(), e)),
    };

TimetableDay _$TimetableDayFromJson(Map<String, dynamic> json) => TimetableDay(
      (json['lessons'] as List<dynamic>)
          .map((e) => (e as List<dynamic>?)
              ?.map((e) => TimetableLesson.fromJson(e as Map<String, dynamic>))
              .toList())
          .toList(),
    );

Map<String, dynamic> _$TimetableDayToJson(TimetableDay instance) =>
    <String, dynamic>{
      'lessons': instance.lessons,
    };

TimetableLesson _$TimetableLessonFromJson(Map<String, dynamic> json) =>
    TimetableLesson(
      url: json['url'] as String? ?? '',
      lessonNo: json['lessonNo'] as int? ?? -1,
      isCanceled: json['isCanceled'] as bool? ?? false,
      lessonClass: json['lessonClass'] == null
          ? null
          : Class.fromJson(json['lessonClass'] as Map<String, dynamic>),
      subject: json['subject'] == null
          ? null
          : Lesson.fromJson(json['subject'] as Map<String, dynamic>),
      teacher: json['teacher'] == null
          ? null
          : Teacher.fromJson(json['teacher'] as Map<String, dynamic>),
      classroom: json['classroom'] == null
          ? null
          : Classroom.fromJson(json['classroom'] as Map<String, dynamic>),
      modifiedSchedule: json['modifiedSchedule'] as bool? ?? false,
      substitutionNote: json['substitutionNote'] as String?,
      substitutionDetails: json['substitutionDetails'] == null
          ? null
          : SubstitutionDetails.fromJson(
              json['substitutionDetails'] as Map<String, dynamic>),
      date:
          json['date'] == null ? null : DateTime.parse(json['date'] as String),
      hourFrom: json['hourFrom'] == null
          ? null
          : DateTime.parse(json['hourFrom'] as String),
      hourTo: json['hourTo'] == null
          ? null
          : DateTime.parse(json['hourTo'] as String),
    );

Map<String, dynamic> _$TimetableLessonToJson(TimetableLesson instance) =>
    <String, dynamic>{
      'url': instance.url,
      'lessonNo': instance.lessonNo,
      'isCanceled': instance.isCanceled,
      'lessonClass': instance.lessonClass,
      'subject': instance.subject,
      'teacher': instance.teacher,
      'classroom': instance.classroom,
      'modifiedSchedule': instance.modifiedSchedule,
      'substitutionNote': instance.substitutionNote,
      'substitutionDetails': instance.substitutionDetails,
      'date': instance.date.toIso8601String(),
      'hourFrom': instance.hourFrom?.toIso8601String(),
      'hourTo': instance.hourTo?.toIso8601String(),
    };

SubstitutionDetails _$SubstitutionDetailsFromJson(Map<String, dynamic> json) =>
    SubstitutionDetails(
      originalUrl: json['originalUrl'] as String? ?? 'htps://g.co',
      originalLessonNo: json['originalLessonNo'] as int? ?? -1,
      originalSubject: json['originalSubject'] == null
          ? null
          : Lesson.fromJson(json['originalSubject'] as Map<String, dynamic>),
      originalTeacher: json['originalTeacher'] == null
          ? null
          : Teacher.fromJson(json['originalTeacher'] as Map<String, dynamic>),
      originalClassroom: json['originalClassroom'] == null
          ? null
          : Classroom.fromJson(
              json['originalClassroom'] as Map<String, dynamic>),
      originalDate: json['originalDate'] == null
          ? null
          : DateTime.parse(json['originalDate'] as String),
      originalHourFrom: json['originalHourFrom'] == null
          ? null
          : DateTime.parse(json['originalHourFrom'] as String),
      originalHourTo: json['originalHourTo'] == null
          ? null
          : DateTime.parse(json['originalHourTo'] as String),
    );

Map<String, dynamic> _$SubstitutionDetailsToJson(
        SubstitutionDetails instance) =>
    <String, dynamic>{
      'originalUrl': instance.originalUrl,
      'originalLessonNo': instance.originalLessonNo,
      'originalSubject': instance.originalSubject,
      'originalTeacher': instance.originalTeacher,
      'originalClassroom': instance.originalClassroom,
      'originalDate': instance.originalDate.toIso8601String(),
      'originalHourFrom': instance.originalHourFrom.toIso8601String(),
      'originalHourTo': instance.originalHourTo.toIso8601String(),
    };
