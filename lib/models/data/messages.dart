import 'package:darq/darq.dart';
import 'package:intl/intl.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:ogaku/models/data/lesson.dart';
import 'package:ogaku/models/data/teacher.dart';

part 'messages.g.dart';

@JsonSerializable(includeIfNull: false)
class Message {
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

  int id;
  String url;
  String topic;
  String? content;
  String? preview;
  bool hasAttachments;
  Teacher? sender;
  DateTime sendDate;
  DateTime? readDate;

  // Set to null for no attachments
  List<({String name, String location})>? attachments;
  // For messages sent by the student - otherwise null
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

@JsonSerializable()
class Messages {
  List<Message> received;
  List<Message> sent;
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
