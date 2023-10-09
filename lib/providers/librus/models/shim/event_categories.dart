import 'package:json_annotation/json_annotation.dart';

part 'event_categories.g.dart';

@JsonSerializable()
class EventCategories {
  EventCategories({
    required this.categories,
  });

  @JsonKey(name: 'Categories')
  final List<Category>? categories;

  factory EventCategories.fromJson(Map<String, dynamic> json) => _$EventCategoriesFromJson(json);

  Map<String, dynamic> toJson() => _$EventCategoriesToJson(this);
}

@JsonSerializable()
class Category {
  Category({
    required this.id,
    required this.name,
    required this.color,
  });

  @JsonKey(name: 'Id')
  final int id;

  @JsonKey(name: 'Name')
  final String name;

  @JsonKey(name: 'Color')
  final Color? color;

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
