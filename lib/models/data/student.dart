import 'package:darq/darq.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:ogaku/models/data/class.dart';
import 'package:ogaku/models/data/attendances.dart';
import 'package:ogaku/models/data/lesson.dart';

part 'student.g.dart';

@JsonSerializable()
class Account {
  Account({
    this.id = -1,
    this.userId = -1,
    this.number = -1,
    this.firstName = '',
    this.lastName = '',
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
    Account? account,
    Class? mainClass,
    this.virtualClasses,
    this.attendances,
    List<Lesson>? subjects,
  })  : account = account ?? Account(),
        mainClass = mainClass ?? Class(),
        subjects = subjects ?? [];

  Iterable<Lesson> get subjectsByGrades =>
      subjects.orderByDescending((element) => element.hasGradesCurrentSemester).thenBy((element) => element.name);

  factory Student.fromJson(Map<String, dynamic> json) => _$StudentFromJson(json);

  Map<String, dynamic> toJson() => _$StudentToJson(this);
}
