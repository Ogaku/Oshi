import 'package:darq/darq.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:ogaku/models/data/class.dart';
import 'package:ogaku/models/data/attendances.dart';
import 'package:ogaku/models/data/lesson.dart';

import 'package:hive/hive.dart';
part 'student.g.dart';

@HiveType(typeId: 30)
@JsonSerializable()
class Account extends HiveObject {
  Account({
    this.id = -1,
    this.userId = -1,
    this.number = -1,
    this.firstName = '',
    this.lastName = '',
  });

  @HiveField(1)
  int id;

  @HiveField(2)
  int userId;

  @HiveField(3)
  int number;

  @HiveField(4)
  String firstName;

  @HiveField(5)
  String lastName;

  String get name => '$firstName $lastName';

  factory Account.fromJson(Map<String, dynamic> json) => _$AccountFromJson(json);

  Map<String, dynamic> toJson() => _$AccountToJson(this);
}

@HiveType(typeId: 31)
@JsonSerializable(includeIfNull: false)
class Student extends HiveObject {
  @HiveField(1)
  Account account;

  @HiveField(2)
  Class mainClass;

  @HiveField(3)
  List<Class>? virtualClasses;

  @HiveField(4)
  List<Attendance>? attendances;

  @HiveField(5)
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
