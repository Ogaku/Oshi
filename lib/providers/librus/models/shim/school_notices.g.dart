// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'school_notices.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SchoolNotices _$SchoolNoticesFromJson(Map<String, dynamic> json) =>
    SchoolNotices(
      schoolNotices: (json['SchoolNotices'] as List<dynamic>?)
          ?.map((e) => SchoolNotice.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$SchoolNoticesToJson(SchoolNotices instance) =>
    <String, dynamic>{
      'SchoolNotices': instance.schoolNotices,
    };

SchoolNotice _$SchoolNoticeFromJson(Map<String, dynamic> json) => SchoolNotice(
      id: json['Id'] as String,
      startDate: json['StartDate'] == null
          ? null
          : DateTime.parse(json['StartDate'] as String),
      endDate: json['EndDate'] == null
          ? null
          : DateTime.parse(json['EndDate'] as String),
      subject: json['Subject'] as String,
      content: json['Content'] as String,
      addedBy: json['AddedBy'] == null
          ? null
          : AddedBy.fromJson(json['AddedBy'] as Map<String, dynamic>),
      creationDate: json['CreationDate'] == null
          ? null
          : DateTime.parse(json['CreationDate'] as String),
      wasRead: json['WasRead'] as bool,
    );

Map<String, dynamic> _$SchoolNoticeToJson(SchoolNotice instance) =>
    <String, dynamic>{
      'Id': instance.id,
      'StartDate': instance.startDate?.toIso8601String(),
      'EndDate': instance.endDate?.toIso8601String(),
      'Subject': instance.subject,
      'Content': instance.content,
      'AddedBy': instance.addedBy,
      'CreationDate': instance.creationDate?.toIso8601String(),
      'WasRead': instance.wasRead,
    };

AddedBy _$AddedByFromJson(Map<String, dynamic> json) => AddedBy(
      id: json['Id'] as int,
      url: json['Url'] as String,
    );

Map<String, dynamic> _$AddedByToJson(AddedBy instance) => <String, dynamic>{
      'Id': instance.id,
      'Url': instance.url,
    };
