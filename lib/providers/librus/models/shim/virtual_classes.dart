import 'package:json_annotation/json_annotation.dart';

part 'virtual_classes.g.dart';

@JsonSerializable()
class VirtualClasses {
  VirtualClasses({
    required this.virtualClasses,
  });

  @JsonKey(name: 'VirtualClasses')
  final List<VirtualClass>? virtualClasses;

  factory VirtualClasses.fromJson(Map<String, dynamic> json) => _$VirtualClassesFromJson(json);

  Map<String, dynamic> toJson() => _$VirtualClassesToJson(this);
}

@JsonSerializable()
class VirtualClass {
  VirtualClass({
    required this.id,
    required this.teacher,
    required this.subject,
    required this.name,
    required this.number,
    required this.symbol,
  });

  @JsonKey(name: 'Id')
  final int id;

  @JsonKey(name: 'Teacher')
  final Subject? teacher;

  @JsonKey(name: 'Subject')
  final Subject? subject;

  @JsonKey(name: 'Name')
  final String name;

  @JsonKey(name: 'Number')
  final int number;

  @JsonKey(name: 'Symbol')
  final String symbol;

  factory VirtualClass.fromJson(Map<String, dynamic> json) => _$VirtualClassFromJson(json);

  Map<String, dynamic> toJson() => _$VirtualClassToJson(this);
}

@JsonSerializable()
class Subject {
  Subject({
    required this.id,
    required this.url,
  });

  @JsonKey(name: 'Id')
  final int id;

  @JsonKey(name: 'Url')
  final String url;

  factory Subject.fromJson(Map<String, dynamic> json) => _$SubjectFromJson(json);

  Map<String, dynamic> toJson() => _$SubjectToJson(this);
}
