// ignore_for_file: prefer_final_fields
import 'package:darq/darq.dart';
import 'package:flutter/cupertino.dart';
import 'package:oshi/share/resources.dart';

import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:oshi/share/share.dart';

part 'config.g.dart';

@HiveType(typeId: 4)
@JsonSerializable(includeIfNull: false)
class Config with ChangeNotifier {
  Config(
      {Map<String, double>? customGradeValues,
      Map<String, double>? customGradeMarginValues,
      Map<String, double>? customGradeModifierValues,
      int? cupertinoAccentColor,
      bool? useCupertino,
      String? languageCode,
      bool? weightedAverage,
      bool? autoArithmeticAverage,
      YearlyAverageMethods? yearlyAverageMethod,
      int? lessonCallTime,
      LessonCallTypes? lessonCallType,
      Duration? bellOffset})
      : _customGradeValues = customGradeValues ?? {},
        _customGradeMarginValues = customGradeMarginValues ?? {},
        _customGradeModifierValues = customGradeModifierValues ?? {'+': 0.5, '-': -0.25},
        _cupertinoAccentColor = cupertinoAccentColor ?? Resources.cupertinoAccentColors.keys.first,
        _useCupertino = useCupertino ?? true,
        _languageCode = languageCode ?? 'en',
        _weightedAverage = weightedAverage ?? true,
        _autoArithmeticAverage = autoArithmeticAverage ?? false,
        _yearlyAverageMethod = yearlyAverageMethod ?? YearlyAverageMethods.allGradesAverage,
        _lessonCallTime = lessonCallTime ?? 15,
        _lessonCallType = lessonCallType ?? LessonCallTypes.countFromEnd,
        _bellOffset = bellOffset ?? Duration.zero;

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
  bool _useCupertino;

  @HiveField(6, defaultValue: 'en')
  String _languageCode;

  @HiveField(7, defaultValue: true)
  bool _weightedAverage;

  @HiveField(8, defaultValue: false)
  bool _autoArithmeticAverage;

  @HiveField(9, defaultValue: YearlyAverageMethods.allGradesAverage)
  YearlyAverageMethods _yearlyAverageMethod;

  @HiveField(10, defaultValue: 15)
  int _lessonCallTime;

  @HiveField(11, defaultValue: LessonCallTypes.countFromEnd)
  LessonCallTypes _lessonCallType;

  @HiveField(12, defaultValue: Duration.zero)
  Duration _bellOffset;

  @JsonKey(includeToJson: false, includeFromJson: false)
  Map<String, double> get customGradeValues => _customGradeValues;

  @JsonKey(includeToJson: false, includeFromJson: false)
  Map<String, double> get customGradeMarginValues => _customGradeMarginValues;

  @JsonKey(includeToJson: false, includeFromJson: false)
  Map<String, double> get customGradeModifierValues => _customGradeModifierValues;

  @JsonKey(includeToJson: false, includeFromJson: false)
  ({CupertinoDynamicColor color, String name}) get cupertinoAccentColor =>
      Resources.cupertinoAccentColors[_cupertinoAccentColor] ?? Resources.cupertinoAccentColors.values.first;

  @JsonKey(includeToJson: false, includeFromJson: false)
  String get languageCode => Share.translator.supportedLanguages.any((x) => x.code == _languageCode)
      ? _languageCode
      : (Share.translator.supportedLanguages.firstOrDefault()?.code ?? 'en');

  @JsonKey(includeToJson: false, includeFromJson: false)
  bool get useCupertino => _useCupertino;

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

  set customGradeValues(Map<String, double> customGradeValues) {
    _customGradeValues = customGradeValues;
    notifyListeners();
  }

  set customGradeMarginValues(Map<String, double> customGradeMarginValues) {
    _customGradeMarginValues = customGradeMarginValues;
    notifyListeners();
  }

  set customGradeModifierValues(Map<String, double> customGradeModifierValues) {
    _customGradeModifierValues = customGradeModifierValues;
    notifyListeners();
  }

  set cupertinoAccentColor(({CupertinoDynamicColor color, String name}) cupertinoAccentColor) {
    _cupertinoAccentColor =
        Resources.cupertinoAccentColors.entries.firstWhereOrDefault((value) => value.value == cupertinoAccentColor)?.key ??
            0;
    notifyListeners();
  }

  set languageCode(String code) {
    _languageCode = code;
    notifyListeners();
  }

  set useCupertino(bool value) {
    _useCupertino = value;
    notifyListeners();
  }

  set weightedAverage(bool value) {
    _weightedAverage = value;
    notifyListeners();
  }

  set autoArithmeticAverage(bool value) {
    _autoArithmeticAverage = value;
    notifyListeners();
  }

  set yearlyAverageMethod(YearlyAverageMethods value) {
    _yearlyAverageMethod = value;
    notifyListeners();
  }

  set lessonCallTime(int value) {
    _lessonCallTime = value;
    notifyListeners();
  }

  set lessonCallType(LessonCallTypes value) {
    _lessonCallType = value;
    notifyListeners();
  }

  set bellOffset(Duration value) {
    _bellOffset = value;
    notifyListeners();
  }

  factory Config.fromJson(Map<String, dynamic> json) => _$ConfigFromJson(json);

  Map<String, dynamic> toJson() => _$ConfigToJson(this);
}
