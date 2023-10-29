import 'package:json_annotation/json_annotation.dart';

part 'users.g.dart';

@JsonSerializable()
class Users {
  Users({
    required this.users,
  });

  @JsonKey(name: 'Users')
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

  @JsonKey(name: 'Id')
  final int id;

  @JsonKey(name: 'UserId')
  int? userId;

  @JsonKey(name: 'FirstName')
  final String firstName;

  @JsonKey(name: 'LastName')
  final String lastName;

  @JsonKey(name: 'IsEmployee')
  final bool isEmployee;

  @JsonKey(name: 'GroupId')
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
