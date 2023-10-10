import 'package:darq/darq.dart';
import 'package:intl/intl.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:ogaku/models/data/class.dart';
import 'package:ogaku/models/data/classroom.dart';
import 'package:ogaku/models/data/lesson.dart';
import 'package:ogaku/models/data/teacher.dart';

part 'timetables.g.dart';

@JsonSerializable()
class Timetables {
  Map<DateTime, TimetableDay> timetable;

  Timetables(
    this.timetable,
  );

  factory Timetables.fromJson(Map<String, dynamic> json) => _$TimetablesFromJson(json);

  Map<String, dynamic> toJson() => _$TimetablesToJson(this);
}

@JsonSerializable()
class TimetableDay {
  List<List<TimetableLesson>?> lessons;

  TimetableDay(
    this.lessons,
  );

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

@JsonSerializable()
class TimetableLesson {
  TimetableLesson({
    this.url = '',
    required this.lessonNo,
    this.isCanceled = false,
    this.lessonClass,
    this.subject,
    this.teacher,
    this.classroom,
    this.modifiedSchedule = false,
    this.substitutionNote,
    this.substitutionDetails,
    required this.date,
    this.hourFrom,
    this.hourTo,
  });

  String url;
  int lessonNo;
  bool isCanceled;
  Class? lessonClass;
  Lesson? subject;
  Teacher? teacher;
  Classroom? classroom;
  bool modifiedSchedule;
  String? substitutionNote;
  SubstitutionDetails? substitutionDetails;
  DateTime date;
  DateTime? hourFrom;
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
  String get detailsStringMovedLesson =>
      'Moved from ${DateFormat.MMMMd().format(substitutionDetails?.originalDate ?? DateTime.now())}, lesson no. ${substitutionDetails?.originalLessonNo}';

  @JsonKey(includeToJson: false, includeFromJson: false)
  String get substitutionDetailsString => isSubstitution
      ? detailsStringSubstitution
      : isMovedLesson
          ? detailsStringMovedLesson
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
@JsonSerializable()
class SubstitutionDetails {
  SubstitutionDetails({
    required this.originalUrl,
    required this.originalLessonNo,
    required this.originalSubject,
    required this.originalTeacher,
    required this.originalClassroom,
    required this.originalDate,
    required this.originalHourFrom,
    required this.originalHourTo,
  });

  String originalUrl;
  int originalLessonNo;
  Lesson? originalSubject;
  Teacher? originalTeacher;
  Classroom? originalClassroom;
  DateTime originalDate;
  DateTime originalHourFrom;
  DateTime originalHourTo;

  factory SubstitutionDetails.fromJson(Map<String, dynamic> json) => _$SubstitutionDetailsFromJson(json);

  Map<String, dynamic> toJson() => _$SubstitutionDetailsToJson(this);
}
