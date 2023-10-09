import 'package:json_annotation/json_annotation.dart';

part 'student_class.g.dart';

@JsonSerializable()
class StudentClass {
  StudentClass({required this.studentClassClass});

  @JsonKey(name: 'Class')
  final Class? studentClassClass;

  factory StudentClass.fromJson(Map<String, dynamic> json) => _$StudentClassFromJson(json);

  Map<String, dynamic> toJson() => _$StudentClassToJson(this);
}

@JsonSerializable()
class Class {
  Class({
    required this.id,
    required this.number,
    required this.symbol,
    required this.beginSchoolYear,
    required this.endFirstSemester,
    required this.endSchoolYear,
    required this.unit,
    required this.classTutor,
    required this.classTutors,
  });

  @JsonKey(name: 'Id')
  final int id;

  @JsonKey(name: 'Number')
  final int number;

  @JsonKey(name: 'Symbol')
  final String symbol;

  @JsonKey(name: 'BeginSchoolYear')
  final DateTime? beginSchoolYear;

  @JsonKey(name: 'EndFirstSemester')
  final DateTime? endFirstSemester;

  @JsonKey(name: 'EndSchoolYear')
  final DateTime? endSchoolYear;

  @JsonKey(name: 'Unit')
  final ClassTutor? unit;

  @JsonKey(name: 'ClassTutor')
  final ClassTutor? classTutor;

  @JsonKey(name: 'ClassTutors')
  final List<ClassTutor>? classTutors;

  factory Class.fromJson(Map<String, dynamic> json) => _$ClassFromJson(json);

  Map<String, dynamic> toJson() => _$ClassToJson(this);
}

@JsonSerializable()
class ClassTutor {
  ClassTutor({
    required this.id,
    required this.url,
  });

  @JsonKey(name: 'Id')
  final int id;

  @JsonKey(name: 'Url')
  final String url;

  factory ClassTutor.fromJson(Map<String, dynamic> json) => _$ClassTutorFromJson(json);

  Map<String, dynamic> toJson() => _$ClassTutorToJson(this);
}
