// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'averages.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AveragesAdapter extends TypeAdapter<Averages> {
  @override
  final int typeId = 39;

  @override
  Averages read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Averages(
      student: fields[1] as double,
      level: fields[2] as double,
    );
  }

  @override
  void write(BinaryWriter writer, Averages obj) {
    writer
      ..writeByte(2)
      ..writeByte(1)
      ..write(obj.student)
      ..writeByte(2)
      ..write(obj.level);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AveragesAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Averages _$AveragesFromJson(Map<String, dynamic> json) => Averages(
      student: (json['student'] as num?)?.toDouble() ?? 0.0,
      level: (json['level'] as num?)?.toDouble() ?? 0.0,
    );

Map<String, dynamic> _$AveragesToJson(Averages instance) => <String, dynamic>{
      'student': instance.student,
      'level': instance.level,
    };
