// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'parent_teacher_conferences.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ParentTeacherConferences _$ParentTeacherConferencesFromJson(
        Map<String, dynamic> json) =>
    ParentTeacherConferences(
      parentTeacherConferences:
          (json['ParentTeacherConferences'] as List<dynamic>?)
              ?.map((e) =>
                  ParentTeacherConference.fromJson(e as Map<String, dynamic>))
              .toList(),
    );

Map<String, dynamic> _$ParentTeacherConferencesToJson(
        ParentTeacherConferences instance) =>
    <String, dynamic>{
      'ParentTeacherConferences': instance.parentTeacherConferences,
    };

ParentTeacherConference _$ParentTeacherConferenceFromJson(
        Map<String, dynamic> json) =>
    ParentTeacherConference(
      id: json['Id'] as int,
      date:
          json['Date'] == null ? null : DateTime.parse(json['Date'] as String),
      name: json['Name'] as String,
      parentTeacherConferenceClass: json['Class'] == null
          ? null
          : Class.fromJson(json['Class'] as Map<String, dynamic>),
      teacher: json['Teacher'] == null
          ? null
          : Class.fromJson(json['Teacher'] as Map<String, dynamic>),
      topic: json['Topic'] as String,
      room: json['Room'],
      time: json['Time'] as String,
    );

Map<String, dynamic> _$ParentTeacherConferenceToJson(
        ParentTeacherConference instance) =>
    <String, dynamic>{
      'Id': instance.id,
      'Date': instance.date?.toIso8601String(),
      'Name': instance.name,
      'Class': instance.parentTeacherConferenceClass,
      'Teacher': instance.teacher,
      'Topic': instance.topic,
      'Room': instance.room,
      'Time': instance.time,
    };

Class _$ClassFromJson(Map<String, dynamic> json) => Class(
      id: json['Id'] as int,
      url: json['Url'] as String,
    );

Map<String, dynamic> _$ClassToJson(Class instance) => <String, dynamic>{
      'Id': instance.id,
      'Url': instance.url,
    };
