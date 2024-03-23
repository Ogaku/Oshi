import 'package:json_annotation/json_annotation.dart';

part 'classrooms.g.dart';

@JsonSerializable()
class Classrooms {
  Classrooms({
    required this.classrooms,
  });

  @JsonKey(name: 'Classrooms', defaultValue: null)
  final List<Classroom>? classrooms;

  factory Classrooms.fromJson(Map<String, dynamic> json) => _$ClassroomsFromJson(json);

  Map<String, dynamic> toJson() => _$ClassroomsToJson(this);
}

@JsonSerializable(includeIfNull: false)
class Classroom {
  Classroom({
    required this.id,
    required this.name,
    required this.symbol,
    required this.size,
    required this.schoolCommonRoom,
    required this.description,
  });

  @JsonKey(name: 'Id', defaultValue: -1)
  final int id;

  @JsonKey(name: 'Name', defaultValue: '')
  final String name;

  @JsonKey(name: 'Symbol', defaultValue: '')
  final String symbol;

  @JsonKey(name: 'Size', defaultValue: -1)
  final int size;

  @JsonKey(name: 'SchoolCommonRoom', defaultValue: false)
  final bool schoolCommonRoom;

  @JsonKey(name: 'Description', defaultValue: null)
  final String? description;

  factory Classroom.fromJson(Map<String, dynamic> json) => _$ClassroomFromJson(json);

  Map<String, dynamic> toJson() => _$ClassroomToJson(this);
}
