// ignore_for_file: curly_braces_in_flow_control_structures

import 'package:darq/darq.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:oshi/models/data/class.dart';
import 'package:oshi/models/data/grade.dart';
import 'package:oshi/models/data/teacher.dart';

import 'package:hive/hive.dart';
import 'package:oshi/share/resources.dart';
import 'package:oshi/share/share.dart';
part 'lesson.g.dart';

@HiveType(typeId: 27)
@JsonSerializable()
class Lesson extends Equatable {
  Lesson({
    this.id = -1,
    this.url = 'https://g.co',
    this.name = '',
    this.no = -1,
    this.short = '',
    this.isExtracurricular = false,
    this.isBlockLesson = false,
    Class? hostClass,
    Teacher? teacher,
    List<Grade>? grades,
  })  : hostClass = hostClass ?? Class(),
        teacher = teacher ?? const Teacher(),
        grades = grades ?? [];

  @HiveField(1)
  final int id;

  @HiveField(2)
  final String url;

  @HiveField(3)
  final String name;

  @HiveField(4)
  final int no;

  @HiveField(5)
  final String short;

  @HiveField(6)
  final bool isExtracurricular;

  @HiveField(7)
  final bool isBlockLesson;

  @HiveField(8)
  final Class hostClass;

  @HiveField(9)
  final Teacher teacher;

  @HiveField(10)
  final List<Grade> grades;

  @JsonKey(includeToJson: false, includeFromJson: false)
  List<Grade> get allGrades => grades
      .appendAll(Share.session.customGrades.containsKey(this) ? (Share.session.customGrades[this] ?? []) : [])
      .toList();

  @JsonKey(includeToJson: false, includeFromJson: false)
  Iterable<Grade> get gradesFirstSemester => allGrades.where((element) => element.semester == 1);

  @JsonKey(includeToJson: false, includeFromJson: false)
  Iterable<Grade> get gradesSecondSemester => allGrades.where((element) => element.semester == 2);

  @JsonKey(includeToJson: false, includeFromJson: false)
  Iterable<Grade> get gradesCurrentSemester =>
      DateTime.now().getDateOnly().isBefore(hostClass.endFirstSemester) ? gradesFirstSemester : gradesSecondSemester;

  @JsonKey(includeToJson: false, includeFromJson: false)
  bool get hasGrades => allGrades.isNotEmpty;

  @JsonKey(includeToJson: false, includeFromJson: false)
  bool get hasGradesCurrentSemester => gradesCurrentSemester.isNotEmpty;

  @JsonKey(includeToJson: false, includeFromJson: false)
  String get nameExtra => name + (isExtracurricular ? '*' : '');

  @JsonKey(includeToJson: false, includeFromJson: false)
  double get gradesAverage => allGrades
      .where((x) => x.countsToAverage && x.asValue >= 0)
      .toList()
      .gadesAverage(weighted: Share.session.settings.weightedAverage, adapt: Share.session.settings.autoArithmeticAverage);

  @JsonKey(includeToJson: false, includeFromJson: false)
  double get gradesSemAverage => allGrades
      .where((x) => x.countsToAverage && x.asValue >= 0 && x.semester == 1)
      .toList()
      .gadesAverage(weighted: Share.session.settings.weightedAverage, adapt: Share.session.settings.autoArithmeticAverage);

  @JsonKey(includeToJson: false, includeFromJson: false)
  bool get hasUnseen => allGrades.any((x) => x.unseen);

  @JsonKey(includeToJson: false, includeFromJson: false)
  bool get hasMajor => topMajor != null;

  @JsonKey(includeToJson: false, includeFromJson: false)
  Grade? get topMajor => allGrades.any((x) => x.semester > 1)
      ? (allGrades.firstWhereOrDefault((x) => x.isFinal) ?? allGrades.firstWhereOrDefault((x) => x.isFinalProposition))
      : (allGrades.firstWhereOrDefault((x) => x.isSemester) ?? allGrades.firstWhereOrDefault((x) => x.isSemesterProposition));

  @JsonKey(includeToJson: false, includeFromJson: false)
  int get unseenCount => allGrades.count((x) => x.unseen);

  @override
  List<Object> get props => [
        id,
        url,
        name,
        no,
        short,
        isExtracurricular,
        isBlockLesson,
        teacher,
      ];

  factory Lesson.fromJson(Map<String, dynamic> json) => _$LessonFromJson(json);

  Map<String, dynamic> toJson() => _$LessonToJson(this);
}

extension DateExtension on DateTime {
  DateTime getDateOnly() {
    return DateTime(year, month, day);
  }
}

extension AverageExtension on List<Grade> {
  double gadesAverage({required bool weighted, required bool adapt}) {
    /* Weighted or arithmetic average generator */
    double average(bool weighted, bool adapt, {bool firstSemester = true, bool secondSemester = true}) {
      if (isEmpty) return -1;

      var count = 0;
      bool weightedTmp = weighted;
      double valueSum = 0;
      double weightSum = 0;

      var semesterSelector =
          where((x) => (firstSemester ? (x.semester == 1) : false) || (secondSemester ? (x.semester == 2) : false));

      if (adapt && semesterSelector.all((x) => x.weight == 0)) weightedTmp = false;

      for (var record in semesterSelector) {
        count++;
        valueSum += record.asValue * (weightedTmp ? record.weight : 1);
        weightSum += (weightedTmp ? record.weight : 1);
      }

      switch (count) {
        case 0:
          return -100;
        case 1:
          return first.asValue;
      }

      if (weightSum != 0) return valueSum / weightSum;

      return -100;
    }

    /* Return the average, depending on the selected configuration */
    return switch (Share.session.settings.yearlyAverageMethod) {
      YearlyAverageMethods.allGradesAverage => average(weighted, adapt),
      YearlyAverageMethods.averagesAverage =>
        (average(weighted, adapt, secondSemester: false) + average(weighted, adapt, firstSemester: false)) / 2.0,
      YearlyAverageMethods.finalPlusAverage => ((firstWhereOrDefault((x) =>
                          x.semester == 2 && (x.isSemesterProposition || x.isSemester || x.isFinalProposition || x.isFinal))
                      ?.asValue ??
                  -1) +
              average(weighted, adapt, firstSemester: false)) /
          2.0,
      YearlyAverageMethods.averagePlusFinal => ((firstWhereOrDefault((x) =>
                          x.semester == 1 && (x.isSemesterProposition || x.isSemester || x.isFinalProposition || x.isFinal))
                      ?.asValue ??
                  -1) +
              average(weighted, adapt, secondSemester: false)) /
          2.0,
      YearlyAverageMethods.finalsAverage => ((firstWhereOrDefault((x) =>
                          x.semester == 1 && (x.isSemesterProposition || x.isSemester || x.isFinalProposition || x.isFinal))
                      ?.asValue ??
                  -1) +
              (firstWhereOrDefault((x) =>
                          x.semester == 2 && (x.isSemesterProposition || x.isSemester || x.isFinalProposition || x.isFinal))
                      ?.asValue ??
                  -1)) /
          2.0,
    };
  }
}
