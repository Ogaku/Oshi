// ignore_for_file: curly_braces_in_flow_control_structures

import 'package:json_annotation/json_annotation.dart';
import 'package:ogaku/models/data/teacher.dart';
import 'package:ogaku/share/config.dart';

part 'grade.g.dart';

@JsonSerializable()
class Grade {
  Grade({
    this.id = -1,
    this.url = 'https://g.co',
    this.name = '',
    this.value = '',
    this.weight = 0,
    List<String>? comments,
    this.countsToAverage = false,
    DateTime? date,
    DateTime? addDate,
    Teacher? addedBy,
    this.semester = 1,
    this.isConstituent = false,
    this.isSemester = false,
    this.isSemesterProposition = false,
    this.isFinal = false,
    this.isFinalProposition = false,
  })  : comments = comments ?? [],
        date = date ?? DateTime(2000),
        addDate = addDate ?? DateTime(2000),
        addedBy = addedBy ?? Teacher();

  int id;
  String url;
  String name;
  String value;
  int weight;
  List<String> comments;
  bool countsToAverage;
  DateTime date;
  DateTime addDate;
  Teacher addedBy;
  int semester;
  bool isConstituent;
  bool isSemester;
  bool isSemesterProposition;
  bool isFinal;
  bool isFinalProposition;

  String get nameWithWeight => '$name, weight $weight';
  String get addedByString => 'Added by ${addedBy.name}';

  double get asValue {
    double val = switch (value) {
          _ when (Config.customGradeValues?.containsKey(value) ?? false) => Config.customGradeValues![value],
          '1' => 1,
          '2' => 2,
          '3' => 3,
          '4' => 4,
          '5' => 5,
          '6' => 6,
          _ => -1
        } ??
        -1;

    try {
      // Handle all 6+, 1-, 5+ grade string values
      if ((Config.customGradeModifierValues?.containsKey(value[value.length - 1]) ?? false) &&
          !(Config.customGradeValues?.containsKey(value) ?? false))
        val += (Config.customGradeValues?[value[value.length - 1]] ?? 0);
    } catch (ex) {
      // ignored
    }

    return val;
  }

  factory Grade.fromJson(Map<String, dynamic> json) => _$GradeFromJson(json);

  Map<String, dynamic> toJson() => _$GradeToJson(this);
}
