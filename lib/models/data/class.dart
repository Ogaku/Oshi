import 'package:json_annotation/json_annotation.dart';
import 'package:oshi/models/data/event.dart';
import 'package:oshi/models/data/teacher.dart';
import 'package:oshi/models/data/unit.dart';

import 'package:hive/hive.dart';
part 'class.g.dart';

@HiveType(typeId: 23)
@JsonSerializable(includeIfNull: false)
class Class {
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

  @HiveField(0)
  final int id;
  
  @HiveField(1)  
  final int number;
  
  @HiveField(2)  
  final String symbol;
  
  @HiveField(3)  
  final String? name;
  
  @HiveField(4)  
  final DateTime beginSchoolYear;
  
  @HiveField(5)  
  final DateTime endFirstSemester;
  
  @HiveField(6)  
  final DateTime endSchoolYear;
  
  @HiveField(7)  
  final Unit unit;
  
  @HiveField(8)  
  final Teacher classTutor;
  
  @HiveField(9)  
  List<Event> events;

  String get className => (name?.isEmpty ?? true) ? (number.toString() + symbol) : name!;

  factory Class.fromJson(Map<String, dynamic> json) => _$ClassFromJson(json);

  Map<String, dynamic> toJson() => _$ClassToJson(this);
}
