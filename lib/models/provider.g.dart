// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'provider.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProviderDataAdapter extends TypeAdapter<ProviderData> {
  @override
  final int typeId = 10;

  @override
  ProviderData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProviderData(
      student: fields[1] as Student?,
      timetables: fields[2] as Timetables?,
      messages: fields[3] as Messages?,
    );
  }

  @override
  void write(BinaryWriter writer, ProviderData obj) {
    writer
      ..writeByte(3)
      ..writeByte(1)
      ..write(obj.student)
      ..writeByte(2)
      ..write(obj.timetables)
      ..writeByte(3)
      ..write(obj.messages);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProviderDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProviderData _$ProviderDataFromJson(Map<String, dynamic> json) => ProviderData(
      student: json['student'] == null
          ? null
          : Student.fromJson(json['student'] as Map<String, dynamic>),
      timetables: json['timetables'] == null
          ? null
          : Timetables.fromJson(json['timetables'] as Map<String, dynamic>),
      messages: json['messages'] == null
          ? null
          : Messages.fromJson(json['messages'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ProviderDataToJson(ProviderData instance) =>
    <String, dynamic>{
      'student': instance.student,
      'timetables': instance.timetables,
      'messages': instance.messages,
    };
