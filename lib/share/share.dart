import 'package:darq/darq.dart';
import 'package:event/event.dart' as events;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:oshi/models/data/announcement.dart';
import 'package:oshi/models/data/attendances.dart';
import 'package:oshi/models/data/grade.dart';
import 'package:oshi/models/data/lesson.dart';
import 'package:oshi/models/data/messages.dart';
import 'package:oshi/models/data/timetables.dart';
import 'package:oshi/models/data/event.dart';
import 'package:oshi/models/provider.dart';

import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

import 'package:oshi/models/data/teacher.dart';
import 'package:oshi/models/progress.dart';

import 'package:oshi/providers/librus/librus_data.dart';
import 'package:oshi/providers/sample/sample_data.dart';
import 'package:oshi/share/config.dart';
import 'package:oshi/share/resources.dart';
import 'package:oshi/share/translator.dart';

part 'share.g.dart';

class Share {
  // The application string resources handler
  static Translator translator = Translator();
  static String currentIdleSplash = '???';
  static ({String title, String subtitle}) currentEndingSplash = (title: '???', subtitle: '???');

  // The provider and register data for the current session
  // MUST be initialized before switching to the base app
  static late Session session;

  // Shared settings data for managing sessions
  static Settings settings = Settings();
  static String buildNumber = '9.9.9.9';
  static bool hasCheckedForUpdates = false;

  // Raised by the app to notify that the uses's just logged in
  // To subscribe: event.subscribe((args) => {})
  static events.Event<events.Value<StatefulWidget Function()>> changeBase =
      events.Event<events.Value<StatefulWidget Function()>>();
  static events.Event refreshBase = events.Event(); // Trigger a setState on the base app and everything subscribed
  static events.Event<events.Value<({String title, String message, Map<String, Future<void> Function()> actions})>>
      showErrorModal =
      events.Event<events.Value<({String title, String message, Map<String, Future<void> Function()> actions})>>();

  // Navigate the grades page to the specified subject
  static events.Event<events.Value<Lesson>> gradesNavigate = events.Event<events.Value<Lesson>>();

  // Navigate the messages page to the specified message
  static events.Event<events.Value<Message>> messagesNavigate = events.Event<events.Value<Message>>();

  // Navigate the messages page to the specified announcement
  static events.Event<events.Value<({Message message, Announcement parent})>> messagesNavigateAnnouncement =
      events.Event<events.Value<({Message message, Announcement parent})>>();

  // Navigate the timetable page to the specified day
  static events.Event<events.Value<DateTime>> timetableNavigateDay = events.Event<events.Value<DateTime>>();

  // Navigate the bottom tab bar to the specified page
  static events.Event<events.Value<int>> tabsNavigatePage = events.Event<events.Value<int>>();

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

  // The application configuration
  Config config = Config();

  // Load all the data from storage, called manually
  Future<({bool success, Exception? message})> load() async {
    try {
      // Remove all change listeners
      config.removeListener(save);

      // Load saved settings
      sessions = (await Hive.openBox('sessions')).get('sessions', defaultValue: SessionsData());
      config = (await Hive.openBox('config')).get('config', defaultValue: Config());

      // Re-setup change listeners
      config.addListener(save);
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
      (await Hive.openBox('config')).put('config', config);
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
      // Remove all change listeners
      config.removeListener(save);

      // Clear internal settings
      (await Hive.openBox('sessions')).clear();
      (await Hive.openBox('config')).clear();

      // Re-generate settings
      sessions = SessionsData();
      config = Config();
    } on Exception catch (ex) {
      return (success: false, message: ex);
    } catch (ex) {
      return (success: false, message: Exception(ex));
    }
    return (success: true, message: null);
  }
}

@HiveType(typeId: 2)
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
}

@HiveType(typeId: 3)
class Session extends HiveObject {
  Session(
      {this.sessionName = 'John Doe',
      this.providerGuid = 'PROVGUID-SHIM-SMPL-FAKE-DATAPROVIDER',
      Map<String, String>? credentials,
      IProvider? provider,
      List<RegisterChanges>? changes})
      : provider = provider ?? Share.providers[providerGuid]!.factory(),
        sessionCredentials = credentials ?? {},
        data = ProviderData(),
        changes = changes ?? [];

  // Internal 'pretty' name
  @HiveField(1)
  String sessionName;

  // Persistent login, pass, etc
  @HiveField(2)
  Map<String, String> sessionCredentials;

  // Updates for each refresh (if any)
  @HiveField(3)
  List<RegisterChanges> changes;

  // Downlaoded data
  @HiveField(4)
  ProviderData data;

  @HiveField(5)
  String providerGuid;

  @JsonKey(includeToJson: false, includeFromJson: false)
  IProvider provider;

  // Login and reset methods for early setup - implement as async
  Future<({bool success, Exception? message})> login(
      {Map<String, String>? credentials, IProgress<({double? progress, String? message})>? progress}) async {
    if (credentials?.isNotEmpty ?? false) sessionCredentials = credentials ?? {};
    return await provider.login(credentials: credentials ?? sessionCredentials, progress: progress);
  }

  // Login and reset methods for early setup - implement as async
  Future<({bool success, Exception? message})> tryLogin(
      {Map<String, String>? credentials,
      IProgress<({double? progress, String? message})>? progress,
      bool showErrors = false}) async {
    try {
      if (credentials?.isNotEmpty ?? false) sessionCredentials = credentials ?? {};
      return await provider.login(credentials: credentials ?? sessionCredentials, progress: progress);
    } catch (ex, stack) {
      if (showErrors) {
        Share.showErrorModal.broadcast(events.Value((
          title: 'Error logging in!',
          message:
              'An exception "$ex" occurred and the provider couldn\'t log you in to the e-register.\n\nPlease check your credentials and try again later.',
          actions: {
            'Copy Exception': () async => await Clipboard.setData(ClipboardData(text: ex.toString())),
            'Copy Stack Trace': () async => await Clipboard.setData(ClipboardData(text: stack.toString())),
          }
        )));
      }
      return (success: false, message: Exception(ex));
    }
  }

  // Login and refresh methods for runtime - implement as async
  // For null 'weekStart' - get (only) the current week's data
  // For reporting 'progress' - mark 'Progress' as null for indeterminate status
  Future<({bool success, Exception? message})> refreshAll(
      {DateTime? weekStart, IProgress<({double? progress, String? message})>? progress, bool saveChanges = true}) async {
    try {
      var result1 = await provider.refresh(weekStart: weekStart, progress: progress);
      var result2 = await provider.refreshMessages(progress: progress);
      await updateData(info: result1.success, messages: result2.success, saveChanges: saveChanges);

      Share.currentIdleSplash = Share.translator.getRandomSplash();
      Share.currentEndingSplash = Share.translator.getRandomEndingSplash();

      return (success: result1.success && result2.success, message: result1.message ?? result2.message);
    } catch (ex, stack) {
      Share.showErrorModal.broadcast(events.Value((
        title: 'Error refreshing data!',
        message:
            'A fatal exception "$ex" occurred and the provider couldn\'t update the e-register data.\n\nPlease try again later.\nConsider reporting this error.',
        actions: {
          'Copy Exception': () async => await Clipboard.setData(ClipboardData(text: ex.toString())),
          'Copy Stack Trace': () async => await Clipboard.setData(ClipboardData(text: stack.toString())),
        }
      )));
      return (success: false, message: Exception(ex));
    }
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
  Future<void> updateData({bool info = false, bool messages = false, bool saveChanges = true}) async {
    if (provider.registerData == null) throw Exception('Provider cannot be null, cannot proceed!');
    try {
      /* Look for any changes, cache everything */

      /* Timetable */
      var timetableChanges = provider.registerData!.timetables.timetable.entries
          .select((x, index) => data.timetables.timetable[x.key] == null
              ? x.value.lessons
                  .select((y, index) => y?.where((z) => z.modifiedSchedule || z.isCanceled))
                  .selectMany((w, index) => w?.toList() ?? <TimetableLesson>[])
              : x.value.lessons
                  .except(data.timetables.timetable[x.key]!.lessons)
                  .select((y, index) => y
                      ?.where((z) => z.modifiedSchedule || z.isCanceled)
                      .except(data.timetables.timetable[x.key]!.lessons.elementAtOrNull(index) ?? []))
                  .selectMany((w, index) => w?.toList() ?? <TimetableLesson>[]))
          .selectMany((w, index) => w)
          .select((lesson, index) => RegisterChange<TimetableLesson>(
              type: lesson.isCanceled ? RegisterChangeTypes.removed : RegisterChangeTypes.changed, value: lesson))
          .toList();

      /* Grades */
      var allGradesDownloaded = provider.registerData!.student.subjects
          .select((subject, index) => subject.grades)
          .selectMany((subject, index) => subject)
          .toList();
      var allGradesSaved =
          data.student.subjects.select((subject, index) => subject.grades).selectMany((subject, index) => subject).toList();

      var gradeChanges = allGradesDownloaded
          .except(allGradesSaved)
          .select((x, index) => RegisterChange<Grade>(
              type: allGradesSaved.any((y) => y.id == x.id && y.id > 0 && x.id > 0)
                  ? RegisterChangeTypes.changed
                  : RegisterChangeTypes.added,
              value: x))
          .appendAll(allGradesSaved.except(allGradesDownloaded).select((x, index) => RegisterChange<Grade>(
              type: allGradesDownloaded.any((y) => y.id == x.id && y.id > 0 && x.id > 0)
                  ? RegisterChangeTypes.changed
                  : RegisterChangeTypes.removed,
              value: x)))
          .toList();

      /* Events */
      var eventChanges = provider.registerData!.student.mainClass.events
          .except(data.student.mainClass.events)
          .select((x, index) => RegisterChange<Event>(
              type: data.student.mainClass.events.any((y) => y.id == x.id && y.id > 0 && x.id > 0)
                  ? RegisterChangeTypes.changed
                  : RegisterChangeTypes.added,
              value: x))
          .appendAll(data.student.mainClass.events
              .except(provider.registerData!.student.mainClass.events)
              .where(
                  (x) => !provider.registerData!.student.mainClass.events.any((y) => y.id == x.id && y.id > 0 && x.id > 0))
              .select((x, index) => RegisterChange<Event>(type: RegisterChangeTypes.removed, value: x)))
          .toList();

      /* Grades */
      var allAttendancesDownloaded = provider.registerData!.student.attendances;
      var allAttendancesSaved = data.student.attendances;

      var attendanceChanges = allAttendancesDownloaded
          ?.except(allAttendancesSaved ?? [])
          .where((x) => x.type != AttendanceType.present)
          .select((x, index) => RegisterChange<Attendance>(
              type: (allAttendancesSaved?.any((y) => y.id == x.id && y.id > 0 && x.id > 0) ?? false)
                  ? RegisterChangeTypes.changed
                  : RegisterChangeTypes.added,
              value: x))
          .appendAll(allAttendancesSaved
                  ?.except(allAttendancesDownloaded)
                  .where((x) => !allAttendancesDownloaded.any((y) => y.id == x.id && y.id > 0 && x.id > 0))
                  .select((x, index) => RegisterChange<Attendance>(type: RegisterChangeTypes.removed, value: x)) ??
              [])
          .toList();

      /* Announcements */
      var announcementChanges = provider.registerData!.student.mainClass.unit.announcements
          ?.except(data.student.mainClass.unit.announcements ?? [])
          .select((x, index) => RegisterChange<Announcement>(
              type: (data.student.mainClass.unit.announcements?.any((y) => y.id == x.id && y.id > 0 && x.id > 0) ?? false)
                  ? RegisterChangeTypes.changed
                  : RegisterChangeTypes.added,
              value: x))
          .appendAll(data.student.mainClass.unit.announcements
                  ?.except(provider.registerData!.student.mainClass.unit.announcements ?? [])
                  .where((x) => (provider.registerData!.student.mainClass.unit.announcements
                          ?.any((y) => y.id == x.id && y.id > 0 && x.id > 0) ??
                      false))
                  .select((x, index) => RegisterChange<Announcement>(type: RegisterChangeTypes.removed, value: x)) ??
              [])
          .toList();

      /* Messages */
      var messageChanges = provider.registerData!.messages.received
          .except(data.messages.received)
          .select((x, index) => RegisterChange<Message>(type: RegisterChangeTypes.added, value: x))
          .toList();

      /* Push everything to the register */
      var detectedChanges = RegisterChanges(
          refreshDate: DateTime.now(),
          timetableChanges: timetableChanges.nullIfEmpty(info),
          gradeChanges: gradeChanges.nullIfEmpty(info),
          eventChanges: eventChanges.nullIfEmpty(info),
          attendanceChanges: attendanceChanges?.nullIfEmpty(info),
          announcementChanges: announcementChanges?.nullIfEmpty(info),
          messageChanges: messageChanges.nullIfEmpty(messages));

      if (saveChanges && detectedChanges.any) changes.add(detectedChanges);
    } catch (ex) {
      // ignored
    }

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
    await Share.settings.save();
  }
}

@HiveType(typeId: 59)
class RegisterChanges {
  RegisterChanges(
      {DateTime? refreshDate,
      List<RegisterChange<TimetableLesson>>? timetableChanges,
      List<RegisterChange<Grade>>? gradeChanges,
      List<RegisterChange<Event>>? eventChanges,
      List<RegisterChange<Announcement>>? announcementChanges,
      List<RegisterChange<Message>>? messageChanges,
      List<RegisterChange<Attendance>>? attendanceChanges})
      : refreshDate = refreshDate ?? DateTime.now(),
        timetablesChanged = timetableChanges ?? [],
        gradesChanged = gradeChanges ?? [],
        eventsChanged = eventChanges ?? [],
        announcementsChanged = announcementChanges ?? [],
        messagesChanged = messageChanges ?? [],
        attendancesChanged = attendanceChanges ?? [];

  @HiveField(0)
  DateTime refreshDate;

  @HiveField(1)
  List<RegisterChange<TimetableLesson>> timetablesChanged;

  @HiveField(2)
  List<RegisterChange<Grade>> gradesChanged;

  @HiveField(3)
  List<RegisterChange<Event>> eventsChanged;

  @HiveField(4)
  List<RegisterChange<Announcement>> announcementsChanged;

  @HiveField(5)
  List<RegisterChange<Message>> messagesChanged;

  @HiveField(6)
  List<RegisterChange<Attendance>> attendancesChanged;

  bool get any =>
      timetablesChanged.isNotEmpty ||
      gradesChanged.isNotEmpty ||
      eventsChanged.isNotEmpty ||
      announcementsChanged.isNotEmpty ||
      messagesChanged.isNotEmpty ||
      attendancesChanged.isNotEmpty;
}

class RegisterChange<T> {
  RegisterChange({required this.value, required this.type});
  T value;
  RegisterChangeTypes type;
}

class RegisterChangeAdapter<T> extends TypeAdapter<RegisterChange<T>> {
  RegisterChangeAdapter({required int id}) : typeId = id;

  @override
  final int typeId;

  @override
  RegisterChange<T> read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RegisterChange(
      value: fields[1],
      type: fields[2] as RegisterChangeTypes,
    );
  }

  @override
  void write(BinaryWriter writer, RegisterChange obj) {
    writer
      ..writeByte(2)
      ..writeByte(1)
      ..write(obj.value)
      ..writeByte(2)
      ..write(obj.type);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is RegisterChangeAdapter && runtimeType == other.runtimeType && typeId == other.typeId;
}

extension OrNullExtension<T> on List<T> {
  List<T>? nullIfEmpty([bool and = true]) => (isNotEmpty && and) ? this : null;
}
