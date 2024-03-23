import 'package:json_annotation/json_annotation.dart';

part 'homework_categories.g.dart';

@JsonSerializable()
class HomeworkCategories {
  HomeworkCategories({
    required this.categories,
  });

  @JsonKey(name: 'Categories', defaultValue: null)
  final List<Category>? categories;

  factory HomeworkCategories.fromJson(Map<String, dynamic> json) =>
      _$HomeworkCategoriesFromJson(json);

  Map<String, dynamic> toJson() => _$HomeworkCategoriesToJson(this);
}

@JsonSerializable()
class Category {
  Category({
    required this.id,
    required this.teacher,
    required this.categoryName,
  });

  @JsonKey(name: 'Id', defaultValue: -1)
  final int id;

  @JsonKey(name: 'Teacher', defaultValue: null)
  final Teacher? teacher;

  @JsonKey(name: 'CategoryName', defaultValue: '')
  final String categoryName;

  factory Category.fromJson(Map<String, dynamic> json) => _$CategoryFromJson(json);

  Map<String, dynamic> toJson() => _$CategoryToJson(this);
}

@JsonSerializable()
class Teacher {
  Teacher({
    required this.id,
    required this.url,
  });

  @JsonKey(name: 'Id', defaultValue: -1)
  final int id;

  @JsonKey(name: 'Url', defaultValue: '')
  final String url;

  factory Teacher.fromJson(Map<String, dynamic> json) => _$TeacherFromJson(json);

  Map<String, dynamic> toJson() => _$TeacherToJson(this);
}
