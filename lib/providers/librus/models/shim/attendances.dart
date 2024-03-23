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

  @JsonKey(name: 'Lesson', defaultValue: null)
  final Link? lesson;

  @JsonKey(name: 'Student', defaultValue: null)
  final Link? student;

  @JsonKey(name: 'Date', defaultValue: null)
  final DateTime? date;

  @JsonKey(name: 'AddDate', defaultValue: null)
  final DateTime? addDate;

  @JsonKey(name: 'LessonNo', defaultValue: -1)
  final int lessonNo;

  @JsonKey(name: 'Semester', defaultValue: -1)
  final int semester;

  @JsonKey(name: 'Type', defaultValue: null)
  final Link? type;

  @JsonKey(name: 'AddedBy', defaultValue: null)
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

  @JsonKey(name: 'Id', defaultValue: -1)
  final int id;

  @JsonKey(name: 'Url', defaultValue: '')
  final String url;

  factory Link.fromJson(Map<String, dynamic> json) => _$LinkFromJson(json);

  Map<String, dynamic> toJson() => _$LinkToJson(this);
}
