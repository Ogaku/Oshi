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
      .._customGradeValues =
          fields[1] == null ? {} : (fields[1] as Map).cast<String, double>()
      .._customGradeMarginValues =
          fields[2] == null ? {} : (fields[2] as Map).cast<String, double>()
      .._customGradeModifierValues = fields[3] == null
          ? {'+': 0.5, '-': -0.25}
          : (fields[3] as Map).cast<String, double>()
      .._cupertinoAccentColor = fields[4] == null ? 0 : fields[4] as int
      .._useCupertino = fields[5] == null ? true : fields[5] as bool
      .._languageCode = fields[6] == null ? 'en' : fields[6] as String
      .._weightedAverage = fields[7] == null ? true : fields[7] as bool
      .._autoArithmeticAverage = fields[8] == null ? false : fields[8] as bool
      .._yearlyAverageMethod = fields[9] == null
          ? YearlyAverageMethods.allGradesAverage
          : fields[9] as YearlyAverageMethods
      .._lessonCallTime = fields[10] == null ? 15 : fields[10] as int
      .._lessonCallType = fields[11] == null
          ? LessonCallTypes.countFromEnd
          : fields[11] as LessonCallTypes
      .._bellOffset =
          fields[12] == null ? Duration.zero : fields[12] as Duration
      .._devMode = fields[13] == null ? false : fields[13] as bool
      .._notificationsAskedOnce =
          fields[14] == null ? false : fields[14] as bool;
  }

  @override
  void write(BinaryWriter writer, Config obj) {
    writer
      ..writeByte(14)
      ..writeByte(1)
      ..write(obj._customGradeValues)
      ..writeByte(2)
      ..write(obj._customGradeMarginValues)
      ..writeByte(3)
      ..write(obj._customGradeModifierValues)
      ..writeByte(4)
      ..write(obj._cupertinoAccentColor)
      ..writeByte(5)
      ..write(obj._useCupertino)
      ..writeByte(6)
      ..write(obj._languageCode)
      ..writeByte(7)
      ..write(obj._weightedAverage)
      ..writeByte(8)
      ..write(obj._autoArithmeticAverage)
      ..writeByte(9)
      ..write(obj._yearlyAverageMethod)
      ..writeByte(10)
      ..write(obj._lessonCallTime)
      ..writeByte(11)
      ..write(obj._lessonCallType)
      ..writeByte(12)
      ..write(obj._bellOffset)
      ..writeByte(13)
      ..write(obj._devMode)
      ..writeByte(14)
      ..write(obj._notificationsAskedOnce);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConfigAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Config _$ConfigFromJson(Map<String, dynamic> json) => Config();

Map<String, dynamic> _$ConfigToJson(Config instance) => <String, dynamic>{};
