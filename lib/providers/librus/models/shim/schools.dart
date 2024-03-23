import 'package:json_annotation/json_annotation.dart';

part 'schools.g.dart';

@JsonSerializable()
class Schools {
  Schools({
    required this.school,
  });

  @JsonKey(name: 'School', defaultValue: null)
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

  @JsonKey(name: 'Id', defaultValue: -1)
  final int id;

  @JsonKey(name: 'Name', defaultValue: '')
  final String name;

  @JsonKey(name: 'Town', defaultValue: '')
  final String town;

  @JsonKey(name: 'Street', defaultValue: '')
  final String street;

  @JsonKey(name: 'State', defaultValue: '')
  final String state;

  @JsonKey(name: 'BuildingNumber', defaultValue: '')
  final String buildingNumber;

  @JsonKey(name: 'ApartmentNumber', defaultValue: '')
  final String apartmentNumber;

  @JsonKey(name: 'LessonsRange', defaultValue: null)
  final List<LessonsRange>? lessonsRange;

  @JsonKey(name: 'SchoolYear', defaultValue: -1)
  final int schoolYear;

  @JsonKey(name: 'VocationalSchool', defaultValue: -1)
  final int vocationalSchool;

  @JsonKey(name: 'NameHeadTeacher', defaultValue: '')
  final String nameHeadTeacher;

  @JsonKey(name: 'SurnameHeadTeacher', defaultValue: '')
  final String surnameHeadTeacher;

  @JsonKey(name: 'Project', defaultValue: -1)
  final int project;

  @JsonKey(name: 'PostCode', defaultValue: '')
  final String postCode;

  @JsonKey(name: 'Email', defaultValue: '')
  final String email;

  @JsonKey(name: 'PhoneNumber', defaultValue: '')
  final String phoneNumber;

  factory School.fromJson(Map<String, dynamic> json) => _$SchoolFromJson(json);

  Map<String, dynamic> toJson() => _$SchoolToJson(this);
}

@JsonSerializable()
class LessonsRange {
  LessonsRange({
    this.from = '08:00',
    this.to = '08:45',
    this.rawFrom = 946713600,
    this.rawTo = 946716300,
  });

  @JsonKey(name: 'From', defaultValue: '08:00')
  final String from;

  @JsonKey(name: 'To', defaultValue: '08:45')
  final String to;

  @JsonKey(name: 'RawFrom', defaultValue: 946713600)
  final int rawFrom;

  @JsonKey(name: 'RawTo', defaultValue: 946716300)
  final int rawTo;

  factory LessonsRange.fromJson(Map<String, dynamic> json) => _$LessonsRangeFromJson(json);

  Map<String, dynamic> toJson() => _$LessonsRangeToJson(this);
}
