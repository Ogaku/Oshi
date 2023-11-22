// ignore_for_file: curly_braces_in_flow_control_structures

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart' as notifications;
import 'package:hive_flutter/adapters.dart';
import 'package:intl/date_symbol_data_local.dart';
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

import 'package:oshi/interface/material/sessions_page.dart' as materialapp show sessionsPage;
import 'package:oshi/interface/cupertino/sessions_page.dart' as cupertinoapp show sessionsPage;
import 'package:oshi/interface/cupertino/base_app.dart' as cupertinoapp show baseApp;

import 'package:logging_to_logcat/logging_to_logcat.dart';
import 'package:logging/logging.dart';

Future<void> main() async {
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
  if (Share.settings.sessions.lastSession != null) Share.session.tryLogin(); // Auto-login on restart if valid

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

  // Start the actual application
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  StatefulWidget Function() child = Share.settings.config.useCupertino
      ? () => (Share.settings.sessions.lastSession != null ? cupertinoapp.baseApp : cupertinoapp.sessionsPage)
      : () => materialapp.sessionsPage;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting();
  }

  @override
  Widget build(BuildContext context) {
    // Re-subscribe to all events
    Share.changeBase.unsubscribeAll();
    Share.changeBase.subscribe((args) {
      setState(() {
        if (args != null) child = args.value;
      });
    });

    return child();
  }
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
