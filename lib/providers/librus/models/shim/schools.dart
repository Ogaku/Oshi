import 'package:json_annotation/json_annotation.dart';

part 'schools.g.dart';

@JsonSerializable()
class Schools {
  Schools({
    required this.school,
  });

  @JsonKey(name: 'School')
  final School? school;

  factory Schools.fromJson(Map<String, dynamic> json) => _$SchoolsFromJson(json);

  Map<String, dynamic> toJson() => _$SchoolsToJson(this);
}

@JsonSerializable()
class School {
  School({
    required this.id,
    required this.name,
    required this.town,
    required this.street,
    required this.state,
    required this.buildingNumber,
    required this.apartmentNumber,
    required this.lessonsRange,
    required this.schoolYear,
    required this.vocationalSchool,
    required this.nameHeadTeacher,
    required this.surnameHeadTeacher,
    required this.project,
    required this.postCode,
    required this.email,
    required this.phoneNumber,
  });

  @JsonKey(name: 'Id')
  final int id;

  @JsonKey(name: 'Name')
  final String name;

  @JsonKey(name: 'Town')
  final String town;

  @JsonKey(name: 'Street')
  final String street;

  @JsonKey(name: 'State')
  final String state;

  @JsonKey(name: 'BuildingNumber')
  final String buildingNumber;

  @JsonKey(name: 'ApartmentNumber')
  final String apartmentNumber;

  @JsonKey(name: 'LessonsRange')
  final List<LessonsRange>? lessonsRange;

  @JsonKey(name: 'SchoolYear')
  final int schoolYear;

  @JsonKey(name: 'VocationalSchool')
  final int vocationalSchool;

  @JsonKey(name: 'NameHeadTeacher')
  final String nameHeadTeacher;

  @JsonKey(name: 'SurnameHeadTeacher')
  final String surnameHeadTeacher;

  @JsonKey(name: 'Project')
  final int project;

  @JsonKey(name: 'PostCode')
  final String postCode;

  @JsonKey(name: 'Email')
  final String email;

  @JsonKey(name: 'PhoneNumber')
  final String phoneNumber;

  factory School.fromJson(Map<String, dynamic> json) => _$SchoolFromJson(json);

  Map<String, dynamic> toJson() => _$SchoolToJson(this);
}

@JsonSerializable()
class LessonsRange {
  LessonsRange({
    this.from = '08:45',
    this.to = '08:00',
    this.rawFrom = 946713600,
    this.rawTo = 946716300,
  });

  @JsonKey(name: 'From')
  final String from;

  @JsonKey(name: 'To')
  final String to;

  @JsonKey(name: 'RawFrom')
  final int rawFrom;

  @JsonKey(name: 'RawTo')
  final int rawTo;

  factory LessonsRange.fromJson(Map<String, dynamic> json) => _$LessonsRangeFromJson(json);

  Map<String, dynamic> toJson() => _$LessonsRangeToJson(this);
}
