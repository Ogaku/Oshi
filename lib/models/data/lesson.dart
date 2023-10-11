// ignore_for_file: curly_braces_in_flow_control_structures

import 'package:json_annotation/json_annotation.dart';
import 'package:ogaku/models/data/class.dart';
import 'package:ogaku/models/data/grade.dart';
import 'package:ogaku/models/data/teacher.dart';

part 'lesson.g.dart';

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

  int id;
  String url;
  String name;
  int no;
  String short;
  bool isExtracurricular;
  bool isBlockLesson;

  Class hostClass;
  Teacher teacher;
  List<Grade> grades;

  Iterable<Grade> get gradesFirstSemester => grades.where((element) => element.semester == 1);
  Iterable<Grade> get gradesSecondSemester => grades.where((element) => element.semester == 2);

  Iterable<Grade> get gradesCurrentSemester =>
      DateTime.now().getDateOnly().isBefore(hostClass.endFirstSemester) ? gradesFirstSemester : gradesSecondSemester;

  bool get hasGrades => grades.isNotEmpty;
  bool get hasGradesCurrentSemester => gradesCurrentSemester.isNotEmpty;

  String get nameExtra => name + (isExtracurricular ? '*' : '');
  double get gradesAverage => grades.where((x) => x.countsToAverage).toList().weightedAverage();

  factory Lesson.fromJson(Map<String, dynamic> json) => _$LessonFromJson(json);

  Map<String, dynamic> toJson() => _$LessonToJson(this);
}

extension DateExtension on DateTime {
  DateTime getDateOnly() {
    return DateTime(year, month, day);
  }
}

extension AverageExtension on List<Grade> {
  double weightedAverage() {
    if (isEmpty) return -1;

    var count = 0;
    double valueSum = 0;
    double weightSum = 0;

    forEach((record) {
      count++;
      valueSum += record.asValue * record.weight;
      weightSum += record.weight;
    });

    switch (count) {
      case 0:
        return -1;
      case 1:
        return first.asValue;
    }

    if (weightSum != 0) return valueSum / weightSum;

    return -1;
  }
}
