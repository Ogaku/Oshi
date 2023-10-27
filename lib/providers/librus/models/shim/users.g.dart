// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'users.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Users _$UsersFromJson(Map<String, dynamic> json) => Users(
      users: (json['Users'] as List<dynamic>?)
          ?.map((e) => User.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$UsersToJson(Users instance) => <String, dynamic>{
      'Users': instance.users,
    };

User _$UserFromJson(Map<String, dynamic> json) => User(
      id: json['Id'] as int,
      firstName: json['FirstName'] as String? ?? '',
      lastName: json['LastName'] as String,
      isEmployee: json['IsEmployee'] as bool,
      groupId: json['GroupId'] as int,
    )..userId = json['UserId'] as int?;

Map<String, dynamic> _$UserToJson(User instance) {
  final val = <String, dynamic>{
    'Id': instance.id,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('UserId', instance.userId);
  val['FirstName'] = instance.firstName;
  val['LastName'] = instance.lastName;
  val['IsEmployee'] = instance.isEmployee;
  val['GroupId'] = instance.groupId;
  return val;
}
