// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'grade_comments.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GradeComments _$GradeCommentsFromJson(Map<String, dynamic> json) =>
    GradeComments(
      comments: (json['Comments'] as List<dynamic>?)
          ?.map((e) => Comment.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$GradeCommentsToJson(GradeComments instance) =>
    <String, dynamic>{
      'Comments': instance.comments,
    };

Comment _$CommentFromJson(Map<String, dynamic> json) => Comment(
      id: json['Id'] as int? ?? -1,
      addedBy: json['AddedBy'] == null
          ? null
          : AddedBy.fromJson(json['AddedBy'] as Map<String, dynamic>),
      grade: json['Grade'] == null
          ? null
          : AddedBy.fromJson(json['Grade'] as Map<String, dynamic>),
      text: json['Text'] as String? ?? '',
    );

Map<String, dynamic> _$CommentToJson(Comment instance) => <String, dynamic>{
      'Id': instance.id,
      'AddedBy': instance.addedBy,
      'Grade': instance.grade,
      'Text': instance.text,
    };

AddedBy _$AddedByFromJson(Map<String, dynamic> json) => AddedBy(
      id: json['Id'] as int? ?? -1,
      url: json['Url'] as String? ?? '',
    );

Map<String, dynamic> _$AddedByToJson(AddedBy instance) => <String, dynamic>{
      'Id': instance.id,
      'Url': instance.url,
    };
