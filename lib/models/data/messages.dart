import 'package:darq/darq.dart';
import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:oshi/models/data/teacher.dart';

import 'package:hive/hive.dart';
import 'package:oshi/share/share.dart';
import 'package:oshi/share/translator.dart';
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

  static String cleanHtml(String html) {
    if (html.isEmpty) return html;
    return html
        .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'</p>', caseSensitive: false), '\n\n')
        .replaceAll(RegExp(r'<p[^>]*>', caseSensitive: false), '')
        .replaceAll(RegExp(r'</div>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'</li>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'<li[^>]*>', caseSensitive: false), '\u2022 ')
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&amp;', '&')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&apos;', "'")
        .replaceAll('&ndash;', '\u2013')
        .replaceAll('&mdash;', '\u2014')
        .replaceAll('&oacute;', '\u00F3')
        .replaceAll('&Oacute;', '\u00D3')
        .replaceAllMapped(RegExp(r'&#(\d+);'), (m) {
          final code = int.tryParse(m.group(1)!);
          return code != null ? String.fromCharCode(code) : m.group(0)!;
        })
        .replaceAllMapped(RegExp(r'&#x([0-9a-fA-F]+);'), (m) {
          final code = int.tryParse(m.group(1)!, radix: 16);
          return code != null ? String.fromCharCode(code) : m.group(0)!;
        })
        .replaceAll(RegExp(r'\n{3,}'), '\n\n')
        .trim();
  }

  String? get cleanContent => content != null ? cleanHtml(content!) : null;

  bool get read =>
      receivers != null ||
      (readDate != null &&
          readDate != DateTime(2000) &&
          !readDate!.isAfter(DateTime.now().add(const Duration(days: 1))));

  String get senderName =>
      sender?.name ??
      ((receivers?.isNotEmpty ?? false)
          ? '/Messages/To'.localized.format(receivers?.select((x, index) => x.name).join(', ') ?? '')
          : '94149CBB-5B72-4186-A155-20A9C7FB1B2C'.localized);

  String get previewString {
    final raw = (preview?.isEmpty ?? true) ? (content?.trim() ?? '/Messages/NoPreview'.localized) : preview!.trim();
    return cleanHtml(raw).replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  String get sendDateString {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final msgDay = DateTime(sendDate.year, sendDate.month, sendDate.day);
    if (msgDay == today) {
      return DateFormat.Hm(Share.settings.appSettings.localeCode).format(sendDate);
    }
    if (sendDate.year != now.year) {
      return DateFormat.yMMMd(Share.settings.appSettings.localeCode).format(sendDate);
    }
    return DateFormat.MMMd(Share.settings.appSettings.localeCode).format(sendDate);
  }

  String get readDateString => '/Messages/ReadDate'.localized.format(
      DateFormat.yMMMd(Share.settings.appSettings.localeCode).format(readDate ?? DateTime(2000)),
      DateFormat.Hm(Share.settings.appSettings.localeCode).format(readDate ?? DateTime(2000)));

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
