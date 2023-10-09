// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'unit.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Unit _$UnitFromJson(Map<String, dynamic> json) => Unit(
      id: json['id'] as int,
      url: json['url'] as String,
      luckyNumber: json['luckyNumber'] as int?,
      name: json['name'] as String,
      principalName: json['principalName'] as String,
      address: json['address'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      type: json['type'] as String,
      behaviourType: json['behaviourType'] as String,
      lessonsRange: (json['lessonsRange'] as List<dynamic>)
          .map((e) => LessonRanges.fromJson(e as Map<String, dynamic>))
          .toList(),
      announcements: (json['announcements'] as List<dynamic>?)
          ?.map((e) => Announcement.fromJson(e as Map<String, dynamic>))
          .toList(),
      teacherAbsences: (json['teacherAbsences'] as List<dynamic>?)
          ?.map((e) => Event.fromJson(e as Map<String, dynamic>))
          .toList(),
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
  val['name'] = instance.name;
  val['principalName'] = instance.principalName;
  val['address'] = instance.address;
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
      from: DateTime.parse(json['from'] as String),
      to: DateTime.parse(json['to'] as String),
    );

Map<String, dynamic> _$LessonRangesToJson(LessonRanges instance) =>
    <String, dynamic>{
      'from': instance.from.toIso8601String(),
      'to': instance.to.toIso8601String(),
    };
