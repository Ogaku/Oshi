// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'unit.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UnitAdapter extends TypeAdapter<Unit> {
  @override
  final int typeId = 37;

  @override
  Unit read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Unit(
      id: fields[1] as int,
      url: fields[2] as String,
      luckyNumber: fields[3] as int?,
      name: fields[5] as String,
      fullName: fields[15] as String,
      principalName: fields[6] as String,
      address: fields[7] as String,
      town: fields[16] as String,
      email: fields[8] as String,
      phone: fields[9] as String,
      type: fields[10] as String,
      behaviourType: fields[11] as String,
      lessonsRange: (fields[12] as List?)?.cast<LessonRanges>(),
      announcements: (fields[13] as List?)?.cast<Announcement>(),
      teacherAbsences: (fields[14] as List?)?.cast<Event>(),
      luckyNumberTomorrow: fields[4] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Unit obj) {
    writer
      ..writeByte(16)
      ..writeByte(1)
      ..write(obj.id)
      ..writeByte(2)
      ..write(obj.url)
      ..writeByte(3)
      ..write(obj.luckyNumber)
      ..writeByte(4)
      ..write(obj.luckyNumberTomorrow)
      ..writeByte(5)
      ..write(obj.name)
      ..writeByte(15)
      ..write(obj.fullName)
      ..writeByte(6)
      ..write(obj.principalName)
      ..writeByte(7)
      ..write(obj.address)
      ..writeByte(16)
      ..write(obj.town)
      ..writeByte(8)
      ..write(obj.email)
      ..writeByte(9)
      ..write(obj.phone)
      ..writeByte(10)
      ..write(obj.type)
      ..writeByte(11)
      ..write(obj.behaviourType)
      ..writeByte(12)
      ..write(obj.lessonsRange)
      ..writeByte(13)
      ..write(obj.announcements)
      ..writeByte(14)
      ..write(obj.teacherAbsences);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UnitAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class LessonRangesAdapter extends TypeAdapter<LessonRanges> {
  @override
  final int typeId = 38;

  @override
  LessonRanges read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LessonRanges(
      from: fields[1] as DateTime?,
      to: fields[2] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, LessonRanges obj) {
    writer
      ..writeByte(2)
      ..writeByte(1)
      ..write(obj.from)
      ..writeByte(2)
      ..write(obj.to);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LessonRangesAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Unit _$UnitFromJson(Map<String, dynamic> json) => Unit(
      id: json['id'] as int? ?? -1,
      url: json['url'] as String? ?? 'https://g.co',
      luckyNumber: json['luckyNumber'] as int?,
      name: json['name'] as String? ?? '',
      fullName: json['fullName'] as String? ?? '',
      principalName: json['principalName'] as String? ?? '',
      address: json['address'] as String? ?? '',
      town: json['town'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      type: json['type'] as String? ?? '',
      behaviourType: json['behaviourType'] as String? ?? '',
      lessonsRange: (json['lessonsRange'] as List<dynamic>?)
          ?.map((e) => LessonRanges.fromJson(e as Map<String, dynamic>))
          .toList(),
      announcements: (json['announcements'] as List<dynamic>?)
          ?.map((e) => Announcement.fromJson(e as Map<String, dynamic>))
          .toList(),
      teacherAbsences: (json['teacherAbsences'] as List<dynamic>?)
          ?.map((e) => Event.fromJson(e as Map<String, dynamic>))
          .toList(),
      luckyNumberTomorrow: json['luckyNumberTomorrow'] as bool? ?? false,
    );

Map<String, dynamic> _$UnitToJson(Unit instance) {
  final val = <String, dynamic>{
    'id': instance.id,
    'url': instance.url,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('luckyNumber', instance.luckyNumber);
  val['luckyNumberTomorrow'] = instance.luckyNumberTomorrow;
  val['name'] = instance.name;
  val['fullName'] = instance.fullName;
  val['principalName'] = instance.principalName;
  val['address'] = instance.address;
  val['town'] = instance.town;
  val['email'] = instance.email;
  val['phone'] = instance.phone;
  val['type'] = instance.type;
  val['behaviourType'] = instance.behaviourType;
  val['lessonsRange'] = instance.lessonsRange;
  writeNotNull('announcements', instance.announcements);
  writeNotNull('teacherAbsences', instance.teacherAbsences);
  return val;
}

LessonRanges _$LessonRangesFromJson(Map<String, dynamic> json) => LessonRanges(
      from:
          json['from'] == null ? null : DateTime.parse(json['from'] as String),
      to: json['to'] == null ? null : DateTime.parse(json['to'] as String),
    );

Map<String, dynamic> _$LessonRangesToJson(LessonRanges instance) =>
    <String, dynamic>{
      'from': instance.from.toIso8601String(),
      'to': instance.to.toIso8601String(),
    };
