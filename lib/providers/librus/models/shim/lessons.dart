import 'package:json_annotation/json_annotation.dart';

part 'lessons.g.dart';

@JsonSerializable()
class Lessons {
  Lessons({
    required this.lessons,
  });

  @JsonKey(name: 'Lessons', defaultValue: null)
  final List<Lesson>? lessons;

  factory Lessons.fromJson(Map<String, dynamic> json) => _$LessonsFromJson(json);

  Map<String, dynamic> toJson() => _$LessonsToJson(this);
}

@JsonSerializable(includeIfNull: false)
class Lesson {
  Lesson({
    required this.id,
    required this.teacher,
    required this.subject,
    this.lessonClass
  });

  @JsonKey(name: 'Id', defaultValue: -1)
  final int id;

  @JsonKey(name: 'Teacher', defaultValue: null)
  final Link? teacher;

  @JsonKey(name: 'Subject', defaultValue: null)
  final Link? subject;

  @JsonKey(name: 'Class', defaultValue: null)
  final Link? lessonClass;

  factory Lesson.fromJson(Map<String, dynamic> json) => _$LessonFromJson(json);

  Map<String, dynamic> toJson() => _$LessonToJson(this);
}

@JsonSerializable()
class Link {
  Link({
    required this.id,
    required this.url,
  });

  @JsonKey(name: 'Id', defaultValue: -1)
  final int id;

  @JsonKey(name: 'Url', defaultValue: '')
  final String url;

  factory Link.fromJson(Map<String, dynamic> json) => _$LinkFromJson(json);

  Map<String, dynamic> toJson() => _$LinkToJson(this);
}
