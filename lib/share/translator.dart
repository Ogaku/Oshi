import 'dart:async' show Future;
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:darq/darq.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as path;

class Translator {
  Set<({String code, String name, String path})> _supportedLanguages = {};
  Set<({String code, String name})> get supportedLanguages =>
      _supportedLanguages.select((x, index) => (code: x.code, name: x.name)).toSet();

  Map<String, String> _localeTextResoures = {};
  Map<String, String> _englishTextResoures = {};

  List<String> _localeSplashResoures = [];
  List<String> _englishSplashResoures = [];

  List<({String title, String subtitle})> _localeEndingSplashResoures = [];
  List<({String title, String subtitle})> _englishEndingSplashResoures = [];

  String _localeLanguageName = 'Unknown';
  String get localeName => _localeLanguageName;

  String get(String key) => _localeTextResoures[key] ?? _englishTextResoures[key] ?? key;

  String getRandomSplash() => _localeSplashResoures.isNotEmpty
      ? _localeSplashResoures[Random().nextInt(_localeSplashResoures.length)]
      : _englishSplashResoures.isNotEmpty
          ? _englishSplashResoures[Random().nextInt(_englishSplashResoures.length)]
          : '?????';

  ({String title, String subtitle}) getRandomEndingSplash([String replace = '???']) =>
      (_localeEndingSplashResoures.isNotEmpty
              ? _localeEndingSplashResoures[Random().nextInt(_localeEndingSplashResoures.length)]
              : _englishEndingSplashResoures.isNotEmpty
                  ? _englishEndingSplashResoures[Random().nextInt(_englishEndingSplashResoures.length)]
                  : (title: '?????', subtitle: '?????'))
          .formatSubtitle(replace);

  Future<void> loadResources(String languageKey) async {
    try {
      // Load our resources, scan supported languages
      var json = await _loadAssets('locales');

      _supportedLanguages = json.entries
          .select((x, index) => (
                code: x.key,
                name:
                    '${json[languageKey]?[x.key] ?? x.value[x.key] ?? x.key}${x.key == languageKey ? '' : ' (${x.value[x.key]})'}',
                path: x.key
              ))
          .toSet();
    } catch (ex) {
      if (kDebugMode) print(ex);
    }

    try {
      // Load our resources, and English for fallback
      var json = await _loadAssets(_supportedLanguages.firstWhereOrDefault((x) => x.code == languageKey)?.path ?? 'en');
      _localeLanguageName = _supportedLanguages.firstWhereOrDefault((x) => x.code == languageKey)?.name ?? 'Unknown';

      // Parse and move to the outer scope
      _localeTextResoures = (json['messages'] as List<dynamic>)
          .toMap((entry) => MapEntry(entry['id'].toString(), entry['translation'].toString()));

      _localeSplashResoures = (json['splashes'] as List<dynamic>?)?.cast<String>() ?? ['?????'];
      _localeEndingSplashResoures = (json['ending_splashes'] as List<dynamic>?)
              ?.select((entry, index) => (title: entry['title'].toString(), subtitle: entry['subtitle'].toString()))
              .toList() ??
          [(title: '?????', subtitle: '?????')];
    } catch (ex) {
      if (kDebugMode) print(ex);
    }

    try {
      // Load our resources, and English for fallback
      var json = await _loadAssets('en');

      // Parse and move to the outer scope
      _englishTextResoures = (json['messages'] as List<dynamic>)
          .toMap((entry) => MapEntry(entry['id'].toString(), entry['translation'].toString()));

      _englishSplashResoures = (json['splashes'] as List<dynamic>?)?.cast<String>() ?? ['?????'];
      _englishEndingSplashResoures = (json['ending_splashes'] as List<dynamic>?)
              ?.select((entry, index) => (title: entry['title'].toString(), subtitle: entry['subtitle'].toString()))
              .toList() ??
          [(title: '?????', subtitle: '?????')];
    } catch (ex) {
      if (kDebugMode) print(ex);
    }
  }

  Future<Map<String, dynamic>> _loadAssets(String code) async {
    try {
      return jsonDecode(kDebugMode && Platform.isWindows
          ? await File(path.join(Directory.current.path, 'assets/resources/strings/$code.json')).readAsString()
          : await rootBundle.loadString('assets/resources/strings/$code.json'));
    } catch (ex) {
      return code == 'en' ? {} : await _loadAssets('en');
    }
  }
}

extension ReplaceSubtitleExtension on ({String title, String subtitle}) {
  ({String title, String subtitle}) formatSubtitle(String value) =>
      (title: title, subtitle: subtitle.replaceAll('{}', value));
}
