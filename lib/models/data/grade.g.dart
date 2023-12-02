// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'grade.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GradeAdapter extends TypeAdapter<Grade> {
  @override
  final int typeId = 26;

  @override
  Grade read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Grade(
      id: fields[0] as int,
      url: fields[1] as String,
      name: fields[2] as String,
      value: fields[3] as String,
      weight: fields[4] as int,
      comments: (fields[5] as List?)?.cast<String>(),
      countsToAverage: fields[6] as bool,
      date: fields[7] as DateTime?,
      addDate: fields[8] as DateTime?,
      addedBy: fields[9] as Teacher?,
      semester: fields[10] as int,
      isConstituent: fields[11] as bool,
      isSemester: fields[12] as bool,
      isSemesterProposition: fields[13] as bool,
      isFinal: fields[14] as bool,
      isFinalProposition: fields[15] as bool,
      resitPart: fields[16] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Grade obj) {
    writer
      ..writeByte(17)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.url)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.value)
      ..writeByte(4)
      ..write(obj.weight)
      ..writeByte(5)
      ..write(obj.comments)
      ..writeByte(6)
      ..write(obj.countsToAverage)
      ..writeByte(7)
      ..write(obj.date)
      ..writeByte(8)
      ..write(obj.addDate)
      ..writeByte(9)
      ..write(obj.addedBy)
      ..writeByte(10)
      ..write(obj.semester)
      ..writeByte(11)
      ..write(obj.isConstituent)
      ..writeByte(12)
      ..write(obj.isSemester)
      ..writeByte(13)
      ..write(obj.isSemesterProposition)
      ..writeByte(14)
      ..write(obj.isFinal)
      ..writeByte(15)
      ..write(obj.isFinalProposition)
      ..writeByte(16)
      ..write(obj.resitPart);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GradeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Grade _$GradeFromJson(Map<String, dynamic> json) => Grade(
      id: json['id'] as int? ?? -1,
      url: json['url'] as String? ?? 'https://g.co',
      name: json['name'] as String? ?? '',
      value: json['value'] as String? ?? '',
      weight: json['weight'] as int? ?? 0,
      comments: (json['comments'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      countsToAverage: json['countsToAverage'] as bool? ?? false,
      date:
          json['date'] == null ? null : DateTime.parse(json['date'] as String),
      addDate: json['addDate'] == null
          ? null
          : DateTime.parse(json['addDate'] as String),
      addedBy: json['addedBy'] == null
          ? null
          : Teacher.fromJson(json['addedBy'] as Map<String, dynamic>),
      semester: json['semester'] as int? ?? 1,
      isConstituent: json['isConstituent'] as bool? ?? false,
      isSemester: json['isSemester'] as bool? ?? false,
      isSemesterProposition: json['isSemesterProposition'] as bool? ?? false,
      isFinal: json['isFinal'] as bool? ?? false,
      isFinalProposition: json['isFinalProposition'] as bool? ?? false,
      resitPart: json['resitPart'] as bool? ?? false,
    );

Map<String, dynamic> _$GradeToJson(Grade instance) => <String, dynamic>{
      'id': instance.id,
      'url': instance.url,
      'name': instance.name,
      'value': instance.value,
      'weight': instance.weight,
      'comments': instance.comments,
      'countsToAverage': instance.countsToAverage,
      'date': instance.date.toIso8601String(),
      'addDate': instance.addDate.toIso8601String(),
      'addedBy': instance.addedBy,
      'semester': instance.semester,
      'isConstituent': instance.isConstituent,
      'isSemester': instance.isSemester,
      'isSemesterProposition': instance.isSemesterProposition,
      'isFinal': instance.isFinal,
      'isFinalProposition': instance.isFinalProposition,
      'resitPart': instance.resitPart,
    };
