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
      id: (json['Id'] as num?)?.toInt() ?? -1,
      teacher: json['Teacher'] == null
          ? null
          : Link.fromJson(json['Teacher'] as Map<String, dynamic>),
      subject: json['Subject'] == null
          ? null
          : Link.fromJson(json['Subject'] as Map<String, dynamic>),
      lessonClass: json['Class'] == null
          ? null
          : Link.fromJson(json['Class'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$LessonToJson(Lesson instance) {
  final val = <String, dynamic>{
    'Id': instance.id,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('Teacher', instance.teacher);
  writeNotNull('Subject', instance.subject);
  writeNotNull('Class', instance.lessonClass);
  return val;
}

Link _$LinkFromJson(Map<String, dynamic> json) => Link(
      id: (json['Id'] as num?)?.toInt() ?? -1,
      url: json['Url'] as String? ?? '',
    );

Map<String, dynamic> _$LinkToJson(Link instance) => <String, dynamic>{
      'Id': instance.id,
      'Url': instance.url,
    };
