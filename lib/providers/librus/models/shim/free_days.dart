import 'package:json_annotation/json_annotation.dart';

part 'free_days.g.dart';

@JsonSerializable()
class SchoolFreeDays {
  SchoolFreeDays({
    required this.schoolFreeDays,
  });

  @JsonKey(name: 'SchoolFreeDays')
  final List<SchoolFreeDay>? schoolFreeDays;

  factory SchoolFreeDays.fromJson(Map<String, dynamic> json) => _$SchoolFreeDaysFromJson(json);

  Map<String, dynamic> toJson() => _$SchoolFreeDaysToJson(this);
}

@JsonSerializable()
class SchoolFreeDay {
  SchoolFreeDay({
    required this.id,
    required this.name,
    required this.dateFrom,
    required this.dateTo,
    required this.units,
  });

  @JsonKey(name: 'Id')
  final int id;

  @JsonKey(name: 'Name')
  final String name;

  @JsonKey(name: 'DateFrom')
  final DateTime? dateFrom;

  @JsonKey(name: 'DateTo')
  final DateTime? dateTo;

  @JsonKey(name: 'Units')
  final List<Unit>? units;

  factory SchoolFreeDay.fromJson(Map<String, dynamic> json) => _$SchoolFreeDayFromJson(json);

  Map<String, dynamic> toJson() => _$SchoolFreeDayToJson(this);
}

@JsonSerializable()
class Unit {
  Unit({
    required this.id,
    required this.url,
  });

  @JsonKey(name: 'Id')
  final int id;

  @JsonKey(name: 'Url')
  final String url;

  factory Unit.fromJson(Map<String, dynamic> json) => _$UnitFromJson(json);

  Map<String, dynamic> toJson() => _$UnitToJson(this);
}
