import 'package:json_annotation/json_annotation.dart';

part 'messages_users.g.dart';

@JsonSerializable()
class MessagesUsers {
  MessagesUsers({
    required this.receivers,
  });

  final List<Receiver>? receivers;

  factory MessagesUsers.fromJson(Map<String, dynamic> json) => _$MessagesUsersFromJson(json);

  Map<String, dynamic> toJson() => _$MessagesUsersToJson(this);
}

@JsonSerializable()
class Receiver {
  Receiver({
    required this.accountId,
    required this.label,
    required this.userId,
  });

  final String accountId;
  final String label;
  final String userId;

  int get accountIdInt => int.tryParse(accountId) ?? -1;
  int get userIdInt => int.tryParse(userId) ?? -1;

  factory Receiver.fromJson(Map<String, dynamic> json) => _$ReceiverFromJson(json);

  Map<String, dynamic> toJson() => _$ReceiverToJson(this);
}
