import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import 'package:hive/hive.dart';
part 'averages.g.dart';

@HiveType(typeId: 39)
@JsonSerializable()
class Averages extends Equatable {
  const Averages({this.student = 0.0, this.level = 0.0});

  @HiveField(1)
  final double student;

  @HiveField(2)
  final double level;

  @override
  List<Object> get props => [student, level];

  factory Averages.fromJson(Map<String, dynamic> json) => _$AveragesFromJson(json);

  Map<String, dynamic> toJson() => _$AveragesToJson(this);
}
