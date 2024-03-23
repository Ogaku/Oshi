import 'package:json_annotation/json_annotation.dart';

part 'grade_comments.g.dart';

@JsonSerializable()
class GradeComments {
  GradeComments({
    required this.comments,
  });

  @JsonKey(name: 'Comments', defaultValue: null)
  final List<Comment>? comments;

  factory GradeComments.fromJson(Map<String, dynamic> json) => _$GradeCommentsFromJson(json);

  Map<String, dynamic> toJson() => _$GradeCommentsToJson(this);
}

@JsonSerializable()
class Comment {
  Comment({
    required this.id,
    required this.addedBy,
    required this.grade,
    required this.text,
  });

  @JsonKey(name: 'Id', defaultValue: -1)
  final int id;

  @JsonKey(name: 'AddedBy', defaultValue: null)
  final AddedBy? addedBy;

  @JsonKey(name: 'Grade', defaultValue: null)
  final AddedBy? grade;

  @JsonKey(name: 'Text', defaultValue: '')
  final String text;

  factory Comment.fromJson(Map<String, dynamic> json) => _$CommentFromJson(json);

  Map<String, dynamic> toJson() => _$CommentToJson(this);
}

@JsonSerializable()
class AddedBy {
  AddedBy({
    required this.id,
    required this.url,
  });

  @JsonKey(name: 'Id', defaultValue: -1)
  final int id;

  @JsonKey(name: 'Url', defaultValue: '')
  final String url;

  factory AddedBy.fromJson(Map<String, dynamic> json) => _$AddedByFromJson(json);

  Map<String, dynamic> toJson() => _$AddedByToJson(this);
}
