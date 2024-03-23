// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'virtual_classes.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VirtualClasses _$VirtualClassesFromJson(Map<String, dynamic> json) =>
    VirtualClasses(
      virtualClasses: (json['VirtualClasses'] as List<dynamic>?)
          ?.map((e) => VirtualClass.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$VirtualClassesToJson(VirtualClasses instance) =>
    <String, dynamic>{
      'VirtualClasses': instance.virtualClasses,
    };

VirtualClass _$VirtualClassFromJson(Map<String, dynamic> json) => VirtualClass(
      id: json['Id'] as int? ?? -1,
      teacher: json['Teacher'] == null
          ? null
          : Subject.fromJson(json['Teacher'] as Map<String, dynamic>),
      subject: json['Subject'] == null
          ? null
          : Subject.fromJson(json['Subject'] as Map<String, dynamic>),
      name: json['Name'] as String? ?? '',
      number: json['Number'] as int? ?? -1,
      symbol: json['Symbol'] as String? ?? '',
    );

Map<String, dynamic> _$VirtualClassToJson(VirtualClass instance) =>
    <String, dynamic>{
      'Id': instance.id,
      'Teacher': instance.teacher,
      'Subject': instance.subject,
      'Name': instance.name,
      'Number': instance.number,
      'Symbol': instance.symbol,
    };

Subject _$SubjectFromJson(Map<String, dynamic> json) => Subject(
      id: json['Id'] as int? ?? -1,
      url: json['Url'] as String? ?? '',
    );

Map<String, dynamic> _$SubjectToJson(Subject instance) => <String, dynamic>{
      'Id': instance.id,
      'Url': instance.url,
    };
