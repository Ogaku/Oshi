import 'package:json_annotation/json_annotation.dart';

part 'homework_assignments.g.dart';

@JsonSerializable()
class HomeWorkAssignments {
  HomeWorkAssignments({
    required this.homeWorkAssignments,
  });

  @JsonKey(name: 'HomeWorkAssignments', defaultValue: null)
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

  @JsonKey(name: 'Id', defaultValue: -1)
  final int id;

  @JsonKey(name: 'Teacher', defaultValue: null)
  final Category? teacher;

  @JsonKey(name: 'Student', defaultValue: null)
  final List<Category>? student;

  @JsonKey(name: 'Date', defaultValue: null)
  final DateTime? date;

  @JsonKey(name: 'DueDate', defaultValue: null)
  final DateTime? dueDate;

  @JsonKey(name: 'Text', defaultValue: '')
  final String text;

  @JsonKey(name: 'Topic', defaultValue: '')
  final String topic;

  @JsonKey(name: 'Lesson', defaultValue: null)
  final Category? lesson;

  @JsonKey(name: 'MustSendAttachFile', defaultValue: false)
  final bool mustSendAttachFile;

  @JsonKey(name: 'SendFilePossible', defaultValue: false)
  final bool sendFilePossible;

  @JsonKey(name: 'AddedFiles', defaultValue: false)
  final bool addedFiles;

  @JsonKey(name: 'HomeworkAssigmentFiles', defaultValue: null)
  final List<Map<String, dynamic>>? homeworkAssigmentFiles;

  @JsonKey(name: 'StudentsWhoMarkedAsDone', defaultValue: null)
  final List<dynamic>? studentsWhoMarkedAsDone;

  @JsonKey(name: 'Category', defaultValue: null)
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

  @JsonKey(name: 'Id', defaultValue: -1)
  final int id;

  @JsonKey(name: 'Url', defaultValue: '')
  final String url;

  factory Category.fromJson(Map<String, dynamic> json) => _$CategoryFromJson(json);

  Map<String, dynamic> toJson() => _$CategoryToJson(this);
}
