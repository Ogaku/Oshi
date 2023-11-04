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
    return Config(
      useCupertino: fields[5] as bool?,
    )
      .._customGradeValues = (fields[1] as Map).cast<String, double>()
      .._customGradeMarginValues = (fields[2] as Map).cast<String, double>()
      .._customGradeModifierValues = (fields[3] as Map).cast<String, double>()
      .._cupertinoAccentColor = fields[4] as int
      .._languageCode = fields[6] as String;
  }

  @override
  void write(BinaryWriter writer, Config obj) {
    writer
      ..writeByte(6)
      ..writeByte(1)
      ..write(obj._customGradeValues)
      ..writeByte(2)
      ..write(obj._customGradeMarginValues)
      ..writeByte(3)
      ..write(obj._customGradeModifierValues)
      ..writeByte(4)
      ..write(obj._cupertinoAccentColor)
      ..writeByte(5)
      ..write(obj.useCupertino)
      ..writeByte(6)
      ..write(obj._languageCode);
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

Config _$ConfigFromJson(Map<String, dynamic> json) => Config(
      useCupertino: json['useCupertino'] as bool?,
    );

Map<String, dynamic> _$ConfigToJson(Config instance) => <String, dynamic>{
      'useCupertino': instance.useCupertino,
    };
