// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'free_day_types.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FreeDayTypes _$FreeDayTypesFromJson(Map<String, dynamic> json) => FreeDayTypes(
      types: (json['Types'] as List<dynamic>?)
          ?.map((e) => Type.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$FreeDayTypesToJson(FreeDayTypes instance) =>
    <String, dynamic>{
      'Types': instance.types,
    };

Type _$TypeFromJson(Map<String, dynamic> json) => Type(
      id: json['Id'] as int? ?? -1,
      name: json['Name'] as String? ?? '',
    );

Map<String, dynamic> _$TypeToJson(Type instance) => <String, dynamic>{
      'Id': instance.id,
      'Name': instance.name,
    };
