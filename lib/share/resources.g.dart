// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'resources.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class YearlyAverageMethodsAdapter extends TypeAdapter<YearlyAverageMethods> {
  @override
  final int typeId = 5;

  @override
  YearlyAverageMethods read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 1:
        return YearlyAverageMethods.allGradesAverage;
      case 2:
        return YearlyAverageMethods.averagesAverage;
      case 3:
        return YearlyAverageMethods.finalPlusAverage;
      case 4:
        return YearlyAverageMethods.averagePlusFinal;
      case 5:
        return YearlyAverageMethods.finalsAverage;
      default:
        return YearlyAverageMethods.allGradesAverage;
    }
  }

  @override
  void write(BinaryWriter writer, YearlyAverageMethods obj) {
    switch (obj) {
      case YearlyAverageMethods.allGradesAverage:
        writer.writeByte(1);
        break;
      case YearlyAverageMethods.averagesAverage:
        writer.writeByte(2);
        break;
      case YearlyAverageMethods.finalPlusAverage:
        writer.writeByte(3);
        break;
      case YearlyAverageMethods.averagePlusFinal:
        writer.writeByte(4);
        break;
      case YearlyAverageMethods.finalsAverage:
        writer.writeByte(5);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is YearlyAverageMethodsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class LessonCallTypesAdapter extends TypeAdapter<LessonCallTypes> {
  @override
  final int typeId = 6;

  @override
  LessonCallTypes read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 1:
        return LessonCallTypes.countFromEnd;
      case 2:
        return LessonCallTypes.countFromStart;
      case 3:
        return LessonCallTypes.halfLesson;
      case 4:
        return LessonCallTypes.wholeLesson;
      default:
        return LessonCallTypes.countFromEnd;
    }
  }

  @override
  void write(BinaryWriter writer, LessonCallTypes obj) {
    switch (obj) {
      case LessonCallTypes.countFromEnd:
        writer.writeByte(1);
        break;
      case LessonCallTypes.countFromStart:
        writer.writeByte(2);
        break;
      case LessonCallTypes.halfLesson:
        writer.writeByte(3);
        break;
      case LessonCallTypes.wholeLesson:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LessonCallTypesAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
