// ignore_for_file: curly_braces_in_flow_control_structures

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:oshi/share/config.dart';
import 'package:oshi/share/resources.dart';
import 'package:oshi/share/share.dart';

import 'package:oshi/models/data/announcement.dart' show AnnouncementAdapter;
import 'package:oshi/models/data/attendances.dart' show AttendanceAdapter, AttendanceTypeAdapter;
import 'package:oshi/models/data/class.dart' show ClassAdapter;
import 'package:oshi/models/data/classroom.dart' show ClassroomAdapter;
import 'package:oshi/models/data/event.dart' show EventAdapter, EventCategoryAdapter;
import 'package:oshi/models/data/grade.dart' show GradeAdapter;
import 'package:oshi/models/data/lesson.dart' show LessonAdapter;
import 'package:oshi/models/data/messages.dart' show MessagesAdapter, MessageAdapter, AttachmentAdapter;
import 'package:oshi/models/data/student.dart' show StudentAdapter, AccountAdapter;
import 'package:oshi/models/data/teacher.dart' show TeacherAdapter;
import 'package:oshi/models/data/timetables.dart'
    show TimetablesAdapter, TimetableDayAdapter, TimetableLessonAdapter, SubstitutionDetailsAdapter;
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
    ..registerAdapter(DurationAdapter());

  await Share.settings.load(); // TODO you'll know what to do with this... when time comes.
  Share.session = Share.settings.sessions.lastSession ?? Session(providerGuid: 'PROVGUID-SHIM-SMPL-FAKE-DATAPROVIDER');
  if (Share.settings.sessions.lastSession != null) Share.session.tryLogin(); // Auto-login on restart if valid

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
