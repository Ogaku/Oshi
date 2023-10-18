import 'package:darq/darq.dart';
import 'package:intl/intl.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:ogaku/models/data/class.dart';
import 'package:ogaku/models/data/classroom.dart';
import 'package:ogaku/models/data/lesson.dart';
import 'package:ogaku/models/data/teacher.dart';

import 'package:hive/hive.dart';
part 'timetables.g.dart';

@HiveType(typeId: 33)
@JsonSerializable()
class Timetables extends HiveObject {
  @HiveField(1)
  Map<DateTime, TimetableDay> timetable;

  Timetables({
    Map<DateTime, TimetableDay>? timetable,
  }) : timetable = timetable ?? {};

  factory Timetables.fromJson(Map<String, dynamic> json) => _$TimetablesFromJson(json);

  Map<String, dynamic> toJson() => _$TimetablesToJson(this);
}

@HiveType(typeId: 34)
@JsonSerializable()
class TimetableDay extends HiveObject {
  @HiveField(1)
  List<List<TimetableLesson>?> lessons;

  TimetableDay({
    List<List<TimetableLesson>?>? lessons,
  }) : lessons = lessons ?? [];

  // The start time of the first non-cancelled lesson
  @JsonKey(includeToJson: false, includeFromJson: false)
  DateTime? get dayStart => lessons
      .firstWhereOrDefault((x) => x?.any((y) => !y.isCanceled) ?? false, defaultValue: null)
      ?.firstWhereOrDefault((x) => !x.isCanceled)
      ?.hourFrom;

  // The end time of the last non-cancelled lesson
  @JsonKey(includeToJson: false, includeFromJson: false)
  DateTime? get dayEnd => lessons
      .lastWhereOrDefault((x) => x?.any((y) => !y.isCanceled) ?? false, defaultValue: null)
      ?.lastWhereOrDefault((x) => !x.isCanceled)
      ?.hourTo;

  // Today's lessons, stripped out of empty|null list blocks
  @JsonKey(includeToJson: false, includeFromJson: false)
  List<List<TimetableLesson>?> get lessonsStripped => lessons
      .skipWhile((value) => (value?.isEmpty ?? true))
      .reverse()
      .skipWhile((value) => (value?.isEmpty ?? true))
      .reverse()
      .toList();

  // Does this day have any non-cancelled lessons?
  @JsonKey(includeToJson: false, includeFromJson: false)
  bool get hasValidLessons => lessons.any((x) => x?.any((y) => !y.isCanceled) ?? false);

  // Does this day have any lesson objects?
  @JsonKey(includeToJson: false, includeFromJson: false)
  bool get hasLessons => lessons.any((x) => x?.isNotEmpty ?? false);

  factory TimetableDay.fromJson(Map<String, dynamic> json) => _$TimetableDayFromJson(json);

  Map<String, dynamic> toJson() => _$TimetableDayToJson(this);
}

@HiveType(typeId: 35)
@JsonSerializable()
class TimetableLesson extends HiveObject {
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
  String url;

  @HiveField(2)
  int lessonNo;

  @HiveField(3)
  bool isCanceled;

  @HiveField(4)
  Class? lessonClass;

  @HiveField(5)
  Lesson? subject;

  @HiveField(6)
  Teacher? teacher;

  @HiveField(7)
  Classroom? classroom;

  @HiveField(8)
  bool modifiedSchedule;

  @HiveField(9)
  String? substitutionNote;

  @HiveField(10)
  SubstitutionDetails? substitutionDetails;

  @HiveField(11)
  DateTime date;

  @HiveField(12)
  DateTime? hourFrom;

  @HiveField(13)
  DateTime? hourTo;

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
  String get startTime => DateFormat.jm().format(hourFrom ?? DateTime.now());

  @JsonKey(includeToJson: false, includeFromJson: false)
  String get endTime => DateFormat.jm().format(hourTo ?? DateTime.now());

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
      "${DateFormat('HH:mm').format(hourFrom ?? DateTime.now())} - ${DateFormat('HH:mm').format(hourTo ?? DateTime.now())} • ${teacher?.name}";

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

  factory TimetableLesson.fromJson(Map<String, dynamic> json) => _$TimetableLessonFromJson(json);

  Map<String, dynamic> toJson() => _$TimetableLessonToJson(this);
}

// Details of the ORIGINAL lesson
// Put the new data in the base object
@HiveType(typeId: 36)
@JsonSerializable()
class SubstitutionDetails extends HiveObject {
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
  String originalUrl;

  @HiveField(2)
  int originalLessonNo;

  @HiveField(3)
  Lesson? originalSubject;

  @HiveField(4)
  Teacher? originalTeacher;

  @HiveField(5)
  Classroom? originalClassroom;

  @HiveField(6)
  DateTime originalDate;

  @HiveField(7)
  DateTime originalHourFrom;

  @HiveField(8)
  DateTime originalHourTo;

  factory SubstitutionDetails.fromJson(Map<String, dynamic> json) => _$SubstitutionDetailsFromJson(json);

  Map<String, dynamic> toJson() => _$SubstitutionDetailsToJson(this);
}
