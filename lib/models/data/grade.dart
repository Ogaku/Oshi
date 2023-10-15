// ignore_for_file: curly_braces_in_flow_control_structures

import 'package:darq/darq.dart';
import 'package:intl/intl.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:ogaku/models/data/teacher.dart';
import 'package:ogaku/share/config.dart';

import 'package:hive/hive.dart';
part 'grade.g.dart';

@HiveType(typeId: 26)
@JsonSerializable()
class Grade extends HiveObject {
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

  @HiveField(0)
  int id;

  @HiveField(1)
  String url;

  @HiveField(2)
  String name;

  @HiveField(3)
  String value;

  @HiveField(4)
  int weight;

  @HiveField(5)
  List<String> comments;

  @HiveField(6)
  bool countsToAverage;

  @HiveField(7)
  DateTime date;

  @HiveField(8)
  DateTime addDate;

  @HiveField(9)
  Teacher addedBy;

  @HiveField(10)
  int semester;

  @HiveField(11)
  bool isConstituent;

  @HiveField(12)
  bool isSemester;

  @HiveField(13)
  bool isSemesterProposition;

  @HiveField(14)
  bool isFinal;

  @HiveField(15)
  bool isFinalProposition;

  String get nameWithWeight => '$name, weight $weight';
  String get addedByString => 'Added by ${addedBy.name}';

  String get detailsDateString =>
      (countsToAverage ? '${weight.toString()} • ' : '') + DateFormat('EEEE, d MMMM y').format(date);

  String get commentsString => comments.select((x, index) => x.replaceAll('\n', ' ').replaceAll('  ', ' ')).join(' • ');

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
