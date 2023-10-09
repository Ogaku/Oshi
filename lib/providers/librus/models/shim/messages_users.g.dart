// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'messages_users.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MessagesUsers _$MessagesUsersFromJson(Map<String, dynamic> json) =>
    MessagesUsers(
      receivers: (json['receivers'] as List<dynamic>?)
          ?.map((e) => Receiver.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$MessagesUsersToJson(MessagesUsers instance) =>
    <String, dynamic>{
      'receivers': instance.receivers,
    };

Receiver _$ReceiverFromJson(Map<String, dynamic> json) => Receiver(
      accountId: json['accountId'] as String,
      label: json['label'] as String,
      userId: json['userId'] as String,
    );

Map<String, dynamic> _$ReceiverToJson(Receiver instance) => <String, dynamic>{
      'accountId': instance.accountId,
      'label': instance.label,
      'userId': instance.userId,
    };
