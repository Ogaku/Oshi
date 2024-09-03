// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'messages.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MessageAdapter extends TypeAdapter<Message> {
  @override
  final int typeId = 28;

  @override
  Message read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Message(
      id: fields[1] as int,
      url: fields[2] as String,
      topic: fields[3] as String,
      content: fields[4] as String?,
      preview: fields[5] as String?,
      hasAttachments: fields[6] as bool,
      sender: fields[7] as Teacher?,
      sendDate: fields[8] as DateTime?,
      readDate: fields[9] as DateTime?,
      attachments: (fields[10] as List?)?.cast<Attachment>(),
      receivers: (fields[11] as List?)?.cast<Teacher>(),
    );
  }

  @override
  void write(BinaryWriter writer, Message obj) {
    writer
      ..writeByte(11)
      ..writeByte(1)
      ..write(obj.id)
      ..writeByte(2)
      ..write(obj.url)
      ..writeByte(3)
      ..write(obj.topic)
      ..writeByte(4)
      ..write(obj.content)
      ..writeByte(5)
      ..write(obj.preview)
      ..writeByte(6)
      ..write(obj.hasAttachments)
      ..writeByte(7)
      ..write(obj.sender)
      ..writeByte(8)
      ..write(obj.sendDate)
      ..writeByte(9)
      ..write(obj.readDate)
      ..writeByte(10)
      ..write(obj.attachments)
      ..writeByte(11)
      ..write(obj.receivers);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MessageAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MessagesAdapter extends TypeAdapter<Messages> {
  @override
  final int typeId = 29;

  @override
  Messages read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Messages(
      received: (fields[1] as List?)?.cast<Message>(),
      sent: (fields[2] as List?)?.cast<Message>(),
      receivers: (fields[3] as List?)?.cast<Teacher>(),
    );
  }

  @override
  void write(BinaryWriter writer, Messages obj) {
    writer
      ..writeByte(3)
      ..writeByte(1)
      ..write(obj.received)
      ..writeByte(2)
      ..write(obj.sent)
      ..writeByte(3)
      ..write(obj.receivers);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MessagesAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AttachmentAdapter extends TypeAdapter<Attachment> {
  @override
  final int typeId = 99;

  @override
  Attachment read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Attachment(
      name: fields[1] as String?,
      location: fields[2] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Attachment obj) {
    writer
      ..writeByte(2)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.location);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AttachmentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Message _$MessageFromJson(Map<String, dynamic> json) => Message(
      id: (json['id'] as num?)?.toInt() ?? -1,
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
          ?.map((e) => Attachment.fromJson(e as Map<String, dynamic>))
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
  writeNotNull('attachments', instance.attachments);
  writeNotNull('receivers', instance.receivers);
  return val;
}

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

Attachment _$AttachmentFromJson(Map<String, dynamic> json) => Attachment(
      name: json['name'] as String?,
      location: json['location'] as String?,
    );

Map<String, dynamic> _$AttachmentToJson(Attachment instance) =>
    <String, dynamic>{
      'name': instance.name,
      'location': instance.location,
    };
