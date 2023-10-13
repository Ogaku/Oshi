import 'package:darq/darq.dart';
import 'package:intl/intl.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:ogaku/models/data/lesson.dart';
import 'package:ogaku/models/data/teacher.dart';

import 'package:hive/hive.dart';
part 'messages.g.dart';

@HiveType(typeId: 28)
@JsonSerializable(includeIfNull: false)
class Message extends HiveObject {
  Message({
    this.id = -1,
    this.url = 'https://g.co',
    this.topic = '',
    this.content,
    this.preview,
    this.hasAttachments = false,
    this.sender,
    DateTime? sendDate,
    this.readDate,
    this.attachments,
    this.receivers,
    this.fetchMessageContent,
    this.moveMessageToTrash,
  }) : sendDate = sendDate ?? DateTime(2000);

  
  @HiveField(1)
  int id;
  
  @HiveField(2)
  String url;
  
  @HiveField(3)
  String topic;
  
  @HiveField(4)
  String? content;
  
  @HiveField(5)
  String? preview;
  
  @HiveField(6)
  bool hasAttachments;
  
  @HiveField(7)
  Teacher? sender;
  
  @HiveField(8)
  DateTime sendDate;
  
  @HiveField(9)
  DateTime? readDate;

  // Set to null for no attachments
  @HiveField(10)
  List<({String name, String location})>? attachments;
  // For messages sent by the student - otherwise null
  @HiveField(11)
  List<Teacher>? receivers;

  // Fetch the actual content, sender details
  @JsonKey(includeFromJson: false, includeToJson: false)
  Future Function(Message)? fetchMessageContent;

  // Move the message to trash
  @JsonKey(includeFromJson: false, includeToJson: false)
  Future Function(Message)? moveMessageToTrash;

  bool get read => readDate == null || readDate!.isAfter(DateTime.now());

  String get senderName =>
      sender?.name ??
      ((receivers?.isNotEmpty ?? false) ? "To: ${receivers?.select((x, index) => x.name).join(', ')}" : 'Unknown.');

  String get previewString => (preview?.isEmpty ?? true) ? (content ?? 'No content.') : preview!.trim();

  String get sendDateString => sendDate.difference(DateTime.now().getDateOnly()).inDays > 0
      ? DateFormat.Hm().format(sendDate)
      : DateFormat('d MMM').format(sendDate);

  String get senderInitials => (sender?.name.isEmpty ?? true)
      ? ':)' // Placeholder, but it's up to you what to display there
      : sender!.name.split('').where((element) => RegExp('[A-Z]').hasMatch(element)).take(2).join();

  factory Message.fromJson(Map<String, dynamic> json) => _$MessageFromJson(json);

  Map<String, dynamic> toJson() => _$MessageToJson(this);
}

@HiveType(typeId: 29)
@JsonSerializable()
class Messages extends HiveObject {
  @HiveField(1)
  List<Message> received;
  
  @HiveField(2)
  List<Message> sent;
  
  @HiveField(3)
  List<Teacher> receivers;

  Messages({
    List<Message>? received,
    List<Message>? sent,
    List<Teacher>? receivers,
  })  : received = received ?? [],
        sent = sent ?? [],
        receivers = receivers ?? [];

  factory Messages.fromJson(Map<String, dynamic> json) => _$MessagesFromJson(json);

  Map<String, dynamic> toJson() => _$MessagesToJson(this);
}
