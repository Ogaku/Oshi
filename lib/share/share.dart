// ignore_for_file: avoid_function_literals_in_foreach_calls

import 'dart:convert';
import 'package:universal_io/io.dart';

import 'package:appcenter_sdk_flutter/appcenter_sdk_flutter.dart';
import 'package:darq/darq.dart';
import 'package:dio/dio.dart';
import 'package:event/event.dart' as event;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart' as notifications;
import 'package:format/format.dart';
import 'package:intl/intl.dart';
import 'package:mutex/mutex.dart';
import 'package:oshi/interface/shared/pages/absences.dart';
import 'package:oshi/interface/shared/pages/home.dart';
import 'package:oshi/interface/shared/pages/timetable.dart';
import 'package:oshi/models/data/announcement.dart';
import 'package:oshi/models/data/attendances.dart';
import 'package:oshi/models/data/grade.dart';
import 'package:oshi/models/data/lesson.dart';
import 'package:oshi/models/data/messages.dart';
import 'package:oshi/models/data/timetables.dart';
import 'package:oshi/models/data/event.dart';
import 'package:oshi/models/provider.dart';
import 'package:platform_device_id/platform_device_id.dart';

import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

import 'package:oshi/models/data/teacher.dart';
import 'package:oshi/models/progress.dart';
import 'package:oshi/interface/shared/pages/home.dart' show DateTimeExtension;

import 'package:oshi/providers/librus/librus_data.dart' hide DateTimeExtension;
import 'package:oshi/providers/sample/sample_data.dart';
import 'package:oshi/share/config.dart';
import 'package:oshi/share/notifications.dart';
import 'package:oshi/share/resources.dart';
import 'package:oshi/share/translator.dart';
import 'package:oshi/share/appcenter.dart' as apps;

part 'share.g.dart';

class Share {
  // The application string resources handler
  static Translator translator = Translator();
  static notifications.FlutterLocalNotificationsPlugin notificationsPlugin = notifications.FlutterLocalNotificationsPlugin();

  static String currentIdleSplash = '???';
  static ({String title, String subtitle}) currentEndingSplash = (title: '???', subtitle: '???');
  static ({Exception exception, StackTrace trace})? settingsLoadError;

  // The provider and register data for the current session
  // MUST be initialized before switching to the base app
  static late Session session;
  static final Mutex settingsMutex = Mutex();

  // Shared settings data for managing sessions
  static Settings settings = Settings();
  static String buildNumber = '9.9.9.9';
  static bool backgroundSyncActive = false;

  // Raised by the app to notify that the uses's just logged in
  // To subscribe: event.subscribe((args) => {})
  static event.Event<event.Value<StatefulWidget Function()>> changeBase =
      event.Event<event.Value<StatefulWidget Function()>>();
  static event.Event refreshBase = event.Event(); // Trigger a setState on the base app and everything subscribed
  static event.Event checkUpdates = event.Event(); // Trigger an update on the base app and everything subscribed
  static event.Event openTimeline = event.Event(); // Trigger an event on the home page and everything subscribed
  static event.Event refreshAll = event.Event(); // Trigger an event on every "unread" widget (unseen) subscribed
  static event.Event<event.Value<({String title, String message, Map<String, Future<void> Function()> actions})>>
      showErrorModal =
      event.Event<event.Value<({String title, String message, Map<String, Future<void> Function()> actions})>>();

  // Navigate the grades page to the specified subject
  static event.Event<event.Value<Lesson>> gradesNavigate = event.Event<event.Value<Lesson>>();

  // Navigate the messages page to the specified message
  static event.Event<event.Value<Message>> messagesNavigate = event.Event<event.Value<Message>>();

  // Navigate the messages page to the specified announcement
  static event.Event<event.Value<({Message message, Announcement parent})>> messagesNavigateAnnouncement =
      event.Event<event.Value<({Message message, Announcement parent})>>();

  // Navigate the timetable page to the specified day
  static event.Event<event.Value<DateTime>> timetableNavigateDay = event.Event<event.Value<DateTime>>();

  // Navigate the bottom tab bar to the specified page
  static event.Event<event.Value<int>> tabsNavigatePage = event.Event<event.Value<int>>();

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
  Config appSettings = Config();

  // Load all the data from storage, called manually
  Future<({bool success, Exception? message})> load() async {
    try {
      await Share.settingsMutex.protect<void>(() async {
        // Load saved settings
        sessions = (await Hive.openBox('sessions')).get('sessions', defaultValue: SessionsData());
        appSettings = (await Hive.openBox('config'))
            .get('config', defaultValue: Config(languageCode: Platform.localeName.substring(0, 2)));
      });
    } on Exception catch (ex, stack) {
      try {
        Share.settingsLoadError = (exception: ex, trace: stack);
        await AppCenterCrashes.trackException(message: ex.toString(), stackTrace: stack);
        await AppCenterAnalytics.trackEvent(name: '${ex.toString()}:\n ${stack.toString()}');
      } catch (e) {
        // ignored
      }
      return (success: false, message: ex);
    } catch (ex, stack) {
      try {
        Share.settingsLoadError = (exception: Exception(ex), trace: stack);
        await AppCenterCrashes.trackException(message: ex.toString(), stackTrace: stack);
        await AppCenterAnalytics.trackEvent(name: '${ex.toString()}:\n ${stack.toString()}');
      } catch (e) {
        // ignored
      }
      return (success: false, message: Exception(ex));
    }
    return (success: true, message: null);
  }

  // Save all received data to storage, called automatically
  bool _settingsSaveActive = false;
  Future<({bool success, Exception? message})> save([void Function()? inline]) async {
    if (inline != null) {
      try {
        inline(); // Execute th einline function passed
        if (_settingsSaveActive) return (success: true, message: null);
        _settingsSaveActive = true; // Mark as waiting for grouped saves
        await Future.delayed(const Duration(seconds: 5)); // Wait for more
        await save(); // Save settings and unlock the inline controller
        _settingsSaveActive = false; // Mark as available, back to normal
        return (success: true, message: null);
      } catch (ex) {
        _settingsSaveActive = false; // Mark as not working
        return (success: false, message: Exception(ex));
      }
    }

    try {
      // Update the badges
      Share.session.unreadChanges.updateBadge();
      Share.refreshBase.broadcast();
      Share.refreshAll.broadcast();
    } catch (ex) {
      // ignored
    }

    try {
      await Share.settingsMutex.protect<void>(() async {
        // Remove everything, as Hive's append-only
        (await Hive.openBox('sessions')).clear();
        (await Hive.openBox('config')).clear();

        // Put the new data in, thank the dev for being an idiot
        (await Hive.openBox('sessions')).put('sessions', sessions);
        (await Hive.openBox('config')).put('config', appSettings);
      });
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
      await Share.settingsMutex.protect<void>(() async {
        // Clear internal settings
        (await Hive.openBox('sessions')).clear();
        (await Hive.openBox('config')).clear();
      });

      // Re-generate settings
      sessions = SessionsData();
      appSettings = Config();
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
      List<RegisterChanges>? changes,
      List<Event>? adminEvents,
      List<Event>? customEvents,
      List<Event>? sharedEvents,
      Map<Lesson, List<Grade>>? customGrades,
      SessionConfig? settings,
      UnreadChanges? unreadChanges})
      : provider = provider ?? Share.providers[providerGuid]!.factory(),
        sessionCredentials = credentials ?? {},
        data = ProviderData(),
        changes = changes ?? [],
        adminEvents = adminEvents ?? [],
        customEvents = customEvents ?? [],
        sharedEvents = sharedEvents ?? [],
        customGrades = customGrades ?? {},
        settings = settings ?? SessionConfig(),
        unreadChanges = unreadChanges ?? UnreadChanges();

  // Refresh status
  final RefreshStatus refreshStatus = RefreshStatus();

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

  @HiveField(8)
  SessionConfig settings = SessionConfig();

  @JsonKey(includeToJson: false, includeFromJson: false)
  IProvider provider;

  // Updates for each session (if any)
  @HiveField(6)
  List<Event> adminEvents;

  @HiveField(7)
  List<Event> customEvents;

  @HiveField(10, defaultValue: [])
  List<Event> sharedEvents;

  @HiveField(11, defaultValue: {})
  Map<Lesson, List<Grade>> customGrades;

  @HiveField(9)
  UnreadChanges unreadChanges;

  @JsonKey(includeToJson: false, includeFromJson: false)
  List<Event> get events =>
      data.student.mainClass.events.appendAll(adminEvents).appendAll(customEvents).appendAll(sharedEvents).toList();

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
        Share.showErrorModal.broadcast(event.Value((
          title: 'Error logging in!',
          message:
              'An exception "$ex" occurred and the provider couldn\'t log you in to the e-register.\n\nPlease check your credentials and try again later.',
          actions: {
            'Copy Exception': () async => await Clipboard.setData(ClipboardData(text: ex.toString())),
            'Copy Stack Trace': () async => await Clipboard.setData(ClipboardData(text: stack.toString())),
          }
        )));
      }
      try {
        await AppCenterCrashes.trackException(message: ex.toString(), stackTrace: stack, properties: {'where': 'refresh'});
      } catch (e) {
        // ignored
      }
      return (success: false, message: Exception(ex));
    }
  }

  // Login and refresh methods for runtime - implement as async
  // For null 'weekStart' - get (only) the current week's data
  // For reporting 'progress' - mark 'Progress' as null for indeterminate status
  Future<({bool success, Exception? message})> refreshAll(
      {DateTime? weekStart,
      IProgress<({double? progress, String? message})>? progress,
      bool saveChanges = true,
      bool showErrors = true}) async {
    // Already working, skip for now
    if (refreshStatus.isRefreshing) return (success: true, message: null);

    Share.checkUpdates.broadcast(); // Check for updates everywhere
    refreshStatus.markAsStarted(); // Refresh started

    try {
      var mProgress = (progress as Progress<({double? progress, String? message})>?) ??
          Progress<({double? progress, String? message})>();

      NotificationController.sendNotification(
          playSoundforce: false,
          title: 'Syncing everything...',
          content: 'Please wait a while...',
          category: NotificationCategories.other,
          id: 9999992);

      mProgress.progressChanged.subscribe((args) {
        refreshStatus.progressStatus = args?.value.message;
        NotificationController.sendNotification(
            playSoundforce: false,
            title: 'Syncing everything...',
            content: (args?.value.message?.isEmpty ?? true) ? 'Please wait a while...' : args!.value.message!,
            category: NotificationCategories.other,
            progress: args?.value.progress ?? 0.0,
            id: 9999992);
      });

      // Actually refresh everything
      var result1 = await provider.refresh(weekStart: weekStart, progress: mProgress);
      var result2 = await provider.refreshMessages(progress: mProgress);

      NotificationController.sendNotification(
          playSoundforce: false,
          title: 'Syncing everything...',
          content: 'Saving the downloaded data...',
          category: NotificationCategories.other,
          id: 9999992);

      // Check out admin events
      try {
        adminEvents = ((await () async {
          var data = (await Dio(BaseOptions(baseUrl: 'https://raw.githubusercontent.com'))
                  .get('/Ogaku/Toudai/main/admin_events.json'))
              .data;
          return data is String ? jsonDecode(data) : data;
        }())["admin_events"] as List<dynamic>)
            .select((element, index) => Event(
                date: DateTime.parse(element["start"]),
                timeFrom: DateTime.parse(element["start"]),
                timeTo: DateTime.parse(element["end"]),
                title: element["title"][Share.settings.appSettings.languageCode] ?? element["title"]["en"] ?? '',
                content:
                    element["description"][Share.settings.appSettings.languageCode] ?? element["description"]["en"] ?? '',
                category: EventCategory.admin))
            .toList();
      } catch (ex) {
        // ignored
      }

      // Check out shared events, if allowed in settings
      if (Share.session.settings.allowSzkolnyIntegration) {
        try {
          var data = (await Dio(BaseOptions(baseUrl: 'https://api.szkolny.eu')).post('/appSync',
                  options: Options(headers: {
                    "X-ApiKey": apps.AppCenter.szkolnyAppKey,
                    "X-AppBuild": Share.buildNumber.split('.').last.toString(),
                    "X-AppFlavor": "Release",
                    "X-AppVersion": Share.buildNumber.toString(),
                    "X-DeviceId": (await PlatformDeviceId.getDeviceId)?.trim() ?? "UNKNOWN",
                    // "X-Signature": "",
                    // "X-Timestamp": timestamp.toString(),
                    'Content-Type': 'application/json'
                  }),
                  data: jsonEncode({
                    "deviceId": (await PlatformDeviceId.getDeviceId)?.trim() ?? "UNKNOWN",
                    "userCodes": [Share.session.data.student.userCode],
                    "users": [
                      {
                        "loginType": Share.session.provider.loginType,
                        "studentName": Share.session.data.student.account.name,
                        "studentNameShort":
                            '${Share.session.data.student.account.firstName} ${Share.session.data.student.account.lastName[0]}.',
                        "teamCodes": Share.session.data.student.teamCodes.keys.toList(),
                        "userCode": Share.session.data.student.userCode
                      }
                    ],
                    "lastSync": -1
                  })))
              .data;

          var eventsJson = (await () async {
            return data is String ? jsonDecode(data) : data;
          }());

          if (eventsJson["success"] == true) {
            sharedEvents = (eventsJson["data"]["events"] as List<dynamic>)
                .where((element) => Share.session.data.student.teamCodes.keys.contains(element["teamCode"]))
                .select((element, index) {
              var eventDate = element["eventDate"] > 10000101
                  ? DateTime(
                      int.parse(element["eventDate"].toString().substring(0, 4)),
                      int.parse(element["eventDate"].toString().substring(4, 6)),
                      int.parse(element["eventDate"].toString().substring(6, 8)))
                  : null;

              var startTime = element["startTime"] > 10000
                  ? DateTime(
                      eventDate?.year ?? 2000,
                      eventDate?.month ?? 1,
                      eventDate?.day ?? 1,
                      int.parse(element["startTime"].toString().substring(0, element["startTime"].toString().length - 4)),
                      int.parse(element["startTime"].toString().substring(
                          element["startTime"].toString().length - 4, element["startTime"].toString().length - 2)),
                      int.parse(element["startTime"]
                          .toString()
                          .substring(element["startTime"].toString().length - 2, element["startTime"].toString().length)))
                  : null;

              return Event(
                  id: (element["id"] as int?) ?? -1,
                  teamCode: element["teamCode"],
                  date: eventDate,
                  timeFrom: startTime,
                  timeTo: startTime?.add(const Duration(minutes: 45)),
                  isSharedEvent: true,
                  lessonNo: eventDate != null
                      ? (Share.session.data.timetables[eventDate]?.lessons
                          .firstWhereOrDefault((x) => x?.any((y) => y.timeFrom?.asHour() == startTime?.asHour()) ?? false)
                          ?.firstWhereOrDefault((x) => x.timeFrom?.asHour() == startTime?.asHour())
                          ?.lessonNo)
                      : null,
                  sender: Teacher(firstName: element["sharedByName"] ?? ''),
                  content: element["topic"] ?? '',
                  category: (element["type"] as int? ?? 0).asEventCategory);
            }).toList();
          }
        } catch (ex) {
          // ignored
        }
      }

      NotificationController.sendNotification(
          playSoundforce: false,
          title: 'Syncing everything...',
          content: 'Saving the downloaded data...',
          category: NotificationCategories.other,
          id: 9999992);

      // Sync the downloaded data
      await updateData(info: result1.success, messages: result2.success, saveChanges: saveChanges);

      Share.currentIdleSplash = Share.translator.getRandomSplash();
      Share.currentEndingSplash = Share.translator.getRandomEndingSplash();
      Future.delayed(const Duration(seconds: 2)).then((value) => Share.notificationsPlugin.cancel(9999992));

      refreshStatus.markAsDone(); // Refresh started
      return (success: result1.success && result2.success, message: result1.message ?? result2.message);
    } catch (ex, stack) {
      if (showErrors) {
        Share.showErrorModal.broadcast(event.Value((
          title: 'Error refreshing data!',
          message:
              'A fatal exception "$ex" occurred and the provider couldn\'t update the e-register data.\n\nPlease try again later.\nConsider reporting this error.',
          actions: {
            'Copy Exception': () async => await Clipboard.setData(ClipboardData(text: ex.toString())),
            'Copy Stack Trace': () async => await Clipboard.setData(ClipboardData(text: stack.toString())),
          }
        )));
      }
      Share.notificationsPlugin.cancel(9999992);
      refreshStatus.markAsDone(); // Refresh started
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
          .where((x) => x.date.asDate().isAfterOrSame(DateTime.now().asDate()))
          .select((lesson, index) => RegisterChange<TimetableLesson>(
              type: lesson.isCanceled ? RegisterChangeTypes.removed : RegisterChangeTypes.changed, value: lesson))
          .toList();

      /* Grades */
      var allGradesDownloaded = provider.registerData!.student.subjects
          .select((subject, index) => (subject: subject, grades: subject.grades))
          .selectMany(
              (subject, index) => subject.grades.select((element, index) => (subject: subject.subject, grade: element)))
          .toList();
      var allGradesSaved = data.student.subjects
          .select((subject, index) => (subject: subject, grades: subject.grades))
          .selectMany(
              (subject, index) => subject.grades.select((element, index) => (subject: subject.subject, grade: element)))
          .toList();

      var gradeChanges = allGradesDownloaded
          .except(allGradesSaved, (element) => element.grade)
          .select((x, index) => RegisterChange<Grade>(
              type: allGradesSaved.any((y) => y.grade.id == x.grade.id && y.grade.id > 0 && x.grade.id > 0)
                  ? RegisterChangeTypes.changed
                  : RegisterChangeTypes.added,
              value: x.grade,
              payload: x.subject))
          .appendAll(allGradesSaved.except(allGradesDownloaded, (element) => element.grade).select((x, index) =>
              RegisterChange<Grade>(
                  type: allGradesDownloaded.any((y) => y.grade.id == x.grade.id && y.grade.id > 0 && x.grade.id > 0)
                      ? RegisterChangeTypes.changed
                      : RegisterChangeTypes.removed,
                  value: x.grade,
                  payload: x.subject)))
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

      /* Attendance */
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

      if (saveChanges && detectedChanges.any) {
        changes.add(detectedChanges);

        // Compose unread badges
        unreadChanges.timetables.addAll(detectedChanges.timetablesChanged.select((x, index) => x.value.hashCode));
        unreadChanges.grades.addAll(detectedChanges.gradesChanged.select((x, index) => x.value.hashCode));
        unreadChanges.attendances.addAll(detectedChanges.attendancesChanged.select((x, index) => x.value.hashCode));
        unreadChanges.events.addAll(detectedChanges.eventsChanged
            .where((x) => x.value.category != EventCategory.teacher)
            .select((x, index) => x.value.hashCode));

        var notifications = <({String title, String body, TimelineNotification payload})>[];
        // var messageNotifications = <({String title, String body, TimelineNotification payload})>[];

        // Compose timetable notifications
        if (settings.enableTimetableNotifications) {
          detectedChanges.timetablesChanged.forEach((element) => notifications.add((
                title: '/Notifications/Categories/Timetable/${switch (element.type) {
                  RegisterChangeTypes.removed => "Cancelled",
                  RegisterChangeTypes.changed when element.value.isMovedLesson => "Moved",
                  RegisterChangeTypes.changed when element.value.isSubstitution => "Substitution",
                  _ => "New"
                }}'
                    .localized
                    .format(DateFormat.yMd(Share.settings.appSettings.localeCode).format(element.value.date),
                        element.value.lessonNo),
                body: (element.value.isSubstitution &&
                            (element.value.substitutionDetails?.originalSubject?.name.isNotEmpty ?? false)
                        ? '${element.value.substitutionDetails?.originalSubject?.name} → '
                        : '') +
                    '/Notifications/Captions/Joiners/Lesson'.localized.format(
                        element.value.subject?.name ?? element.value.classroomString,
                        element.value.teacher?.name ?? '/Notifications/Placeholder/Teacher'.localized),
                payload: TimelineNotification(data: element.value)
              )));
        }

        // Compose message notifications
        if (settings.enableMessagesNotifications) {
          detectedChanges.messagesChanged
              .where((element) => element.type == RegisterChangeTypes.added)
              .forEach((element) => notifications.add((
                    title: '/Notifications/Categories/Messages/New'.localized.format(element.value.senderName),
                    body: element.value.topic,
                    payload: TimelineNotification(data: element.value)
                  )));
        }

        // Compose attendance notifications
        if (settings.enableAttendanceNotifications) {
          detectedChanges.attendancesChanged
              .where((element) =>
                  element.type == RegisterChangeTypes.added &&
                  (element.value.type == AttendanceType.absent ||
                      element.value.type == AttendanceType.late ||
                      element.value.type == AttendanceType.excused))
              .forEach((element) => notifications.add((
                    title: '/Notifications/Categories/Attendance/${switch (element.value.type) {
                      AttendanceType.absent => "Absence",
                      AttendanceType.late => "Late",
                      AttendanceType.excused => "Excused",
                      _ => "New"
                    }}'
                        .localized
                        .format(DateFormat.yMd(Share.settings.appSettings.localeCode).format(element.value.date),
                            element.value.lessonNo),
                    body: '/Notifications/Captions/Joiners/Lesson'.localized.format(
                        element.value.lesson.subject?.name ?? '/Notifications/Placeholder/Lesson'.localized,
                        element.value.teacher.name),
                    payload: TimelineNotification(data: element.value)
                  )));

          detectedChanges.attendancesChanged
              .where((element) =>
                  element.type == RegisterChangeTypes.changed ||
                  element.type == RegisterChangeTypes.removed ||
                  (element.type == RegisterChangeTypes.added &&
                      element.value.type != AttendanceType.absent &&
                      element.value.type != AttendanceType.late &&
                      element.value.type != AttendanceType.excused))
              .forEach((element) => notifications.add((
                    title: '/Notifications/Categories/Attendance/${switch (element.type) {
                      RegisterChangeTypes.added => "New",
                      RegisterChangeTypes.changed => "Changed",
                      RegisterChangeTypes.removed => "Removed"
                    }}'
                        .localized
                        .format(
                            element.value.type.asString(),
                            DateFormat.yMd(Share.settings.appSettings.localeCode).format(element.value.date),
                            element.value.lessonNo),
                    body: '/Notifications/Captions/Joiners/Lesson'.localized.format(
                        element.value.lesson.subject?.name ?? '/Notifications/Placeholder/Lesson'.localized,
                        element.value.teacher.name),
                    payload: TimelineNotification(data: element.value)
                  )));
        }

        // Compose grade notifications
        if (settings.enableGradesNotifications) {
          detectedChanges.gradesChanged
              .where((element) => element.type == RegisterChangeTypes.added)
              .forEach((element) => notifications.add((
                    title: '/Notifications/Categories/Grades/New'.localized.format(
                        element.value.value,
                        (element.payload is Lesson ? element.payload as Lesson : null)?.name ??
                            '/Notifications/Placeholder/Lesson'.localized.toLowerCase()),
                    body: element.value.name,
                    payload: TimelineNotification(data: element.payload)
                  )));

          detectedChanges.gradesChanged
              .where((element) => element.type == RegisterChangeTypes.removed || element.type == RegisterChangeTypes.changed)
              .forEach((element) => notifications.add((
                    title: '/Notifications/Categories/Grades/${switch (element.type) {
                      RegisterChangeTypes.added => "New",
                      RegisterChangeTypes.changed => "Changed",
                      RegisterChangeTypes.removed => "Removed"
                    }}'
                        .localized
                        .format(element.value.value,
                            DateFormat.yMd(Share.settings.appSettings.localeCode).format(element.value.date)),
                    body: '/Notifications/Captions/Joiners/Lesson'.localized.format(
                        (element.payload is Lesson ? element.payload as Lesson : null)?.name ??
                            '/Notifications/Placeholder/Lesson'.localized,
                        (element.payload is Lesson ? element.payload as Lesson : null)?.teacher.name ??
                            '/Notifications/Placeholder/Teacher'.localized),
                    payload: TimelineNotification(data: element.payload)
                  )));
        }

        // Compose announcement notifications
        if (settings.enableAnnouncementsNotifications) {
          detectedChanges.announcementsChanged.forEach((element) => notifications.add((
                title: '/Notifications/Categories/Announcement/${switch (element.type) {
                  RegisterChangeTypes.changed => "Changed",
                  _ => "New"
                }}'
                    .localized
                    .format(element.value.contact?.name ?? '/Notifications/Placeholder/Teacher'.localized),
                body: element.value.subject,
                payload: TimelineNotification(data: element.value)
              )));
        }

        // Compose event notifications
        if (settings.enableEventsNotifications) {
          detectedChanges.eventsChanged
              .where((element) => element.value.category == EventCategory.teacher)
              .forEach((element) => notifications.add((
                    title: '/Notifications/Categories/Event/Teacher/${switch (element.type) {
                      RegisterChangeTypes.added => "New",
                      RegisterChangeTypes.changed => "Changed",
                      RegisterChangeTypes.removed => "Removed"
                    }}'
                        .localized
                        .format(element.value.sender?.name ?? ''),
                    body: (element.value.timeFrom.month == element.value.timeTo?.month &&
                            element.value.timeFrom.day == element.value.timeTo?.day)
                        ? DateFormat.yMMMMEEEEd(Share.settings.appSettings.localeCode)
                                .format(element.value.timeTo ?? DateTime.now()) // Wednesday, May 10
                            +
                            ((element.value.timeFrom.hour != 0 && element.value.timeTo?.hour != 0) &&
                                    (element.value.timeFrom.asDate() == element.value.timeTo?.asDate())
                                ? "(${DateFormat.Hm(Share.settings.appSettings.localeCode).format(element.value.timeFrom)} - ${DateFormat.Hm(Share.settings.appSettings.localeCode).format(element.value.timeTo ?? DateTime.now())})"
                                : '') // (10:30 - 11:25)
                        : (element.value.timeFrom.month == element.value.timeTo?.month)
                            ? "${DateFormat.d(Share.settings.appSettings.localeCode).format(element.value.timeFrom)} - ${DateFormat.yMMMMEEEEd(Share.settings.appSettings.localeCode).format(element.value.timeTo ?? DateTime.now())}" // 10 - 15 May 2023
                            : "${DateFormat.MMMEd(Share.settings.appSettings.localeCode).format(element.value.timeFrom)} - ${DateFormat.MMMEd(Share.settings.appSettings.localeCode).format(element.value.timeTo ?? DateTime.now())}", // Wed, May 10 - Fri, May 15
                    payload: TimelineNotification(data: element.value)
                  )));

          detectedChanges.eventsChanged
              .where((element) => element.value.category != EventCategory.teacher)
              .forEach((element) => notifications.add((
                    title: '/Notifications/Categories/Event/${switch (element.type) {
                      RegisterChangeTypes.added => "New",
                      RegisterChangeTypes.changed => "Changed",
                      RegisterChangeTypes.removed => "Removed"
                    }}'
                        .localized
                        .format(
                            element.value.category.asString(),
                            DateFormat.MMMMEEEEd(Share.settings.appSettings.localeCode)
                                .format(element.value.date ?? element.value.timeFrom)),
                    body: element.value.titleString.isNotEmpty
                        ? element.value.titleString
                        : (element.value.sender?.name ?? element.value.subtitleString),
                    payload: TimelineNotification(data: element.value)
                  )));
        }

        // Send all composed notifications
        notifications.forEach((element) => NotificationController.sendNotification(
            playSoundforce: notifications.first == element ? null : false,
            title: element.title,
            content: element.body,
            data: jsonEncode(element.payload.toJson())));

        // messageNotifications.forEach((element) => NotificationController.sendNotification(
        //     playSoundforce: messageNotifications.first == element ? null : false,
        //     title: element.title,
        //     content: element.body,
        //     category: NotificationCategories.messages,
        //     data: jsonEncode(element.payload.toJson())));
      }
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

@HiveType(typeId: 58)
class UnreadChanges {
  UnreadChanges({List<int>? timetables, List<int>? grades, List<int>? events, List<int>? attendances})
      : timetables = timetables ?? [],
        grades = grades ?? [],
        events = events ?? [],
        attendances = attendances ?? [];

  @HiveField(1)
  List<int> timetables;

  @HiveField(2)
  List<int> grades;

  @HiveField(3)
  List<int> events;

  @HiveField(4)
  List<int> attendances;

  int get gradesCount => Share.session.data.student.subjects.sum((x) => x.unseenCount);
  int get timetablesCount => Share.session.data.timetables.timetable.entries
      .where((x) => x.key.asDate().isAfterOrSame(DateTime.now().asDate()))
      .sum((x) => x.value.unreadCount)
      .round();
  int get messagesCount => Share.session.data.messages.received.count((x) => !x.read);
  int get announcementsCount => (Share.session.data.student.mainClass.unit.announcements?.count((x) => !x.read) ?? 0);
  int get eventsCount => Share.session.data.student.mainClass.events
      .where((x) => (x.date ?? x.timeFrom).asDate().isAfterOrSame(DateTime.now().asDate()))
      .count((x) => x.unseen);
  int get attendancesCount => (Share.session.data.student.attendances?.count((x) => x.unseen) ?? 0);

  int get homeworksCount => Share.session.data.student.mainClass.events
      .where((x) => (x.date ?? x.timeFrom).asDate().isAfterOrSame(DateTime.now().asDate()))
      .where((x) => x.category == EventCategory.homework)
      .count((x) => x.unseen);

  void markAsRead({bool attendaceOnly = false}) {
    if (!attendaceOnly) {
      timetables.clear();
      events.clear();
      grades.clear();
    }

    attendances.clear();
    updateBadge();

    Share.settings.save();
    Share.refreshBase.broadcast();
    Share.refreshAll.broadcast();
  }

  int count() {
    return gradesCount + timetablesCount + messagesCount + announcementsCount + eventsCount + attendancesCount;
  }

  void updateBadge() {
    try {
      var unreads = count();
      if (unreads > 0) {
        _setBadge();
      } else {
        _resetBadge();
      }
    } catch (ex) {
      // ignored
    }
  }

  void _setBadge([int? cnt]) {
    try {
      FlutterAppBadger.updateBadgeCount(cnt ?? count());
    } catch (ex) {
      // ignored
    }
  }

  void _resetBadge() {
    try {
      FlutterAppBadger.removeBadge();
    } catch (ex) {
      // ignored
    }
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
  RegisterChange({required this.value, required this.type, this.payload});
  T value;
  dynamic payload;
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

extension EventCategorySelector on int {
  EventCategory get asEventCategory => switch (this) {
        -5 => EventCategory.onlineLesson,
        -1 || 3 || 4 => EventCategory.homework,
        1 => EventCategory.test,
        2 || 3 => EventCategory.shortTest,
        5 => EventCategory.gathering,
        6 => EventCategory.freeDay,
        7 => EventCategory.lecture,
        _ => EventCategory.other
      };
}

extension SzkolnyEventCategorySelector on EventCategory {
  int get asEventCategory => switch (this) {
        EventCategory.onlineLesson => -5,
        EventCategory.homework => -1,
        EventCategory.test => 1,
        EventCategory.shortTest => 2,
        EventCategory.gathering => 5,
        EventCategory.freeDay => 6,
        EventCategory.lecture => 7,
        EventCategory.classWork => 1,
        _ => 0
      };
}

extension ProviderLoginType on IProvider {
  int get loginType => switch (runtimeType) { LibrusDataReader => 2, _ => 20 };
}
