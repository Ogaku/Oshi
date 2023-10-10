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
    required this.id,
    required this.url,
    required this.luckyNumber,
    required this.name,
    required this.principalName,
    required this.address,
    required this.email,
    required this.phone,
    required this.type,
    required this.behaviourType,
    required this.lessonsRange,
    required this.announcements,
    required this.teacherAbsences,
  });

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
