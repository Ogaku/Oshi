// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'class.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Class _$ClassFromJson(Map<String, dynamic> json) => Class(
      id: json['id'] as int,
      number: json['number'] as int,
      symbol: json['symbol'] as String,
      name: json['name'] as String?,
      beginSchoolYear: DateTime.parse(json['beginSchoolYear'] as String),
      endFirstSemester: DateTime.parse(json['endFirstSemester'] as String),
      endSchoolYear: DateTime.parse(json['endSchoolYear'] as String),
      unit: Unit.fromJson(json['unit'] as Map<String, dynamic>),
      classTutor: Teacher.fromJson(json['classTutor'] as Map<String, dynamic>),
      events: (json['events'] as List<dynamic>)
          .map((e) => Event.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ClassToJson(Class instance) {
  final val = <String, dynamic>{
    'id': instance.id,
    'number': instance.number,
    'symbol': instance.symbol,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('name', instance.name);
  val['beginSchoolYear'] = instance.beginSchoolYear.toIso8601String();
  val['endFirstSemester'] = instance.endFirstSemester.toIso8601String();
  val['endSchoolYear'] = instance.endSchoolYear.toIso8601String();
  val['unit'] = instance.unit;
  val['classTutor'] = instance.classTutor;
  val['events'] = instance.events;
  return val;
}
