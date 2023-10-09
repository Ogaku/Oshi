import 'package:json_annotation/json_annotation.dart';

part 'outbox_messages.g.dart';

@JsonSerializable()
class OutboxMessages {
  OutboxMessages({
    required this.data,
    required this.total,
  });

  final List<Datum>? data;
  final int total;

  factory OutboxMessages.fromJson(Map<String, dynamic> json) => _$OutboxMessagesFromJson(json);

  Map<String, dynamic> toJson() => _$OutboxMessagesToJson(this);
}

@JsonSerializable()
class Datum {
  Datum({
    required this.messageId,
    required this.receiverFirstName,
    required this.receiverLastName,
    required this.receiverName,
    required this.topic,
    required this.content,
    required this.sendDate,
    required this.isAnyFileAttached,
  });

  final String messageId;
  final String receiverFirstName;
  final String receiverLastName;
  final String receiverName;
  final String topic;
  final String content;
  final DateTime? sendDate;
  final bool isAnyFileAttached;

  factory Datum.fromJson(Map<String, dynamic> json) => _$DatumFromJson(json);

  Map<String, dynamic> toJson() => _$DatumToJson(this);
}

@JsonSerializable()
class OutboxMessage {
  OutboxMessage({
    required this.data,
  });

  final Data? data;

  factory OutboxMessage.fromJson(Map<String, dynamic> json) => _$OutboxMessageFromJson(json);

  Map<String, dynamic> toJson() => _$OutboxMessageToJson(this);
}

@JsonSerializable()
class Data {
  Data({
    required this.messageId,
    required this.receiver,
    required this.senderFirstName,
    required this.senderLastName,
    required this.topic,
    required this.message,
    required this.sendDate,
    required this.readDate,
    required this.userFirstName,
    required this.userLastName,
    required this.noReply,
    required this.archive,
    required this.senderName,
    required this.receivers,
  });

  final String messageId;
  final String receiver;
  final String senderFirstName;
  final String senderLastName;
  final String topic;

  @JsonKey(name: 'Message')
  final String message;
  final DateTime? sendDate;
  final DateTime? readDate;
  final String userFirstName;
  final String userLastName;
  final int noReply;
  final int archive;
  final String senderName;
  final List<Receiver>? receivers;

  factory Data.fromJson(Map<String, dynamic> json) => _$DataFromJson(json);

  Map<String, dynamic> toJson() => _$DataToJson(this);
}

@JsonSerializable()
class Receiver {
  Receiver({
    required this.receiverId,
    required this.firstName,
    required this.lastName,
    required this.className,
    required this.pupilFirstName,
    required this.pupilLastName,
    required this.group,
    required this.readed,
    required this.active,
    required this.otherNodeUuid,
    required this.otherNodeAccountId,
    required this.name,
    required this.groupId,
  });

  final String receiverId;
  final String firstName;
  final String lastName;
  final dynamic className;
  final dynamic pupilFirstName;
  final dynamic pupilLastName;
  final String group;
  final dynamic readed;
  final int active;
  final dynamic otherNodeUuid;
  final dynamic otherNodeAccountId;
  final String name;
  final String groupId;

  factory Receiver.fromJson(Map<String, dynamic> json) => _$ReceiverFromJson(json);

  Map<String, dynamic> toJson() => _$ReceiverToJson(this);
}

@JsonSerializable()
class MessageToSend {
  MessageToSend({this.topic, this.content, this.copyTo, this.receivers, this.storageId, this.category});

  String? topic;
  String? content;
  String? copyTo;
  Receivers? receivers;
  Object? storageId;
  String? category;

  factory MessageToSend.fromJson(Map<String, dynamic> json) => _$MessageToSendFromJson(json);

  Map<String, dynamic> toJson() => _$MessageToSendToJson(this);
}

@JsonSerializable()
class Receivers {
  List<Schoolreceiver>? schoolReceivers;

  Receivers({
    this.schoolReceivers,
  });

  factory Receivers.fromJson(Map<String, dynamic> json) => _$ReceiversFromJson(json);

  Map<String, dynamic> toJson() => _$ReceiversToJson(this);
}

@JsonSerializable()
class Schoolreceiver {
  String? accountId;

  Schoolreceiver({
    this.accountId,
  });

  factory Schoolreceiver.fromJson(Map<String, dynamic> json) => _$SchoolreceiverFromJson(json);

  Map<String, dynamic> toJson() => _$SchoolreceiverToJson(this);
}
