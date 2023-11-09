import 'package:darq/darq.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:oshi/models/data/class.dart';
import 'package:oshi/models/data/attendances.dart';
import 'package:oshi/models/data/lesson.dart';

import 'package:hive/hive.dart';
part 'student.g.dart';

@HiveType(typeId: 30)
@JsonSerializable()
class Account {
  Account({
    this.id = -1,
    this.userId = -1,
    this.number = -1,
    this.firstName = '',
    this.lastName = '',
  });

  @HiveField(1)
  final int id;

  @HiveField(2)
  final int userId;

  @HiveField(3)
  final int number;

  @HiveField(4)
  final String firstName;

  @HiveField(5)
  final String lastName;

  String get name => '$firstName $lastName';

  factory Account.fromJson(Map<String, dynamic> json) => _$AccountFromJson(json);

  Map<String, dynamic> toJson() => _$AccountToJson(this);
}

@HiveType(typeId: 31)
@JsonSerializable(includeIfNull: false)
class Student {
  @HiveField(1)
  final Account account;

  @HiveField(2)
  final Class mainClass;

  @HiveField(3)
  final List<Class>? virtualClasses;

  @HiveField(4)
  final List<Attendance>? attendances;

  @HiveField(5)
  final List<Lesson> subjects;

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
