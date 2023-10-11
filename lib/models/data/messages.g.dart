// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'messages.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Message _$MessageFromJson(Map<String, dynamic> json) => Message(
      id: json['id'] as int? ?? -1,
      url: json['url'] as String? ?? 'https://g.co',
      topic: json['topic'] as String? ?? '',
      content: json['content'] as String?,
      preview: json['preview'] as String?,
      hasAttachments: json['hasAttachments'] as bool? ?? false,
      sender: json['sender'] == null
          ? null
          : Teacher.fromJson(json['sender'] as Map<String, dynamic>),
      sendDate: json['sendDate'] == null
          ? null
          : DateTime.parse(json['sendDate'] as String),
      readDate: json['readDate'] == null
          ? null
          : DateTime.parse(json['readDate'] as String),
      attachments: (json['attachments'] as List<dynamic>?)
          ?.map((e) => _$recordConvert(
                e,
                ($jsonValue) => (
                  location: $jsonValue['location'] as String,
                  name: $jsonValue['name'] as String,
                ),
              ))
          .toList(),
      receivers: (json['receivers'] as List<dynamic>?)
          ?.map((e) => Teacher.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$MessageToJson(Message instance) {
  final val = <String, dynamic>{
    'id': instance.id,
    'url': instance.url,
    'topic': instance.topic,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('content', instance.content);
  writeNotNull('preview', instance.preview);
  val['hasAttachments'] = instance.hasAttachments;
  writeNotNull('sender', instance.sender);
  val['sendDate'] = instance.sendDate.toIso8601String();
  writeNotNull('readDate', instance.readDate?.toIso8601String());
  writeNotNull(
      'attachments',
      instance.attachments
          ?.map((e) => {
                'location': e.location,
                'name': e.name,
              })
          .toList());
  writeNotNull('receivers', instance.receivers);
  return val;
}

$Rec _$recordConvert<$Rec>(
  Object? value,
  $Rec Function(Map) convert,
) =>
    convert(value as Map<String, dynamic>);

Messages _$MessagesFromJson(Map<String, dynamic> json) => Messages(
      received: (json['received'] as List<dynamic>?)
          ?.map((e) => Message.fromJson(e as Map<String, dynamic>))
          .toList(),
      sent: (json['sent'] as List<dynamic>?)
          ?.map((e) => Message.fromJson(e as Map<String, dynamic>))
          .toList(),
      receivers: (json['receivers'] as List<dynamic>?)
          ?.map((e) => Teacher.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$MessagesToJson(Messages instance) => <String, dynamic>{
      'received': instance.received,
      'sent': instance.sent,
      'receivers': instance.receivers,
    };
