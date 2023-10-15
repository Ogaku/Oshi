// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'share.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SessionsDataAdapter extends TypeAdapter<SessionsData> {
  @override
  final int typeId = 2;

  @override
  SessionsData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SessionsData(
      sessions: (fields[2] as Map?)?.cast<String, Session>(),
      lastSessionId: fields[1] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, SessionsData obj) {
    writer
      ..writeByte(2)
      ..writeByte(1)
      ..write(obj.lastSessionId)
      ..writeByte(2)
      ..write(obj.sessions);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SessionsDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SessionAdapter extends TypeAdapter<Session> {
  @override
  final int typeId = 3;

  @override
  Session read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Session(
      sessionName: fields[1] as String,
      providerGuid: fields[5] as String,
    )
      ..sessionCredentials = (fields[2] as Map).cast<String, String>()
      ..data = fields[4] as ProviderData;
  }

  @override
  void write(BinaryWriter writer, Session obj) {
    writer
      ..writeByte(4)
      ..writeByte(1)
      ..write(obj.sessionName)
      ..writeByte(5)
      ..write(obj.providerGuid)
      ..writeByte(2)
      ..write(obj.sessionCredentials)
      ..writeByte(4)
      ..write(obj.data);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SessionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SessionsData _$SessionsDataFromJson(Map<String, dynamic> json) => SessionsData(
      sessions: (json['sessions'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, Session.fromJson(e as Map<String, dynamic>)),
      ),
      lastSessionId: json['lastSessionId'] as String? ??
          'SESSIONS-SHIM-SMPL-FAKE-DATAPROVIDER',
    );

Map<String, dynamic> _$SessionsDataToJson(SessionsData instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('lastSessionId', instance.lastSessionId);
  val['sessions'] = instance.sessions;
  return val;
}

Session _$SessionFromJson(Map<String, dynamic> json) => Session(
      sessionName: json['sessionName'] as String? ?? 'John Doe',
      providerGuid: json['providerGuid'] as String? ??
          'PROVGUID-SHIM-SMPL-FAKE-DATAPROVIDER',
    )
      ..sessionCredentials =
          Map<String, String>.from(json['sessionCredentials'] as Map)
      ..data = ProviderData.fromJson(json['data'] as Map<String, dynamic>);

Map<String, dynamic> _$SessionToJson(Session instance) => <String, dynamic>{
      'sessionName': instance.sessionName,
      'providerGuid': instance.providerGuid,
      'sessionCredentials': instance.sessionCredentials,
      'data': instance.data,
    };
