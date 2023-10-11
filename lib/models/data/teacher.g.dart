// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'teacher.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Teacher _$TeacherFromJson(Map<String, dynamic> json) => Teacher(
      id: json['id'] as int? ?? -1,
      userId: json['userId'] as int?,
      url: json['url'] as String? ?? '',
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      isHomeTeacher: json['isHomeTeacher'] as bool?,
      absent: _$recordConvertNullable(
        json['absent'],
        ($jsonValue) => (
          from: DateTime.parse($jsonValue['from'] as String),
          to: DateTime.parse($jsonValue['to'] as String),
        ),
      ),
    );

Map<String, dynamic> _$TeacherToJson(Teacher instance) => <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'url': instance.url,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'isHomeTeacher': instance.isHomeTeacher,
      'absent': instance.absent == null
          ? null
          : {
              'from': instance.absent!.from.toIso8601String(),
              'to': instance.absent!.to.toIso8601String(),
            },
    };

$Rec? _$recordConvertNullable<$Rec>(
  Object? value,
  $Rec Function(Map) convert,
) =>
    value == null ? null : convert(value as Map<String, dynamic>);
