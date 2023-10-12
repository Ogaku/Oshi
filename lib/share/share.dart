import 'dart:convert';

import 'package:event/event.dart';
import 'package:flutter/material.dart';
import 'package:ogaku/models/provider.dart';

import 'package:ogaku/models/data/teacher.dart' show Teacher;
import 'package:ogaku/models/progress.dart' show IProgress;
import 'package:uuid/uuid.dart';

import 'package:ogaku/providers/librus/librus_data.dart' show LibrusDataReader;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Share {
  // The provider and register data for the current session
  // MUST be initialized before switching to the base app
  static late Session session;

  // Raised by the app to notify that the uses's just logged in
  // To subscribe: event.subscribe((args) => {})
  static Event<Value<StatefulWidget Function()>> changeBase = Event<Value<StatefulWidget Function()>>();

  // All sessions maintained by the app, including the current one
  static List<Session> sessions = [Session(sessionId: '81C59CC9-AA58-4FF4-BE69-91B1028F1C04', provider: LibrusDataReader())];

  // Currently supported provider types, maps sample instances to factories
  static Map<IProvider, IProvider Function()> providers = {
    // Librus synergia: log in with a synergia account
    LibrusDataReader(): () => LibrusDataReader()
  };
}

class Session {
  Session(
      {String? sessionId,
      this.sessionName = 'John Doe',
      this.sessionUsername = '',
      this.sessionPassword = '',
      required this.provider})
      : sessionId = sessionId ?? const Uuid().v4(),
        data = ProviderData();

  // Internal ID and 'pretty' name
  String sessionId;
  String sessionName;

  // Persistent login and pass
  String sessionUsername;
  String sessionPassword;

  // Gneral data and the provider
  ProviderData data;
  IProvider provider;

  // Shared storage container
  final storage = const FlutterSecureStorage();

  // Load all the data from storage, called manually, TODO USE SECURESTORAGE
  Future<({bool success, Exception? message})> loadData() async => (success: true, message: null);

  // Save all received data to storage, called automatically, TODO USE SECURESTORAGE
  Future<({bool success, Exception? message})> saveData() async => (success: true, message: null);

  // Clear provider settings - login data, other custom settings, TODO USE SECURESTORAGE
  Future<({bool success, Exception? message})> clearSettings() async => (success: true, message: null);

  // Login and reset methods for early setup - implement as async
  Future<({bool success, Exception? message})> login({String? username, String? password}) async {
    if (username?.isNotEmpty ?? false) sessionUsername = username ?? '';
    if (password?.isNotEmpty ?? false) sessionPassword = password ?? '';

    return await provider.login(
        session: sessionId, username: username ?? sessionUsername, password: password ?? sessionPassword);
  }

  // Login and refresh methods for runtime - implement as async
  // For null 'weekStart' - get (only) the current week's data
  // For reporting 'progress' - mark 'Progress' as null for indeterminate status
  Future<({bool success, Exception? message})> refresh(
      {DateTime? weekStart, IProgress<({double? progress, String? message})>? progress}) async {
    var result = await provider.refresh(weekStart: weekStart, progress: progress);
    if (result.success) await updateData(info: true);
    return result;
  }

  // Login and refresh methods for runtime - implement as async
  // For null 'weekStart' - get (only) the current week's data
  // For reporting 'progress' - mark 'Progress' as null for indeterminate status
  Future<({bool success, Exception? message})> refreshMessages(
      {IProgress<({double? progress, String? message})>? progress}) async {
    var result = await provider.refreshMessages(progress: progress);
    if (result.success) await updateData(messages: true);
    return result;
  }

  // Send a message to selected user/s, fetched from `Messages.Receivers`
  // Don't encode the strings, the provider will need to take care of that
  Future<({bool success, Exception? message})> sendMessage(List<Teacher> receivers, String topic, String content) async {
    var result = await provider.sendMessage(receivers: receivers, topic: topic, content: content);
    if (result.success) await updateData(messages: true);
    return result;
  }

  // Update session's data based on the provider, save to storage
  Future<void> updateData({bool info = false, bool messages = false}) async {
    if (provider.registerData == null) throw Exception('Provider cannot be null, cannot proceed!');
    if (messages) data.messages = provider.registerData!.messages;
    if (info) {
      data.student = provider.registerData!.student;
      sessionName = data.student.account.name;
      provider.registerData!.timetables.timetable.forEach((key, value) => data.timetables.timetable.update(
            key,
            (x) => x = value,
            ifAbsent: () => value,
          ));
    }
    await saveData();
  }

  Future load() async {
    sessionUsername = await getSetting('login');
    sessionPassword = await getSetting('pass');
    sessionName = await getSetting('name', 'John Doe');

    try {
      data = ProviderData.fromJson(jsonDecode(await getSetting('data' '{}')));
    } catch (ex) {
      // ignored
    }
  }

  Future save() async {
    await setSetting('login', sessionUsername);
    await setSetting('pass', sessionPassword);
    await setSetting('name', sessionName);

    try {
      await setSetting('data', jsonEncode(data.toJson()));
    } catch (ex) {
      // ignored
    }
  }

//#region Internal management
  Future<String> getSetting(String key, [String? fallback]) async {
    return await storage.read(key: '$sessionId+$key') ?? fallback ?? '';
  }

  Future setSetting(String key, String value) async {
    return await storage.write(key: '$sessionId+$key', value: value);
  }
//#endregion}
}
