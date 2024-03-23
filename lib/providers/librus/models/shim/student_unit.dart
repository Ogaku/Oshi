import 'package:intl/intl.dart';
import 'package:json_annotation/json_annotation.dart';

part 'student_unit.g.dart';

@JsonSerializable()
class StudentUnit {
  StudentUnit({
    required this.unit,
  });

  @JsonKey(name: 'Unit', defaultValue: null)
  final Unit? unit;

  factory StudentUnit.fromJson(Map<String, dynamic> json) => _$StudentUnitFromJson(json);

  Map<String, dynamic> toJson() => _$StudentUnitToJson(this);
}

@JsonSerializable()
class Unit {
  Unit({
    required this.id,
    required this.name,
    required this.shortName,
    required this.type,
    required this.behaviourType,
    required this.gradesSettings,
    required this.lessonSettings,
    required this.lessonsRange,
    required this.behaviourGradesSettings,
  });

  @JsonKey(name: 'Id', defaultValue: -1)
  final int id;

  @JsonKey(name: 'Name', defaultValue: '')
  final String name;

  @JsonKey(name: 'ShortName', defaultValue: '')
  final String shortName;

  @JsonKey(name: 'Type', defaultValue: '')
  final String type;

  @JsonKey(name: 'BehaviourType', defaultValue: '')
  final String behaviourType;

  @JsonKey(name: 'GradesSettings', defaultValue: null)
  final GradesSettings? gradesSettings;

  @JsonKey(name: 'LessonSettings', defaultValue: null)
  final LessonSettings? lessonSettings;

  @JsonKey(name: 'LessonsRange', defaultValue: null)
  final List<LessonsRange>? lessonsRange;

  @JsonKey(name: 'BehaviourGradesSettings', defaultValue: null)
  final BehaviourGradesSettings? behaviourGradesSettings;

  factory Unit.fromJson(Map<String, dynamic> json) => _$UnitFromJson(json);

  Map<String, dynamic> toJson() => _$UnitToJson(this);
}

@JsonSerializable()
class BehaviourGradesSettings {
  BehaviourGradesSettings({
    required this.startPoints,
    required this.showCategoriesShortcuts,
  });

  @JsonKey(name: 'StartPoints', defaultValue: null)
  final StartPoints? startPoints;

  @JsonKey(name: 'ShowCategoriesShortcuts', defaultValue: null)
  final bool showCategoriesShortcuts;

  factory BehaviourGradesSettings.fromJson(Map<String, dynamic> json) => _$BehaviourGradesSettingsFromJson(json);

  Map<String, dynamic> toJson() => _$BehaviourGradesSettingsToJson(this);
}

@JsonSerializable()
class StartPoints {
  StartPoints({
    required this.semester1,
    required this.semester2,
  });

  @JsonKey(name: 'Semester1', defaultValue: -1)
  final int semester1;

  @JsonKey(name: 'Semester2', defaultValue: -2)
  final int semester2;

  factory StartPoints.fromJson(Map<String, dynamic> json) => _$StartPointsFromJson(json);

  Map<String, dynamic> toJson() => _$StartPointsToJson(this);
}

@JsonSerializable()
class GradesSettings {
  GradesSettings({
    required this.standardGradesEnabled,
    required this.pointGradesEnabled,
    required this.descriptiveGradesEnabled,
    required this.forcePointGradesDictionaries,
    required this.allowOverrangePointGrades,
    required this.allowClassTutorEditGrades,
    required this.canAddAnyGrades,
    this.grade0Map = '',
  });

  @JsonKey(name: 'StandardGradesEnabled', defaultValue: false)
  final bool standardGradesEnabled;

  @JsonKey(name: 'PointGradesEnabled', defaultValue: false)
  final bool pointGradesEnabled;

  @JsonKey(name: 'DescriptiveGradesEnabled', defaultValue: false)
  final bool descriptiveGradesEnabled;

  @JsonKey(name: 'ForcePointGradesDictionaries', defaultValue: false)
  final bool forcePointGradesDictionaries;

  @JsonKey(name: 'AllowOverrangePointGrades', defaultValue: false)
  final bool allowOverrangePointGrades;

  @JsonKey(name: 'AllowClassTutorEditGrades', defaultValue: false)
  final bool allowClassTutorEditGrades;

  @JsonKey(name: 'CanAddAnyGrades', defaultValue: false)
  final bool canAddAnyGrades;

  @JsonKey(name: 'Grade0Map', defaultValue: '')
  final String grade0Map;

  factory GradesSettings.fromJson(Map<String, dynamic> json) => _$GradesSettingsFromJson(json);

  Map<String, dynamic> toJson() => _$GradesSettingsToJson(this);
}

@JsonSerializable()
class LessonSettings {
  LessonSettings({
    required this.allowZeroLessonNumber,
    required this.maxLessonNumber,
    required this.isExtramuralCourse,
    required this.isAdultsDaily,
    required this.allowAddOtherLessons,
    required this.allowAddSubstitutions,
  });

  @JsonKey(name: 'AllowZeroLessonNumber', defaultValue: false)
  final bool allowZeroLessonNumber;

  @JsonKey(name: 'MaxLessonNumber', defaultValue: -1)
  final int maxLessonNumber;

  @JsonKey(name: 'IsExtramuralCourse', defaultValue: false)
  final bool isExtramuralCourse;

  @JsonKey(name: 'IsAdultsDaily', defaultValue: false)
  final bool isAdultsDaily;

  @JsonKey(name: 'AllowAddOtherLessons', defaultValue: false)
  final bool allowAddOtherLessons;

  @JsonKey(name: 'AllowAddSubstitutions', defaultValue: false)
  final bool allowAddSubstitutions;

  factory LessonSettings.fromJson(Map<String, dynamic> json) => _$LessonSettingsFromJson(json);

  Map<String, dynamic> toJson() => _$LessonSettingsToJson(this);
}

@JsonSerializable()
class LessonsRange {
  LessonsRange({
    this.from = '08:00',
    this.to = '08:45',
    this.rawFrom = 946713600,
    this.rawTo = 946716300,
  });

  @JsonKey(name: 'From', defaultValue: '08:00')
  final String from;

  @JsonKey(name: 'To', defaultValue: '08:45')
  final String to;

  @JsonKey(name: 'RawFrom', defaultValue: 946713600)
  final int rawFrom;

  @JsonKey(name: 'RawTo', defaultValue: 946716300)
  final int rawTo;

  DateTime get fromTime => from.asTime();
  DateTime get toTime => to.asTime();

  factory LessonsRange.fromJson(Map<String, dynamic> json) => _$LessonsRangeFromJson(json);

  Map<String, dynamic> toJson() => _$LessonsRangeToJson(this);
}

extension DateTimeHourExtension on DateTime {
  DateTime withTime(DateTime? other) =>
      other == null ? this : DateTime(year, month, day, other.hour, other.minute, other.second);
  DateTime asHour([DateTime? other]) => (other ?? DateTime(2000)).withTime(this);
}

extension DateTimeExtension on String {
  DateTime asTime([DateTime? other]) =>
      DateTime.parse("${DateFormat('yyyy-MM-dd').format(DateTime(2000))}T$this").toLocal().asHour(other);
}
