import 'package:event/event.dart';
import 'package:flutter/material.dart';
import 'package:oshi/models/provider.dart';

import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

import 'package:oshi/models/data/teacher.dart' show Teacher;
import 'package:oshi/models/progress.dart' show IProgress;

import 'package:oshi/providers/librus/librus_data.dart' show LibrusDataReader;
import 'package:oshi/providers/sample/sample_data.dart' show FakeDataReader;

part 'share.g.dart';

class Share {
  // The provider and register data for the current session
  // MUST be initialized before switching to the base app
  static late Session session;

  // Shared settings data for managing sessions
  static Settings settings = Settings();

  // Raised by the app to notify that the uses's just logged in
  // To subscribe: event.subscribe((args) => {})
  static Event<Value<StatefulWidget Function()>> changeBase = Event<Value<StatefulWidget Function()>>();

  // Currently supported provider types, maps sample instances to factories
  static Map<String, ({IProvider instance, IProvider Function() factory})> providers = {
    // Sample data provider, only for debugging purposes
    'PROVGUID-SHIM-SMPL-FAKE-DATAPROVIDER': (instance: FakeDataReader(), factory: () => FakeDataReader()),
    // Librus synergia: log in with a synergia account
    'PROVGUID-RGLR-PROV-LIBR-LIBRSYNERGIA': (instance: LibrusDataReader(), factory: () => LibrusDataReader()),
  };
}

class Settings {
  // All sessions maintained by the app, including the current one
  SessionsData sessions = SessionsData();

  // Load all the data from storage, called manually
  Future<({bool success, Exception? message})> load() async {
    try {
      sessions = (await Hive.openBox('sessions')).get('sessions', defaultValue: SessionsData());
    } on Exception catch (ex) {
      return (success: false, message: ex);
    } catch (ex) {
      return (success: false, message: Exception(ex));
    }
    return (success: true, message: null);
  }

  // Save all received data to storage, called automatically
  Future<({bool success, Exception? message})> save() async {
    try {
      (await Hive.openBox('sessions')).put('sessions', sessions);
    } on Exception catch (ex) {
      return (success: false, message: ex);
    } catch (ex) {
      return (success: false, message: Exception(ex));
    }
    return (success: true, message: null);
  }

  // Clear provider settings - login data, other custom settings
  Future<({bool success, Exception? message})> clear() async {
    try {
      (await Hive.openBox('sessions')).clear();
    } on Exception catch (ex) {
      return (success: false, message: ex);
    } catch (ex) {
      return (success: false, message: Exception(ex));
    }
    return (success: true, message: null);
  }
}

@HiveType(typeId: 2)
@JsonSerializable(includeIfNull: false)
class SessionsData extends HiveObject {
  SessionsData({Map<String, Session>? sessions, this.lastSessionId = 'SESSIONS-SHIM-SMPL-FAKE-DATAPROVIDER'})
      : sessions = sessions ?? {};

  // The last session's identifier
  @HiveField(1)
  String? lastSessionId;

  // Last session's getter
  @JsonKey(includeToJson: false, includeFromJson: false)
  Session? get lastSession =>
      ((lastSessionId?.isNotEmpty ?? false) && sessions.containsKey(lastSessionId)) ? sessions[lastSessionId!] : null;

  // All sessions maintained by the app, including the current one
  // The 'fake' one is kept here for debugging, overwritten on startup anyway
  @HiveField(2)
  Map<String, Session> sessions = {
    'SESSIONS-SHIM-SMPL-FAKE-DATAPROVIDER': Session(providerGuid: 'PROVGUID-SHIM-SMPL-FAKE-DATAPROVIDER')
  };

  factory SessionsData.fromJson(Map<String, dynamic> json) => _$SessionsDataFromJson(json);

  Map<String, dynamic> toJson() => _$SessionsDataToJson(this);
}

@HiveType(typeId: 3)
@JsonSerializable(includeIfNull: false)
class Session extends HiveObject {
  Session(
      {this.sessionName = 'John Doe',
      this.providerGuid = 'PROVGUID-SHIM-SMPL-FAKE-DATAPROVIDER',
      Map<String, String>? credentials,
      IProvider? provider})
      : provider = provider ?? Share.providers[providerGuid]!.factory(),
        sessionCredentials = credentials ?? {},
        data = ProviderData();

  // Internal 'pretty' name
  @HiveField(1)
  String sessionName;

  @HiveField(5)
  String providerGuid;

  // Persistent login, pass, etc
  @HiveField(2)
  Map<String, String> sessionCredentials;

  // Downlaoded data
  @HiveField(4)
  ProviderData data;

  @JsonKey(includeToJson: false, includeFromJson: false)
  IProvider provider;

  // Login and reset methods for early setup - implement as async
  Future<({bool success, Exception? message})> login({Map<String, String>? credentials}) async {
    if (credentials?.isNotEmpty ?? false) sessionCredentials = credentials ?? {};
    return await provider.login(credentials: credentials ?? sessionCredentials);
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
    if (messages) data.messages = provider.registerData!.messages; // TODO Only update
    if (info) {
      data.student = provider.registerData!.student;
      sessionName = data.student.account.name;
      provider.registerData!.timetables.timetable.forEach((key, value) => data.timetables.timetable.update(
            key,
            (x) => x = value,
            ifAbsent: () => value,
          ));
    }
    await Share.settings.save();
  }

  factory Session.fromJson(Map<String, dynamic> json) => _$SessionFromJson(json);

  Map<String, dynamic> toJson() => _$SessionToJson(this);
}
