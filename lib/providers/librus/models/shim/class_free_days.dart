import 'package:json_annotation/json_annotation.dart';

part 'class_free_days.g.dart';

@JsonSerializable()
class ClassFreeDays {
  ClassFreeDays({
    required this.classFreeDays,
  });

  @JsonKey(name: 'ClassFreeDays')
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

  @JsonKey(name: 'Id')
  final int id;

  @JsonKey(name: 'Class')
  final Class? classFreeDayClass;

  @JsonKey(name: 'Type')
  final Class? type;

  @JsonKey(name: 'DateFrom')
  final DateTime? dateFrom;

  @JsonKey(name: 'DateTo')
  final DateTime? dateTo;

  @JsonKey(name: 'LessonNoFrom')
  final int? lessonNoFrom;

  @JsonKey(name: 'LessonNoTo')
  final int? lessonNoTo;

  @JsonKey(name: 'VirtualClass')
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

  @JsonKey(name: 'Id')
  final int id;

  @JsonKey(name: 'Url')
  final String url;

  factory Class.fromJson(Map<String, dynamic> json) => _$ClassFromJson(json);

  Map<String, dynamic> toJson() => _$ClassToJson(this);
}
