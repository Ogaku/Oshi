// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'student_class.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StudentClass _$StudentClassFromJson(Map<String, dynamic> json) => StudentClass(
      studentClassClass: json['Class'] == null
          ? null
          : Class.fromJson(json['Class'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$StudentClassToJson(StudentClass instance) =>
    <String, dynamic>{
      'Class': instance.studentClassClass,
    };

Class _$ClassFromJson(Map<String, dynamic> json) => Class(
      id: json['Id'] as int,
      number: json['Number'] as int,
      symbol: json['Symbol'] as String,
      beginSchoolYear: json['BeginSchoolYear'] == null
          ? null
          : DateTime.parse(json['BeginSchoolYear'] as String),
      endFirstSemester: json['EndFirstSemester'] == null
          ? null
          : DateTime.parse(json['EndFirstSemester'] as String),
      endSchoolYear: json['EndSchoolYear'] == null
          ? null
          : DateTime.parse(json['EndSchoolYear'] as String),
      unit: json['Unit'] == null
          ? null
          : ClassTutor.fromJson(json['Unit'] as Map<String, dynamic>),
      classTutor: json['ClassTutor'] == null
          ? null
          : ClassTutor.fromJson(json['ClassTutor'] as Map<String, dynamic>),
      classTutors: (json['ClassTutors'] as List<dynamic>?)
          ?.map((e) => ClassTutor.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ClassToJson(Class instance) => <String, dynamic>{
      'Id': instance.id,
      'Number': instance.number,
      'Symbol': instance.symbol,
      'BeginSchoolYear': instance.beginSchoolYear?.toIso8601String(),
      'EndFirstSemester': instance.endFirstSemester?.toIso8601String(),
      'EndSchoolYear': instance.endSchoolYear?.toIso8601String(),
      'Unit': instance.unit,
      'ClassTutor': instance.classTutor,
      'ClassTutors': instance.classTutors,
    };

ClassTutor _$ClassTutorFromJson(Map<String, dynamic> json) => ClassTutor(
      id: json['Id'] as int,
      url: json['Url'] as String,
    );

Map<String, dynamic> _$ClassTutorToJson(ClassTutor instance) =>
    <String, dynamic>{
      'Id': instance.id,
      'Url': instance.url,
    };
