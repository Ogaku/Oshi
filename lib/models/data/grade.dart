// ignore_for_file: curly_braces_in_flow_control_structures

import 'package:darq/darq.dart';
import 'package:intl/intl.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:oshi/models/data/teacher.dart';

import 'package:hive/hive.dart';
import 'package:oshi/share/share.dart';

part 'grade.g.dart';

Map<String, double> get _customGradeModifierValues {
  var values = {...Share.settings.config.customGradeModifierValues};
  values.update('+', (value) => value, ifAbsent: () => 0.5);
  values.update('-', (value) => value, ifAbsent: () => -0.25);
  return values;
}

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

  @JsonKey(includeToJson: false, includeFromJson: false)
  String get nameWithWeight => '$name, weight $weight';

  @JsonKey(includeToJson: false, includeFromJson: false)
  String get addedByString => 'Added by ${addedBy.name}';

  @JsonKey(includeToJson: false, includeFromJson: false)
  String get detailsDateString =>
      (countsToAverage ? '${weight.toString()} • ' : '') + DateFormat('EEEE, d MMMM y').format(date);

  @JsonKey(includeToJson: false, includeFromJson: false)
  String get addedDateString => "${addedBy.name} • ${DateFormat('d.M.y').format(date)}";

  @JsonKey(includeToJson: false, includeFromJson: false)
  String get commentsString => comments.select((x, index) => x.replaceAll('\n', ' ').replaceAll('  ', ' ')).join(' • ');

  @JsonKey(includeToJson: false, includeFromJson: false)
  double get asValue {
    double val = switch (value.isNotEmpty ? value[0] : value) {
          _ when (Share.settings.config.customGradeValues.containsKey(value)) =>
            Share.settings.config.customGradeValues[value],
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
      if ((_customGradeModifierValues.containsKey(value[value.length - 1])) &&
          !(Share.settings.config.customGradeValues.containsKey(value)))
        val += (_customGradeModifierValues[value[value.length - 1]] ?? 0);
    } catch (ex) {
      // ignored
    }

    return val;
  }

  factory Grade.fromJson(Map<String, dynamic> json) => _$GradeFromJson(json);

  Map<String, dynamic> toJson() => _$GradeToJson(this);
}
