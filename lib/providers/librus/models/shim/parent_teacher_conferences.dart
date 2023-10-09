import 'package:json_annotation/json_annotation.dart';

part 'parent_teacher_conferences.g.dart';

@JsonSerializable()
class ParentTeacherConferences {
  ParentTeacherConferences({
    required this.parentTeacherConferences,
  });

  @JsonKey(name: 'ParentTeacherConferences')
  final List<ParentTeacherConference>? parentTeacherConferences;

  factory ParentTeacherConferences.fromJson(Map<String, dynamic> json) => _$ParentTeacherConferencesFromJson(json);

  Map<String, dynamic> toJson() => _$ParentTeacherConferencesToJson(this);
}

@JsonSerializable()
class ParentTeacherConference {
  ParentTeacherConference({
    required this.id,
    required this.date,
    required this.name,
    required this.parentTeacherConferenceClass,
    required this.teacher,
    required this.topic,
    required this.room,
    required this.time,
  });

  @JsonKey(name: 'Id')
  final int id;

  @JsonKey(name: 'Date')
  final DateTime? date;

  @JsonKey(name: 'Name')
  final String name;

  @JsonKey(name: 'Class')
  final Class? parentTeacherConferenceClass;

  @JsonKey(name: 'Teacher')
  final Class? teacher;

  @JsonKey(name: 'Topic')
  final String topic;

  @JsonKey(name: 'Room')
  final dynamic room;

  @JsonKey(name: 'Time')
  final String time;

  factory ParentTeacherConference.fromJson(Map<String, dynamic> json) => _$ParentTeacherConferenceFromJson(json);

  Map<String, dynamic> toJson() => _$ParentTeacherConferenceToJson(this);
}

@JsonSerializable()
class Class {
  Class({
    required this.id,
    required this.url,
  });

  @JsonKey(name: 'Id')
  final int id;

  @JsonKey(name: 'Url')
  final String url;

  factory Class.fromJson(Map<String, dynamic> json) => _$ClassFromJson(json);

  Map<String, dynamic> toJson() => _$ClassToJson(this);
}
