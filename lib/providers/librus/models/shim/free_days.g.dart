// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'free_days.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SchoolFreeDays _$SchoolFreeDaysFromJson(Map<String, dynamic> json) =>
    SchoolFreeDays(
      schoolFreeDays: (json['SchoolFreeDays'] as List<dynamic>?)
          ?.map((e) => SchoolFreeDay.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$SchoolFreeDaysToJson(SchoolFreeDays instance) =>
    <String, dynamic>{
      'SchoolFreeDays': instance.schoolFreeDays,
    };

SchoolFreeDay _$SchoolFreeDayFromJson(Map<String, dynamic> json) =>
    SchoolFreeDay(
      id: json['Id'] as int? ?? -1,
      name: json['Name'] as String? ?? '',
      dateFrom: json['DateFrom'] == null
          ? null
          : DateTime.parse(json['DateFrom'] as String),
      dateTo: json['DateTo'] == null
          ? null
          : DateTime.parse(json['DateTo'] as String),
      units: (json['Units'] as List<dynamic>?)
          ?.map((e) => Unit.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$SchoolFreeDayToJson(SchoolFreeDay instance) =>
    <String, dynamic>{
      'Id': instance.id,
      'Name': instance.name,
      'DateFrom': instance.dateFrom?.toIso8601String(),
      'DateTo': instance.dateTo?.toIso8601String(),
      'Units': instance.units,
    };

Unit _$UnitFromJson(Map<String, dynamic> json) => Unit(
      id: json['Id'] as int? ?? -1,
      url: json['Url'] as String? ?? '',
    );

Map<String, dynamic> _$UnitToJson(Unit instance) => <String, dynamic>{
      'Id': instance.id,
      'Url': instance.url,
    };
