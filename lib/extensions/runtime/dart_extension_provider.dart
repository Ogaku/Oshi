import 'dart:convert';
import 'package:d4rt/d4rt.dart';
import 'package:event/event.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:oshi/extensions/bridge/oshi_bridge.dart';
import 'package:oshi/extensions/models/extension_manifest.dart';
import 'package:oshi/models/data/announcement.dart' show Announcement;
import 'package:oshi/models/data/event.dart' as models show Event;
import 'package:oshi/models/data/messages.dart' show Message;
import 'package:oshi/models/data/teacher.dart' show Teacher;
import 'package:oshi/models/progress.dart' show IProgress;
import 'package:oshi/models/provider.dart' show IProvider, ProviderData;

/// Executes an Oshi `.dart` provider extension using the `d4rt` Dart interpreter
/// (the same extension architecture used by Mangayomi).
class DartExtensionProvider implements IProvider {
  DartExtensionProvider({required this.manifest}) : dataChunk = ProviderData();

  final ExtensionManifest manifest;
  ProviderData dataChunk;

  D4rt? _interpreter;
  final OExtensionHostContext _hostContext = OExtensionHostContext();

  int get loginType => manifest.loginType;

  void _ensureInterpreter() {
    if (_interpreter != null) return;
    final code = manifest.sourceCode;
    if (code == null || code.trim().isEmpty) {
      throw Exception('Extension "${manifest.localizedName}" has no source code installed.');
    }

    final d4rt = D4rt(enableAstCache: true);
    OshiBridge.register(d4rt, _hostContext);
    d4rt.execute(
      source: code,
      positionalArgs: [OSource.fromManifest(manifest)],
    );
    _interpreter = d4rt;
    _syncRegisterData();
  }

  void _syncRegisterData() {
    if (_hostContext.lastData != null) {
      dataChunk = _hostContext.lastData!;
      return;
    }
    if (_interpreter == null) return;
    try {
      final raw = _interpreter!.invoke('getRegisterDataJson', []);
      if (raw is Map && raw.isNotEmpty) {
        final normalized = jsonDecode(jsonEncode(raw)) as Map<String, dynamic>;
        dataChunk = ProviderData.fromJson(normalized);
      }
    } catch (_) {
      // Extension uses OProtocolDriver or setRegisterDataJson instead
    }
  }

  ({bool success, Exception? message}) _parseResult(Object? raw) {
    if (raw is Map) {
      final ok = raw['success'] == true;
      final msg = raw['message']?.toString();
      return (
        success: ok,
        message: (msg != null && msg.isNotEmpty) ? Exception(msg.replaceFirst(RegExp(r'^Exception:\s*'), '')) : null,
      );
    }
    return (success: true, message: null);
  }

  @override
  Event<Value<String>> propertyChanged = Event<Value<String>>();

  @override
  ProviderData? get registerData => _hostContext.lastData ?? dataChunk;

  @override
  String get providerName => manifest.localizedName;

  @override
  String get providerDescription => manifest.localizedDescription;

  @override
  Uri? get providerBannerUri => manifest.effectiveBannerUri;

  @override
  Map<String, ({String name, bool obscure, ({String text, Uri link})? helper})> get credentialsConfig =>
      manifest.credentialsConfigMap;

  @override
  Future<({bool success, Exception? message})> login({
    Map<String, String>? credentials,
    IProgress<({double? progress, String? message})>? progress,
  }) async {
    _hostContext.activeProgress = progress;
    try {
      _ensureInterpreter();
      final raw = await _interpreter!.invoke('login', [credentials ?? <String, String>{}]);
      _syncRegisterData();
      return _parseResult(raw);
    } catch (e, st) {
      debugPrint('[DartExtensionProvider:${manifest.id}] login failed: $e\n$st');
      return (success: false, message: Exception('$e'));
    } finally {
      _hostContext.activeProgress = null;
    }
  }

  @override
  Future<({bool success, Exception? message})> refresh({
    DateTime? weekStart,
    IProgress<({double? progress, String? message})>? progress,
  }) async {
    _hostContext.activeProgress = progress;
    try {
      _ensureInterpreter();
      final raw = await _interpreter!.invoke('refresh', [weekStart?.toIso8601String()]);
      _syncRegisterData();
      return _parseResult(raw);
    } catch (e, st) {
      debugPrint('[DartExtensionProvider:${manifest.id}] refresh failed: $e\n$st');
      return (success: false, message: Exception('$e'));
    } finally {
      _hostContext.activeProgress = null;
    }
  }

  @override
  Future<({bool success, Exception? message})> refreshMessages({
    IProgress<({double? progress, String? message})>? progress,
  }) async {
    _hostContext.activeProgress = progress;
    try {
      _ensureInterpreter();
      final raw = await _interpreter!.invoke('refreshMessages', []);
      _syncRegisterData();
      return _parseResult(raw);
    } catch (e, st) {
      debugPrint('[DartExtensionProvider:${manifest.id}] refreshMessages failed: $e\n$st');
      return (success: false, message: Exception('$e'));
    } finally {
      _hostContext.activeProgress = null;
    }
  }

  @override
  Future<({bool success, Exception? message})> sendMessage({
    required List<Teacher> receivers,
    required String topic,
    required String content,
  }) async {
    try {
      _ensureInterpreter();
      final receiversJson = receivers.map((r) => jsonDecode(jsonEncode(r.toJson())) as Map<String, dynamic>).toList();
      final raw = await _interpreter!.invoke('sendMessage', [receiversJson, topic, content]);
      _syncRegisterData();
      return _parseResult(raw);
    } catch (e, st) {
      debugPrint('[DartExtensionProvider:${manifest.id}] sendMessage failed: $e\n$st');
      return (success: false, message: Exception('$e'));
    }
  }

  @override
  Future<({bool success, Exception? message, Message? result})> fetchMessageContent({
    required Message parent,
    required bool byMe,
  }) async {
    try {
      _ensureInterpreter();
      final parentJson = jsonDecode(jsonEncode(parent.toJson())) as Map<String, dynamic>;
      final raw = await _interpreter!.invoke('fetchMessageContent', [parentJson, byMe]);
      _syncRegisterData();
      if (raw is Map) {
        final parsed = _parseResult(raw);
        Message? resolved;
        if (raw['result'] is Map) {
          final resultMap = jsonDecode(jsonEncode(raw['result'])) as Map<String, dynamic>;
          resolved = Message.fromJson(resultMap);
        }
        return (success: parsed.success, message: parsed.message, result: resolved ?? parent);
      }
      return (success: true, message: null, result: parent);
    } catch (e, st) {
      debugPrint('[DartExtensionProvider:${manifest.id}] fetchMessageContent failed: $e\n$st');
      return (success: false, message: Exception('$e'), result: parent);
    }
  }

  @override
  Future<({bool success, Exception? message})> moveMessageToTrash({
    required Message parent,
    required bool byMe,
  }) async {
    try {
      _ensureInterpreter();
      final parentJson = jsonDecode(jsonEncode(parent.toJson())) as Map<String, dynamic>;
      final raw = await _interpreter!.invoke('moveMessageToTrash', [parentJson, byMe]);
      _syncRegisterData();
      return _parseResult(raw);
    } catch (e, st) {
      debugPrint('[DartExtensionProvider:${manifest.id}] moveMessageToTrash failed: $e\n$st');
      return (success: false, message: Exception('$e'));
    }
  }

  @override
  Future<({bool success, Exception? message})> markEventAsViewed({required models.Event parent}) async {
    try {
      _ensureInterpreter();
      final parentJson = jsonDecode(jsonEncode(parent.toJson())) as Map<String, dynamic>;
      final raw = await _interpreter!.invoke('markEventAsViewed', [parentJson]);
      _syncRegisterData();
      return _parseResult(raw);
    } catch (e) {
      return (success: false, message: Exception('$e'));
    }
  }

  @override
  Future<({bool success, Exception? message})> markEventAsDone({required models.Event parent}) async {
    try {
      _ensureInterpreter();
      final parentJson = jsonDecode(jsonEncode(parent.toJson())) as Map<String, dynamic>;
      final raw = await _interpreter!.invoke('markEventAsDone', [parentJson]);
      _syncRegisterData();
      return _parseResult(raw);
    } catch (e) {
      return (success: false, message: Exception('$e'));
    }
  }

  @override
  Future<({bool success, Exception? message})> markAnnouncementAsViewed({required Announcement parent}) async {
    try {
      _ensureInterpreter();
      final parentJson = jsonDecode(jsonEncode(parent.toJson())) as Map<String, dynamic>;
      final raw = await _interpreter!.invoke('markAnnouncementAsViewed', [parentJson]);
      _syncRegisterData();
      return _parseResult(raw);
    } catch (e) {
      return (success: false, message: Exception('$e'));
    }
  }
}

/// Safe placeholder used when a session references an extension GUID that has not been installed yet.
class UninstalledExtensionProvider implements IProvider {
  UninstalledExtensionProvider(this.guid);

  final String guid;
  final ProviderData _emptyData = ProviderData();

  @override
  Event<Value<String>> propertyChanged = Event<Value<String>>();

  @override
  ProviderData? get registerData => _emptyData;

  @override
  String get providerName => 'Missing extension ($guid)';

  @override
  String get providerDescription =>
      'This register provider extension is not installed. Open Extensions to install it.';

  @override
  Uri? get providerBannerUri => null;

  @override
  Map<String, ({String name, bool obscure, ({String text, Uri link})? helper})> get credentialsConfig => const {};

  Future<({bool success, Exception? message})> _missing() async => (
        success: false,
        message: Exception('Provider extension "$guid" is not installed. Add it in the Extensions browser.'),
      );

  @override
  Future<({bool success, Exception? message})> login({
    Map<String, String>? credentials,
    IProgress<({double? progress, String? message})>? progress,
  }) =>
      _missing();

  @override
  Future<({bool success, Exception? message})> refresh({
    DateTime? weekStart,
    IProgress<({double? progress, String? message})>? progress,
  }) =>
      _missing();

  @override
  Future<({bool success, Exception? message})> refreshMessages({
    IProgress<({double? progress, String? message})>? progress,
  }) =>
      _missing();

  @override
  Future<({bool success, Exception? message})> sendMessage({
    required List<Teacher> receivers,
    required String topic,
    required String content,
  }) =>
      _missing();

  @override
  Future<({bool success, Exception? message, Message? result})> fetchMessageContent({
    required Message parent,
    required bool byMe,
  }) async =>
      (
        success: false,
        message: Exception('Provider extension "$guid" is not installed.'),
        result: parent,
      );

  @override
  Future<({bool success, Exception? message})> moveMessageToTrash({
    required Message parent,
    required bool byMe,
  }) =>
      _missing();

  @override
  Future<({bool success, Exception? message})> markEventAsViewed({required models.Event parent}) => _missing();

  @override
  Future<({bool success, Exception? message})> markEventAsDone({required models.Event parent}) => _missing();

  @override
  Future<({bool success, Exception? message})> markAnnouncementAsViewed({required Announcement parent}) => _missing();
}

