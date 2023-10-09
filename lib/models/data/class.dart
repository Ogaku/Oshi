// -- class.dart --
import 'package:json_annotation/json_annotation.dart';
import 'package:szkolny/models/data/event.dart';
import 'package:szkolny/models/data/teacher.dart';
import 'package:szkolny/models/data/unit.dart';

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
    required this.id,
    required this.number,
    required this.symbol,
    required this.name,
    required this.beginSchoolYear,
    required this.endFirstSemester,
    required this.endSchoolYear,
    required this.unit,
    required this.classTutor,
    required this.events,
  });

  String get className => (name?.isEmpty ?? true) ? (number.toString() + symbol) : name!;

  factory Class.fromJson(Map<String, dynamic> json) => _$ClassFromJson(json);

  Map<String, dynamic> toJson() => _$ClassToJson(this);
}
