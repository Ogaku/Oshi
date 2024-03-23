// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'student_unit.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StudentUnit _$StudentUnitFromJson(Map<String, dynamic> json) => StudentUnit(
      unit: json['Unit'] == null
          ? null
          : Unit.fromJson(json['Unit'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$StudentUnitToJson(StudentUnit instance) =>
    <String, dynamic>{
      'Unit': instance.unit,
    };

Unit _$UnitFromJson(Map<String, dynamic> json) => Unit(
      id: json['Id'] as int? ?? -1,
      name: json['Name'] as String? ?? '',
      shortName: json['ShortName'] as String? ?? '',
      type: json['Type'] as String? ?? '',
      behaviourType: json['BehaviourType'] as String? ?? '',
      gradesSettings: json['GradesSettings'] == null
          ? null
          : GradesSettings.fromJson(
              json['GradesSettings'] as Map<String, dynamic>),
      lessonSettings: json['LessonSettings'] == null
          ? null
          : LessonSettings.fromJson(
              json['LessonSettings'] as Map<String, dynamic>),
      lessonsRange: (json['LessonsRange'] as List<dynamic>?)
          ?.map((e) => LessonsRange.fromJson(e as Map<String, dynamic>))
          .toList(),
      behaviourGradesSettings: json['BehaviourGradesSettings'] == null
          ? null
          : BehaviourGradesSettings.fromJson(
              json['BehaviourGradesSettings'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$UnitToJson(Unit instance) => <String, dynamic>{
      'Id': instance.id,
      'Name': instance.name,
      'ShortName': instance.shortName,
      'Type': instance.type,
      'BehaviourType': instance.behaviourType,
      'GradesSettings': instance.gradesSettings,
      'LessonSettings': instance.lessonSettings,
      'LessonsRange': instance.lessonsRange,
      'BehaviourGradesSettings': instance.behaviourGradesSettings,
    };

BehaviourGradesSettings _$BehaviourGradesSettingsFromJson(
        Map<String, dynamic> json) =>
    BehaviourGradesSettings(
      startPoints: json['StartPoints'] == null
          ? null
          : StartPoints.fromJson(json['StartPoints'] as Map<String, dynamic>),
      showCategoriesShortcuts: json['ShowCategoriesShortcuts'] as bool,
    );

Map<String, dynamic> _$BehaviourGradesSettingsToJson(
        BehaviourGradesSettings instance) =>
    <String, dynamic>{
      'StartPoints': instance.startPoints,
      'ShowCategoriesShortcuts': instance.showCategoriesShortcuts,
    };

StartPoints _$StartPointsFromJson(Map<String, dynamic> json) => StartPoints(
      semester1: json['Semester1'] as int? ?? -1,
      semester2: json['Semester2'] as int? ?? -2,
    );

Map<String, dynamic> _$StartPointsToJson(StartPoints instance) =>
    <String, dynamic>{
      'Semester1': instance.semester1,
      'Semester2': instance.semester2,
    };

GradesSettings _$GradesSettingsFromJson(Map<String, dynamic> json) =>
    GradesSettings(
      standardGradesEnabled: json['StandardGradesEnabled'] as bool? ?? false,
      pointGradesEnabled: json['PointGradesEnabled'] as bool? ?? false,
      descriptiveGradesEnabled:
          json['DescriptiveGradesEnabled'] as bool? ?? false,
      forcePointGradesDictionaries:
          json['ForcePointGradesDictionaries'] as bool? ?? false,
      allowOverrangePointGrades:
          json['AllowOverrangePointGrades'] as bool? ?? false,
      allowClassTutorEditGrades:
          json['AllowClassTutorEditGrades'] as bool? ?? false,
      canAddAnyGrades: json['CanAddAnyGrades'] as bool? ?? false,
      grade0Map: json['Grade0Map'] as String? ?? '',
    );

Map<String, dynamic> _$GradesSettingsToJson(GradesSettings instance) =>
    <String, dynamic>{
      'StandardGradesEnabled': instance.standardGradesEnabled,
      'PointGradesEnabled': instance.pointGradesEnabled,
      'DescriptiveGradesEnabled': instance.descriptiveGradesEnabled,
      'ForcePointGradesDictionaries': instance.forcePointGradesDictionaries,
      'AllowOverrangePointGrades': instance.allowOverrangePointGrades,
      'AllowClassTutorEditGrades': instance.allowClassTutorEditGrades,
      'CanAddAnyGrades': instance.canAddAnyGrades,
      'Grade0Map': instance.grade0Map,
    };

LessonSettings _$LessonSettingsFromJson(Map<String, dynamic> json) =>
    LessonSettings(
      allowZeroLessonNumber: json['AllowZeroLessonNumber'] as bool? ?? false,
      maxLessonNumber: json['MaxLessonNumber'] as int? ?? -1,
      isExtramuralCourse: json['IsExtramuralCourse'] as bool? ?? false,
      isAdultsDaily: json['IsAdultsDaily'] as bool? ?? false,
      allowAddOtherLessons: json['AllowAddOtherLessons'] as bool? ?? false,
      allowAddSubstitutions: json['AllowAddSubstitutions'] as bool? ?? false,
    );

Map<String, dynamic> _$LessonSettingsToJson(LessonSettings instance) =>
    <String, dynamic>{
      'AllowZeroLessonNumber': instance.allowZeroLessonNumber,
      'MaxLessonNumber': instance.maxLessonNumber,
      'IsExtramuralCourse': instance.isExtramuralCourse,
      'IsAdultsDaily': instance.isAdultsDaily,
      'AllowAddOtherLessons': instance.allowAddOtherLessons,
      'AllowAddSubstitutions': instance.allowAddSubstitutions,
    };

LessonsRange _$LessonsRangeFromJson(Map<String, dynamic> json) => LessonsRange(
      from: json['From'] as String? ?? '08:00',
      to: json['To'] as String? ?? '08:45',
      rawFrom: json['RawFrom'] as int? ?? 946713600,
      rawTo: json['RawTo'] as int? ?? 946716300,
    );

Map<String, dynamic> _$LessonsRangeToJson(LessonsRange instance) =>
    <String, dynamic>{
      'From': instance.from,
      'To': instance.to,
      'RawFrom': instance.rawFrom,
      'RawTo': instance.rawTo,
    };
