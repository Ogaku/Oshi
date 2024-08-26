import 'dart:async' show Future;
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:darq/darq.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:oshi/interface/shared/pages/home.dart';
import 'package:oshi/share/platform.dart';
import 'package:oshi/share/share.dart';
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

  ({String title, String subtitle}) getRandomEndingSplash([String? replace]) => (_localeEndingSplashResoures.isNotEmpty
          ? _localeEndingSplashResoures[Random().nextInt(_localeEndingSplashResoures.length)]
          : _englishEndingSplashResoures.isNotEmpty
              ? _englishEndingSplashResoures[Random().nextInt(_englishEndingSplashResoures.length)]
              : (title: '?????', subtitle: '?????'))
      .formatSubtitle(replace ??
          Share.session.data.timetables[DateTime.now().asDate(utc: true).asDate()]?.lessonsNumber.toString() ??
          '???');

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
      return jsonDecode(kDebugMode && isWindows
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

extension TranslatorExtension on String {
  String get localized {
    var result = Share.translator.get(this);
    if (kDebugMode && result == this) {
      try {
        // ignore: avoid_print, we're already checking for kDebugMode
        print('Invalid string requested at ${CustomTrace(StackTrace.current)}, "$this"');
      } catch (ex) {
        // ignored
      }
    }
    return result;
  }
}

class CustomTrace {
  final StackTrace _trace;

  String? fileName;
  String? functionName;
  String? callerFunctionName;
  int? lineNumber;
  int? columnNumber;

  CustomTrace(this._trace) {
    _parseTrace();
  }

  String _getFunctionNameFromFrame(String frame) {
    var currentTrace = frame;
    var indexOfWhiteSpace = currentTrace.indexOf(' ');
    var subStr = currentTrace.substring(indexOfWhiteSpace);
    var indexOfFunction = subStr.indexOf(RegExp(r'[A-Za-z0-9]'));
    subStr = subStr.substring(indexOfFunction);
    indexOfWhiteSpace = subStr.indexOf(' ');
    subStr = subStr.substring(0, indexOfWhiteSpace);
    return subStr;
  }

  void _parseTrace() {
    var frames = _trace.toString().split("\n");
    functionName = _getFunctionNameFromFrame(frames[1]);
    callerFunctionName = _getFunctionNameFromFrame(frames[2]);
    var traceString = frames[1];
    var indexOfFileName = traceString.indexOf(RegExp(r'[A-Za-z]+.dart'));
    var fileInfo = traceString.substring(indexOfFileName);
    var listOfInfos = fileInfo.split(":");
    fileName = listOfInfos[0];
    lineNumber = int.parse(listOfInfos[1]);
    var columnStr = listOfInfos[2];
    columnStr = columnStr.replaceFirst(")", "");
    columnNumber = int.parse(columnStr);
  }

  @override
  String toString() => '$fileName::$functionName:$lineNumber';
}
