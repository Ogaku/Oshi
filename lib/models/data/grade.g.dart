// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'grade.dart';

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
    };
