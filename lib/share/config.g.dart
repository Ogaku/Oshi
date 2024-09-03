// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'config.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ConfigAdapter extends TypeAdapter<Config> {
  @override
  final int typeId = 4;

  @override
  Config read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Config()
      .._useCupertino = fields[1] == null ? true : fields[1] as bool
      .._languageCode = fields[2] == null ? 'en' : fields[2] as String;
  }

  @override
  void write(BinaryWriter writer, Config obj) {
    writer
      ..writeByte(2)
      ..writeByte(1)
      ..write(obj._useCupertino)
      ..writeByte(2)
      ..write(obj._languageCode);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is ConfigAdapter && runtimeType == other.runtimeType && typeId == other.typeId;
}

class SessionConfigAdapter extends TypeAdapter<SessionConfig> {
  @override
  final int typeId = 8;

  @override
  SessionConfig read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SessionConfig()
      .._customGradeValues = fields[1] == null ? {} : (fields[1] as Map).cast<String, double>()
      .._customGradeMarginValues = fields[2] == null ? {} : (fields[2] as Map).cast<String, double>()
      .._customGradeModifierValues = fields[3] == null ? {'+': 0.5, '-': -0.25} : (fields[3] as Map).cast<String, double>()
      .._cupertinoAccentColor = fields[4] == null ? 0 : fields[4] as int
      .._weightedAverage = fields[5] == null ? true : fields[5] as bool
      .._autoArithmeticAverage = fields[6] == null ? false : fields[6] as bool
      .._yearlyAverageMethod = fields[7] == null ? YearlyAverageMethods.allGradesAverage : fields[7] as YearlyAverageMethods
      .._lessonCallTime = fields[8] == null ? 15 : fields[8] as int
      .._lessonCallType = fields[9] == null ? LessonCallTypes.countFromEnd : fields[9] as LessonCallTypes
      .._bellOffset = fields[10] == null ? Duration.zero : fields[10] as Duration
      .._devMode = fields[11] == null ? false : fields[11] as bool
      .._notificationsAskedOnce = fields[12] == null ? false : fields[12] as bool
      .._enableTimetableNotifications = fields[13] == null ? true : fields[13] as bool
      .._enableGradesNotifications = fields[14] == null ? true : fields[14] as bool
      .._enableEventsNotifications = fields[15] == null ? true : fields[15] as bool
      .._enableAttendanceNotifications = fields[16] == null ? true : fields[16] as bool
      .._enableAnnouncementsNotifications = fields[17] == null ? true : fields[17] as bool
      .._enableMessagesNotifications = fields[18] == null ? true : fields[18] as bool
      .._userAvatarImage = fields[19] == null ? '' : fields[19] as String
      .._enableBackgroundSync = fields[20] == null ? true : fields[20] as bool
      .._backgroundSyncWiFiOnly = fields[21] == null ? false : fields[21] as bool
      .._backgroundSyncInterval = fields[22] == null ? 15 : fields[22] as int
      .._allowSzkolnyIntegration = fields[23] == null ? true : fields[23] as bool
      .._shareEventsByDefault = fields[24] == null ? true : fields[24] as bool
      .._customClassrooms = fields[25] == null ? {} : (fields[25] as Map).cast<String, String>();
  }

  @override
  void write(BinaryWriter writer, SessionConfig obj) {
    writer
      ..writeByte(25)
      ..writeByte(1)
      ..write(obj._customGradeValues)
      ..writeByte(2)
      ..write(obj._customGradeMarginValues)
      ..writeByte(3)
      ..write(obj._customGradeModifierValues)
      ..writeByte(4)
      ..write(obj._cupertinoAccentColor)
      ..writeByte(5)
      ..write(obj._weightedAverage)
      ..writeByte(6)
      ..write(obj._autoArithmeticAverage)
      ..writeByte(7)
      ..write(obj._yearlyAverageMethod)
      ..writeByte(8)
      ..write(obj._lessonCallTime)
      ..writeByte(9)
      ..write(obj._lessonCallType)
      ..writeByte(10)
      ..write(obj._bellOffset)
      ..writeByte(11)
      ..write(obj._devMode)
      ..writeByte(12)
      ..write(obj._notificationsAskedOnce)
      ..writeByte(13)
      ..write(obj._enableTimetableNotifications)
      ..writeByte(14)
      ..write(obj._enableGradesNotifications)
      ..writeByte(15)
      ..write(obj._enableEventsNotifications)
      ..writeByte(16)
      ..write(obj._enableAttendanceNotifications)
      ..writeByte(17)
      ..write(obj._enableAnnouncementsNotifications)
      ..writeByte(18)
      ..write(obj._enableMessagesNotifications)
      ..writeByte(19)
      ..write(obj._userAvatarImage)
      ..writeByte(20)
      ..write(obj._enableBackgroundSync)
      ..writeByte(21)
      ..write(obj._backgroundSyncWiFiOnly)
      ..writeByte(22)
      ..write(obj._backgroundSyncInterval)
      ..writeByte(23)
      ..write(obj._allowSzkolnyIntegration)
      ..writeByte(24)
      ..write(obj._shareEventsByDefault)
      ..writeByte(25)
      ..write(obj._customClassrooms);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is SessionConfigAdapter && runtimeType == other.runtimeType && typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Config _$ConfigFromJson(Map<String, dynamic> json) => Config();

Map<String, dynamic> _$ConfigToJson(Config instance) => <String, dynamic>{};

SessionConfig _$SessionConfigFromJson(Map<String, dynamic> json) => SessionConfig();

Map<String, dynamic> _$SessionConfigToJson(SessionConfig instance) => <String, dynamic>{};
