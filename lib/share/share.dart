import 'package:event/event.dart';
import 'package:flutter/material.dart';
import 'package:ogaku/models/provider.dart';

import 'package:ogaku/models/data/teacher.dart' show Teacher;
import 'package:ogaku/models/progress.dart' show IProgress;
import 'package:uuid/uuid.dart';

class Share {
  // The provider and register data for the current session
  // MUST be initialized before switching to the base app
  static late Session session;

  // Raised by the app to notify that the uses's just logged in
  // To subscribe: event.subscribe((args) => {})
  static Event<Value<StatefulWidget Function()>> changeBase = Event<Value<StatefulWidget Function()>>();
}

class Session {
  Session({String? sessionId, required this.provider})
      : sessionId = sessionId ?? const Uuid().v4(),
        data = ProviderData();

  String sessionId;
  ProviderData data;
  IProvider provider;

  // Load the downloaded data from storage, called manually, TODO
  Future<({bool success, Exception? message})> loadData() async => (success: true, message: null);

  // Save the downloaded data to storage, called automatically, TODO
  Future<({bool success, Exception? message})> saveData() async => (success: true, message: null);

  // Login and reset methods for early setup - implement as async
  Future<({bool success, Exception? message})> login({String? username, String? password}) async {
    return await provider.login(session: sessionId, username: username, password: password);
  }

  // Clear provider settings - login data, other custom settings
  Future<({bool success, Exception? message})> clearSettings() async {
    return await provider.clearSettings(session: sessionId);
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
      provider.registerData!.timetables.timetable.forEach((key, value) => data.timetables.timetable.update(
            key,
            (x) => x = value,
            ifAbsent: () => value,
          ));
    }
    await saveData();
  }
}
