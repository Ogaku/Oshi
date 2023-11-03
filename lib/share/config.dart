// ignore_for_file: prefer_final_fields

import 'package:darq/darq.dart';
import 'package:flutter/cupertino.dart';
import 'package:oshi/share/resources.dart';

class Config {
  static Map<String, double>? customGradeValues;
  static Map<String, double>? customGradeMarginValues;

  static Map<String, double>? customGradeModifierValues = {'+': 0.5, '-': -0.25};

  static CupertinoDynamicColor cupertinoAccentColor = CupertinoColors.systemRed;
  static bool useCupertino = true;

  static String _languageCode = 'en';

  static String get languageCode =>
      Resources.languages.containsKey(_languageCode) ? _languageCode : (Resources.languages.keys.firstOrDefault() ?? 'en');
  static set languageCode(String code) => _languageCode = code;
}
