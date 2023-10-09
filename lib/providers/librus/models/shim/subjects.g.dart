// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subjects.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Subjects _$SubjectsFromJson(Map<String, dynamic> json) => Subjects(
      subjects: (json['Subjects'] as List<dynamic>?)
          ?.map((e) => Subject.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$SubjectsToJson(Subjects instance) => <String, dynamic>{
      'Subjects': instance.subjects,
    };

Subject _$SubjectFromJson(Map<String, dynamic> json) => Subject(
      id: json['Id'] as int,
      name: json['Name'] as String,
      no: json['No'] as int,
      short: json['Short'] as String,
      isExtracurricular: json['IsExtracurricular'] as bool,
      isBlockLesson: json['IsBlockLesson'] as bool,
    );

Map<String, dynamic> _$SubjectToJson(Subject instance) => <String, dynamic>{
      'Id': instance.id,
      'Name': instance.name,
      'No': instance.no,
      'Short': instance.short,
      'IsExtracurricular': instance.isExtracurricular,
      'IsBlockLesson': instance.isBlockLesson,
    };
