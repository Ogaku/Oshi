import 'package:json_annotation/json_annotation.dart';

part 'grade_categories.g.dart';

@JsonSerializable()
class GradeCategories {
  GradeCategories({
    required this.categories,
  });

  @JsonKey(name: 'Categories')
  final List<Category>? categories;

  factory GradeCategories.fromJson(Map<String, dynamic> json) => _$GradeCategoriesFromJson(json);

  Map<String, dynamic> toJson() => _$GradeCategoriesToJson(this);
}

@JsonSerializable(includeIfNull: false)
class Category {
  Category({
    required this.id,
    required this.color,
    required this.name,
    required this.countToTheAverage,
    this.weight,
  });

  @JsonKey(name: 'Id')
  final int id;

  @JsonKey(name: 'Color')
  final Color? color;

  @JsonKey(name: 'Name')
  final String name;

  @JsonKey(name: 'CountToTheAverage')
  final bool countToTheAverage;

  @JsonKey(name: 'Weight')
  final int? weight;

  factory Category.fromJson(Map<String, dynamic> json) => _$CategoryFromJson(json);

  Map<String, dynamic> toJson() => _$CategoryToJson(this);
}

@JsonSerializable()
class Color {
  Color({
    required this.id,
    required this.url,
  });

  @JsonKey(name: 'Id')
  final int id;

  @JsonKey(name: 'Url')
  final String url;

  factory Color.fromJson(Map<String, dynamic> json) => _$ColorFromJson(json);

  Map<String, dynamic> toJson() => _$ColorToJson(this);
}
