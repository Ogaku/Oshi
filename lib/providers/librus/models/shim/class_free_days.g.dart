// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'class_free_days.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ClassFreeDays _$ClassFreeDaysFromJson(Map<String, dynamic> json) =>
    ClassFreeDays(
      classFreeDays: (json['ClassFreeDays'] as List<dynamic>?)
          ?.map((e) => ClassFreeDay.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ClassFreeDaysToJson(ClassFreeDays instance) =>
    <String, dynamic>{
      'ClassFreeDays': instance.classFreeDays,
    };

ClassFreeDay _$ClassFreeDayFromJson(Map<String, dynamic> json) => ClassFreeDay(
      id: json['Id'] as int? ?? -1,
      classFreeDayClass: json['Class'] == null
          ? null
          : Class.fromJson(json['Class'] as Map<String, dynamic>),
      type: json['Type'] == null
          ? null
          : Class.fromJson(json['Type'] as Map<String, dynamic>),
      dateFrom: json['DateFrom'] == null
          ? null
          : DateTime.parse(json['DateFrom'] as String),
      dateTo: json['DateTo'] == null
          ? null
          : DateTime.parse(json['DateTo'] as String),
      lessonNoFrom: json['LessonNoFrom'] as int?,
      lessonNoTo: json['LessonNoTo'] as int?,
      virtualClass: json['VirtualClass'] == null
          ? null
          : Class.fromJson(json['VirtualClass'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ClassFreeDayToJson(ClassFreeDay instance) =>
    <String, dynamic>{
      'Id': instance.id,
      'Class': instance.classFreeDayClass,
      'Type': instance.type,
      'DateFrom': instance.dateFrom?.toIso8601String(),
      'DateTo': instance.dateTo?.toIso8601String(),
      'LessonNoFrom': instance.lessonNoFrom,
      'LessonNoTo': instance.lessonNoTo,
      'VirtualClass': instance.virtualClass,
    };

Class _$ClassFromJson(Map<String, dynamic> json) => Class(
      id: json['Id'] as int? ?? -1,
      url: json['Url'] as String? ?? '',
    );

Map<String, dynamic> _$ClassToJson(Class instance) => <String, dynamic>{
      'Id': instance.id,
      'Url': instance.url,
    };
