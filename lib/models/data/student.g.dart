// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'student.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AccountAdapter extends TypeAdapter<Account> {
  @override
  final int typeId = 30;

  @override
  Account read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Account(
      id: fields[1] as int,
      userId: fields[2] as int,
      number: fields[3] as int,
      firstName: fields[4] as String,
      lastName: fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Account obj) {
    writer
      ..writeByte(5)
      ..writeByte(1)
      ..write(obj.id)
      ..writeByte(2)
      ..write(obj.userId)
      ..writeByte(3)
      ..write(obj.number)
      ..writeByte(4)
      ..write(obj.firstName)
      ..writeByte(5)
      ..write(obj.lastName);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AccountAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class StudentAdapter extends TypeAdapter<Student> {
  @override
  final int typeId = 31;

  @override
  Student read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Student(
      account: fields[1] as Account?,
      mainClass: fields[2] as Class?,
      virtualClasses: (fields[3] as List?)?.cast<Class>(),
      attendances: (fields[4] as List?)?.cast<Attendance>(),
      subjects: (fields[5] as List?)?.cast<Lesson>(),
    );
  }

  @override
  void write(BinaryWriter writer, Student obj) {
    writer
      ..writeByte(5)
      ..writeByte(1)
      ..write(obj.account)
      ..writeByte(2)
      ..write(obj.mainClass)
      ..writeByte(3)
      ..write(obj.virtualClasses)
      ..writeByte(4)
      ..write(obj.attendances)
      ..writeByte(5)
      ..write(obj.subjects);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StudentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Account _$AccountFromJson(Map<String, dynamic> json) => Account(
      id: json['id'] as int? ?? -1,
      userId: json['userId'] as int? ?? -1,
      number: json['number'] as int? ?? -1,
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
    );

Map<String, dynamic> _$AccountToJson(Account instance) => <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'number': instance.number,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
    };

Student _$StudentFromJson(Map<String, dynamic> json) => Student(
      account: json['account'] == null
          ? null
          : Account.fromJson(json['account'] as Map<String, dynamic>),
      mainClass: json['mainClass'] == null
          ? null
          : Class.fromJson(json['mainClass'] as Map<String, dynamic>),
      virtualClasses: (json['virtualClasses'] as List<dynamic>?)
          ?.map((e) => Class.fromJson(e as Map<String, dynamic>))
          .toList(),
      attendances: (json['attendances'] as List<dynamic>?)
          ?.map((e) => Attendance.fromJson(e as Map<String, dynamic>))
          .toList(),
      subjects: (json['subjects'] as List<dynamic>?)
          ?.map((e) => Lesson.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$StudentToJson(Student instance) {
  final val = <String, dynamic>{
    'account': instance.account,
    'mainClass': instance.mainClass,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('virtualClasses', instance.virtualClasses);
  writeNotNull('attendances', instance.attendances);
  val['subjects'] = instance.subjects;
  return val;
}
