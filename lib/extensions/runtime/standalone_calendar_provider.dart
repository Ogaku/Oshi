// ignore_for_file: prefer_const_constructors
import 'package:event/event.dart';
import 'package:flutter/widgets.dart';
import 'package:oshi/interface/shared/session_management.dart';
import 'package:oshi/models/data/announcement.dart' show Announcement;
import 'package:oshi/models/data/class.dart' show Class;
import 'package:oshi/models/data/event.dart' as models show Event;
import 'package:oshi/models/data/messages.dart' show Message, Messages;
import 'package:oshi/models/data/student.dart' show Account, Student;
import 'package:oshi/models/data/teacher.dart' show Teacher;
import 'package:oshi/models/data/timetables.dart' show Timetables;
import 'package:oshi/models/data/unit.dart' show Unit;
import 'package:oshi/models/progress.dart' show IProgress;
import 'package:oshi/models/provider.dart' show IProvider, ProviderData;
import 'package:oshi/share/share.dart';
import 'package:uuid/uuid.dart';

/// Built-in provider allowing users to use Oshi purely as a personal calendar,
/// agenda, and timetable organizer without connecting to any school register (e.g. Librus or Vulcan).
class StandaloneCalendarProvider implements IProvider {
  static const String guid = 'PROVGUID-NONE-CALENDAR-STANDALONE';

  StandaloneCalendarProvider({ProviderData? initialData}) {
    registerData = initialData ?? createDefaultData();
  }

  static ProviderData createDefaultData({String name = 'Mój kalendarz'}) {
    final now = DateTime.now();
    // School year begins Sept 1 of current academic year and ends June 30 of following year
    final int schoolYearStart = (now.month >= 9) ? now.year : now.year - 1;
    final beginSchoolYear = DateTime(schoolYearStart, 9, 1);
    final endFirstSemester = DateTime(schoolYearStart + 1, 1, 31);
    final endSchoolYear = DateTime(schoolYearStart + 1, 6, 30);

    return ProviderData(
      student: Student(
        account: Account(
          id: 1,
          userId: 1,
          number: 1,
          firstName: name,
          lastName: '',
        ),
        mainClass: Class(
          id: 1,
          number: 1,
          symbol: 'CAL',
          name: name,
          beginSchoolYear: beginSchoolYear,
          endFirstSemester: endFirstSemester,
          endSchoolYear: endSchoolYear,
          unit: Unit(name: 'Oshi Kalendarz'),
        ),
        subjects: [],
      ),
      timetables: Timetables(),
      messages: Messages(),
    );
  }

  @override
  ProviderData? registerData;

  @override
  Map<String, ({String name, bool obscure, ({String text, Uri link})? helper})> get credentialsConfig => const {};

  @override
  String get providerName => 'Kalendarz (bez dziennika)';

  @override
  String get providerDescription =>
      'Używaj Oshi jako osobistego terminarza i planu lekcji bez logowania do szkolnego dziennika.';

  @override
  Uri? get providerBannerUri => null;

  @override
  Event<Value<String>> propertyChanged = Event<Value<String>>();

  @override
  Future<({bool success, Exception? message})> login({
    Map<String, String>? credentials,
    IProgress<({double? progress, String? message})>? progress,
  }) async {
    registerData ??= createDefaultData();
    return (success: true, message: null);
  }

  @override
  Future<({bool success, Exception? message})> refresh({
    DateTime? weekStart,
    IProgress<({double? progress, String? message})>? progress,
  }) async {
    registerData ??= createDefaultData();
    return (success: true, message: null);
  }

  @override
  Future<({bool success, Exception? message})> refreshMessages({
    IProgress<({double? progress, String? message})>? progress,
  }) async {
    return (success: true, message: null);
  }

  @override
  Future<({bool success, Exception? message})> sendMessage({
    required List<Teacher> receivers,
    required String topic,
    required String content,
  }) async {
    return (success: true, message: null);
  }

  @override
  Future<({bool success, Exception? message, Message? result})> fetchMessageContent({
    required Message parent,
    required bool byMe,
  }) async {
    return (success: true, message: null, result: parent);
  }

  @override
  Future<({bool success, Exception? message})> moveMessageToTrash({
    required Message parent,
    required bool byMe,
  }) async {
    return (success: true, message: null);
  }

  @override
  Future<({bool success, Exception? message})> markEventAsViewed({required models.Event parent}) async =>
      (success: true, message: null);

  @override
  Future<({bool success, Exception? message})> markEventAsDone({required models.Event parent}) async =>
      (success: true, message: null);

  @override
  Future<({bool success, Exception? message})> markAnnouncementAsViewed({required Announcement parent}) async =>
      (success: true, message: null);
}

/// Helper that creates a local standalone calendar session and transitions the app into `baseApplication`.
Future<void> createStandaloneCalendarSession({BuildContext? context, String name = 'Mój kalendarz'}) async {
  final sessionId = const Uuid().v4();
  final provider = StandaloneCalendarProvider();
  final session = Session(
    sessionName: name,
    providerGuid: StandaloneCalendarProvider.guid,
    provider: provider,
  );

  await session.login();
  await session.updateData(info: true, messages: true, saveChanges: false);

  Share.settings.sessions.sessions[sessionId] = session;
  Share.settings.sessions.lastSessionId = sessionId;
  Share.session = session;

  await Share.settings.save();
  Share.changeBase.broadcast(Value(() => baseApplication));
}

