import 'package:flutter_test/flutter_test.dart';
import 'package:oshi/extensions/runtime/standalone_calendar_provider.dart';
import 'package:oshi/interface/shared/pages/welcome.dart';
import 'package:oshi/share/share.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await Share.translator.loadResources('en');
  });

  group('StandaloneCalendarProvider', () {
    test('initializes with valid school year dates and student data', () {
      final provider = StandaloneCalendarProvider();
      expect(provider.providerName, contains('Kalendarz'));
      expect(provider.credentialsConfig.isEmpty, isTrue);

      final data = provider.registerData;
      expect(data, isNotNull);
      expect(data!.student.account.name, isNotEmpty);
      expect(data.student.mainClass.beginSchoolYear.isBefore(data.student.mainClass.endSchoolYear), isTrue);
      expect(data.timetables, isNotNull);
      expect(data.messages, isNotNull);
    });

    test('login and refresh succeed without external network', () async {
      final provider = StandaloneCalendarProvider();
      final loginRes = await provider.login();
      expect(loginRes.success, isTrue);
      expect(loginRes.message, isNull);

      final refreshRes = await provider.refresh();
      expect(refreshRes.success, isTrue);
      expect(refreshRes.message, isNull);

      final refreshMsgRes = await provider.refreshMessages();
      expect(refreshMsgRes.success, isTrue);
      expect(refreshMsgRes.message, isNull);
    });
  });

  group('WelcomePage widget', () {
    testWidgets('renders logo, title, and onboarding action buttons', (tester) async {
      await tester.pumpWidget(
        const WelcomePage(asApp: true),
      );
      await tester.pump();

      // Title & subtitle
      expect(find.text('Oshi'), findsOneWidget);
      expect(find.textContaining('Twój asystent szkolny'), findsOneWidget);

      // Primary "Rozpocznij" button
      expect(find.text('Rozpocznij'), findsOneWidget);

      // Secondary "Tylko kalendarz" button
      expect(find.textContaining('Tylko kalendarz'), findsOneWidget);
    });
  });
}

