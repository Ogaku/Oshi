import 'package:darq/darq.dart';
import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:oshi/interface/cupertino/pages/timetable.dart';
import 'package:oshi/models/data/class.dart';
import 'package:oshi/models/data/classroom.dart';
import 'package:oshi/models/data/lesson.dart';
import 'package:oshi/models/data/teacher.dart';

import 'package:hive/hive.dart';
import 'package:oshi/share/share.dart';
part 'timetables.g.dart';

@HiveType(typeId: 33)
@JsonSerializable()
class Timetables extends Equatable {
  @HiveField(1)
  final Map<DateTime, TimetableDay> timetable;

  Timetables({Map<DateTime, TimetableDay>? timetable}) : timetable = timetable ?? {};

  TimetableDay? operator [](DateTime day) => timetable[day]?.withDay(day);

  @override
  List<Object> get props => [timetable];

  factory Timetables.fromJson(Map<String, dynamic> json) => _$TimetablesFromJson(json);

  Map<String, dynamic> toJson() => _$TimetablesToJson(this);
}

@HiveType(typeId: 34)
@JsonSerializable()
class TimetableDay extends Equatable {
  @HiveField(1)
  final List<List<TimetableLesson>?> lessons;

  TimetableDay({List<List<TimetableLesson>?>? lessons, this.calendarDay}) : lessons = lessons ?? [];

  // The start time of the first non-cancelled lesson
  @JsonKey(includeToJson: false, includeFromJson: false)
  DateTime? get dayStart => (calendarDay ?? DateTime.now()).withTime(lessons
      .firstWhereOrDefault((x) => x?.any((y) => !y.isCanceled) ?? false, defaultValue: null)
      ?.firstWhereOrDefault((x) => !x.isCanceled)
      ?.timeFrom);

  // The end time of the last non-cancelled lesson
  @JsonKey(includeToJson: false, includeFromJson: false)
  DateTime? get dayEnd => (calendarDay ?? DateTime.now()).withTime(lessons
      .lastWhereOrDefault((x) => x?.any((y) => !y.isCanceled) ?? false, defaultValue: null)
      ?.lastWhereOrDefault((x) => !x.isCanceled)
      ?.timeTo);

  // Today's lessons, stripped out of empty|null list blocks
  @JsonKey(includeToJson: false, includeFromJson: false)
  List<List<TimetableLesson>?> get lessonsStripped => lessons
      .skipWhile((value) => (value?.isEmpty ?? true))
      .reverse()
      .skipWhile((value) => (value?.isEmpty ?? true))
      .reverse()
      .where((value) => (value?.isNotEmpty ?? false))
      .toList();

  // Today's lessons, stripped out of empty|null|canc list blocks
  @JsonKey(includeToJson: false, includeFromJson: false)
  List<List<TimetableLesson>?> get lessonsStrippedCancelled => lessons
      .skipWhile((value) => (value?.isEmpty ?? true) || (value?.all((x) => x.isCanceled) ?? false))
      .reverse()
      .skipWhile((value) => (value?.isEmpty ?? true) || (value?.all((x) => x.isCanceled) ?? false))
      .reverse()
      .where((value) => (value?.isNotEmpty ?? false))
      .toList();

  // Today's lessons, stripped out of empty|null|canc list blocks
  @JsonKey(includeToJson: false, includeFromJson: false)
  int get lessonsNumber =>
      lessonsStrippedCancelled.count((x) => (x?.isNotEmpty ?? false) && (x?.any((y) => !y.isCanceled) ?? false));

  // Does this day have any non-cancelled lessons?
  @JsonKey(includeToJson: false, includeFromJson: false)
  bool get hasValidLessons => lessons.any((x) => x?.any((y) => !y.isCanceled) ?? false);

  // Does this day have any lesson objects?
  @JsonKey(includeToJson: false, includeFromJson: false)
  bool get hasLessons => lessons.any((x) => x?.isNotEmpty ?? false);

  // Placeholder for withDay
  @JsonKey(includeToJson: false, includeFromJson: false)
  final DateTime? calendarDay;

  TimetableDay withDay(DateTime day) {
    return TimetableDay(lessons: lessons, calendarDay: day);
  }

  @override
  List<Object> get props => [lessons];

  factory TimetableDay.fromJson(Map<String, dynamic> json) => _$TimetableDayFromJson(json);

  Map<String, dynamic> toJson() => _$TimetableDayToJson(this);
}

@HiveType(typeId: 35)
@JsonSerializable()
class TimetableLesson extends Equatable {
  TimetableLesson({
    this.url = '',
    this.lessonNo = -1,
    this.isCanceled = false,
    this.lessonClass,
    this.subject,
    this.teacher,
    this.classroom,
    this.modifiedSchedule = false,
    this.substitutionNote,
    this.substitutionDetails,
    DateTime? date,
    this.hourFrom,
    this.hourTo,
  }) : date = date ?? DateTime(2000);

  @HiveField(1)
  final String url;

  @HiveField(2)
  final int lessonNo;

  @HiveField(3)
  final bool isCanceled;

  @HiveField(4)
  final Class? lessonClass;

  @HiveField(5)
  final Lesson? subject;

  @HiveField(6)
  final Teacher? teacher;

  @HiveField(7)
  final Classroom? classroom;

  @HiveField(8)
  final bool modifiedSchedule;

  @HiveField(9)
  final String? substitutionNote;

  @HiveField(10)
  final SubstitutionDetails? substitutionDetails;

  @HiveField(11)
  final DateTime date;

  @HiveField(12)
  final DateTime? hourFrom;

  @HiveField(13)
  final DateTime? hourTo;

  @JsonKey(includeToJson: false, includeFromJson: false)
  DateTime? get timeFrom => date.withTime(hourFrom);

  @JsonKey(includeToJson: false, includeFromJson: false)
  DateTime? get timeTo => date.withTime(hourTo);

  @JsonKey(includeToJson: false, includeFromJson: false)
  DateTime? get lessonEndDate => date.add(Duration(hours: hourTo?.hour ?? 0, minutes: hourTo?.minute ?? 0));

  @JsonKey(includeToJson: false, includeFromJson: false)
  bool get isSubstitution =>
      modifiedSchedule && substitutionDetails?.originalDate == date && substitutionDetails?.originalLessonNo == lessonNo;

  @JsonKey(includeToJson: false, includeFromJson: false)
  bool get isMovedLesson =>
      modifiedSchedule &&
      ((substitutionDetails?.originalDate == date && substitutionDetails?.originalLessonNo != lessonNo) ||
          substitutionDetails?.originalDate != date);

  @JsonKey(includeToJson: false, includeFromJson: false)
  String get startTime => DateFormat.jm().format(timeFrom ?? DateTime.now());

  @JsonKey(includeToJson: false, includeFromJson: false)
  String get endTime => DateFormat.jm().format(timeTo ?? DateTime.now());

  @JsonKey(includeToJson: false, includeFromJson: false)
  String get detailsStringSubstitution =>
      'Instead of ${substitutionDetails?.originalSubject?.name} with ${substitutionDetails?.originalTeacher?.name}';

  @JsonKey(includeToJson: false, includeFromJson: false)
  String get detailsStringMovedLessonFrom =>
      'Moved from ${DateFormat.MMMMd().format(substitutionDetails?.originalDate ?? DateTime.now())}, lesson no. ${substitutionDetails?.originalLessonNo}';

  @JsonKey(includeToJson: false, includeFromJson: false)
  String get detailsStringMovedLessonTo =>
      'Moved to ${DateFormat.MMMMd().format(substitutionDetails?.originalDate ?? DateTime.now())}, lesson no. ${substitutionDetails?.originalLessonNo}';

  @JsonKey(includeToJson: false, includeFromJson: false)
  String get detailsTimeTeacherString =>
      "${DateFormat.Hm(Share.settings.appSettings.localeCode).format(hourFrom ?? DateTime.now())} - ${DateFormat.Hm(Share.settings.appSettings.localeCode).format(hourTo ?? DateTime.now())} • ${teacher?.name}";

  @JsonKey(includeToJson: false, includeFromJson: false)
  String get substitutionDetailsString => isSubstitution
      ? detailsStringSubstitution
      : isMovedLesson
          ? (isCanceled ? detailsStringMovedLessonTo : detailsStringMovedLessonFrom)
          : isCanceled
              ? 'This lesson was cancelled'
              : '';

  @JsonKey(includeToJson: false, includeFromJson: false)
  String get classroomString => 'In ${classroom?.name}, ${lessonClass?.name}';

  @JsonKey(includeToJson: false, includeFromJson: false)
  String get teacherString => 'With ${teacher?.name}';

  @override
  List<Object> get props => [url, lessonNo, isCanceled, modifiedSchedule, date];

  factory TimetableLesson.fromJson(Map<String, dynamic> json) => _$TimetableLessonFromJson(json);

  Map<String, dynamic> toJson() => _$TimetableLessonToJson(this);
}

// Details of the ORIGINAL lesson
// Put the new data in the base object
@HiveType(typeId: 36)
@JsonSerializable()
class SubstitutionDetails extends Equatable {
  SubstitutionDetails({
    this.originalUrl = 'htps://g.co',
    this.originalLessonNo = -1,
    this.originalSubject,
    this.originalTeacher,
    this.originalClassroom,
    DateTime? originalDate,
    DateTime? originalHourFrom,
    DateTime? originalHourTo,
  })  : originalDate = originalDate ?? DateTime(2000),
        originalHourFrom = originalHourFrom ?? DateTime(2000),
        originalHourTo = originalHourTo ?? DateTime(2000);

  @HiveField(1)
  final String originalUrl;

  @HiveField(2)
  final int originalLessonNo;

  @HiveField(3)
  final Lesson? originalSubject;

  @HiveField(4)
  final Teacher? originalTeacher;

  @HiveField(5)
  final Classroom? originalClassroom;

  @HiveField(6)
  final DateTime originalDate;

  @HiveField(7)
  final DateTime originalHourFrom;

  @HiveField(8)
  final DateTime originalHourTo;

  @override
  List<Object> get props => [originalUrl, originalLessonNo, originalDate, originalHourFrom, originalHourTo];

  factory SubstitutionDetails.fromJson(Map<String, dynamic> json) => _$SubstitutionDetailsFromJson(json);

  Map<String, dynamic> toJson() => _$SubstitutionDetailsToJson(this);
}
