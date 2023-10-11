import 'package:json_annotation/json_annotation.dart';

part 'homework_assignments.g.dart';

@JsonSerializable()
class HomeWorkAssignments {
  HomeWorkAssignments({
    required this.homeWorkAssignments,
  });

  @JsonKey(name: 'HomeWorkAssignments')
  final List<HomeWorkAssignment>? homeWorkAssignments;

  factory HomeWorkAssignments.fromJson(Map<String, dynamic> json) => _$HomeWorkAssignmentsFromJson(json);

  Map<String, dynamic> toJson() => _$HomeWorkAssignmentsToJson(this);
}

@JsonSerializable()
class HomeWorkAssignment {
  HomeWorkAssignment({
    required this.id,
    required this.teacher,
    required this.student,
    required this.date,
    required this.dueDate,
    required this.text,
    required this.topic,
    required this.lesson,
    required this.mustSendAttachFile,
    required this.sendFilePossible,
    required this.addedFiles,
    required this.homeworkAssigmentFiles,
    required this.category,
    required this.studentsWhoMarkedAsDone,
  });

  @JsonKey(name: 'Id')
  final int id;

  @JsonKey(name: 'Teacher')
  final Category? teacher;

  @JsonKey(name: 'Student')
  final List<Category>? student;

  @JsonKey(name: 'Date')
  final DateTime? date;

  @JsonKey(name: 'DueDate')
  final DateTime? dueDate;

  @JsonKey(name: 'Text')
  final String text;

  @JsonKey(name: 'Topic')
  final String topic;

  @JsonKey(name: 'Lesson')
  final Category? lesson;

  @JsonKey(name: 'MustSendAttachFile')
  final bool mustSendAttachFile;

  @JsonKey(name: 'SendFilePossible')
  final bool sendFilePossible;

  @JsonKey(name: 'AddedFiles')
  final bool addedFiles;

  @JsonKey(name: 'HomeworkAssigmentFiles')
  final List<dynamic>? homeworkAssigmentFiles;

  @JsonKey(name: 'StudentsWhoMarkedAsDone')
  final List<dynamic>? studentsWhoMarkedAsDone;

  @JsonKey(name: 'Category')
  final Category? category;

  factory HomeWorkAssignment.fromJson(Map<String, dynamic> json) => _$HomeWorkAssignmentFromJson(json);

  Map<String, dynamic> toJson() => _$HomeWorkAssignmentToJson(this);
}

@JsonSerializable()
class Category {
  Category({
    required this.id,
    required this.url,
  });

  @JsonKey(name: 'Id')
  final int id;

  @JsonKey(name: 'Url')
  final String url;

  factory Category.fromJson(Map<String, dynamic> json) => _$CategoryFromJson(json);

  Map<String, dynamic> toJson() => _$CategoryToJson(this);
}
