// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'classrooms.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Classrooms _$ClassroomsFromJson(Map<String, dynamic> json) => Classrooms(
      classrooms: (json['Classrooms'] as List<dynamic>?)
          ?.map((e) => Classroom.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ClassroomsToJson(Classrooms instance) =>
    <String, dynamic>{
      'Classrooms': instance.classrooms,
    };

Classroom _$ClassroomFromJson(Map<String, dynamic> json) => Classroom(
      id: json['Id'] as int,
      name: json['Name'] as String,
      symbol: json['Symbol'] as String,
      size: json['Size'] as int,
      schoolCommonRoom: json['SchoolCommonRoom'] as bool,
      description: json['Description'] as String?,
    );

Map<String, dynamic> _$ClassroomToJson(Classroom instance) {
  final val = <String, dynamic>{
    'Id': instance.id,
    'Name': instance.name,
    'Symbol': instance.symbol,
    'Size': instance.size,
    'SchoolCommonRoom': instance.schoolCommonRoom,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('Description', instance.description);
  return val;
}
