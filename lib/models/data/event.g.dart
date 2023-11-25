// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class EventAdapter extends TypeAdapter<Event> {
  @override
  final int typeId = 25;

  @override
  Event read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Event(
      id: fields[0] as int,
      lessonNo: fields[1] as int?,
      date: fields[2] as DateTime?,
      addDate: fields[3] as DateTime?,
      timeFrom: fields[4] as DateTime?,
      timeTo: fields[5] as DateTime?,
      title: fields[6] as String?,
      content: fields[7] as String,
      categoryName: fields[8] as String,
      category: fields[10] as EventCategory,
      done: fields[9] as bool,
      sender: fields[11] as Teacher?,
      attachments: (fields[13] as List?)?.cast<Attachment>(),
      classroom: fields[12] as Classroom?,
      isOwnEvent: fields[14] as bool?,
    );
  }

  @override
  void write(BinaryWriter writer, Event obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.lessonNo)
      ..writeByte(2)
      ..write(obj.date)
      ..writeByte(3)
      ..write(obj.addDate)
      ..writeByte(4)
      ..write(obj.timeFrom)
      ..writeByte(5)
      ..write(obj.timeTo)
      ..writeByte(6)
      ..write(obj.title)
      ..writeByte(7)
      ..write(obj.content)
      ..writeByte(8)
      ..write(obj.categoryName)
      ..writeByte(9)
      ..write(obj.done)
      ..writeByte(10)
      ..write(obj.category)
      ..writeByte(11)
      ..write(obj.sender)
      ..writeByte(12)
      ..write(obj.classroom)
      ..writeByte(13)
      ..write(obj.attachments)
      ..writeByte(14)
      ..write(obj.isOwnEvent);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EventAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class EventCategoryAdapter extends TypeAdapter<EventCategory> {
  @override
  final int typeId = 101;

  @override
  EventCategory read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return EventCategory.gathering;
      case 1:
        return EventCategory.lecture;
      case 2:
        return EventCategory.test;
      case 3:
        return EventCategory.classWork;
      case 4:
        return EventCategory.semCorrection;
      case 5:
        return EventCategory.other;
      case 6:
        return EventCategory.lessonWork;
      case 7:
        return EventCategory.shortTest;
      case 8:
        return EventCategory.correction;
      case 9:
        return EventCategory.onlineLesson;
      case 10:
        return EventCategory.homework;
      case 11:
        return EventCategory.teacher;
      case 12:
        return EventCategory.freeDay;
      case 13:
        return EventCategory.conference;
      case 14:
        return EventCategory.admin;
      default:
        return EventCategory.gathering;
    }
  }

  @override
  void write(BinaryWriter writer, EventCategory obj) {
    switch (obj) {
      case EventCategory.gathering:
        writer.writeByte(0);
        break;
      case EventCategory.lecture:
        writer.writeByte(1);
        break;
      case EventCategory.test:
        writer.writeByte(2);
        break;
      case EventCategory.classWork:
        writer.writeByte(3);
        break;
      case EventCategory.semCorrection:
        writer.writeByte(4);
        break;
      case EventCategory.other:
        writer.writeByte(5);
        break;
      case EventCategory.lessonWork:
        writer.writeByte(6);
        break;
      case EventCategory.shortTest:
        writer.writeByte(7);
        break;
      case EventCategory.correction:
        writer.writeByte(8);
        break;
      case EventCategory.onlineLesson:
        writer.writeByte(9);
        break;
      case EventCategory.homework:
        writer.writeByte(10);
        break;
      case EventCategory.teacher:
        writer.writeByte(11);
        break;
      case EventCategory.freeDay:
        writer.writeByte(12);
        break;
      case EventCategory.conference:
        writer.writeByte(13);
        break;
      case EventCategory.admin:
        writer.writeByte(14);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EventCategoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Event _$EventFromJson(Map<String, dynamic> json) => Event(
      id: json['id'] as int? ?? -1,
      lessonNo: json['lessonNo'] as int?,
      date:
          json['date'] == null ? null : DateTime.parse(json['date'] as String),
      addDate: json['addDate'] == null
          ? null
          : DateTime.parse(json['addDate'] as String),
      timeFrom: json['timeFrom'] == null
          ? null
          : DateTime.parse(json['timeFrom'] as String),
      timeTo: json['timeTo'] == null
          ? null
          : DateTime.parse(json['timeTo'] as String),
      title: json['title'] as String?,
      content: json['content'] as String? ?? '',
      categoryName: json['categoryName'] as String? ?? '',
      category: $enumDecodeNullable(_$EventCategoryEnumMap, json['category']) ??
          EventCategory.other,
      done: json['done'] as bool? ?? false,
      sender: json['sender'] == null
          ? null
          : Teacher.fromJson(json['sender'] as Map<String, dynamic>),
      attachments: (json['attachments'] as List<dynamic>?)
          ?.map((e) => Attachment.fromJson(e as Map<String, dynamic>))
          .toList(),
      classroom: json['classroom'] == null
          ? null
          : Classroom.fromJson(json['classroom'] as Map<String, dynamic>),
      isOwnEvent: json['isOwnEvent'] as bool?,
    );

Map<String, dynamic> _$EventToJson(Event instance) {
  final val = <String, dynamic>{
    'id': instance.id,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('lessonNo', instance.lessonNo);
  writeNotNull('date', instance.date?.toIso8601String());
  writeNotNull('addDate', instance.addDate?.toIso8601String());
  val['timeFrom'] = instance.timeFrom.toIso8601String();
  writeNotNull('timeTo', instance.timeTo?.toIso8601String());
  writeNotNull('title', instance.title);
  val['content'] = instance.content;
  val['categoryName'] = instance.categoryName;
  val['done'] = instance.done;
  val['category'] = _$EventCategoryEnumMap[instance.category]!;
  writeNotNull('sender', instance.sender);
  writeNotNull('classroom', instance.classroom);
  writeNotNull('attachments', instance.attachments);
  val['isOwnEvent'] = instance.isOwnEvent;
  return val;
}

const _$EventCategoryEnumMap = {
  EventCategory.gathering: 'gathering',
  EventCategory.lecture: 'lecture',
  EventCategory.test: 'test',
  EventCategory.classWork: 'classWork',
  EventCategory.semCorrection: 'semCorrection',
  EventCategory.other: 'other',
  EventCategory.lessonWork: 'lessonWork',
  EventCategory.shortTest: 'shortTest',
  EventCategory.correction: 'correction',
  EventCategory.onlineLesson: 'onlineLesson',
  EventCategory.homework: 'homework',
  EventCategory.teacher: 'teacher',
  EventCategory.freeDay: 'freeDay',
  EventCategory.conference: 'conference',
  EventCategory.admin: 'admin',
};
