// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'classroom.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ClassroomAdapter extends TypeAdapter<Classroom> {
  @override
  final int typeId = 24;

  @override
  Classroom read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Classroom(
      id: fields[0] as int,
      url: fields[1] as String,
      name: fields[2] as String,
      symbol: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Classroom obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.url)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.symbol);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClassroomAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Classroom _$ClassroomFromJson(Map<String, dynamic> json) => Classroom(
      id: (json['id'] as num?)?.toInt() ?? -1,
      url: json['url'] as String? ?? 'https://g.co',
      name: json['name'] as String? ?? '',
      symbol: json['symbol'] as String? ?? '',
    );

Map<String, dynamic> _$ClassroomToJson(Classroom instance) => <String, dynamic>{
      'id': instance.id,
      'url': instance.url,
      'name': instance.name,
      'symbol': instance.symbol,
    };
