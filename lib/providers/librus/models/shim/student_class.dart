import 'package:json_annotation/json_annotation.dart';

part 'student_class.g.dart';

@JsonSerializable()
class StudentClass {
  StudentClass({required this.studentClassClass});

  @JsonKey(name: 'Class', defaultValue: null)
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

  @JsonKey(name: 'Id', defaultValue: -1)
  final int id;

  @JsonKey(name: 'Number', defaultValue: -1)
  final int number;

  @JsonKey(name: 'Symbol', defaultValue: '')
  final String symbol;

  @JsonKey(name: 'BeginSchoolYear', defaultValue: null)
  final DateTime? beginSchoolYear;

  @JsonKey(name: 'EndFirstSemester', defaultValue: null)
  final DateTime? endFirstSemester;

  @JsonKey(name: 'EndSchoolYear', defaultValue: null)
  final DateTime? endSchoolYear;

  @JsonKey(name: 'Unit', defaultValue: null)
  final ClassTutor? unit;

  @JsonKey(name: 'ClassTutor', defaultValue: null)
  final ClassTutor? classTutor;

  @JsonKey(name: 'ClassTutors', defaultValue: null)
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

  @JsonKey(name: 'Id', defaultValue: -1)
  final int id;

  @JsonKey(name: 'Url', defaultValue: '')
  final String url;

  factory ClassTutor.fromJson(Map<String, dynamic> json) => _$ClassTutorFromJson(json);

  Map<String, dynamic> toJson() => _$ClassTutorToJson(this);
}
