import 'package:json_annotation/json_annotation.dart';

part 'subjects.g.dart';

@JsonSerializable()
class Subjects {
  Subjects({
    required this.subjects,
  });

  @JsonKey(name: 'Subjects')
  final List<Subject>? subjects;

  factory Subjects.fromJson(Map<String, dynamic> json) => _$SubjectsFromJson(json);

  Map<String, dynamic> toJson() => _$SubjectsToJson(this);
}

@JsonSerializable()
class Subject {
  Subject({
    required this.id,
    required this.name,
    required this.no,
    required this.short,
    required this.isExtracurricular,
    required this.isBlockLesson,
  });

  @JsonKey(name: 'Id')
  final int id;

  @JsonKey(name: 'Name')
  final String name;

  @JsonKey(name: 'No')
  final int no;

  @JsonKey(name: 'Short')
  final String short;

  @JsonKey(name: 'IsExtracurricular')
  final bool isExtracurricular;

  @JsonKey(name: 'IsBlockLesson')
  final bool isBlockLesson;

  factory Subject.fromJson(Map<String, dynamic> json) => _$SubjectFromJson(json);

  Map<String, dynamic> toJson() => _$SubjectToJson(this);
}
