// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_works.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HomeWorks _$HomeWorksFromJson(Map<String, dynamic> json) => HomeWorks(
      homeWorks: (json['HomeWorks'] as List<dynamic>?)
          ?.map((e) => HomeWork.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$HomeWorksToJson(HomeWorks instance) => <String, dynamic>{
      'HomeWorks': instance.homeWorks,
    };

HomeWork _$HomeWorkFromJson(Map<String, dynamic> json) => HomeWork(
      id: (json['Id'] as num?)?.toInt() ?? -1,
      content: json['Content'] as String? ?? '',
      date:
          json['Date'] == null ? null : DateTime.parse(json['Date'] as String),
      category: json['Category'] == null
          ? null
          : Category.fromJson(json['Category'] as Map<String, dynamic>),
      lessonNo: json['LessonNo'] as String?,
      timeFrom: json['TimeFrom'] as String? ?? '',
      timeTo: json['TimeTo'] as String? ?? '',
      createdBy: json['CreatedBy'] == null
          ? null
          : Category.fromJson(json['CreatedBy'] as Map<String, dynamic>),
      homeWorkClass: json['Class'] == null
          ? null
          : Category.fromJson(json['Class'] as Map<String, dynamic>),
      classroom: json['Classroom'] == null
          ? null
          : Classroom.fromJson(json['Classroom'] as Map<String, dynamic>),
      addDate: json['AddDate'] == null
          ? null
          : DateTime.parse(json['AddDate'] as String),
      subject: json['Subject'] == null
          ? null
          : Category.fromJson(json['Subject'] as Map<String, dynamic>),
      virtualClass: json['VirtualClass'] == null
          ? null
          : Category.fromJson(json['VirtualClass'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$HomeWorkToJson(HomeWork instance) => <String, dynamic>{
      'Id': instance.id,
      'Content': instance.content,
      'Date': instance.date?.toIso8601String(),
      'Category': instance.category,
      'LessonNo': instance.lessonNo,
      'TimeFrom': instance.timeFrom,
      'TimeTo': instance.timeTo,
      'CreatedBy': instance.createdBy,
      'Class': instance.homeWorkClass,
      'Classroom': instance.classroom,
      'AddDate': instance.addDate?.toIso8601String(),
      'Subject': instance.subject,
      'VirtualClass': instance.virtualClass,
    };

Category _$CategoryFromJson(Map<String, dynamic> json) => Category(
      id: (json['Id'] as num?)?.toInt() ?? -1,
      url: json['Url'] as String? ?? '',
    );

Map<String, dynamic> _$CategoryToJson(Category instance) => <String, dynamic>{
      'Id': instance.id,
      'Url': instance.url,
    };

Classroom _$ClassroomFromJson(Map<String, dynamic> json) => Classroom(
      id: (json['Id'] as num?)?.toInt() ?? -1,
      symbol: json['Symbol'] as String? ?? '',
      name: json['Name'] as String? ?? '',
      size: (json['Size'] as num?)?.toInt() ?? -1,
    );

Map<String, dynamic> _$ClassroomToJson(Classroom instance) => <String, dynamic>{
      'Id': instance.id,
      'Symbol': instance.symbol,
      'Name': instance.name,
      'Size': instance.size,
    };
