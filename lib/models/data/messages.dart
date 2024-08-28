import 'package:darq/darq.dart';
import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:oshi/models/data/lesson.dart';
import 'package:oshi/models/data/teacher.dart';

import 'package:hive/hive.dart';
import 'package:oshi/share/share.dart';
part 'messages.g.dart';

@HiveType(typeId: 28)
@JsonSerializable(includeIfNull: false)
class Message extends Equatable {
  Message(
      {this.id = -1,
      this.url = 'https://g.co',
      this.topic = '',
      this.content,
      this.preview,
      this.hasAttachments = false,
      this.sender,
      DateTime? sendDate,
      this.readDate,
      this.attachments,
      this.receivers})
      : sendDate = sendDate ?? DateTime(2000);

  Message.from(
      {Message? other,
      int? id,
      String? url,
      String? topic,
      String? content,
      String? preview,
      bool? hasAttachments,
      Teacher? sender,
      DateTime? sendDate,
      DateTime? readDate,
      List<Attachment>? attachments,
      List<Teacher>? receivers})
      : id = id ?? other?.id ?? -1,
        url = url ?? other?.url ?? 'https://g.co',
        topic = topic ?? other?.topic ?? '',
        content = content ?? other?.content,
        preview = preview ?? other?.preview,
        hasAttachments = hasAttachments ?? other?.hasAttachments ?? false,
        sender = sender ?? other?.sender,
        sendDate = sendDate ?? other?.sendDate ?? DateTime(2000),
        readDate = readDate ?? other?.readDate,
        attachments = attachments ?? other?.attachments,
        receivers = receivers ?? other?.receivers;

  @HiveField(1)
  final int id;

  @HiveField(2)
  final String url;

  @HiveField(3)
  final String topic;

  @HiveField(4)
  final String? content;

  @HiveField(5)
  final String? preview;

  @HiveField(6)
  final bool hasAttachments;

  @HiveField(7)
  final Teacher? sender;

  @HiveField(8)
  final DateTime sendDate;

  @HiveField(9)
  final DateTime? readDate;

  // Set to null for no attachments
  @HiveField(10)
  final List<Attachment>? attachments;

  // For messages sent by the student - otherwise null
  @HiveField(11)
  final List<Teacher>? receivers;

  bool get read =>
      receivers != null || (readDate != null && readDate!.isBefore(DateTime.now()) && readDate != DateTime(2000));

  String get senderName =>
      sender?.name ??
      ((receivers?.isNotEmpty ?? false) ? "To: ${receivers?.select((x, index) => x.name).join(', ')}" : 'Unknown');

  String get previewString => (preview?.isEmpty ?? true) ? (content?.trim() ?? 'No preview available') : preview!.trim();

  String get sendDateString => sendDate.difference(DateTime.now().getDateOnly()).inDays > 0
      ? DateFormat.Hm().format(sendDate)
      : DateFormat.MMMd(Share.settings.appSettings.localeCode).format(sendDate);

  String get readDateString =>
      "Read ${DateFormat.yMMMd(Share.settings.appSettings.localeCode).format(readDate ?? DateTime(2000))} ${DateFormat.Hm(Share.settings.appSettings.localeCode).format(readDate ?? DateTime(2000))}";

  String get senderInitials => (sender?.name.isEmpty ?? true)
      ? ':)' // Placeholder, but it's up to you what to display there
      : sender!.name.split('').where((element) => RegExp('[A-Z]').hasMatch(element)).take(2).join();

  @override
  List<Object> get props => [id, url, topic, hasAttachments, sendDate];

  factory Message.fromJson(Map<String, dynamic> json) => _$MessageFromJson(json);

  Map<String, dynamic> toJson() => _$MessageToJson(this);
}

@HiveType(typeId: 29)
@JsonSerializable()
class Messages {
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

@HiveType(typeId: 99)
@JsonSerializable()
class Attachment extends Equatable {
  @HiveField(1)
  final String name;

  @HiveField(2)
  final String location;

  const Attachment({String? name, String? location})
      : name = name ?? 'Unknown',
        location = location ?? 'https://youtu.be/dQw4w9WgXcQ?si=2wQpMrQoFsQbQoKk';

  @override
  List<Object> get props => [name, location];

  factory Attachment.fromJson(Map<String, dynamic> json) => _$AttachmentFromJson(json);

  Map<String, dynamic> toJson() => _$AttachmentToJson(this);
}
