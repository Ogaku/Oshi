import 'package:darq/darq.dart';
import 'package:intl/intl.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:szkolny/models/data/lesson.dart';
import 'package:szkolny/models/data/teacher.dart';

part 'messages.g.dart';

@JsonSerializable(includeIfNull: false)
class Message {
  Message({
    required this.id,
    required this.url,
    required this.topic,
    this.content,
    this.preview,
    required this.hasAttachments,
    this.sender,
    required this.sendDate,
    this.readDate,
    this.attachments,
    this.receivers,
    this.fetchMessageContent,
    this.moveMessageToTrash,
  });

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

  Messages(
    this.received,
    this.sent,
    this.receivers,
  );

  factory Messages.fromJson(Map<String, dynamic> json) => _$MessagesFromJson(json);

  Map<String, dynamic> toJson() => _$MessagesToJson(this);
}
