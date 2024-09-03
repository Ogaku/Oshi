// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'announcement.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AnnouncementAdapter extends TypeAdapter<Announcement> {
  @override
  final int typeId = 21;

  @override
  Announcement read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Announcement(
      id: fields[0] as int,
      url: fields[1] as String,
      read: fields[2] as bool,
      subject: fields[3] as String,
      content: fields[4] as String,
      contact: fields[5] as Teacher?,
      startDate: fields[6] as DateTime?,
      endDate: fields[7] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, Announcement obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.url)
      ..writeByte(2)
      ..write(obj.read)
      ..writeByte(3)
      ..write(obj.subject)
      ..writeByte(4)
      ..write(obj.content)
      ..writeByte(5)
      ..write(obj.contact)
      ..writeByte(6)
      ..write(obj.startDate)
      ..writeByte(7)
      ..write(obj.endDate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnnouncementAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Announcement _$AnnouncementFromJson(Map<String, dynamic> json) => Announcement(
      id: (json['id'] as num?)?.toInt() ?? -1,
      url: json['url'] as String? ?? '',
      read: json['read'] as bool? ?? false,
      subject: json['subject'] as String? ?? '',
      content: json['content'] as String? ?? '',
      contact: json['contact'] == null
          ? null
          : Teacher.fromJson(json['contact'] as Map<String, dynamic>),
      startDate: json['startDate'] == null
          ? null
          : DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] == null
          ? null
          : DateTime.parse(json['endDate'] as String),
    );

Map<String, dynamic> _$AnnouncementToJson(Announcement instance) =>
    <String, dynamic>{
      'id': instance.id,
      'url': instance.url,
      'read': instance.read,
      'subject': instance.subject,
      'content': instance.content,
      'contact': instance.contact,
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate.toIso8601String(),
    };
