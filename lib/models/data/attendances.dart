import 'package:json_annotation/json_annotation.dart';
import 'package:ogaku/models/data/teacher.dart';
import 'package:ogaku/models/data/timetables.dart';

import 'package:hive/hive.dart';
part 'attendances.g.dart';

@HiveType(typeId: 22)
@JsonSerializable(includeIfNull: false)
class Attendance extends HiveObject {
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

  @HiveField(0)
  int id;

  @HiveField(1)
  int lessonNo;

  @HiveField(2)
  TimetableLesson lesson;

  @HiveField(3)
  DateTime date;

  @HiveField(4)
  DateTime addDate;

  @HiveField(5)
  AttendanceType type;

  @HiveField(6)
  Teacher teacher;

  factory Attendance.fromJson(Map<String, dynamic> json) => _$AttendanceFromJson(json);

  Map<String, dynamic> toJson() => _$AttendanceToJson(this);
}

@HiveType(typeId: 102)
enum AttendanceType {
  @HiveField(0)
  absent,
  @HiveField(1)
  late,
  @HiveField(2)
  excused,
  @HiveField(3)
  duty,
  @HiveField(4)
  present,
  @HiveField(5)
  other
}
