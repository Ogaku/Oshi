import 'package:flutter/cupertino.dart';
import 'package:hive/hive.dart';
import 'package:oshi/share/translator.dart';

part 'resources.g.dart';

class Resources {
  static String notificationChannelName = 'oshi_notifications';

  static Map<int, ({CupertinoDynamicColor color, String name})> get cupertinoAccentColors => {
        0: (color: CupertinoColors.systemRed, name: '/Colors/SystemRed'.localized),
        1: (color: CupertinoColors.systemPink, name: '/Colors/SystemPink'.localized),
        2: (color: CupertinoColors.systemOrange, name: '/Colors/SystemOrange'.localized),
        3: (color: CupertinoColors.systemYellow, name: '/Colors/SystemYellow'.localized),
        4: (color: CupertinoColors.systemGreen, name: '/Colors/SystemGreen'.localized),
        5: (color: CupertinoColors.systemMint, name: '/Colors/SystemMint'.localized),
        6: (color: CupertinoColors.systemTeal, name: '/Colors/SystemTeal'.localized),
        7: (color: CupertinoColors.systemCyan, name: '/Colors/SystemCyan'.localized),
        8: (color: CupertinoColors.systemBlue, name: '/Colors/SystemBlue'.localized),
        9: (color: CupertinoColors.systemIndigo, name: '/Colors/SystemIndigo'.localized),
        10: (color: CupertinoColors.systemPurple, name: '/Colors/SystemPurple'.localized)
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
        YearlyAverageMethods.allGradesAverage => '/Enums/YearlyAverageMethods/allGradesAverage'.localized,
        YearlyAverageMethods.averagesAverage => '/Enums/YearlyAverageMethods/averagesAverage'.localized,
        YearlyAverageMethods.finalPlusAverage => '/Enums/YearlyAverageMethods/finalPlusAverage'.localized,
        YearlyAverageMethods.averagePlusFinal => '/Enums/YearlyAverageMethods/averagePlusFinal'.localized,
        YearlyAverageMethods.finalsAverage => '/Enums/YearlyAverageMethods/finalsAverage'.localized
      };
}

extension LessonCallTypesString on LessonCallTypes {
  String get name => switch (this) {
        LessonCallTypes.countFromEnd => '/Enums/LessonCallTypes/countFromEnd'.localized,
        LessonCallTypes.countFromStart => '/Enums/LessonCallTypes/countFromStart'.localized,
        LessonCallTypes.halfLesson => '/Enums/LessonCallTypes/halfLesson'.localized,
        LessonCallTypes.wholeLesson => '/Enums/LessonCallTypes/wholeLesson'.localized
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
