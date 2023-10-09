import 'package:json_annotation/json_annotation.dart';

part 'lessons.g.dart';

@JsonSerializable()
class Lessons {
  Lessons({
    required this.lessons,
  });

  @JsonKey(name: 'Lessons')
  final List<Lesson>? lessons;

  factory Lessons.fromJson(Map<String, dynamic> json) => _$LessonsFromJson(json);

  Map<String, dynamic> toJson() => _$LessonsToJson(this);
}

@JsonSerializable()
class Lesson {
  Lesson({
    required this.id,
    required this.teacher,
    required this.subject,
  });

  @JsonKey(name: 'Id')
  final int id;

  @JsonKey(name: 'Teacher')
  final Subject? teacher;

  @JsonKey(name: 'Subject')
  final Subject? subject;

  factory Lesson.fromJson(Map<String, dynamic> json) => _$LessonFromJson(json);

  Map<String, dynamic> toJson() => _$LessonToJson(this);
}

@JsonSerializable()
class Subject {
  Subject({
    required this.id,
    required this.url,
  });

  @JsonKey(name: 'Id')
  final int id;

  @JsonKey(name: 'Url')
  final String url;

  factory Subject.fromJson(Map<String, dynamic> json) => _$SubjectFromJson(json);

  Map<String, dynamic> toJson() => _$SubjectToJson(this);
}
