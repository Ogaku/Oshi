import 'package:json_annotation/json_annotation.dart';
import 'package:szkolny/models/data/teacher.dart';
import 'package:szkolny/models/data/timetables.dart';

part 'attendances.g.dart';

@JsonSerializable(includeIfNull: false)
class Attendance {
  Attendance({
    required this.id,
    required this.lessonNo,
    required this.lesson,
    required this.date,
    required this.addDate,
    required this.type,
    required this.teacher,
  });

  int id;
  int lessonNo;
  TimetableLesson lesson;
  DateTime date;
  DateTime addDate;
  AttendanceType type;
  Teacher? teacher;

  factory Attendance.fromJson(Map<String, dynamic> json) => _$AttendanceFromJson(json);

  Map<String, dynamic> toJson() => _$AttendanceToJson(this);
}

enum AttendanceType { absent, late, excused, duty, present, other }
