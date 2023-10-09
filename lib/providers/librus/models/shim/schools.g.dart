// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schools.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Schools _$SchoolsFromJson(Map<String, dynamic> json) => Schools(
      school: json['School'] == null
          ? null
          : School.fromJson(json['School'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$SchoolsToJson(Schools instance) => <String, dynamic>{
      'School': instance.school,
    };

School _$SchoolFromJson(Map<String, dynamic> json) => School(
      id: json['Id'] as int,
      name: json['Name'] as String,
      town: json['Town'] as String,
      street: json['Street'] as String,
      state: json['State'] as String,
      buildingNumber: json['BuildingNumber'] as String,
      apartmentNumber: json['ApartmentNumber'] as String,
      lessonsRange: (json['LessonsRange'] as List<dynamic>?)
          ?.map((e) => LessonsRange.fromJson(e as Map<String, dynamic>))
          .toList(),
      schoolYear: json['SchoolYear'] as int,
      vocationalSchool: json['VocationalSchool'] as int,
      nameHeadTeacher: json['NameHeadTeacher'] as String,
      surnameHeadTeacher: json['SurnameHeadTeacher'] as String,
      project: json['Project'] as int,
      postCode: json['PostCode'] as String,
      email: json['Email'] as String,
      phoneNumber: json['PhoneNumber'] as String,
    );

Map<String, dynamic> _$SchoolToJson(School instance) => <String, dynamic>{
      'Id': instance.id,
      'Name': instance.name,
      'Town': instance.town,
      'Street': instance.street,
      'State': instance.state,
      'BuildingNumber': instance.buildingNumber,
      'ApartmentNumber': instance.apartmentNumber,
      'LessonsRange': instance.lessonsRange,
      'SchoolYear': instance.schoolYear,
      'VocationalSchool': instance.vocationalSchool,
      'NameHeadTeacher': instance.nameHeadTeacher,
      'SurnameHeadTeacher': instance.surnameHeadTeacher,
      'Project': instance.project,
      'PostCode': instance.postCode,
      'Email': instance.email,
      'PhoneNumber': instance.phoneNumber,
    };

LessonsRange _$LessonsRangeFromJson(Map<String, dynamic> json) => LessonsRange(
      from: json['From'] as String,
      to: json['To'] as String,
      rawFrom: json['RawFrom'] as int,
      rawTo: json['RawTo'] as int,
    );

Map<String, dynamic> _$LessonsRangeToJson(LessonsRange instance) =>
    <String, dynamic>{
      'From': instance.from,
      'To': instance.to,
      'RawFrom': instance.rawFrom,
      'RawTo': instance.rawTo,
    };
