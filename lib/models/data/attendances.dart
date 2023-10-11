import 'package:json_annotation/json_annotation.dart';
import 'package:ogaku/models/data/teacher.dart';
import 'package:ogaku/models/data/timetables.dart';

part 'attendances.g.dart';

@JsonSerializable(includeIfNull: false)
class Attendance {
  Attendance({
    this.id = -1,
    this.lessonNo = -1,
    TimetableLesson? lesson,
    DateTime? date,
    DateTime? addDate,
    AttendanceType? type,
    Teacher? teacher,
  })  : lesson = lesson ?? TimetableLesson(),
        date = date ?? DateTime(2000),
        addDate = addDate ?? DateTime(2000),
        type = type ?? AttendanceType.other,
        teacher = teacher ?? Teacher();

  int id;
  int lessonNo;
  TimetableLesson lesson;
  DateTime date;
  DateTime addDate;
  AttendanceType type;
  Teacher teacher;

  factory Attendance.fromJson(Map<String, dynamic> json) => _$AttendanceFromJson(json);

  Map<String, dynamic> toJson() => _$AttendanceToJson(this);
}

enum AttendanceType { absent, late, excused, duty, present, other }
