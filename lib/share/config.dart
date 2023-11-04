// ignore_for_file: prefer_final_fields

import 'package:darq/darq.dart';
import 'package:flutter/cupertino.dart';
import 'package:oshi/share/resources.dart';

import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

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
      String? languageCode})
      : _customGradeValues = customGradeValues ?? {},
        _customGradeMarginValues = customGradeMarginValues ?? {},
        _customGradeModifierValues = customGradeModifierValues ?? {'+': 0.5, '-': -0.25},
        _cupertinoAccentColor = cupertinoAccentColor ?? Resources.accentColors.keys.first,
        useCupertino = useCupertino ?? true,
        _languageCode = languageCode ?? 'en';

  @HiveField(1)
  Map<String, double> _customGradeValues;

  @HiveField(2)
  Map<String, double> _customGradeMarginValues;

  @HiveField(3)
  Map<String, double> _customGradeModifierValues;

  @HiveField(4)
  int _cupertinoAccentColor;

  @HiveField(5)
  bool useCupertino;

  @HiveField(6)
  String _languageCode;

  @JsonKey(includeToJson: false, includeFromJson: false)
  Map<String, double> get customGradeValues => _customGradeValues;

  @JsonKey(includeToJson: false, includeFromJson: false)
  Map<String, double> get customGradeMarginValues => _customGradeMarginValues;

  @JsonKey(includeToJson: false, includeFromJson: false)
  Map<String, double> get customGradeModifierValues => _customGradeModifierValues;

  @JsonKey(includeToJson: false, includeFromJson: false)
  ({CupertinoDynamicColor color, String name}) get cupertinoAccentColor =>
      Resources.accentColors[_cupertinoAccentColor] ?? Resources.accentColors.values.first;

  @JsonKey(includeToJson: false, includeFromJson: false)
  String get languageCode =>
      Resources.languages.containsKey(_languageCode) ? _languageCode : (Resources.languages.keys.firstOrDefault() ?? 'en');

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
        Resources.accentColors.entries.firstWhereOrDefault((value) => value.value == cupertinoAccentColor)?.key ?? 0;
    notifyListeners();
  }

  set languageCode(String code) {
    _languageCode = code;
    notifyListeners();
  }

  factory Config.fromJson(Map<String, dynamic> json) => _$ConfigFromJson(json);

  Map<String, dynamic> toJson() => _$ConfigToJson(this);
}
