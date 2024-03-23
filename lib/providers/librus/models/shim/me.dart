import 'package:json_annotation/json_annotation.dart';

part 'me.g.dart';

@JsonSerializable()
class Me {
  Me({required this.me});

  @JsonKey(name: 'Me', defaultValue: null)
  final MeClass? me;

  factory Me.fromJson(Map<String, dynamic> json) => _$MeFromJson(json);

  Map<String, dynamic> toJson() => _$MeToJson(this);
}

@JsonSerializable()
class MeClass {
  MeClass({
    required this.account,
    required this.refresh,
    required this.user,
    required this.meClass,
  });

  @JsonKey(name: 'Account', defaultValue: null)
  final Account? account;

  @JsonKey(name: 'Refresh', defaultValue: -1)
  final int refresh;

  @JsonKey(name: 'User', defaultValue: null)
  final User? user;

  @JsonKey(name: 'Class', defaultValue: null)
  final Class? meClass;

  factory MeClass.fromJson(Map<String, dynamic> json) => _$MeClassFromJson(json);

  Map<String, dynamic> toJson() => _$MeClassToJson(this);
}

@JsonSerializable()
class Account {
  Account(
      {required this.id,
      required this.userId,
      required this.firstName,
      required this.lastName,
      required this.email,
      required this.groupId,
      required this.isActive,
      required this.login});

  @JsonKey(name: 'Id', defaultValue: -1)
  final int id;

  @JsonKey(name: 'UserId', defaultValue: -1)
  final int userId;

  @JsonKey(name: 'FirstName', defaultValue: '')
  final String firstName;

  @JsonKey(name: 'LastName', defaultValue: '')
  final String lastName;

  @JsonKey(name: 'Email', defaultValue: '')
  final String email;

  @JsonKey(name: 'GroupId', defaultValue: -1)
  final int groupId;

  @JsonKey(name: 'IsActive', defaultValue: false)
  final bool isActive;

  @JsonKey(name: 'Login', defaultValue: '')
  final String login;

  factory Account.fromJson(Map<String, dynamic> json) => _$AccountFromJson(json);

  Map<String, dynamic> toJson() => _$AccountToJson(this);
}

@JsonSerializable()
class Class {
  Class({
    required this.id,
    required this.url,
  });

  @JsonKey(name: 'Id', defaultValue: -1)
  final int id;

  @JsonKey(name: 'Url', defaultValue: '')
  final String url;

  factory Class.fromJson(Map<String, dynamic> json) => _$ClassFromJson(json);

  Map<String, dynamic> toJson() => _$ClassToJson(this);
}

@JsonSerializable()
class User {
  User({
    required this.firstName,
    required this.lastName,
  });

  @JsonKey(name: 'FirstName', defaultValue: '')
  final String firstName;

  @JsonKey(name: 'LastName', defaultValue: '')
  final String lastName;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);
}
