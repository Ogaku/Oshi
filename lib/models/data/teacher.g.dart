// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'teacher.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TeacherAdapter extends TypeAdapter<Teacher> {
  @override
  final int typeId = 32;

  @override
  Teacher read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Teacher(
      id: fields[1] as int,
      userId: fields[2] as int?,
      url: fields[3] as String,
      firstName: fields[4] as String,
      lastName: fields[5] as String,
      isHomeTeacher: fields[6] as bool?,
      absent: fields[7] as ({DateTime from, DateTime to})?,
    );
  }

  @override
  void write(BinaryWriter writer, Teacher obj) {
    writer
      ..writeByte(7)
      ..writeByte(1)
      ..write(obj.id)
      ..writeByte(2)
      ..write(obj.userId)
      ..writeByte(3)
      ..write(obj.url)
      ..writeByte(4)
      ..write(obj.firstName)
      ..writeByte(5)
      ..write(obj.lastName)
      ..writeByte(6)
      ..write(obj.isHomeTeacher)
      ..writeByte(7)
      ..write(obj.absent);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TeacherAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Teacher _$TeacherFromJson(Map<String, dynamic> json) => Teacher(
      id: json['id'] as int? ?? -1,
      userId: json['userId'] as int?,
      url: json['url'] as String? ?? '',
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      isHomeTeacher: json['isHomeTeacher'] as bool?,
      absent: _$recordConvertNullable(
        json['absent'],
        ($jsonValue) => (
          from: DateTime.parse($jsonValue['from'] as String),
          to: DateTime.parse($jsonValue['to'] as String),
        ),
      ),
    );

Map<String, dynamic> _$TeacherToJson(Teacher instance) => <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'url': instance.url,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'isHomeTeacher': instance.isHomeTeacher,
      'absent': instance.absent == null
          ? null
          : {
              'from': instance.absent!.from.toIso8601String(),
              'to': instance.absent!.to.toIso8601String(),
            },
    };

$Rec? _$recordConvertNullable<$Rec>(
  Object? value,
  $Rec Function(Map) convert,
) =>
    value == null ? null : convert(value as Map<String, dynamic>);
