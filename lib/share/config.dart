// ignore_for_file: prefer_final_fields
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:oshi/share/platform.dart';
import 'package:universal_io/io.dart';
import 'dart:typed_data';

import 'package:darq/darq.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/date_symbol_data_file.dart';
import 'package:oshi/share/resources.dart';

import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:oshi/share/share.dart';
import 'package:path_provider/path_provider.dart';

part 'config.g.dart';

@HiveType(typeId: 4)
@JsonSerializable(includeIfNull: false)
class Config with ChangeNotifier {
  Config({
    bool? useCupertino,
    String? languageCode,
  })  : _useCupertino = useCupertino ?? (!isIOS),
        _languageCode = languageCode ?? 'en';

  // TODO All HiveFields should be private and trigger a settings save

  @HiveField(1, defaultValue: true) // TODO Change to false when done
  bool _useCupertino;

  @HiveField(2, defaultValue: 'en')
  String _languageCode;

  @JsonKey(includeToJson: false, includeFromJson: false)
  String get languageCode => Share.translator.supportedLanguages.any((x) => x.code == _languageCode)
      ? _languageCode
      : (Share.translator.supportedLanguages.firstOrDefault()?.code ?? 'en');

  @JsonKey(includeToJson: false, includeFromJson: false)
  String get localeCode => availableLocalesForDateFormatting.contains(_languageCode) ? _languageCode : 'en';

  @JsonKey(includeToJson: false, includeFromJson: false)
  bool get useCupertino => _useCupertino;

  set languageCode(String code) {
    _languageCode = code;
    notifyListeners();
    Share.settings.save();
  }

  set useCupertino(bool value) {
    _useCupertino = value;
    notifyListeners();
    Share.settings.save();
  }

  factory Config.fromJson(Map<String, dynamic> json) => _$ConfigFromJson(json);

  Map<String, dynamic> toJson() => _$ConfigToJson(this);
}

@HiveType(typeId: 8)
@JsonSerializable(includeIfNull: false)
class SessionConfig with ChangeNotifier {
  SessionConfig({
    Map<String, double>? customGradeValues,
    Map<String, double>? customGradeMarginValues,
    Map<String, double>? customGradeModifierValues,
    int? cupertinoAccentColor,
    bool? weightedAverage,
    bool? autoArithmeticAverage,
    YearlyAverageMethods? yearlyAverageMethod,
    int? lessonCallTime,
    LessonCallTypes? lessonCallType,
    Duration? bellOffset,
    bool? devMode,
    bool? notificationsAskedOnce,
    bool? enableTimetableNotifications,
    bool? enableGradesNotifications,
    bool? enableEventsNotifications,
    bool? enableAttendanceNotifications,
    bool? enableAnnouncementsNotifications,
    bool? enableMessagesNotifications,
    String? userAvatarImage,
    bool? enableBackgroundSync,
    bool? backgroundSyncWiFiOnly,
    int? backgroundSyncInterval,
    bool? allowSzkolnyIntegration,
    bool? shareEventsByDefault,
  })  : _customGradeValues = customGradeValues ?? {},
        _customGradeMarginValues = customGradeMarginValues ?? {},
        _customGradeModifierValues = customGradeModifierValues ?? {'+': 0.5, '-': -0.25},
        _cupertinoAccentColor = cupertinoAccentColor ?? Resources.cupertinoAccentColors.keys.first,
        _weightedAverage = weightedAverage ?? true,
        _autoArithmeticAverage = autoArithmeticAverage ?? false,
        _yearlyAverageMethod = yearlyAverageMethod ?? YearlyAverageMethods.allGradesAverage,
        _lessonCallTime = lessonCallTime ?? 15,
        _lessonCallType = lessonCallType ?? LessonCallTypes.countFromEnd,
        _bellOffset = bellOffset ?? Duration.zero,
        _devMode = devMode ?? false,
        _notificationsAskedOnce = notificationsAskedOnce ?? false,
        _enableTimetableNotifications = enableTimetableNotifications ?? true,
        _enableGradesNotifications = enableGradesNotifications ?? true,
        _enableEventsNotifications = enableEventsNotifications ?? true,
        _enableAttendanceNotifications = enableAttendanceNotifications ?? true,
        _enableAnnouncementsNotifications = enableAnnouncementsNotifications ?? true,
        _enableMessagesNotifications = enableMessagesNotifications ?? true,
        _userAvatarImage = userAvatarImage ?? '',
        _enableBackgroundSync = enableBackgroundSync ?? true,
        _backgroundSyncWiFiOnly = backgroundSyncWiFiOnly ?? false,
        _backgroundSyncInterval = backgroundSyncInterval ?? 15,
        _allowSzkolnyIntegration = allowSzkolnyIntegration ?? true,
        _shareEventsByDefault = shareEventsByDefault ?? true;

  // TODO All HiveFields should be private and trigger a settings save

  @HiveField(1, defaultValue: {})
  Map<String, double> _customGradeValues;

  @HiveField(2, defaultValue: {})
  Map<String, double> _customGradeMarginValues;

  @HiveField(3, defaultValue: {'+': 0.5, '-': -0.25})
  Map<String, double> _customGradeModifierValues;

  @HiveField(4, defaultValue: 0)
  int _cupertinoAccentColor;

  @HiveField(5, defaultValue: true)
  bool _weightedAverage;

  @HiveField(6, defaultValue: false)
  bool _autoArithmeticAverage;

  @HiveField(7, defaultValue: YearlyAverageMethods.allGradesAverage)
  YearlyAverageMethods _yearlyAverageMethod;

  @HiveField(8, defaultValue: 15)
  int _lessonCallTime;

  @HiveField(9, defaultValue: LessonCallTypes.countFromEnd)
  LessonCallTypes _lessonCallType;

  @HiveField(10, defaultValue: Duration.zero)
  Duration _bellOffset;

  @HiveField(11, defaultValue: false)
  bool _devMode;

  @HiveField(12, defaultValue: false)
  bool _notificationsAskedOnce;

  @HiveField(13, defaultValue: true)
  bool _enableTimetableNotifications;

  @HiveField(14, defaultValue: true)
  bool _enableGradesNotifications;

  @HiveField(15, defaultValue: true)
  bool _enableEventsNotifications;

  @HiveField(16, defaultValue: true)
  bool _enableAttendanceNotifications;

  @HiveField(17, defaultValue: true)
  bool _enableAnnouncementsNotifications;

  @HiveField(18, defaultValue: true)
  bool _enableMessagesNotifications;

  @HiveField(19, defaultValue: '')
  String _userAvatarImage;

  @HiveField(20, defaultValue: !kIsWeb)
  bool _enableBackgroundSync;

  @HiveField(21, defaultValue: false)
  bool _backgroundSyncWiFiOnly;

  @HiveField(22, defaultValue: 15)
  int _backgroundSyncInterval;

  @HiveField(23, defaultValue: true)
  bool _allowSzkolnyIntegration;

  @HiveField(24, defaultValue: true)
  bool _shareEventsByDefault;

  @JsonKey(includeToJson: false, includeFromJson: false)
  Map<String, double> get customGradeValues => _customGradeValues;

  @JsonKey(includeToJson: false, includeFromJson: false)
  Map<String, double> get customGradeMarginValues => _customGradeMarginValues;

  @JsonKey(includeToJson: false, includeFromJson: false)
  Map<String, double> get customGradeModifierValues => _customGradeModifierValues;

  @JsonKey(includeToJson: false, includeFromJson: false)
  Map<double, double> get customGradeMarginValuesMap => customGradeMarginValues.entries
      .orderByDescending((x) => double.tryParse(x.key) ?? -1)
      .toMap((x) => MapEntry<double, double>(double.tryParse(x.key) ?? -1, x.value));

  @JsonKey(includeToJson: false, includeFromJson: false)
  ({CupertinoDynamicColor color, String name}) get cupertinoAccentColor =>
      Resources.cupertinoAccentColors[_cupertinoAccentColor] ?? Resources.cupertinoAccentColors.values.first;

  @JsonKey(includeToJson: false, includeFromJson: false)
  bool get weightedAverage => _weightedAverage;

  @JsonKey(includeToJson: false, includeFromJson: false)
  bool get autoArithmeticAverage => _autoArithmeticAverage;

  @JsonKey(includeToJson: false, includeFromJson: false)
  YearlyAverageMethods get yearlyAverageMethod => _yearlyAverageMethod;

  @JsonKey(includeToJson: false, includeFromJson: false)
  int get lessonCallTime => _lessonCallTime;

  @JsonKey(includeToJson: false, includeFromJson: false)
  LessonCallTypes get lessonCallType => _lessonCallType;

  @JsonKey(includeToJson: false, includeFromJson: false)
  Duration get bellOffset => _bellOffset;

  @JsonKey(includeToJson: false, includeFromJson: false)
  bool get devMode => _devMode;

  @JsonKey(includeToJson: false, includeFromJson: false)
  bool get notificationsAskedOnce => _notificationsAskedOnce;

  @JsonKey(includeToJson: false, includeFromJson: false)
  bool get enableTimetableNotifications => _enableTimetableNotifications;

  @JsonKey(includeToJson: false, includeFromJson: false)
  bool get enableGradesNotifications => _enableGradesNotifications;

  @JsonKey(includeToJson: false, includeFromJson: false)
  bool get enableEventsNotifications => _enableEventsNotifications;

  @JsonKey(includeToJson: false, includeFromJson: false)
  bool get enableAttendanceNotifications => _enableAttendanceNotifications;

  @JsonKey(includeToJson: false, includeFromJson: false)
  bool get enableAnnouncementsNotifications => _enableAnnouncementsNotifications;

  @JsonKey(includeToJson: false, includeFromJson: false)
  bool get enableMessagesNotifications => _enableMessagesNotifications;

  @JsonKey(includeToJson: false, includeFromJson: false)
  Uint8List? get userAvatar {
    try {
      return base64Decode(_userAvatarImage);
    } catch (ex) {
      return null;
    }
  }

  @JsonKey(includeToJson: false, includeFromJson: false)
  Future<Image?> get userAvatarImage async {
    try {
      if (userAvatar?.isEmpty ?? true) return null;

      return Image.file((await File(
              '${(await getApplicationDocumentsDirectory()).path}/useravatar.${_getBase64FileExtension(_userAvatarImage)}')
          .writeAsBytes(List.from(userAvatar!))));
    } catch (ex) {
      return null;
    }
  }

  @JsonKey(includeToJson: false, includeFromJson: false)
  bool get enableBackgroundSync => _enableBackgroundSync;

  @JsonKey(includeToJson: false, includeFromJson: false)
  bool get allowSzkolnyIntegration => _allowSzkolnyIntegration;

  @JsonKey(includeToJson: false, includeFromJson: false)
  bool get shareEventsByDefault => _shareEventsByDefault;

  @JsonKey(includeToJson: false, includeFromJson: false)
  bool get backgroundSyncWiFiOnly => _backgroundSyncWiFiOnly;

  @JsonKey(includeToJson: false, includeFromJson: false)
  int get backgroundSyncInterval => _backgroundSyncInterval;

  set customGradeValues(Map<String, double> customGradeValues) {
    _customGradeValues = customGradeValues;
    notifyListeners();
    Share.settings.save();
  }

  set customGradeMarginValues(Map<String, double> customGradeMarginValues) {
    _customGradeMarginValues = customGradeMarginValues;
    notifyListeners();
    Share.settings.save();
  }

  set customGradeModifierValues(Map<String, double> customGradeModifierValues) {
    _customGradeModifierValues = customGradeModifierValues;
    notifyListeners();
    Share.settings.save();
  }

  set cupertinoAccentColor(({CupertinoDynamicColor color, String name}) cupertinoAccentColor) {
    _cupertinoAccentColor =
        Resources.cupertinoAccentColors.entries.firstWhereOrDefault((value) => value.value == cupertinoAccentColor)?.key ??
            0;
    notifyListeners();
    Share.settings.save();
  }

  set weightedAverage(bool value) {
    _weightedAverage = value;
    notifyListeners();
    Share.settings.save();
  }

  set autoArithmeticAverage(bool value) {
    _autoArithmeticAverage = value;
    notifyListeners();
    Share.settings.save();
  }

  set yearlyAverageMethod(YearlyAverageMethods value) {
    _yearlyAverageMethod = value;
    notifyListeners();
    Share.settings.save();
  }

  set lessonCallTime(int value) {
    _lessonCallTime = value;
    notifyListeners();
    Share.settings.save();
  }

  set lessonCallType(LessonCallTypes value) {
    _lessonCallType = value;
    notifyListeners();
    Share.settings.save();
  }

  set bellOffset(Duration value) {
    _bellOffset = value;
    notifyListeners();
    Share.settings.save();
  }

  set devMode(bool value) {
    _devMode = value;
    notifyListeners();
    Share.settings.save();
  }

  set notificationsAskedOnce(bool value) {
    _notificationsAskedOnce = value;
    notifyListeners();
    Share.settings.save();
  }

  set enableTimetableNotifications(bool value) {
    _enableTimetableNotifications = value;
    notifyListeners();
    Share.settings.save();
  }

  set enableGradesNotifications(bool value) {
    _enableGradesNotifications = value;
    notifyListeners();
    Share.settings.save();
  }

  set enableEventsNotifications(bool value) {
    _enableEventsNotifications = value;
    notifyListeners();
    Share.settings.save();
  }

  set enableAttendanceNotifications(bool value) {
    _enableAttendanceNotifications = value;
    notifyListeners();
    Share.settings.save();
  }

  set enableAnnouncementsNotifications(bool value) {
    _enableAnnouncementsNotifications = value;
    notifyListeners();
    Share.settings.save();
  }

  set enableMessagesNotifications(bool value) {
    _enableMessagesNotifications = value;
    notifyListeners();
    Share.settings.save();
  }

  Future<void> setUserAvatar(Uint8List? value) async {
    try {
      _userAvatarImage = value != null ? base64Encode(value) : '';
      await File(
              '${(await getApplicationDocumentsDirectory()).path}/useravatar.${_getBase64FileExtension(_userAvatarImage)}')
          .writeAsBytes(List.from(userAvatar!));
      notifyListeners();
      Share.settings.save();
    } catch (ex) {
      // ignored
    }
  }

  set enableBackgroundSync(bool value) {
    _enableBackgroundSync = value;
    notifyListeners();
    Share.settings.save();
  }

  set allowSzkolnyIntegration(bool value) {
    _allowSzkolnyIntegration = value;
    notifyListeners();
    Share.settings.save();
  }

  set shareEventsByDefault(bool value) {
    _shareEventsByDefault = value;
    notifyListeners();
    Share.settings.save();
  }

  set backgroundSyncWiFiOnly(bool value) {
    _backgroundSyncWiFiOnly = value;
    notifyListeners();
    Share.settings.save();
  }

  set backgroundSyncInterval(int value) {
    _backgroundSyncInterval = value;
    notifyListeners();
    Share.settings.save();
  }

  String _getBase64FileExtension(String base64String) {
    switch (base64String.characters.first) {
      case '/':
        return 'jpeg';
      case 'i':
        return 'png';
      case 'R':
        return 'gif';
      case 'U':
        return 'webp';
      case 'J':
        return 'pdf';
      default:
        return 'unknown';
    }
  }

  factory SessionConfig.fromJson(Map<String, dynamic> json) => _$SessionConfigFromJson(json);

  Map<String, dynamic> toJson() => _$SessionConfigToJson(this);
}
