import 'package:json_annotation/json_annotation.dart';

part 'teacher.g.dart';

@JsonSerializable()
class Teacher {
  Teacher(
      {this.id = -1, this.userId, this.url = '', this.firstName = '', this.lastName = '', this.isHomeTeacher, this.absent});

  int id;
  int? userId;

  String url;
  String firstName;
  String lastName;
  bool? isHomeTeacher;

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
