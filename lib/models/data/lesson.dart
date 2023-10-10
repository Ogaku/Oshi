// ignore_for_file: curly_braces_in_flow_control_structures

import 'package:json_annotation/json_annotation.dart';
import 'package:ogaku/models/data/class.dart';
import 'package:ogaku/models/data/grade.dart';
import 'package:ogaku/models/data/teacher.dart';

part 'lesson.g.dart';

@JsonSerializable()
class Lesson {
  Lesson({
    required this.id,
    required this.url,
    required this.name,
    required this.no,
    required this.short,
    required this.isExtracurricular,
    required this.isBlockLesson,
    this.hostClass,
    this.teacher,
    this.grades,
  }) {
    grades ??= [];
  }

  int id;
  String url;
  String name;
  int no;
  String short;
  bool isExtracurricular;
  bool isBlockLesson;

  Class? hostClass;
  Teacher? teacher;
  List<Grade>? grades;

  Iterable<Grade> get gradesFirstSemester => grades!.where((element) => element.semester == 1);
  Iterable<Grade> get gradesSecondSemester => grades!.where((element) => element.semester == 2);

  Iterable<Grade> get gradesCurrentSemester =>
      DateTime.now().getDateOnly().isBefore(hostClass?.endFirstSemester ?? DateTime.now())
          ? gradesFirstSemester
          : gradesSecondSemester;

  bool get hasGrades => grades!.isNotEmpty;
  bool get hasGradesCurrentSemester => gradesCurrentSemester.isNotEmpty;

  String get nameExtra => name + (isExtracurricular ? '*' : '');
  double get gradesAverage => grades!.weightedAverage();

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

/*
  public static double WeightedAverage<T>(this IEnumerable<T> records, Func<T, double> value, Func<T, double> weight)
    {
        if (records == null)
            return -1;

        var count = 0;
        double valueSum = 0;
        double weightSum = 0;

        var enumerable = records.ToList();
        foreach (var record in enumerable)
        {
            count++;
            var recordWeight = weight(record);

            valueSum += value(record) * recordWeight;
            weightSum += recordWeight;
        }

        switch (count)
        {
            case 0:
                return -1;
            case 1:
                return value(enumerable.Single());
        }

        if (weightSum != 0)
            return valueSum / weightSum;

        return -1;
    }
 */