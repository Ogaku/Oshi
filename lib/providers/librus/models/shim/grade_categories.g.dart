// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'grade_categories.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GradeCategories _$GradeCategoriesFromJson(Map<String, dynamic> json) =>
    GradeCategories(
      categories: (json['Categories'] as List<dynamic>?)
          ?.map((e) => Category.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$GradeCategoriesToJson(GradeCategories instance) =>
    <String, dynamic>{
      'Categories': instance.categories,
    };

Category _$CategoryFromJson(Map<String, dynamic> json) => Category(
      id: json['Id'] as int? ?? -1,
      color: json['Color'] == null
          ? null
          : Color.fromJson(json['Color'] as Map<String, dynamic>),
      name: json['Name'] as String? ?? '',
      countToTheAverage: json['CountToTheAverage'] as bool? ?? false,
      weight: json['Weight'] as int?,
    );

Map<String, dynamic> _$CategoryToJson(Category instance) {
  final val = <String, dynamic>{
    'Id': instance.id,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('Color', instance.color);
  val['Name'] = instance.name;
  val['CountToTheAverage'] = instance.countToTheAverage;
  writeNotNull('Weight', instance.weight);
  return val;
}

Color _$ColorFromJson(Map<String, dynamic> json) => Color(
      id: json['Id'] as int? ?? -1,
      url: json['Url'] as String? ?? '',
    );

Map<String, dynamic> _$ColorToJson(Color instance) => <String, dynamic>{
      'Id': instance.id,
      'Url': instance.url,
    };
