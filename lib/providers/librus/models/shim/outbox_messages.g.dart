// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'outbox_messages.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OutboxMessages _$OutboxMessagesFromJson(Map<String, dynamic> json) =>
    OutboxMessages(
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => Datum.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: json['total'] as int,
    );

Map<String, dynamic> _$OutboxMessagesToJson(OutboxMessages instance) =>
    <String, dynamic>{
      'data': instance.data,
      'total': instance.total,
    };

Datum _$DatumFromJson(Map<String, dynamic> json) => Datum(
      messageId: json['messageId'] as String,
      receiverFirstName: json['receiverFirstName'] as String,
      receiverLastName: json['receiverLastName'] as String,
      receiverName: json['receiverName'] as String,
      topic: json['topic'] as String,
      content: json['content'] as String,
      sendDate: json['sendDate'] == null
          ? null
          : DateTime.parse(json['sendDate'] as String),
      isAnyFileAttached: json['isAnyFileAttached'] as bool,
    );

Map<String, dynamic> _$DatumToJson(Datum instance) => <String, dynamic>{
      'messageId': instance.messageId,
      'receiverFirstName': instance.receiverFirstName,
      'receiverLastName': instance.receiverLastName,
      'receiverName': instance.receiverName,
      'topic': instance.topic,
      'content': instance.content,
      'sendDate': instance.sendDate?.toIso8601String(),
      'isAnyFileAttached': instance.isAnyFileAttached,
    };

OutboxMessage _$OutboxMessageFromJson(Map<String, dynamic> json) =>
    OutboxMessage(
      data: json['data'] == null
          ? null
          : Data.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$OutboxMessageToJson(OutboxMessage instance) =>
    <String, dynamic>{
      'data': instance.data,
    };

Data _$DataFromJson(Map<String, dynamic> json) => Data(
      messageId: json['messageId'] as String,
      receiver: json['receiver'] as String,
      senderFirstName: json['senderFirstName'] as String,
      senderLastName: json['senderLastName'] as String,
      topic: json['topic'] as String,
      message: json['Message'] as String,
      sendDate: json['sendDate'] == null
          ? null
          : DateTime.parse(json['sendDate'] as String),
      readDate: json['readDate'] == null
          ? null
          : DateTime.parse(json['readDate'] as String),
      userFirstName: json['userFirstName'] as String,
      userLastName: json['userLastName'] as String,
      noReply: json['noReply'] as int,
      archive: json['archive'] as int,
      senderName: json['senderName'] as String,
      receivers: (json['receivers'] as List<dynamic>?)
          ?.map((e) => Receiver.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$DataToJson(Data instance) => <String, dynamic>{
      'messageId': instance.messageId,
      'receiver': instance.receiver,
      'senderFirstName': instance.senderFirstName,
      'senderLastName': instance.senderLastName,
      'topic': instance.topic,
      'Message': instance.message,
      'sendDate': instance.sendDate?.toIso8601String(),
      'readDate': instance.readDate?.toIso8601String(),
      'userFirstName': instance.userFirstName,
      'userLastName': instance.userLastName,
      'noReply': instance.noReply,
      'archive': instance.archive,
      'senderName': instance.senderName,
      'receivers': instance.receivers,
    };

Receiver _$ReceiverFromJson(Map<String, dynamic> json) => Receiver(
      receiverId: json['receiverId'] as String,
      firstName: json['firstName'] as String? ?? 'Unknown',
      lastName: json['lastName'] as String? ?? 'Receiver',
      className: json['className'],
      pupilFirstName: json['pupilFirstName'],
      pupilLastName: json['pupilLastName'],
      group: json['group'] as String,
      readed: json['readed'],
      active: json['active'] as int,
      otherNodeUuid: json['otherNodeUuid'],
      otherNodeAccountId: json['otherNodeAccountId'],
      name: json['name'] as String,
      groupId: json['groupId'] as String,
    );

Map<String, dynamic> _$ReceiverToJson(Receiver instance) => <String, dynamic>{
      'receiverId': instance.receiverId,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'className': instance.className,
      'pupilFirstName': instance.pupilFirstName,
      'pupilLastName': instance.pupilLastName,
      'group': instance.group,
      'readed': instance.readed,
      'active': instance.active,
      'otherNodeUuid': instance.otherNodeUuid,
      'otherNodeAccountId': instance.otherNodeAccountId,
      'name': instance.name,
      'groupId': instance.groupId,
    };

MessageToSend _$MessageToSendFromJson(Map<String, dynamic> json) =>
    MessageToSend(
      topic: json['topic'] as String?,
      content: json['content'] as String?,
      copyTo: json['copyTo'] as String?,
      receivers: json['receivers'] == null
          ? null
          : Receivers.fromJson(json['receivers'] as Map<String, dynamic>),
      storageId: json['storageId'],
      category: json['category'] as String?,
    );

Map<String, dynamic> _$MessageToSendToJson(MessageToSend instance) =>
    <String, dynamic>{
      'topic': instance.topic,
      'content': instance.content,
      'copyTo': instance.copyTo,
      'receivers': instance.receivers,
      'storageId': instance.storageId,
      'category': instance.category,
    };

Receivers _$ReceiversFromJson(Map<String, dynamic> json) => Receivers(
      schoolReceivers: (json['schoolReceivers'] as List<dynamic>?)
          ?.map((e) => Schoolreceiver.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ReceiversToJson(Receivers instance) => <String, dynamic>{
      'schoolReceivers': instance.schoolReceivers,
    };

Schoolreceiver _$SchoolreceiverFromJson(Map<String, dynamic> json) =>
    Schoolreceiver(
      accountId: json['accountId'] as String?,
    );

Map<String, dynamic> _$SchoolreceiverToJson(Schoolreceiver instance) =>
    <String, dynamic>{
      'accountId': instance.accountId,
    };
