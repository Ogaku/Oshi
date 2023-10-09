// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lessons.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Lessons _$LessonsFromJson(Map<String, dynamic> json) => Lessons(
      lessons: (json['Lessons'] as List<dynamic>?)
          ?.map((e) => Lesson.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$LessonsToJson(Lessons instance) => <String, dynamic>{
      'Lessons': instance.lessons,
    };

Lesson _$LessonFromJson(Map<String, dynamic> json) => Lesson(
      id: json['Id'] as int,
      teacher: json['Teacher'] == null
          ? null
          : Subject.fromJson(json['Teacher'] as Map<String, dynamic>),
      subject: json['Subject'] == null
          ? null
          : Subject.fromJson(json['Subject'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$LessonToJson(Lesson instance) => <String, dynamic>{
      'Id': instance.id,
      'Teacher': instance.teacher,
      'Subject': instance.subject,
    };

Subject _$SubjectFromJson(Map<String, dynamic> json) => Subject(
      id: json['Id'] as int,
      url: json['Url'] as String,
    );

Map<String, dynamic> _$SubjectToJson(Subject instance) => <String, dynamic>{
      'Id': instance.id,
      'Url': instance.url,
    };
