import 'package:json_annotation/json_annotation.dart';

part 'free_days.g.dart';

@JsonSerializable()
class SchoolFreeDays {
  SchoolFreeDays({
    required this.schoolFreeDays,
  });

  @JsonKey(name: 'SchoolFreeDays', defaultValue: null)
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

  @JsonKey(name: 'Id', defaultValue: -1)
  final int id;

  @JsonKey(name: 'Name', defaultValue: '')
  final String name;

  @JsonKey(name: 'DateFrom', defaultValue: null)
  final DateTime? dateFrom;

  @JsonKey(name: 'DateTo', defaultValue: null)
  final DateTime? dateTo;

  @JsonKey(name: 'Units', defaultValue: null)
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

  @JsonKey(name: 'Id', defaultValue: -1)
  final int id;

  @JsonKey(name: 'Url', defaultValue: '')
  final String url;

  factory Unit.fromJson(Map<String, dynamic> json) => _$UnitFromJson(json);

  Map<String, dynamic> toJson() => _$UnitToJson(this);
}
