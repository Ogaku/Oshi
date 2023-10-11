// -- unit.dart --
import 'package:json_annotation/json_annotation.dart';
import 'package:ogaku/models/data/announcement.dart';
import 'package:ogaku/models/data/event.dart';

part 'unit.g.dart';

@JsonSerializable(includeIfNull: false)
class Unit {
  int id;
  String url;
  int? luckyNumber;
  bool luckyNumberTomorrow;
  String name;
  String principalName;
  String address;
  String email;
  String phone;
  String type;
  String behaviourType;
  List<LessonRanges> lessonsRange;
  List<Announcement>? announcements;
  List<Event>? teacherAbsences;

  Unit({
    this.id = -1,
    this.url = 'https://g.co',
    this.luckyNumber,
    this.name = '',
    this.principalName = '',
    this.address = '',
    this.email = '',
    this.phone = '',
    this.type = '',
    this.behaviourType = '',
    List<LessonRanges>? lessonsRange,
    this.announcements,
    this.teacherAbsences,
    this.luckyNumberTomorrow = false,
  }) : lessonsRange = lessonsRange ?? [];

  factory Unit.fromJson(Map<String, dynamic> json) => _$UnitFromJson(json);

  Map<String, dynamic> toJson() => _$UnitToJson(this);
}

@JsonSerializable()
class LessonRanges {
  DateTime from;
  DateTime to;

  LessonRanges({
    required this.from,
    required this.to,
  });

  factory LessonRanges.fromJson(Map<String, dynamic> json) => _$LessonRangesFromJson(json);

  Map<String, dynamic> toJson() => _$LessonRangesToJson(this);
}
