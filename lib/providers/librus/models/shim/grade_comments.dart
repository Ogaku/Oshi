import 'package:json_annotation/json_annotation.dart';

part 'grade_comments.g.dart';

@JsonSerializable()
class GradeComments {
  GradeComments({
    required this.comments,
  });

  @JsonKey(name: 'Comments')
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

  @JsonKey(name: 'Id')
  final int id;

  @JsonKey(name: 'AddedBy')
  final AddedBy? addedBy;

  @JsonKey(name: 'Grade')
  final AddedBy? grade;

  @JsonKey(name: 'Text')
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

  @JsonKey(name: 'Id')
  final int id;

  @JsonKey(name: 'Url')
  final String url;

  factory AddedBy.fromJson(Map<String, dynamic> json) => _$AddedByFromJson(json);

  Map<String, dynamic> toJson() => _$AddedByToJson(this);
}
