// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'class.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ClassAdapter extends TypeAdapter<Class> {
  @override
  final int typeId = 23;

  @override
  Class read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Class(
      id: fields[0] as int,
      number: fields[1] as int,
      symbol: fields[2] as String,
      name: fields[3] as String?,
      beginSchoolYear: fields[4] as DateTime?,
      endFirstSemester: fields[5] as DateTime?,
      endSchoolYear: fields[6] as DateTime?,
      unit: fields[7] as Unit?,
      classTutor: fields[8] as Teacher?,
      events: (fields[9] as List?)?.cast<Event>(),
      averages: (fields[10] as Map?)?.cast<DateTime, Averages>(),
    );
  }

  @override
  void write(BinaryWriter writer, Class obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.number)
      ..writeByte(2)
      ..write(obj.symbol)
      ..writeByte(3)
      ..write(obj.name)
      ..writeByte(4)
      ..write(obj.beginSchoolYear)
      ..writeByte(5)
      ..write(obj.endFirstSemester)
      ..writeByte(6)
      ..write(obj.endSchoolYear)
      ..writeByte(7)
      ..write(obj.unit)
      ..writeByte(8)
      ..write(obj.classTutor)
      ..writeByte(9)
      ..write(obj.events)
      ..writeByte(10)
      ..write(obj.averages);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClassAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Class _$ClassFromJson(Map<String, dynamic> json) => Class(
      id: json['id'] as int? ?? -1,
      number: json['number'] as int? ?? -1,
      symbol: json['symbol'] as String? ?? '',
      name: json['name'] as String? ?? '',
      beginSchoolYear: json['beginSchoolYear'] == null
          ? null
          : DateTime.parse(json['beginSchoolYear'] as String),
      endFirstSemester: json['endFirstSemester'] == null
          ? null
          : DateTime.parse(json['endFirstSemester'] as String),
      endSchoolYear: json['endSchoolYear'] == null
          ? null
          : DateTime.parse(json['endSchoolYear'] as String),
      unit: json['unit'] == null
          ? null
          : Unit.fromJson(json['unit'] as Map<String, dynamic>),
      classTutor: json['classTutor'] == null
          ? null
          : Teacher.fromJson(json['classTutor'] as Map<String, dynamic>),
      events: (json['events'] as List<dynamic>?)
          ?.map((e) => Event.fromJson(e as Map<String, dynamic>))
          .toList(),
      averages: (json['averages'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(
            DateTime.parse(k), Averages.fromJson(e as Map<String, dynamic>)),
      ),
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
  val['averages'] =
      instance.averages.map((k, e) => MapEntry(k.toIso8601String(), e));
  return val;
}
