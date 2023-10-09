import 'package:json_annotation/json_annotation.dart';

part 'teacher_free_days.g.dart';

@JsonSerializable()
class TeacherFreeDays {
  TeacherFreeDays({
    required this.teacherFreeDays,
  });

  @JsonKey(name: 'TeacherFreeDays')
  final List<TeacherFreeDay>? teacherFreeDays;

  factory TeacherFreeDays.fromJson(Map<String, dynamic> json) => _$TeacherFreeDaysFromJson(json);

  Map<String, dynamic> toJson() => _$TeacherFreeDaysToJson(this);
}

@JsonSerializable(includeIfNull: false)
class TeacherFreeDay {
  TeacherFreeDay({
    required this.id,
    this.teacher,
    this.dateFrom,
    this.dateTo,
    this.timeFrom,
    this.timeTo,
  });

  @JsonKey(name: 'Id')
  final int id;

  @JsonKey(name: 'Teacher')
  final Teacher? teacher;

  @JsonKey(name: 'DateFrom')
  final DateTime? dateFrom;

  @JsonKey(name: 'DateTo')
  final DateTime? dateTo;

  @JsonKey(name: 'TimeFrom')
  final String? timeFrom;

  @JsonKey(name: 'TimeTo')
  final String? timeTo;

  factory TeacherFreeDay.fromJson(Map<String, dynamic> json) => _$TeacherFreeDayFromJson(json);

  Map<String, dynamic> toJson() => _$TeacherFreeDayToJson(this);
}

@JsonSerializable()
class Teacher {
  Teacher({
    required this.id,
    required this.url,
  });

  @JsonKey(name: 'Id')
  final int id;

  @JsonKey(name: 'Url')
  final String url;

  factory Teacher.fromJson(Map<String, dynamic> json) => _$TeacherFromJson(json);

  Map<String, dynamic> toJson() => _$TeacherToJson(this);
}
