import 'package:json_annotation/json_annotation.dart';

part 'teacher_free_days.g.dart';

@JsonSerializable()
class TeacherFreeDays {
  TeacherFreeDays({
    required this.teacherFreeDays,
  });

  @JsonKey(name: 'TeacherFreeDays', defaultValue: null)
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

  @JsonKey(name: 'Id', defaultValue: -1)
  final int id;

  @JsonKey(name: 'Teacher', defaultValue: null)
  final Teacher? teacher;

  @JsonKey(name: 'DateFrom', defaultValue: null)
  final DateTime? dateFrom;

  @JsonKey(name: 'DateTo', defaultValue: null)
  final DateTime? dateTo;

  @JsonKey(name: 'TimeFrom', defaultValue: null)
  final String? timeFrom;

  @JsonKey(name: 'TimeTo', defaultValue: null)
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

  @JsonKey(name: 'Id', defaultValue: -1)
  final int id;

  @JsonKey(name: 'Url', defaultValue: '')
  final String url;

  factory Teacher.fromJson(Map<String, dynamic> json) => _$TeacherFromJson(json);

  Map<String, dynamic> toJson() => _$TeacherToJson(this);
}
