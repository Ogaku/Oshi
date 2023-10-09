import 'package:intl/intl.dart';
import 'package:json_annotation/json_annotation.dart';

part 'student_unit.g.dart';

@JsonSerializable()
class StudentUnit {
  StudentUnit({
    required this.unit,
  });

  @JsonKey(name: 'Unit')
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

  @JsonKey(name: 'Id')
  final int id;

  @JsonKey(name: 'Name')
  final String name;

  @JsonKey(name: 'ShortName')
  final String shortName;

  @JsonKey(name: 'Type')
  final String type;

  @JsonKey(name: 'BehaviourType')
  final String behaviourType;

  @JsonKey(name: 'GradesSettings')
  final GradesSettings? gradesSettings;

  @JsonKey(name: 'LessonSettings')
  final LessonSettings? lessonSettings;

  @JsonKey(name: 'LessonsRange')
  final List<LessonsRange>? lessonsRange;

  @JsonKey(name: 'BehaviourGradesSettings')
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

  @JsonKey(name: 'StartPoints')
  final StartPoints? startPoints;

  @JsonKey(name: 'ShowCategoriesShortcuts')
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

  @JsonKey(name: 'Semester1')
  final int semester1;

  @JsonKey(name: 'Semester2')
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
    required this.grade0Map,
  });

  @JsonKey(name: 'StandardGradesEnabled')
  final bool standardGradesEnabled;

  @JsonKey(name: 'PointGradesEnabled')
  final bool pointGradesEnabled;

  @JsonKey(name: 'DescriptiveGradesEnabled')
  final bool descriptiveGradesEnabled;

  @JsonKey(name: 'ForcePointGradesDictionaries')
  final bool forcePointGradesDictionaries;

  @JsonKey(name: 'AllowOverrangePointGrades')
  final bool allowOverrangePointGrades;

  @JsonKey(name: 'AllowClassTutorEditGrades')
  final bool allowClassTutorEditGrades;

  @JsonKey(name: 'CanAddAnyGrades')
  final bool canAddAnyGrades;

  @JsonKey(name: 'Grade0Map')
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

  @JsonKey(name: 'AllowZeroLessonNumber')
  final bool allowZeroLessonNumber;

  @JsonKey(name: 'MaxLessonNumber')
  final int maxLessonNumber;

  @JsonKey(name: 'IsExtramuralCourse')
  final bool isExtramuralCourse;

  @JsonKey(name: 'IsAdultsDaily')
  final bool isAdultsDaily;

  @JsonKey(name: 'AllowAddOtherLessons')
  final bool allowAddOtherLessons;

  @JsonKey(name: 'AllowAddSubstitutions')
  final bool allowAddSubstitutions;

  factory LessonSettings.fromJson(Map<String, dynamic> json) => _$LessonSettingsFromJson(json);

  Map<String, dynamic> toJson() => _$LessonSettingsToJson(this);
}

@JsonSerializable()
class LessonsRange {
  LessonsRange({
    required this.from,
    required this.to,
    required this.rawFrom,
    required this.rawTo,
  });

  @JsonKey(name: 'From')
  final String from;

  @JsonKey(name: 'To')
  final String to;

  @JsonKey(name: 'RawFrom')
  final int rawFrom;

  @JsonKey(name: 'RawTo')
  final int rawTo;

  DateTime get fromTime => from.asTime();
  DateTime get toTime => to.asTime();

  factory LessonsRange.fromJson(Map<String, dynamic> json) => _$LessonsRangeFromJson(json);

  Map<String, dynamic> toJson() => _$LessonsRangeToJson(this);
}

extension DateTimeExtension on String {
  DateTime asTime() => DateTime.parse("${DateFormat('yyyy-MM-dd').format(DateTime.now())}T$this").toLocal();
}
