// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'classroom.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Classroom _$ClassroomFromJson(Map<String, dynamic> json) => Classroom(
      id: json['id'] as int? ?? -1,
      url: json['url'] as String? ?? 'https://g.co',
      name: json['name'] as String? ?? '',
      symbol: json['symbol'] as String? ?? '',
    );

Map<String, dynamic> _$ClassroomToJson(Classroom instance) => <String, dynamic>{
      'id': instance.id,
      'url': instance.url,
      'name': instance.name,
      'symbol': instance.symbol,
    };
