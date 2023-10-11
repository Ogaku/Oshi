import 'package:json_annotation/json_annotation.dart';

part 'classroom.g.dart';

@JsonSerializable()
class Classroom {
  Classroom({this.id = -1, this.url = 'https://g.co', this.name = '', this.symbol = ''});

  int id;
  String url;
  String name;
  String symbol;

  factory Classroom.fromJson(Map<String, dynamic> json) => _$ClassroomFromJson(json);

  Map<String, dynamic> toJson() => _$ClassroomToJson(this);
}
