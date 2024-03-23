import 'package:json_annotation/json_annotation.dart';

part 'subjects.g.dart';

@JsonSerializable()
class Subjects {
  Subjects({
    required this.subjects,
  });

  @JsonKey(name: 'Subjects', defaultValue: null)
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

  @JsonKey(name: 'Id', defaultValue: -1)
  final int id;

  @JsonKey(name: 'Name', defaultValue: '')
  final String name;

  @JsonKey(name: 'No', defaultValue: -1)
  final int no;

  @JsonKey(name: 'Short', defaultValue: '')
  final String short;

  @JsonKey(name: 'IsExtracurricular', defaultValue: false)
  final bool isExtracurricular;

  @JsonKey(name: 'IsBlockLesson', defaultValue: false)
  final bool isBlockLesson;

  factory Subject.fromJson(Map<String, dynamic> json) => _$SubjectFromJson(json);

  Map<String, dynamic> toJson() => _$SubjectToJson(this);
}
