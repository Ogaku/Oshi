import 'dart:io';

import 'package:background_fetch/background_fetch.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/widgets.dart';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart' as notifications;
import 'package:hive_flutter/adapters.dart';
import 'package:oshi/share/config.dart';
import 'package:oshi/share/notifications.dart';
import 'package:oshi/share/resources.dart';
import 'package:oshi/share/share.dart';

import 'package:oshi/models/data/announcement.dart' show Announcement, AnnouncementAdapter;
import 'package:oshi/models/data/attendances.dart' show Attendance, AttendanceAdapter, AttendanceTypeAdapter;
import 'package:oshi/models/data/class.dart' show ClassAdapter;
import 'package:oshi/models/data/classroom.dart' show ClassroomAdapter;
import 'package:oshi/models/data/event.dart' show Event, EventAdapter, EventCategoryAdapter;
import 'package:oshi/models/data/grade.dart' show Grade, GradeAdapter;
import 'package:oshi/models/data/lesson.dart' show LessonAdapter;
import 'package:oshi/models/data/messages.dart' show AttachmentAdapter, Message, MessageAdapter, MessagesAdapter;
import 'package:oshi/models/data/student.dart' show StudentAdapter, AccountAdapter;
import 'package:oshi/models/data/teacher.dart' show TeacherAdapter;
import 'package:oshi/models/data/timetables.dart'
    show SubstitutionDetailsAdapter, TimetableDayAdapter, TimetableLesson, TimetableLessonAdapter, TimetablesAdapter;
import 'package:oshi/models/data/unit.dart' show UnitAdapter, LessonRangesAdapter;
import 'package:oshi/models/provider.dart' show ProviderDataAdapter;

import 'package:logging_to_logcat/logging_to_logcat.dart';
import 'package:logging/logging.dart';

// [Android-only] This "Headless Task" is run when the Android app is terminated with `enableHeadless: true`
// Be sure to annotate your callback function to avoid issues in release mode on Flutter >= 3.3.0
@pragma('vm:entry-point')
void backgroundFetchHeadlessTask(HeadlessTask task) async {
  String taskId = task.taskId;
  bool isTimeout = task.timeout;

  if (isTimeout) {
    // This task has exceeded its allowed execution time
    // Fuck it, we ballin' (don't care boutta this shit)
    BackgroundFetch.finish(taskId);
    return;
  }
  // Setup routine, see background.dart
  await setupBaseApplication();

  // Validate our internet connection
  if (Share.settings.config.backgroundSyncWiFiOnly &&
      (await (Connectivity().checkConnectivity())) != ConnectivityResult.wifi) return;

  // Validate our session data
  if (Share.settings.sessions.lastSession == null || !Share.settings.config.enableBackgroundSync) return;

  // Refresh everything
  await Share.session.refreshAll();

  // Do your work here...
  BackgroundFetch.finish(taskId);
}

Future<void> setupBaseApplication() async {
  if (Platform.isAndroid) {
    WidgetsFlutterBinding.ensureInitialized();
    Logger.root.activateLogcat();
  }

  await Hive.initFlutter();

  Hive
    ..registerAdapter(AnnouncementAdapter())
    ..registerAdapter(AttendanceAdapter())
    ..registerAdapter(AttendanceTypeAdapter())
    ..registerAdapter(ClassAdapter())
    ..registerAdapter(ClassroomAdapter())
    ..registerAdapter(EventAdapter())
    ..registerAdapter(EventCategoryAdapter())
    ..registerAdapter(GradeAdapter())
    ..registerAdapter(LessonAdapter())
    ..registerAdapter(MessagesAdapter())
    ..registerAdapter(MessageAdapter())
    ..registerAdapter(AttachmentAdapter())
    ..registerAdapter(StudentAdapter())
    ..registerAdapter(AccountAdapter())
    ..registerAdapter(TeacherAdapter())
    ..registerAdapter(TimetablesAdapter())
    ..registerAdapter(TimetableDayAdapter())
    ..registerAdapter(TimetableLessonAdapter())
    ..registerAdapter(SubstitutionDetailsAdapter())
    ..registerAdapter(UnitAdapter())
    ..registerAdapter(LessonRangesAdapter())
    ..registerAdapter(ProviderDataAdapter())
    ..registerAdapter(SessionsDataAdapter())
    ..registerAdapter(SessionAdapter())
    ..registerAdapter(YearlyAverageMethodsAdapter())
    ..registerAdapter(LessonCallTypesAdapter())
    ..registerAdapter(ConfigAdapter())
    ..registerAdapter(DurationAdapter())
    ..registerAdapter(RegisterChangesAdapter())
    ..registerAdapter(RegisterChangeTypesAdapter())
    ..registerAdapter(RegisterChangeAdapter<TimetableLesson>(id: 51))
    ..registerAdapter(RegisterChangeAdapter<Grade>(id: 52))
    ..registerAdapter(RegisterChangeAdapter<Event>(id: 53))
    ..registerAdapter(RegisterChangeAdapter<Announcement>(id: 54))
    ..registerAdapter(RegisterChangeAdapter<Message>(id: 55))
    ..registerAdapter(RegisterChangeAdapter<Attendance>(id: 56));

  // Load english localization resources
  await Share.translator.loadResources('en');

  await Share.settings.load(); // Load all settings from hive, make sure nothing is missing
  Share.session = Share.settings.sessions.lastSession ?? Session(providerGuid: 'PROVGUID-SHIM-SMPL-FAKE-DATAPROVIDER');
  if (Share.settings.sessions.lastSession != null) await Share.session.tryLogin(showErrors: false); // Auto-login

  // Load localization resources, generate placeholder splashes
  await Share.translator.loadResources(Share.settings.config.languageCode);
  Share.currentIdleSplash = Share.translator.getRandomSplash();
  Share.currentEndingSplash = Share.translator.getRandomEndingSplash();

  // Set the icon to null if you want to use the default app icon
  await Share.notificationsPlugin.initialize(
    notifications.InitializationSettings(
        android: const notifications.AndroidInitializationSettings('app_icon'),
        macOS: notifications.DarwinInitializationSettings(
            onDidReceiveLocalNotification: NotificationController.onNotificationResponse,
            notificationCategories: NotificationController.notificationCategories.values.toList()),
        iOS: notifications.DarwinInitializationSettings(
            onDidReceiveLocalNotification: NotificationController.onNotificationResponse,
            notificationCategories: NotificationController.notificationCategories.values.toList()),
        linux: const notifications.LinuxInitializationSettings(defaultActionName: 'Open notification')),
    onDidReceiveNotificationResponse: NotificationController.notificationResponseReceived,
    onDidReceiveBackgroundNotificationResponse: NotificationController.notificationTapBackground,
  );
}

class DurationAdapter extends TypeAdapter<Duration> {
  @override
  final int typeId = 103;

  @override
  Duration read(BinaryReader reader) {
    return Duration(seconds: reader.read());
  }

  @override
  void write(BinaryWriter writer, Duration obj) {
    writer.write(obj.inSeconds);
  }
}
