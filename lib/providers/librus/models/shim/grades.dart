import 'package:json_annotation/json_annotation.dart';

part 'grades.g.dart';

@JsonSerializable()
class Grades {
  Grades({
    required this.grades,
  });

  @JsonKey(name: 'Grades', defaultValue: null)
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
    this.resit,
    this.improvement,
  });

  @JsonKey(name: 'Id', defaultValue: -1)
  final int id;

  @JsonKey(name: 'Lesson', defaultValue: null)
  final Link? lesson;

  @JsonKey(name: 'Subject', defaultValue: null)
  final Link? subject;

  @JsonKey(name: 'Student', defaultValue: null)
  final Link? student;

  @JsonKey(name: 'Category', defaultValue: null)
  final Link? category;

  @JsonKey(name: 'AddedBy', defaultValue: null)
  final Link? addedBy;

  @JsonKey(name: 'Grade', defaultValue: '')
  final String grade;

  @JsonKey(name: 'Date', defaultValue: null)
  final DateTime? date;

  @JsonKey(name: 'AddDate', defaultValue: null)
  final DateTime? addDate;

  @JsonKey(name: 'Semester', defaultValue: -1)
  final int semester;

  @JsonKey(name: 'IsConstituent', defaultValue: false)
  final bool isConstituent;

  @JsonKey(name: 'IsSemester', defaultValue: false)
  final bool isSemester;

  @JsonKey(name: 'IsSemesterProposition', defaultValue: false)
  final bool isSemesterProposition;

  @JsonKey(name: 'IsFinal', defaultValue: false)
  final bool isFinal;

  @JsonKey(name: 'IsFinalProposition', defaultValue: false)
  final bool isFinalProposition;

  @JsonKey(name: 'Comments', defaultValue: null)
  final List<Link>? comments;

  @JsonKey(name: 'Resit', defaultValue: null)
  final dynamic resit;

  @JsonKey(name: 'Improvement', defaultValue: null)
  final dynamic improvement;

  factory Grade.fromJson(Map<String, dynamic> json) => _$GradeFromJson(json);

  Map<String, dynamic> toJson() => _$GradeToJson(this);
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
