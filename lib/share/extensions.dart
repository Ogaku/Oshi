// ignore_for_file: prefer_const_constructors

import 'package:darq/darq.dart';
import 'package:duration/duration.dart';
import 'package:duration/locale.dart';
import 'package:oshi/share/resources.dart';
import 'package:oshi/share/share.dart';
import 'package:oshi/share/translator.dart';

extension ListExtension<T> on List<T> {
  Iterable<T> intersperse(T element) sync* {
    for (int i = 0; i < length; i++) {
      yield this[i];
      if (length != i + 1) yield element;
    }
  }
}

extension ListAppendExtension<T> on Iterable<T> {
  List<T> appendIf(T element, bool condition) {
    if (!condition) return toList();
    return append(element).toList();
  }

  List<T> prependIf(T element, bool condition) {
    if (!condition) return toList();
    return prepend(element).toList();
  }

  List<T> appendAllIf(Iterable<T> element, bool condition) {
    if (!condition) return toList();
    return appendAll(element).toList();
  }

  List<T> prependAllIf(Iterable<T> element, bool condition) {
    if (!condition) return toList();
    return prependAll(element).toList();
  }

  List<T> appendIfEmpty(T element) {
    return appendIf(element, isEmpty).toList();
  }

  List<T> prependIfEmpty(T element) {
    return prependIf(element, isEmpty).toList();
  }

  List<T> appendAllIfEmpty(Iterable<T> element) {
    return appendAllIf(element, isEmpty).toList();
  }

  List<T> prependAllIfEmpty(Iterable<T> element) {
    return prependAllIf(element, isEmpty).toList();
  }
}

extension LessonNumber on int {
  String asLessonNumber() => switch (this) {
        1 => '$this ${"/Home/Counters/Lessons/Singular".localized}', // "lekcja"
        >= 2 && < 5 ||
        _ when this % 10 >= 2 && this % 10 < 5 =>
          '$this ${"/Home/Counters/Lessons/Plural/Start".localized}', // "lekcje"
        >= 5 && < 22 ||
        _ when (this % 10 >= 5 && this % 10 < 9) || (this % 10 >= 0 && this % 10 < 2) =>
          '$this ${"/Home/Counters/Lessons/Plural/End".localized}', // "lekcji"
        _ => '$this ${"/Home/Counters/Lessons/Plural/End".localized}' // "lekcji"
        // Note for other languages:
        // stackoverflow.com/a/76413634
      };

  String asTimetablesNumber([RegisterChangeTypes? changeType]) {
    var modifier = switch (changeType) {
      RegisterChangeTypes.added => '/New',
      RegisterChangeTypes.changed => '/Updated',
      RegisterChangeTypes.removed => '/Removed',
      _ => '/Both',
    };
    return switch (this) {
      1 => '$this ${"/Timeline/Lang/Counters/Timetables$modifier/Singular".localized}', // "lekcja"
      >= 2 && < 5 ||
      _ when this % 10 >= 2 && this % 10 < 5 =>
        '$this ${"/Timeline/Lang/Counters/Timetables$modifier/Plural/Start".localized}', // "lekcje"
      >= 5 && < 22 ||
      _ when (this % 10 >= 5 && this % 10 < 9) || (this % 10 >= 0 && this % 10 < 2) =>
        '$this ${"/Timeline/Lang/Counters/Timetables$modifier/Plural/End".localized}', // "lekcji"
      _ => '$this ${"/Timeline/Lang/Counters/Timetables$modifier/Plural/End".localized}' // "lekcji"
      // Note for other languages:
      // stackoverflow.com/a/76413634
    };
  }

  String asGradesNumber([RegisterChangeTypes? changeType]) {
    var modifier = switch (changeType) {
      RegisterChangeTypes.added => '/New',
      RegisterChangeTypes.changed => '/Updated',
      RegisterChangeTypes.removed => '/Removed',
      _ => '/Both',
    };
    return switch (this) {
      1 => '$this ${"/Timeline/Lang/Counters/Grades$modifier/Singular".localized}', // "lekcja"
      >= 2 && < 5 ||
      _ when this % 10 >= 2 && this % 10 < 5 =>
        '$this ${"/Timeline/Lang/Counters/Grades$modifier/Plural/Start".localized}', // "lekcje"
      >= 5 && < 22 ||
      _ when (this % 10 >= 5 && this % 10 < 9) || (this % 10 >= 0 && this % 10 < 2) =>
        '$this ${"/Timeline/Lang/Counters/Grades$modifier/Plural/End".localized}', // "lekcji"
      _ => '$this ${"/Timeline/Lang/Counters/Grades$modifier/Plural/End".localized}' // "lekcji"
      // Note for other languages:
      // stackoverflow.com/a/76413634
    };
  }

  String asEventsNumber([RegisterChangeTypes? changeType]) {
    var modifier = switch (changeType) {
      RegisterChangeTypes.added => '/New',
      RegisterChangeTypes.changed => '/Updated',
      RegisterChangeTypes.removed => '/Removed',
      _ => '/Both',
    };
    return switch (this) {
      1 => '$this ${"/Timeline/Lang/Counters/Events$modifier/Singular".localized}', // "lekcja"
      >= 2 && < 5 ||
      _ when this % 10 >= 2 && this % 10 < 5 =>
        '$this ${"/Timeline/Lang/Counters/Events$modifier/Plural/Start".localized}', // "lekcje"
      >= 5 && < 22 ||
      _ when (this % 10 >= 5 && this % 10 < 9) || (this % 10 >= 0 && this % 10 < 2) =>
        '$this ${"/Timeline/Lang/Counters/Events$modifier/Plural/End".localized}', // "lekcji"
      _ => '$this ${"/Timeline/Lang/Counters/Events$modifier/Plural/End".localized}' // "lekcji"
      // Note for other languages:
      // stackoverflow.com/a/76413634
    };
  }

  String asAnnouncementsNumber([RegisterChangeTypes? changeType]) {
    var modifier = switch (changeType) {
      RegisterChangeTypes.added => '/New',
      RegisterChangeTypes.changed => '/Updated',
      RegisterChangeTypes.removed => '/Removed',
      _ => '/Both',
    };
    return switch (this) {
      1 => '$this ${"/Timeline/Lang/Counters/Announcements$modifier/Singular".localized}', // "lekcja"
      >= 2 && < 5 ||
      _ when this % 10 >= 2 && this % 10 < 5 =>
        '$this ${"/Timeline/Lang/Counters/Announcements$modifier/Plural/Start".localized}', // "lekcje"
      >= 5 && < 22 ||
      _ when (this % 10 >= 5 && this % 10 < 9) || (this % 10 >= 0 && this % 10 < 2) =>
        '$this ${"/Timeline/Lang/Counters/Announcements$modifier/Plural/End".localized}', // "lekcji"
      _ => '$this ${"/Timeline/Lang/Counters/Announcements$modifier/Plural/End".localized}' // "lekcji"
      // Note for other languages:
      // stackoverflow.com/a/76413634
    };
  }

  String asMessagesNumber([RegisterChangeTypes? changeType]) {
    var modifier = switch (changeType) {
      RegisterChangeTypes.added => '/New',
      RegisterChangeTypes.changed => '/Updated',
      RegisterChangeTypes.removed => '/Removed',
      _ => '/Both',
    };
    return switch (this) {
      1 => '$this ${"/Timeline/Lang/Counters/Messages$modifier/Singular".localized}', // "lekcja"
      >= 2 && < 5 ||
      _ when this % 10 >= 2 && this % 10 < 5 =>
        '$this ${"/Timeline/Lang/Counters/Messages$modifier/Plural/Start".localized}', // "lekcje"
      >= 5 && < 22 ||
      _ when (this % 10 >= 5 && this % 10 < 9) || (this % 10 >= 0 && this % 10 < 2) =>
        '$this ${"/Timeline/Lang/Counters/Messages$modifier/Plural/End".localized}', // "lekcji"
      _ => '$this ${"/Timeline/Lang/Counters/Messages$modifier/Plural/End".localized}' // "lekcji"
      // Note for other languages:
      // stackoverflow.com/a/76413634
    };
  }

  String asAttendancesNumber([RegisterChangeTypes? changeType]) {
    var modifier = switch (changeType) {
      RegisterChangeTypes.added => '/New',
      RegisterChangeTypes.changed => '/Updated',
      RegisterChangeTypes.removed => '/Removed',
      _ => '/Both',
    };
    return switch (this) {
      1 => '$this ${"/Timeline/Lang/Counters/Attendances$modifier/Singular".localized}', // "lekcja"
      >= 2 && < 5 ||
      _ when this % 10 >= 2 && this % 10 < 5 =>
        '$this ${"/Timeline/Lang/Counters/Attendances$modifier/Plural/Start".localized}', // "lekcje"
      >= 5 && < 22 ||
      _ when (this % 10 >= 5 && this % 10 < 9) || (this % 10 >= 0 && this % 10 < 2) =>
        '$this ${"/Timeline/Lang/Counters/Attendances$modifier/Plural/End".localized}', // "lekcji"
      _ => '$this ${"/Timeline/Lang/Counters/Attendances$modifier/Plural/End".localized}' // "lekcji"
      // Note for other languages:
      // stackoverflow.com/a/76413634
    };
  }
}

extension Pretty on Duration {
  String get prettyBellString => prettyDuration(abs() + Share.session.settings.bellOffset,
      tersity: abs() < Duration(minutes: 1) ? DurationTersity.second : DurationTersity.minute,
      upperTersity: DurationTersity.minute,
      abbreviated: abs() < Duration(minutes: 1),
      conjunction: ', ',
      locale: DurationLocale.fromLanguageCode(Share.settings.appSettings.localeCode) ?? EnglishDurationLocale());
}

extension DateTimeExtension on DateTime {
  bool isAfterOrSame(DateTime? other) => this == other || isAfter(other ?? DateTime.now());
  bool isBeforeOrSame(DateTime? other) => this == other || isBefore(other ?? DateTime.now());
  DateTime withTime(DateTime? other) =>
      other == null ? this : DateTime(year, month, day, other.hour, other.minute, other.second);
  DateTime asHour([DateTime? other]) => (other ?? DateTime(2000)).withTime(this);

  bool isAfterOrEqualTo(DateTime dateTime) {
    final isAtSameMomentAs = dateTime.isAtSameMomentAs(this);
    return isAtSameMomentAs | isAfter(dateTime);
  }

  bool isBeforeOrEqualTo(DateTime dateTime) {
    final isAtSameMomentAs = dateTime.isAtSameMomentAs(this);
    return isAtSameMomentAs | isBefore(dateTime);
  }

  bool isBetween(
    DateTime fromDateTime,
    DateTime toDateTime,
  ) {
    final isAfter = isAfterOrEqualTo(fromDateTime);
    final isBefore = isBeforeOrEqualTo(toDateTime);
    return isAfter && isBefore;
  }
}
