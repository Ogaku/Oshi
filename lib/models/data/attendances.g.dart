// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attendances.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AttendanceAdapter extends TypeAdapter<Attendance> {
  @override
  final int typeId = 22;

  @override
  Attendance read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Attendance(
      id: fields[0] as int,
      lessonNo: fields[1] as int,
      lesson: fields[2] as TimetableLesson?,
      date: fields[3] as DateTime?,
      addDate: fields[4] as DateTime?,
      type: fields[5] as AttendanceType?,
      teacher: fields[6] as Teacher?,
    );
  }

  @override
  void write(BinaryWriter writer, Attendance obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.lessonNo)
      ..writeByte(2)
      ..write(obj.lesson)
      ..writeByte(3)
      ..write(obj.date)
      ..writeByte(4)
      ..write(obj.addDate)
      ..writeByte(5)
      ..write(obj.type)
      ..writeByte(6)
      ..write(obj.teacher);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AttendanceAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AttendanceTypeAdapter extends TypeAdapter<AttendanceType> {
  @override
  final int typeId = 102;

  @override
  AttendanceType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return AttendanceType.absent;
      case 1:
        return AttendanceType.late;
      case 2:
        return AttendanceType.excused;
      case 3:
        return AttendanceType.duty;
      case 4:
        return AttendanceType.present;
      case 5:
        return AttendanceType.other;
      default:
        return AttendanceType.absent;
    }
  }

  @override
  void write(BinaryWriter writer, AttendanceType obj) {
    switch (obj) {
      case AttendanceType.absent:
        writer.writeByte(0);
        break;
      case AttendanceType.late:
        writer.writeByte(1);
        break;
      case AttendanceType.excused:
        writer.writeByte(2);
        break;
      case AttendanceType.duty:
        writer.writeByte(3);
        break;
      case AttendanceType.present:
        writer.writeByte(4);
        break;
      case AttendanceType.other:
        writer.writeByte(5);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AttendanceTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Attendance _$AttendanceFromJson(Map<String, dynamic> json) => Attendance(
      id: (json['id'] as num?)?.toInt() ?? -1,
      lessonNo: (json['lessonNo'] as num?)?.toInt() ?? -1,
      lesson: json['lesson'] == null
          ? null
          : TimetableLesson.fromJson(json['lesson'] as Map<String, dynamic>),
      date:
          json['date'] == null ? null : DateTime.parse(json['date'] as String),
      addDate: json['addDate'] == null
          ? null
          : DateTime.parse(json['addDate'] as String),
      type: $enumDecodeNullable(_$AttendanceTypeEnumMap, json['type']),
      teacher: json['teacher'] == null
          ? null
          : Teacher.fromJson(json['teacher'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AttendanceToJson(Attendance instance) =>
    <String, dynamic>{
      'id': instance.id,
      'lessonNo': instance.lessonNo,
      'lesson': instance.lesson,
      'date': instance.date.toIso8601String(),
      'addDate': instance.addDate.toIso8601String(),
      'type': _$AttendanceTypeEnumMap[instance.type]!,
      'teacher': instance.teacher,
    };

const _$AttendanceTypeEnumMap = {
  AttendanceType.absent: 'absent',
  AttendanceType.late: 'late',
  AttendanceType.excused: 'excused',
  AttendanceType.duty: 'duty',
  AttendanceType.present: 'present',
  AttendanceType.other: 'other',
};
