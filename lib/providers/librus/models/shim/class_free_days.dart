import 'package:json_annotation/json_annotation.dart';

part 'class_free_days.g.dart';

@JsonSerializable()
class ClassFreeDays {
  ClassFreeDays({
    required this.classFreeDays,
  });

  @JsonKey(name: 'ClassFreeDays', defaultValue: null)
  final List<ClassFreeDay>? classFreeDays;

  factory ClassFreeDays.fromJson(Map<String, dynamic> json) => _$ClassFreeDaysFromJson(json);

  Map<String, dynamic> toJson() => _$ClassFreeDaysToJson(this);
}

@JsonSerializable()
class ClassFreeDay {
  ClassFreeDay({
    required this.id,
    this.classFreeDayClass,
    this.type,
    this.dateFrom,
    this.dateTo,
    this.lessonNoFrom,
    this.lessonNoTo,
    this.virtualClass,
  });

  @JsonKey(name: 'Id', defaultValue: -1)
  final int id;

  @JsonKey(name: 'Class', defaultValue: null)
  final Class? classFreeDayClass;

  @JsonKey(name: 'Type', defaultValue: null)
  final Class? type;

  @JsonKey(name: 'DateFrom', defaultValue: null)
  final DateTime? dateFrom;

  @JsonKey(name: 'DateTo', defaultValue: null)
  final DateTime? dateTo;

  @JsonKey(name: 'LessonNoFrom', defaultValue: null)
  final int? lessonNoFrom;

  @JsonKey(name: 'LessonNoTo', defaultValue: null)
  final int? lessonNoTo;

  @JsonKey(name: 'VirtualClass', defaultValue: null)
  final Class? virtualClass;

  factory ClassFreeDay.fromJson(Map<String, dynamic> json) => _$ClassFreeDayFromJson(json);

  Map<String, dynamic> toJson() => _$ClassFreeDayToJson(this);
}

@JsonSerializable()
class Class {
  Class({
    required this.id,
    required this.url,
  });

  @JsonKey(name: 'Id', defaultValue: -1)
  final int id;

  @JsonKey(name: 'Url', defaultValue: '')
  final String url;

  factory Class.fromJson(Map<String, dynamic> json) => _$ClassFromJson(json);

  Map<String, dynamic> toJson() => _$ClassToJson(this);
}
