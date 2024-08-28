import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import 'package:hive/hive.dart';
part 'teacher.g.dart';

@HiveType(typeId: 32)
@JsonSerializable()
class Teacher extends Equatable {
  const Teacher(
      {this.id = -1, this.userId, this.url = '', this.firstName = '', this.lastName = '', this.isHomeTeacher, this.absent});

  @HiveField(1)
  final int id;

  @HiveField(2)
  final int? userId;

  @HiveField(3)
  final String url;

  @HiveField(4)
  final String firstName;

  @HiveField(5)
  final String lastName;

  @HiveField(6)
  final bool? isHomeTeacher;

  @HiveField(7)
  final ({DateTime from, DateTime to})? absent;

  String get name {
    if (firstName.isEmpty && lastName.isEmpty) return 'Unknown';
    if (firstName.isEmpty) return lastName;
    return lastName.isEmpty ? firstName : '$firstName $lastName';
  }

  String get nameInv {
    if (firstName.isEmpty && lastName.isEmpty) return 'Unknown';
    if (firstName.isEmpty) return lastName;
    return lastName.isEmpty ? firstName : '$lastName $firstName';
  }

  @override
  List<Object> get props => [id, url, firstName, lastName];

  factory Teacher.fromJson(Map<String, dynamic> json) => _$TeacherFromJson(json);

  Map<String, dynamic> toJson() => _$TeacherToJson(this);
}
