import 'package:json_annotation/json_annotation.dart';

part 'users.g.dart';

@JsonSerializable()
class Users {
  Users({
    required this.users,
  });

  @JsonKey(name: 'Users', defaultValue: null)
  final List<User>? users;

  factory Users.fromJson(Map<String, dynamic> json) => _$UsersFromJson(json);

  Map<String, dynamic> toJson() => _$UsersToJson(this);
}

@JsonSerializable(includeIfNull: false)
class User {
  User({
    required this.id,
    this.firstName = '',
    required this.lastName,
    required this.isEmployee,
    required this.groupId,
  });

  @JsonKey(name: 'Id', defaultValue: -1)
  final int id;

  @JsonKey(name: 'UserId', defaultValue: null)
  int? userId;

  @JsonKey(name: 'FirstName', defaultValue: '')
  final String firstName;

  @JsonKey(name: 'LastName', defaultValue: '')
  final String lastName;

  @JsonKey(name: 'IsEmployee', defaultValue: false)
  final bool isEmployee;

  @JsonKey(name: 'GroupId', defaultValue: -1)
  final int groupId;

  @JsonKey(includeFromJson: false, includeToJson: false)
  bool isHomeTeacher = false;

  @JsonKey(includeFromJson: false, includeToJson: false)
  String get nameInv {
    if (firstName.isEmpty && lastName.isEmpty) return 'Unknown';
    if (firstName.isEmpty) return lastName;
    return lastName.isEmpty ? firstName : '$lastName $firstName';
  }

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);
}
