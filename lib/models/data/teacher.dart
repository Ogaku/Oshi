import 'package:json_annotation/json_annotation.dart';

import 'package:hive/hive.dart';
part 'teacher.g.dart';

@HiveType(typeId: 32)
@JsonSerializable()
class Teacher extends HiveObject {
  Teacher(
      {this.id = -1, this.userId, this.url = '', this.firstName = '', this.lastName = '', this.isHomeTeacher, this.absent});

  @HiveField(1)
  int id;

  @HiveField(2)
  int? userId;

  @HiveField(3)
  String url;

  @HiveField(4)
  String firstName;

  @HiveField(5)
  String lastName;

  @HiveField(6)
  bool? isHomeTeacher;

  @HiveField(7)
  ({DateTime from, DateTime to})? absent;

  String get name {
    if (firstName.isEmpty && lastName.isEmpty) return 'UNKNOWN';
    if (firstName.isEmpty) return lastName;
    return lastName.isEmpty ? firstName : '$firstName $lastName';
  }

  String get nameInv {
    if (firstName.isEmpty && lastName.isEmpty) return 'UNKNOWN';
    if (firstName.isEmpty) return lastName;
    return lastName.isEmpty ? firstName : '$lastName $firstName';
  }

  factory Teacher.fromJson(Map<String, dynamic> json) => _$TeacherFromJson(json);

  Map<String, dynamic> toJson() => _$TeacherToJson(this);
}
