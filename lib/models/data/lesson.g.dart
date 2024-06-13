// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lesson.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LessonAdapter extends TypeAdapter<Lesson> {
  @override
  final int typeId = 27;

  @override
  Lesson read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Lesson(
      id: fields[1] as int,
      url: fields[2] as String,
      name: fields[3] as String,
      no: fields[4] as int,
      short: fields[5] as String,
      isExtracurricular: fields[6] as bool,
      isBlockLesson: fields[7] as bool,
      hostClass: fields[8] as Class?,
      teacher: fields[9] as Teacher?,
    );
  }

  @override
  void write(BinaryWriter writer, Lesson obj) {
    writer
      ..writeByte(10)
      ..writeByte(1)
      ..write(obj.id)
      ..writeByte(2)
      ..write(obj.url)
      ..writeByte(3)
      ..write(obj.name)
      ..writeByte(4)
      ..write(obj.no)
      ..writeByte(5)
      ..write(obj.short)
      ..writeByte(6)
      ..write(obj.isExtracurricular)
      ..writeByte(7)
      ..write(obj.isBlockLesson)
      ..writeByte(8)
      ..write(obj.hostClass)
      ..writeByte(9)
      ..write(obj.teacher)
      ..writeByte(10)
      ..write(obj._grades);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LessonAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Lesson _$LessonFromJson(Map<String, dynamic> json) => Lesson(
      id: json['id'] as int? ?? -1,
      url: json['url'] as String? ?? 'https://g.co',
      name: json['name'] as String? ?? '',
      no: json['no'] as int? ?? -1,
      short: json['short'] as String? ?? '',
      isExtracurricular: json['isExtracurricular'] as bool? ?? false,
      isBlockLesson: json['isBlockLesson'] as bool? ?? false,
      hostClass: json['hostClass'] == null
          ? null
          : Class.fromJson(json['hostClass'] as Map<String, dynamic>),
      teacher: json['teacher'] == null
          ? null
          : Teacher.fromJson(json['teacher'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$LessonToJson(Lesson instance) => <String, dynamic>{
      'id': instance.id,
      'url': instance.url,
      'name': instance.name,
      'no': instance.no,
      'short': instance.short,
      'isExtracurricular': instance.isExtracurricular,
      'isBlockLesson': instance.isBlockLesson,
      'hostClass': instance.hostClass,
      'teacher': instance.teacher,
    };
