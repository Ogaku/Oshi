import 'package:json_annotation/json_annotation.dart';

part 'home_works.g.dart';

@JsonSerializable()
class HomeWorks {
  HomeWorks({
    required this.homeWorks,
  });

  @JsonKey(name: 'HomeWorks', defaultValue: null)
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

  @JsonKey(name: 'Id', defaultValue: -1)
  final int id;

  @JsonKey(name: 'Content', defaultValue: '')
  final String content;

  @JsonKey(name: 'Date', defaultValue: null)
  final DateTime? date;

  @JsonKey(name: 'Category', defaultValue: null)
  final Category? category;

  @JsonKey(name: 'LessonNo', defaultValue: null)
  final String? lessonNo;

  @JsonKey(name: 'TimeFrom', defaultValue: '')
  final String timeFrom;

  @JsonKey(name: 'TimeTo', defaultValue: '')
  final String timeTo;

  @JsonKey(name: 'CreatedBy', defaultValue: null)
  final Category? createdBy;

  @JsonKey(name: 'Class', defaultValue: null)
  final Category? homeWorkClass;

  @JsonKey(name: 'Classroom', defaultValue: null)
  final Classroom? classroom;

  @JsonKey(name: 'AddDate', defaultValue: null)
  final DateTime? addDate;

  @JsonKey(name: 'Subject', defaultValue: null)
  final Category? subject;

  @JsonKey(name: 'VirtualClass', defaultValue: null)
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

  @JsonKey(name: 'Id', defaultValue: -1)
  final int id;

  @JsonKey(name: 'Url', defaultValue: '')
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

  @JsonKey(name: 'Id', defaultValue: -1)
  final int id;

  @JsonKey(name: 'Symbol', defaultValue: '')
  final String symbol;

  @JsonKey(name: 'Name', defaultValue: '')
  final String name;

  @JsonKey(name: 'Size', defaultValue: -1)
  final int size;

  factory Classroom.fromJson(Map<String, dynamic> json) => _$ClassroomFromJson(json);

  Map<String, dynamic> toJson() => _$ClassroomToJson(this);
}
