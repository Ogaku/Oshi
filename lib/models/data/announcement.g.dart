// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'announcement.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Announcement _$AnnouncementFromJson(Map<String, dynamic> json) => Announcement(
      id: json['id'] as int? ?? -1,
      url: json['url'] as String? ?? '',
      read: json['read'] as bool? ?? false,
      subject: json['subject'] as String? ?? '',
      content: json['content'] as String? ?? '',
      contact: json['contact'] == null
          ? null
          : Teacher.fromJson(json['contact'] as Map<String, dynamic>),
      startDate: json['startDate'] == null
          ? null
          : DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] == null
          ? null
          : DateTime.parse(json['endDate'] as String),
    );

Map<String, dynamic> _$AnnouncementToJson(Announcement instance) =>
    <String, dynamic>{
      'id': instance.id,
      'url': instance.url,
      'read': instance.read,
      'subject': instance.subject,
      'content': instance.content,
      'contact': instance.contact,
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate.toIso8601String(),
    };
