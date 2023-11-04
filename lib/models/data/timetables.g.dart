// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timetables.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TimetablesAdapter extends TypeAdapter<Timetables> {
  @override
  final int typeId = 33;

  @override
  Timetables read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Timetables(
      timetable: (fields[1] as Map?)?.cast<DateTime, TimetableDay>(),
    );
  }

  @override
  void write(BinaryWriter writer, Timetables obj) {
    writer
      ..writeByte(1)
      ..writeByte(1)
      ..write(obj.timetable);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TimetablesAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TimetableDayAdapter extends TypeAdapter<TimetableDay> {
  @override
  final int typeId = 34;

  @override
  TimetableDay read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TimetableDay(
      lessons: (fields[1] as List?)
          ?.map((dynamic e) => (e as List?)?.cast<TimetableLesson>())
          ?.toList(),
    );
  }

  @override
  void write(BinaryWriter writer, TimetableDay obj) {
    writer
      ..writeByte(1)
      ..writeByte(1)
      ..write(obj.lessons);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TimetableDayAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TimetableLessonAdapter extends TypeAdapter<TimetableLesson> {
  @override
  final int typeId = 35;

  @override
  TimetableLesson read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TimetableLesson(
      url: fields[1] as String,
      lessonNo: fields[2] as int,
      isCanceled: fields[3] as bool,
      lessonClass: fields[4] as Class?,
      subject: fields[5] as Lesson?,
      teacher: fields[6] as Teacher?,
      classroom: fields[7] as Classroom?,
      modifiedSchedule: fields[8] as bool,
      substitutionNote: fields[9] as String?,
      substitutionDetails: fields[10] as SubstitutionDetails?,
      date: fields[11] as DateTime?,
      hourFrom: fields[12] as DateTime?,
      hourTo: fields[13] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, TimetableLesson obj) {
    writer
      ..writeByte(13)
      ..writeByte(1)
      ..write(obj.url)
      ..writeByte(2)
      ..write(obj.lessonNo)
      ..writeByte(3)
      ..write(obj.isCanceled)
      ..writeByte(4)
      ..write(obj.lessonClass)
      ..writeByte(5)
      ..write(obj.subject)
      ..writeByte(6)
      ..write(obj.teacher)
      ..writeByte(7)
      ..write(obj.classroom)
      ..writeByte(8)
      ..write(obj.modifiedSchedule)
      ..writeByte(9)
      ..write(obj.substitutionNote)
      ..writeByte(10)
      ..write(obj.substitutionDetails)
      ..writeByte(11)
      ..write(obj.date)
      ..writeByte(12)
      ..write(obj.hourFrom)
      ..writeByte(13)
      ..write(obj.hourTo);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TimetableLessonAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SubstitutionDetailsAdapter extends TypeAdapter<SubstitutionDetails> {
  @override
  final int typeId = 36;

  @override
  SubstitutionDetails read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SubstitutionDetails(
      originalUrl: fields[1] as String,
      originalLessonNo: fields[2] as int,
      originalSubject: fields[3] as Lesson?,
      originalTeacher: fields[4] as Teacher?,
      originalClassroom: fields[5] as Classroom?,
      originalDate: fields[6] as DateTime?,
      originalHourFrom: fields[7] as DateTime?,
      originalHourTo: fields[8] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, SubstitutionDetails obj) {
    writer
      ..writeByte(8)
      ..writeByte(1)
      ..write(obj.originalUrl)
      ..writeByte(2)
      ..write(obj.originalLessonNo)
      ..writeByte(3)
      ..write(obj.originalSubject)
      ..writeByte(4)
      ..write(obj.originalTeacher)
      ..writeByte(5)
      ..write(obj.originalClassroom)
      ..writeByte(6)
      ..write(obj.originalDate)
      ..writeByte(7)
      ..write(obj.originalHourFrom)
      ..writeByte(8)
      ..write(obj.originalHourTo);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SubstitutionDetailsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Timetables _$TimetablesFromJson(Map<String, dynamic> json) => Timetables(
      timetable: (json['timetable'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(DateTime.parse(k),
            TimetableDay.fromJson(e as Map<String, dynamic>)),
      ),
    );

Map<String, dynamic> _$TimetablesToJson(Timetables instance) =>
    <String, dynamic>{
      'timetable':
          instance.timetable.map((k, e) => MapEntry(k.toIso8601String(), e)),
    };

TimetableDay _$TimetableDayFromJson(Map<String, dynamic> json) => TimetableDay(
      lessons: (json['lessons'] as List<dynamic>?)
          ?.map((e) => (e as List<dynamic>?)
              ?.map((e) => TimetableLesson.fromJson(e as Map<String, dynamic>))
              .toList())
          .toList(),
    );

Map<String, dynamic> _$TimetableDayToJson(TimetableDay instance) =>
    <String, dynamic>{
      'lessons': instance.lessons,
    };

TimetableLesson _$TimetableLessonFromJson(Map<String, dynamic> json) =>
    TimetableLesson(
      url: json['url'] as String? ?? '',
      lessonNo: json['lessonNo'] as int? ?? -1,
      isCanceled: json['isCanceled'] as bool? ?? false,
      lessonClass: json['lessonClass'] == null
          ? null
          : Class.fromJson(json['lessonClass'] as Map<String, dynamic>),
      subject: json['subject'] == null
          ? null
          : Lesson.fromJson(json['subject'] as Map<String, dynamic>),
      teacher: json['teacher'] == null
          ? null
          : Teacher.fromJson(json['teacher'] as Map<String, dynamic>),
      classroom: json['classroom'] == null
          ? null
          : Classroom.fromJson(json['classroom'] as Map<String, dynamic>),
      modifiedSchedule: json['modifiedSchedule'] as bool? ?? false,
      substitutionNote: json['substitutionNote'] as String?,
      substitutionDetails: json['substitutionDetails'] == null
          ? null
          : SubstitutionDetails.fromJson(
              json['substitutionDetails'] as Map<String, dynamic>),
      date:
          json['date'] == null ? null : DateTime.parse(json['date'] as String),
      hourFrom: json['hourFrom'] == null
          ? null
          : DateTime.parse(json['hourFrom'] as String),
      hourTo: json['hourTo'] == null
          ? null
          : DateTime.parse(json['hourTo'] as String),
    );

Map<String, dynamic> _$TimetableLessonToJson(TimetableLesson instance) =>
    <String, dynamic>{
      'url': instance.url,
      'lessonNo': instance.lessonNo,
      'isCanceled': instance.isCanceled,
      'lessonClass': instance.lessonClass,
      'subject': instance.subject,
      'teacher': instance.teacher,
      'classroom': instance.classroom,
      'modifiedSchedule': instance.modifiedSchedule,
      'substitutionNote': instance.substitutionNote,
      'substitutionDetails': instance.substitutionDetails,
      'date': instance.date.toIso8601String(),
      'hourFrom': instance.hourFrom?.toIso8601String(),
      'hourTo': instance.hourTo?.toIso8601String(),
    };

SubstitutionDetails _$SubstitutionDetailsFromJson(Map<String, dynamic> json) =>
    SubstitutionDetails(
      originalUrl: json['originalUrl'] as String? ?? 'htps://g.co',
      originalLessonNo: json['originalLessonNo'] as int? ?? -1,
      originalSubject: json['originalSubject'] == null
          ? null
          : Lesson.fromJson(json['originalSubject'] as Map<String, dynamic>),
      originalTeacher: json['originalTeacher'] == null
          ? null
          : Teacher.fromJson(json['originalTeacher'] as Map<String, dynamic>),
      originalClassroom: json['originalClassroom'] == null
          ? null
          : Classroom.fromJson(
              json['originalClassroom'] as Map<String, dynamic>),
      originalDate: json['originalDate'] == null
          ? null
          : DateTime.parse(json['originalDate'] as String),
      originalHourFrom: json['originalHourFrom'] == null
          ? null
          : DateTime.parse(json['originalHourFrom'] as String),
      originalHourTo: json['originalHourTo'] == null
          ? null
          : DateTime.parse(json['originalHourTo'] as String),
    );

Map<String, dynamic> _$SubstitutionDetailsToJson(
        SubstitutionDetails instance) =>
    <String, dynamic>{
      'originalUrl': instance.originalUrl,
      'originalLessonNo': instance.originalLessonNo,
      'originalSubject': instance.originalSubject,
      'originalTeacher': instance.originalTeacher,
      'originalClassroom': instance.originalClassroom,
      'originalDate': instance.originalDate.toIso8601String(),
      'originalHourFrom': instance.originalHourFrom.toIso8601String(),
      'originalHourTo': instance.originalHourTo.toIso8601String(),
    };
