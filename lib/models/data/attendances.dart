import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:oshi/models/data/teacher.dart';
import 'package:oshi/models/data/timetables.dart';

import 'package:hive/hive.dart';
import 'package:oshi/share/share.dart';
part 'attendances.g.dart';

@HiveType(typeId: 22)
@JsonSerializable(includeIfNull: false)
class Attendance extends Equatable {
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
  final int id;

  @HiveField(1)
  final int lessonNo;

  @HiveField(2)
  final TimetableLesson lesson;

  @HiveField(3)
  final DateTime date;

  @HiveField(4)
  final DateTime addDate;

  @HiveField(5)
  final AttendanceType type;

  @HiveField(6)
  final Teacher teacher;

  @override
  List<Object> get props => [id, lessonNo, date, type];

  @JsonKey(includeToJson: false, includeFromJson: false)
  String get addedDateString => "${teacher.name} • ${DateFormat.yMd(Share.settings.appSettings.localeCode).format(date)}";

  @JsonKey(includeToJson: false, includeFromJson: false)
  bool get unseen => Share.session.unreadChanges.attendances.contains(hashCode);
  void markAsSeen() => Share.settings.save(() => Share.session.unreadChanges.attendances.remove(hashCode));

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
