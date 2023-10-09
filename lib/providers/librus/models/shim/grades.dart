import 'package:json_annotation/json_annotation.dart';

part 'grades.g.dart';

@JsonSerializable()
class Grades {
  Grades({
    required this.grades,
  });

  @JsonKey(name: 'Grades')
  final List<Grade>? grades;

  factory Grades.fromJson(Map<String, dynamic> json) => _$GradesFromJson(json);

  Map<String, dynamic> toJson() => _$GradesToJson(this);
}

@JsonSerializable(includeIfNull: false)
class Grade {
  Grade({
    required this.id,
    this.lesson,
    this.subject,
    this.student,
    this.category,
    this.addedBy,
    required this.grade,
    this.date,
    this.addDate,
    required this.semester,
    required this.isConstituent,
    required this.isSemester,
    required this.isSemesterProposition,
    required this.isFinal,
    required this.isFinalProposition,
    this.comments,
  });

  @JsonKey(name: 'Id')
  final int id;

  @JsonKey(name: 'Lesson')
  final Link? lesson;

  @JsonKey(name: 'Subject')
  final Link? subject;

  @JsonKey(name: 'Student')
  final Link? student;

  @JsonKey(name: 'Category')
  final Link? category;

  @JsonKey(name: 'AddedBy')
  final Link? addedBy;

  @JsonKey(name: 'Grade')
  final String grade;

  @JsonKey(name: 'Date')
  final DateTime? date;

  @JsonKey(name: 'AddDate')
  final DateTime? addDate;

  @JsonKey(name: 'Semester')
  final int semester;

  @JsonKey(name: 'IsConstituent')
  final bool isConstituent;

  @JsonKey(name: 'IsSemester')
  final bool isSemester;

  @JsonKey(name: 'IsSemesterProposition')
  final bool isSemesterProposition;

  @JsonKey(name: 'IsFinal')
  final bool isFinal;

  @JsonKey(name: 'IsFinalProposition')
  final bool isFinalProposition;

  @JsonKey(name: 'Comments')
  final List<Link>? comments;

  factory Grade.fromJson(Map<String, dynamic> json) => _$GradeFromJson(json);

  Map<String, dynamic> toJson() => _$GradeToJson(this);
}

@JsonSerializable()
class Link {
  Link({
    required this.id,
    required this.url,
  });

  @JsonKey(name: 'Id')
  final int id;

  @JsonKey(name: 'Url')
  final String url;

  factory Link.fromJson(Map<String, dynamic> json) => _$LinkFromJson(json);

  Map<String, dynamic> toJson() => _$LinkToJson(this);
}
