import 'package:json_annotation/json_annotation.dart';

part 'attendances.g.dart';

@JsonSerializable()
class Attendances {
  Attendances({
    required this.attendances,
  });

  @JsonKey(name: 'Attendances')
  final List<DataAttendance>? attendances;

  factory Attendances.fromJson(Map<String, dynamic> json) => _$AttendancesFromJson(json);

  Map<String, dynamic> toJson() => _$AttendancesToJson(this);
}

@JsonSerializable()
class DataAttendance {
  DataAttendance({
    required this.lesson,
    required this.student,
    required this.date,
    required this.addDate,
    required this.lessonNo,
    required this.semester,
    required this.type,
    required this.addedBy,
  });

  @JsonKey(name: 'Lesson')
  final Link? lesson;

  @JsonKey(name: 'Student')
  final Link? student;

  @JsonKey(name: 'Date')
  final DateTime? date;

  @JsonKey(name: 'AddDate')
  final DateTime? addDate;

  @JsonKey(name: 'LessonNo')
  final int lessonNo;

  @JsonKey(name: 'Semester')
  final int semester;

  @JsonKey(name: 'Type')
  final Link? type;

  @JsonKey(name: 'AddedBy')
  final Link? addedBy;

  factory DataAttendance.fromJson(Map<String, dynamic> json) => _$DataAttendanceFromJson(json);

  Map<String, dynamic> toJson() => _$DataAttendanceToJson(this);
}

@JsonSerializable()
class Link {
  Link({
    required this.id,
    required this.url,
  });

  @JsonKey(name: 'Id')
  final int id;

  @JsonKey(name: 'Url')
  final String url;

  factory Link.fromJson(Map<String, dynamic> json) => _$LinkFromJson(json);

  Map<String, dynamic> toJson() => _$LinkToJson(this);
}
