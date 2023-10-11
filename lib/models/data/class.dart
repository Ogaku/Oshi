// -- class.dart --
import 'package:json_annotation/json_annotation.dart';
import 'package:ogaku/models/data/event.dart';
import 'package:ogaku/models/data/teacher.dart';
import 'package:ogaku/models/data/unit.dart';

part 'class.g.dart';

@JsonSerializable(includeIfNull: false)
class Class {
  int id;
  int number;
  String symbol;
  String? name;
  DateTime beginSchoolYear;
  DateTime endFirstSemester;
  DateTime endSchoolYear;
  Unit unit;
  Teacher classTutor;
  List<Event> events;

  Class({
    this.id = -1,
    this.number = -1,
    this.symbol = '',
    this.name = '',
    DateTime? beginSchoolYear,
    DateTime? endFirstSemester,
    DateTime? endSchoolYear,
    Unit? unit,
    Teacher? classTutor,
    List<Event>? events,
  })  : beginSchoolYear = beginSchoolYear ?? DateTime(2000),
        endFirstSemester = endFirstSemester ?? DateTime(2000),
        endSchoolYear = endSchoolYear ?? DateTime(2000),
        unit = unit ?? Unit(),
        classTutor = classTutor ?? Teacher(),
        events = events ?? [];

  String get className => (name?.isEmpty ?? true) ? (number.toString() + symbol) : name!;

  factory Class.fromJson(Map<String, dynamic> json) => _$ClassFromJson(json);

  Map<String, dynamic> toJson() => _$ClassToJson(this);
}
