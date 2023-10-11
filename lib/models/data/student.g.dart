// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'student.dart';

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
