import 'package:flutter/cupertino.dart';
import 'package:hive/hive.dart';

part 'resources.g.dart';

class Resources {
  static String notificationChannelName = 'oshi_notifications';

  static Map<int, ({CupertinoDynamicColor color, String name})> cupertinoAccentColors = {
    0: (color: CupertinoColors.systemRed, name: 'System Red'),
    1: (color: CupertinoColors.systemPink, name: 'System Pink'),
    2: (color: CupertinoColors.systemOrange, name: 'System Orange'),
    3: (color: CupertinoColors.systemYellow, name: 'System Yellow'),
    4: (color: CupertinoColors.systemGreen, name: 'System Green'),
    5: (color: CupertinoColors.systemMint, name: 'System Mint'),
    6: (color: CupertinoColors.systemTeal, name: 'System Teal'),
    7: (color: CupertinoColors.systemCyan, name: 'System Cyan'),
    8: (color: CupertinoColors.systemBlue, name: 'System Blue'),
    9: (color: CupertinoColors.systemIndigo, name: 'System Indigo'),
    10: (color: CupertinoColors.systemPurple, name: 'System Purple')
  };
}

@HiveType(typeId: 5)
enum YearlyAverageMethods {
  @HiveField(1)
  allGradesAverage,
  @HiveField(2)
  averagesAverage,
  @HiveField(3)
  finalPlusAverage,
  @HiveField(4)
  averagePlusFinal,
  @HiveField(5)
  finalsAverage
}

@HiveType(typeId: 6)
enum LessonCallTypes {
  @HiveField(1)
  countFromEnd,
  @HiveField(2)
  countFromStart,
  @HiveField(3)
  halfLesson,
  @HiveField(4)
  wholeLesson
}

@HiveType(typeId: 7)
enum RegisterChangeTypes {
  @HiveField(1)
  added,
  @HiveField(2)
  changed,
  @HiveField(3)
  removed
}

extension YearlyAverageMethodsString on YearlyAverageMethods {
  String get name => switch (this) {
        YearlyAverageMethods.allGradesAverage => 'Average of all grades',
        YearlyAverageMethods.averagesAverage => 'Average of semester averages',
        YearlyAverageMethods.finalPlusAverage => '1. sem final + 2. sem average',
        YearlyAverageMethods.averagePlusFinal => '1. sem average + 2. sem final',
        YearlyAverageMethods.finalsAverage => 'Average of the final grades'
      };
}

extension LessonCallTypesString on LessonCallTypes {
  String get name => switch (this) {
        LessonCallTypes.countFromEnd => 'Count from the end',
        LessonCallTypes.countFromStart => 'Count from beginning',
        LessonCallTypes.halfLesson => 'Half of the lesson',
        LessonCallTypes.wholeLesson => 'Whole lesson'
      };
}

/// Returns a `hashCode` for [props].
int mapPropsToHashCode(Iterable? props) => _finish(props == null ? 0 : props.fold(0, _combine));

/// Jenkins Hash Functions
/// https://en.wikipedia.org/wiki/Jenkins_hash_function
int _combine(int hash, dynamic object) {
  if (object is Map) {
    object.keys.sorted((dynamic a, dynamic b) => a.hashCode - b.hashCode).forEach((dynamic key) {
      hash = hash ^ _combine(hash, <dynamic>[key, object[key]]);
    });
    return hash;
  }
  if (object is Set) {
    object = object.sorted(((dynamic a, dynamic b) => a.hashCode - b.hashCode));
  }
  if (object is Iterable) {
    for (final value in object) {
      hash = hash ^ _combine(hash, value);
    }
    return hash ^ object.length;
  }

  hash = 0x1fffffff & (hash + object.hashCode);
  hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
  return hash ^ (hash >> 6);
}

int _finish(int hash) {
  hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
  hash = hash ^ (hash >> 11);
  return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
}

/// Returns a string for [props].
String mapPropsToString(Type runtimeType, List<Object?> props) =>
    '$runtimeType(${props.map((prop) => prop.toString()).join(', ')})';

extension IterableExtension<T> on Iterable<T> {
  /// Creates a sorted list of the elements of the iterable.
  ///
  /// The elements are ordered by the [compare] [Comparator].
  List<T> sorted(Comparator<T> compare) => [...this]..sort(compare);
}
