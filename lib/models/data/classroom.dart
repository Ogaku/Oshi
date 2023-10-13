import 'package:json_annotation/json_annotation.dart';

import 'package:hive/hive.dart';
part 'classroom.g.dart';

@HiveType(typeId: 24)
@JsonSerializable()
class Classroom extends HiveObject {
  Classroom({this.id = -1, this.url = 'https://g.co', this.name = '', this.symbol = ''});

  @HiveField(0)
  int id;
  
  @HiveField(1)
  String url;
  
  @HiveField(2)
  String name;
  
  @HiveField(3)
  String symbol;

  factory Classroom.fromJson(Map<String, dynamic> json) => _$ClassroomFromJson(json);

  Map<String, dynamic> toJson() => _$ClassroomToJson(this);
}
