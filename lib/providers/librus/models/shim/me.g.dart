// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'me.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Me _$MeFromJson(Map<String, dynamic> json) => Me(
      me: json['Me'] == null
          ? null
          : MeClass.fromJson(json['Me'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$MeToJson(Me instance) => <String, dynamic>{
      'Me': instance.me,
    };

MeClass _$MeClassFromJson(Map<String, dynamic> json) => MeClass(
      account: json['Account'] == null
          ? null
          : Account.fromJson(json['Account'] as Map<String, dynamic>),
      refresh: json['Refresh'] as int,
      user: json['User'] == null
          ? null
          : User.fromJson(json['User'] as Map<String, dynamic>),
      meClass: json['Class'] == null
          ? null
          : Class.fromJson(json['Class'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$MeClassToJson(MeClass instance) => <String, dynamic>{
      'Account': instance.account,
      'Refresh': instance.refresh,
      'User': instance.user,
      'Class': instance.meClass,
    };

Account _$AccountFromJson(Map<String, dynamic> json) => Account(
      id: json['Id'] as int,
      userId: json['UserId'] as int,
      firstName: json['FirstName'] as String,
      lastName: json['LastName'] as String,
      email: json['Email'] as String,
      groupId: json['GroupId'] as int,
      isActive: json['IsActive'] as bool,
      login: json['Login'] as String,
    );

Map<String, dynamic> _$AccountToJson(Account instance) => <String, dynamic>{
      'Id': instance.id,
      'UserId': instance.userId,
      'FirstName': instance.firstName,
      'LastName': instance.lastName,
      'Email': instance.email,
      'GroupId': instance.groupId,
      'IsActive': instance.isActive,
      'Login': instance.login,
    };

Class _$ClassFromJson(Map<String, dynamic> json) => Class(
      id: json['Id'] as int,
      url: json['Url'] as String,
    );

Map<String, dynamic> _$ClassToJson(Class instance) => <String, dynamic>{
      'Id': instance.id,
      'Url': instance.url,
    };

User _$UserFromJson(Map<String, dynamic> json) => User(
      firstName: json['FirstName'] as String,
      lastName: json['LastName'] as String,
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'FirstName': instance.firstName,
      'LastName': instance.lastName,
    };
