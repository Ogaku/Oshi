// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inbox_messages.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InboxMessages _$InboxMessagesFromJson(Map<String, dynamic> json) =>
    InboxMessages(
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => Datum.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: json['total'] as int,
    );

Map<String, dynamic> _$InboxMessagesToJson(InboxMessages instance) =>
    <String, dynamic>{
      'data': instance.data,
      'total': instance.total,
    };

Datum _$DatumFromJson(Map<String, dynamic> json) => Datum(
      messageId: json['messageId'] as String,
      senderFirstName: json['senderFirstName'] as String,
      senderLastName: json['senderLastName'] as String,
      senderName: json['senderName'] as String,
      topic: json['topic'] as String,
      content: json['content'] as String,
      sendDate: json['sendDate'] == null
          ? null
          : DateTime.parse(json['sendDate'] as String),
      readDate: json['readDate'] == null
          ? null
          : DateTime.parse(json['readDate'] as String),
      isAnyFileAttached: json['isAnyFileAttached'] as bool,
    );

Map<String, dynamic> _$DatumToJson(Datum instance) {
  final val = <String, dynamic>{
    'messageId': instance.messageId,
    'senderFirstName': instance.senderFirstName,
    'senderLastName': instance.senderLastName,
    'senderName': instance.senderName,
    'topic': instance.topic,
    'content': instance.content,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('sendDate', instance.sendDate?.toIso8601String());
  writeNotNull('readDate', instance.readDate?.toIso8601String());
  val['isAnyFileAttached'] = instance.isAnyFileAttached;
  return val;
}

InboxMessage _$InboxMessageFromJson(Map<String, dynamic> json) => InboxMessage(
      data: json['data'] == null
          ? null
          : Data.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$InboxMessageToJson(InboxMessage instance) =>
    <String, dynamic>{
      'data': instance.data,
    };

Data _$DataFromJson(Map<String, dynamic> json) => Data(
      messageId: json['messageId'] as String,
      receiver: json['receiver'] as String,
      senderId: json['senderId'] as String,
      senderFirstName: json['senderFirstName'] as String? ?? '',
      senderLastName: json['senderLastName'] as String,
      senderGroup: json['senderGroup'] as String,
      myMessage: json['myMessage'] as String,
      topic: json['topic'] as String,
      message: json['Message'] as String,
      sendDate: json['sendDate'] == null
          ? null
          : DateTime.parse(json['sendDate'] as String),
      readDate: json['readDate'] == null
          ? null
          : DateTime.parse(json['readDate'] as String),
      spam: json['spam'] as String,
      state: json['state'] as String,
      userFirstName: json['userFirstName'] as String,
      userLastName: json['userLastName'] as String,
      userClass: json['userClass'] as String,
      originalMessage: json['originalMessage'] as String,
      originalTopic: json['originalTopic'] as String,
      noReply: json['noReply'] as int,
      archive: json['archive'] as int,
      senderGroupId: json['senderGroupId'] as String,
      senderName: json['senderName'] as String,
      attachementInfo: json['attachementInfo'] as String,
      attachments: (json['attachments'] as List<dynamic>?)
          ?.map((e) => Attachment.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$DataToJson(Data instance) {
  final val = <String, dynamic>{
    'messageId': instance.messageId,
    'receiver': instance.receiver,
    'senderId': instance.senderId,
    'senderFirstName': instance.senderFirstName,
    'senderLastName': instance.senderLastName,
    'senderGroup': instance.senderGroup,
    'myMessage': instance.myMessage,
    'topic': instance.topic,
    'Message': instance.message,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('sendDate', instance.sendDate?.toIso8601String());
  writeNotNull('readDate', instance.readDate?.toIso8601String());
  val['spam'] = instance.spam;
  val['state'] = instance.state;
  val['userFirstName'] = instance.userFirstName;
  val['userLastName'] = instance.userLastName;
  val['userClass'] = instance.userClass;
  val['originalMessage'] = instance.originalMessage;
  val['originalTopic'] = instance.originalTopic;
  val['noReply'] = instance.noReply;
  val['archive'] = instance.archive;
  val['senderGroupId'] = instance.senderGroupId;
  val['senderName'] = instance.senderName;
  val['attachementInfo'] = instance.attachementInfo;
  writeNotNull('attachments', instance.attachments);
  return val;
}

Attachment _$AttachmentFromJson(Map<String, dynamic> json) => Attachment(
      filename: json['filename'] as String,
      id: json['id'] as String,
    );

Map<String, dynamic> _$AttachmentToJson(Attachment instance) =>
    <String, dynamic>{
      'filename': instance.filename,
      'id': instance.id,
    };
