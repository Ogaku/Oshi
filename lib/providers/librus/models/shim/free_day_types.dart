import 'package:json_annotation/json_annotation.dart';

part 'free_day_types.g.dart';

@JsonSerializable()
class FreeDayTypes {
  FreeDayTypes({
    required this.types,
  });

  @JsonKey(name: 'Types', defaultValue: null)
  final List<Type>? types;

  factory FreeDayTypes.fromJson(Map<String, dynamic> json) => _$FreeDayTypesFromJson(json);

  Map<String, dynamic> toJson() => _$FreeDayTypesToJson(this);
}

@JsonSerializable()
class Type {
  Type({
    required this.id,
    required this.name,
  });

  @JsonKey(name: 'Id', defaultValue: -1)
  final int id;

  @JsonKey(name: 'Name', defaultValue: '')
  final String name;

  factory Type.fromJson(Map<String, dynamic> json) => _$TypeFromJson(json);

  Map<String, dynamic> toJson() => _$TypeToJson(this);
}
