// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'homework_categories.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HomeworkCategories _$HomeworkCategoriesFromJson(Map<String, dynamic> json) =>
    HomeworkCategories(
      categories: (json['Categories'] as List<dynamic>?)
          ?.map((e) => Category.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$HomeworkCategoriesToJson(HomeworkCategories instance) =>
    <String, dynamic>{
      'Categories': instance.categories,
    };

Category _$CategoryFromJson(Map<String, dynamic> json) => Category(
      id: (json['Id'] as num?)?.toInt() ?? -1,
      teacher: json['Teacher'] == null
          ? null
          : Teacher.fromJson(json['Teacher'] as Map<String, dynamic>),
      categoryName: json['CategoryName'] as String? ?? '',
    );

Map<String, dynamic> _$CategoryToJson(Category instance) => <String, dynamic>{
      'Id': instance.id,
      'Teacher': instance.teacher,
      'CategoryName': instance.categoryName,
    };

Teacher _$TeacherFromJson(Map<String, dynamic> json) => Teacher(
      id: (json['Id'] as num?)?.toInt() ?? -1,
      url: json['Url'] as String? ?? '',
    );

Map<String, dynamic> _$TeacherToJson(Teacher instance) => <String, dynamic>{
      'Id': instance.id,
      'Url': instance.url,
    };
