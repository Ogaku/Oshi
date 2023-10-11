// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event.dart';

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
      sender: json['sender'] == null
          ? null
          : Teacher.fromJson(json['sender'] as Map<String, dynamic>),
      classroom: json['classroom'] == null
          ? null
          : Classroom.fromJson(json['classroom'] as Map<String, dynamic>),
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
  val['category'] = _$EventCategoryEnumMap[instance.category]!;
  writeNotNull('sender', instance.sender);
  writeNotNull('classroom', instance.classroom);
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
};
