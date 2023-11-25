// ignore_for_file: curly_braces_in_flow_control_structures

import 'package:darq/darq.dart';
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
class Lesson {
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
        teacher = teacher ?? Teacher(),
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

  Iterable<Grade> get gradesFirstSemester => grades.where((element) => element.semester == 1);
  Iterable<Grade> get gradesSecondSemester => grades.where((element) => element.semester == 2);

  Iterable<Grade> get gradesCurrentSemester =>
      DateTime.now().getDateOnly().isBefore(hostClass.endFirstSemester) ? gradesFirstSemester : gradesSecondSemester;

  bool get hasGrades => grades.isNotEmpty;
  bool get hasGradesCurrentSemester => gradesCurrentSemester.isNotEmpty;

  String get nameExtra => name + (isExtracurricular ? '*' : '');
  double get gradesAverage => grades
      .where((x) => x.countsToAverage && x.asValue >= 0)
      .toList()
      .gadesAverage(weighted: Share.session.settings.weightedAverage, adapt: Share.session.settings.autoArithmeticAverage);

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
