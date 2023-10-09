// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_categories.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EventCategories _$EventCategoriesFromJson(Map<String, dynamic> json) =>
    EventCategories(
      categories: (json['Categories'] as List<dynamic>?)
          ?.map((e) => Category.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$EventCategoriesToJson(EventCategories instance) =>
    <String, dynamic>{
      'Categories': instance.categories,
    };

Category _$CategoryFromJson(Map<String, dynamic> json) => Category(
      id: json['Id'] as int,
      name: json['Name'] as String,
      color: json['Color'] == null
          ? null
          : Color.fromJson(json['Color'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$CategoryToJson(Category instance) => <String, dynamic>{
      'Id': instance.id,
      'Name': instance.name,
      'Color': instance.color,
    };

Color _$ColorFromJson(Map<String, dynamic> json) => Color(
      id: json['Id'] as int,
      url: json['Url'] as String,
    );

Map<String, dynamic> _$ColorToJson(Color instance) => <String, dynamic>{
      'Id': instance.id,
      'Url': instance.url,
    };
