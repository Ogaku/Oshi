// -- unit.dart --
import 'package:json_annotation/json_annotation.dart';
import 'package:oshi/models/data/announcement.dart';
import 'package:oshi/models/data/event.dart';

import 'package:hive/hive.dart';
part 'unit.g.dart';

@HiveType(typeId: 37)
@JsonSerializable(includeIfNull: false)
class Unit extends HiveObject {
  @HiveField(1)
  int id;

  @HiveField(2)
  String url;

  @HiveField(3)
  int? luckyNumber;

  @HiveField(4)
  bool luckyNumberTomorrow;

  @HiveField(5)
  String name;

  @HiveField(6)
  String principalName;

  @HiveField(7)
  String address;

  @HiveField(8)
  String email;

  @HiveField(9)
  String phone;

  @HiveField(10)
  String type;

  @HiveField(11)
  String behaviourType;

  @HiveField(12)
  List<LessonRanges> lessonsRange;

  @HiveField(13)
  List<Announcement>? announcements;

  @HiveField(14)
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

@HiveType(typeId: 38)
@JsonSerializable()
class LessonRanges extends HiveObject {
  @HiveField(1)
  DateTime from;

  @HiveField(2)
  DateTime to;

  LessonRanges({
    DateTime? from,
    DateTime? to,
  })  : from = from ?? DateTime(2000),
        to = to ?? DateTime(2000);

  factory LessonRanges.fromJson(Map<String, dynamic> json) => _$LessonRangesFromJson(json);

  Map<String, dynamic> toJson() => _$LessonRangesToJson(this);
}
