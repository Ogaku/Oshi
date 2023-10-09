// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'homework_assignments.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HomeWorkAssignments _$HomeWorkAssignmentsFromJson(Map<String, dynamic> json) =>
    HomeWorkAssignments(
      homeWorkAssignments: (json['HomeWorkAssignments'] as List<dynamic>?)
          ?.map((e) => HomeWorkAssignment.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$HomeWorkAssignmentsToJson(
        HomeWorkAssignments instance) =>
    <String, dynamic>{
      'HomeWorkAssignments': instance.homeWorkAssignments,
    };

HomeWorkAssignment _$HomeWorkAssignmentFromJson(Map<String, dynamic> json) =>
    HomeWorkAssignment(
      id: json['Id'] as int,
      teacher: json['Teacher'] == null
          ? null
          : Category.fromJson(json['Teacher'] as Map<String, dynamic>),
      student: (json['Student'] as List<dynamic>?)
          ?.map((e) => Category.fromJson(e as Map<String, dynamic>))
          .toList(),
      date:
          json['Date'] == null ? null : DateTime.parse(json['Date'] as String),
      dueDate: json['DueDate'] == null
          ? null
          : DateTime.parse(json['DueDate'] as String),
      text: json['Text'] as String,
      topic: json['Topic'] as String,
      lesson: json['Lesson'] == null
          ? null
          : Category.fromJson(json['Lesson'] as Map<String, dynamic>),
      mustSendAttachFile: json['MustSendAttachFile'] as bool,
      sendFilePossible: json['SendFilePossible'] as bool,
      addedFiles: json['AddedFiles'] as bool,
      homeworkAssigmentFiles: json['HomeworkAssigmentFiles'] as List<dynamic>?,
      category: json['Category'] == null
          ? null
          : Category.fromJson(json['Category'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$HomeWorkAssignmentToJson(HomeWorkAssignment instance) =>
    <String, dynamic>{
      'Id': instance.id,
      'Teacher': instance.teacher,
      'Student': instance.student,
      'Date': instance.date?.toIso8601String(),
      'DueDate': instance.dueDate?.toIso8601String(),
      'Text': instance.text,
      'Topic': instance.topic,
      'Lesson': instance.lesson,
      'MustSendAttachFile': instance.mustSendAttachFile,
      'SendFilePossible': instance.sendFilePossible,
      'AddedFiles': instance.addedFiles,
      'HomeworkAssigmentFiles': instance.homeworkAssigmentFiles,
      'Category': instance.category,
    };

Category _$CategoryFromJson(Map<String, dynamic> json) => Category(
      id: json['Id'] as int,
      url: json['Url'] as String,
    );

Map<String, dynamic> _$CategoryToJson(Category instance) => <String, dynamic>{
      'Id': instance.id,
      'Url': instance.url,
    };

StudentsMarkedAsDoneDateClass _$StudentsMarkedAsDoneDateClassFromJson(
        Map<String, dynamic> json) =>
    StudentsMarkedAsDoneDateClass(
      the2071133: json['2071133'] == null
          ? null
          : DateTime.parse(json['2071133'] as String),
    );

Map<String, dynamic> _$StudentsMarkedAsDoneDateClassToJson(
        StudentsMarkedAsDoneDateClass instance) =>
    <String, dynamic>{
      '2071133': instance.the2071133?.toIso8601String(),
    };
