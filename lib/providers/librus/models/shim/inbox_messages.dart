import 'package:json_annotation/json_annotation.dart';

part 'inbox_messages.g.dart';

@JsonSerializable()
class InboxMessages {
  InboxMessages({
    required this.data,
    required this.total,
  });

  final List<Datum>? data;
  final int total;

  factory InboxMessages.fromJson(Map<String, dynamic> json) => _$InboxMessagesFromJson(json);

  Map<String, dynamic> toJson() => _$InboxMessagesToJson(this);
}

@JsonSerializable(includeIfNull: false)
class Datum {
  Datum({
    required this.messageId,
    required this.senderFirstName,
    required this.senderLastName,
    required this.senderName,
    required this.topic,
    required this.content,
    this.sendDate,
    this.readDate,
    required this.isAnyFileAttached,
  });

  final String messageId;
  final String senderFirstName;
  final String senderLastName;
  final String senderName;
  final String topic;
  final String content;
  final DateTime? sendDate;
  final DateTime? readDate;
  final bool isAnyFileAttached;

  factory Datum.fromJson(Map<String, dynamic> json) => _$DatumFromJson(json);

  Map<String, dynamic> toJson() => _$DatumToJson(this);
}

@JsonSerializable()
class InboxMessage {
  InboxMessage({
    required this.data,
  });

  final Data? data;

  factory InboxMessage.fromJson(Map<String, dynamic> json) => _$InboxMessageFromJson(json);

  Map<String, dynamic> toJson() => _$InboxMessageToJson(this);
}

@JsonSerializable(includeIfNull: false)
class Data {
  Data({
    required this.messageId,
    required this.receiver,
    required this.senderId,
    this.senderFirstName = '',
    required this.senderLastName,
    required this.senderGroup,
    required this.myMessage,
    required this.topic,
    required this.message,
    this.sendDate,
    this.readDate,
    required this.spam,
    required this.state,
    required this.userFirstName,
    required this.userLastName,
    required this.userClass,
    required this.originalMessage,
    required this.originalTopic,
    required this.noReply,
    required this.archive,
    required this.senderGroupId,
    required this.senderName,
    required this.attachementInfo,
    required this.attachments,
  });

  final String messageId;
  final String receiver;
  final String senderId;
  final String senderFirstName;
  final String senderLastName;
  final String senderGroup;
  final String myMessage;
  final String topic;

  @JsonKey(name: 'Message')
  final String message;
  final DateTime? sendDate;
  final DateTime? readDate;
  final String spam;
  final String state;
  final String userFirstName;
  final String userLastName;
  final String userClass;
  final String originalMessage;
  final String originalTopic;
  final int noReply;
  final int archive;
  final String senderGroupId;
  final String senderName;
  final String attachementInfo;
  final List<Attachment>? attachments;

  factory Data.fromJson(Map<String, dynamic> json) => _$DataFromJson(json);

  Map<String, dynamic> toJson() => _$DataToJson(this);
}

@JsonSerializable()
class Attachment {
  Attachment({
    required this.filename,
    required this.id,
  });

  final String filename;
  final String id;

  factory Attachment.fromJson(Map<String, dynamic> json) => _$AttachmentFromJson(json);

  Map<String, dynamic> toJson() => _$AttachmentToJson(this);
}
