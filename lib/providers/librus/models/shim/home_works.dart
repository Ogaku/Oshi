import 'package:json_annotation/json_annotation.dart';

part 'home_works.g.dart';

@JsonSerializable()
class HomeWorks {
  HomeWorks({
    required this.homeWorks,
  });

  @JsonKey(name: 'HomeWorks')
  final List<HomeWork>? homeWorks;

  factory HomeWorks.fromJson(Map<String, dynamic> json) => _$HomeWorksFromJson(json);

  Map<String, dynamic> toJson() => _$HomeWorksToJson(this);
}

@JsonSerializable()
class HomeWork {
  HomeWork({
    required this.id,
    required this.content,
    required this.date,
    required this.category,
    this.lessonNo,
    required this.timeFrom,
    required this.timeTo,
    required this.createdBy,
    required this.homeWorkClass,
    required this.classroom,
    required this.addDate,
    required this.subject,
    required this.virtualClass,
  });

  @JsonKey(name: 'Id')
  final int id;

  @JsonKey(name: 'Content')
  final String content;

  @JsonKey(name: 'Date')
  final DateTime? date;

  @JsonKey(name: 'Category')
  final Category? category;

  @JsonKey(name: 'LessonNo')
  final String? lessonNo;

  @JsonKey(name: 'TimeFrom')
  final String timeFrom;

  @JsonKey(name: 'TimeTo')
  final String timeTo;

  @JsonKey(name: 'CreatedBy')
  final Category? createdBy;

  @JsonKey(name: 'Class')
  final Category? homeWorkClass;

  @JsonKey(name: 'Classroom')
  final Classroom? classroom;

  @JsonKey(name: 'AddDate')
  final DateTime? addDate;

  @JsonKey(name: 'Subject')
  final Category? subject;

  @JsonKey(name: 'VirtualClass')
  final Category? virtualClass;

  factory HomeWork.fromJson(Map<String, dynamic> json) => _$HomeWorkFromJson(json);

  Map<String, dynamic> toJson() => _$HomeWorkToJson(this);
}

@JsonSerializable()
class Category {
  Category({
    required this.id,
    required this.url,
  });

  @JsonKey(name: 'Id')
  final int id;

  @JsonKey(name: 'Url')
  final String url;

  factory Category.fromJson(Map<String, dynamic> json) => _$CategoryFromJson(json);

  Map<String, dynamic> toJson() => _$CategoryToJson(this);
}

@JsonSerializable()
class Classroom {
  Classroom({
    required this.id,
    required this.symbol,
    required this.name,
    required this.size,
  });

  @JsonKey(name: 'Id')
  final int id;

  @JsonKey(name: 'Symbol')
  final String symbol;

  @JsonKey(name: 'Name')
  final String name;

  @JsonKey(name: 'Size')
  final int size;

  factory Classroom.fromJson(Map<String, dynamic> json) => _$ClassroomFromJson(json);

  Map<String, dynamic> toJson() => _$ClassroomToJson(this);
}
