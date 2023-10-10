import 'package:darq/darq.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:ogaku/models/data/class.dart';
import 'package:ogaku/models/data/attendances.dart';
import 'package:ogaku/models/data/lesson.dart';

part 'student.g.dart';

@JsonSerializable()
class Account {
  Account({
    required this.id,
    required this.userId,
    required this.number,
    required this.firstName,
    required this.lastName,
  });

  int id;
  int userId;
  int number;
  String firstName;
  String lastName;

  String get name => '$firstName $lastName';

  factory Account.fromJson(Map<String, dynamic> json) => _$AccountFromJson(json);

  Map<String, dynamic> toJson() => _$AccountToJson(this);
}

@JsonSerializable(includeIfNull: false)
class Student {
  Account account;
  Class mainClass;
  List<Class>? virtualClasses;
  List<Attendance>? attendances;
  List<Lesson> subjects;

  Student({
    required this.account,
    required this.mainClass,
    required this.virtualClasses,
    required this.attendances,
    required this.subjects,
  });

  Iterable<Lesson> get subjectsByGrades =>
      subjects.orderByDescending((element) => element.hasGradesCurrentSemester).thenBy((element) => element.name);

  factory Student.fromJson(Map<String, dynamic> json) => _$StudentFromJson(json);

  Map<String, dynamic> toJson() => _$StudentToJson(this);
}
