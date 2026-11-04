import 'package:event/event.dart';

import 'package:oshi/models/data/announcement.dart';
import 'package:oshi/models/data/attendances.dart';
import 'package:oshi/models/data/averages.dart';
import 'package:oshi/models/data/class.dart';
import 'package:oshi/models/data/classroom.dart';
import 'package:oshi/models/data/grade.dart';
import 'package:oshi/models/data/lesson.dart';
import 'package:oshi/models/data/messages.dart';
import 'package:oshi/models/data/student.dart';
import 'package:oshi/models/data/teacher.dart';
import 'package:oshi/models/data/timetables.dart';
import 'package:oshi/models/data/unit.dart';
import 'package:oshi/models/progress.dart';
import 'package:oshi/models/provider.dart';
import 'package:oshi/models/data/event.dart' as models;
import 'package:oshi/share/translator.dart';

class FakeDataReader implements IProvider {
  FakeDataReader() {
    _initSampleData();
  }

  late ProviderData _data;

  void _initSampleData() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final schoolYearStartYear = now.month < 9 ? now.year - 1 : now.year;
    final beginSchoolYear = DateTime(schoolYearStartYear, 9, 1);
    final endFirstSemester = DateTime(schoolYearStartYear + 1, 1, 31);
    final endSchoolYear = DateTime(schoolYearStartYear + 1, 6, 25);

    const tMath = Teacher(id: 1, userId: 101, firstName: 'Saeko', lastName: 'Takami', isHomeTeacher: true);
    const tCs = Teacher(id: 2, userId: 102, firstName: 'Tadashi', lastName: 'Satomi');
    const tEng = Teacher(id: 3, userId: 103, firstName: 'yukino', lastName: 'Mayuzumi');
    const tPhys = Teacher(id: 4, userId: 104, firstName: 'Kei', lastName: 'Nanjo');
    const tHist = Teacher(id: 5, userId: 105, firstName: 'hannya', lastName: 'Principal');
    const tPol = Teacher(id: 6, userId: 106, firstName: 'Eriko', lastName: 'Kirishima');

    final teachers = [tMath, tCs, tEng, tPhys, tHist, tPol];

    final c101 = Classroom(id: 1, name: 'Room 101', symbol: '101');
    final c204 = Classroom(id: 2, name: 'Lab 204', symbol: '204');
    final c302 = Classroom(id: 3, name: 'Room 302', symbol: '302');
    final c105 = Classroom(id: 4, name: 'Room 105', symbol: '105');

    DateTime lessonTime(int hour, int minute, [DateTime? base]) {
      final d = base ?? DateTime(2000);
      return DateTime(d.year, d.month, d.day, hour, minute);
    }

    final lessonHours = <(int, int, int, int)>[
      (8, 0, 8, 45),
      (8, 55, 9, 40),
      (9, 50, 10, 35),
      (10, 45, 11, 30),
      (11, 45, 12, 30),
      (12, 40, 13, 25),
      (13, 35, 14, 20),
    ];

    final unit = Unit(
      id: 1,
      name: 'St. Hermelin High',
      fullName: 'St. Hermelin High School',
      principalName: 'Hannya Principal',
      address: '123 Mikage-cho',
      town: 'Mikage-cho',
      email: 'office@hermelin.edu',
      phone: '+48 12 345 67 89',
      luckyNumber: 7,
      luckyNumberTomorrow: false,
      lessonsRange: [
        for (final h in lessonHours)
          LessonRanges(from: lessonTime(h.$1, h.$2), to: lessonTime(h.$3, h.$4)),
      ],
      announcements: [
        Announcement(
          id: 1,
          subject: 'School Cultural Festival Next Friday',
          content:
              'Dear students, the annual St. Hermelin Cultural Festival will take place next Friday. Class representatives should submit their booth proposals by Wednesday.',
          contact: tHist,
          read: false,
          startDate: today.subtract(const Duration(days: 1)),
          endDate: today.add(const Duration(days: 10)),
        ),
        Announcement(
          id: 2,
          subject: 'Library Opening Hours Extended',
          content: 'The school library will remain open until 18:00 on weekdays during the exam preparation period.',
          contact: tMath,
          read: true,
          startDate: today.subtract(const Duration(days: 5)),
          endDate: today.add(const Duration(days: 30)),
        ),
      ],
    );

    final mainClass = Class(
      id: 1,
      number: 3,
      symbol: 'c',
      name: '3c',
      beginSchoolYear: beginSchoolYear,
      endFirstSemester: endFirstSemester,
      endSchoolYear: endSchoolYear,
      unit: unit,
      classTutor: tMath,
      averages: {
        DateTime(schoolYearStartYear, 9): const Averages(student: 4.50, level: 4.10),
        DateTime(schoolYearStartYear, 10): const Averages(student: 4.65, level: 4.18),
        DateTime(schoolYearStartYear, 11): const Averages(student: 4.78, level: 4.22),
      },
      events: [
        models.Event(
          id: 101,
          lessonNo: 2,
          date: today.add(const Duration(days: 1)),
          addDate: today.subtract(const Duration(days: 2)),
          timeFrom: lessonTime(8, 55, today.add(const Duration(days: 1))),
          timeTo: lessonTime(9, 40, today.add(const Duration(days: 1))),
          title: 'Calculus & Derivatives Test',
          content: 'Chapter 4: Derivatives, chain rule, and extrema problems.',
          categoryName: 'Test',
          category: models.EventCategory.test,
          sender: tMath,
          classroom: c101,
        ),
        models.Event(
          id: 102,
          lessonNo: 3,
          date: today.add(const Duration(days: 2)),
          addDate: today.subtract(const Duration(days: 1)),
          timeFrom: lessonTime(9, 50, today.add(const Duration(days: 2))),
          timeTo: lessonTime(10, 35, today.add(const Duration(days: 2))),
          title: 'Algorithms Homework: Graph Traversal',
          content: 'Implement BFS and DFS in Dart and analyze time complexity.',
          categoryName: 'Homework',
          category: models.EventCategory.homework,
          done: false,
          sender: tCs,
          classroom: c204,
        ),
        models.Event(
          id: 103,
          lessonNo: 4,
          date: today.add(const Duration(days: 3)),
          addDate: today,
          timeFrom: lessonTime(10, 45, today.add(const Duration(days: 3))),
          timeTo: lessonTime(11, 30, today.add(const Duration(days: 3))),
          title: 'Vocabulary Short Quiz',
          content: 'Units 5-6 vocabulary and idioms.',
          categoryName: 'Short Test',
          category: models.EventCategory.shortTest,
          sender: tEng,
          classroom: c302,
        ),
      ],
    );

    final currentSem = today.isBefore(endFirstSemester) ? 1 : 2;

    final sMath = Lesson(
      id: 1,
      name: 'Mathematics',
      short: 'MATH',
      no: 1,
      hostClass: mainClass,
      teacher: tMath,
      grades: [
        Grade(
          id: 1,
          name: 'Algebra Quiz',
          value: '5',
          weight: 2,
          countsToAverage: true,
          date: today.subtract(const Duration(days: 12)),
          addDate: today.subtract(const Duration(days: 12)),
          addedBy: tMath,
          semester: currentSem,
          isConstituent: true,
          comments: const ['Well done!'],
        ),
        Grade(
          id: 2,
          name: 'Calculus Test',
          value: '5+',
          weight: 3,
          countsToAverage: true,
          date: today.subtract(const Duration(days: 2)),
          addDate: today.subtract(const Duration(days: 2)),
          addedBy: tMath,
          semester: currentSem,
          isConstituent: true,
          comments: const ['Excellent solution on problem 4'],
        ),
        Grade(
          id: 3,
          name: 'Homework',
          value: '4+',
          weight: 1,
          countsToAverage: true,
          date: today.subtract(const Duration(days: 5)),
          addDate: today.subtract(const Duration(days: 5)),
          addedBy: tMath,
          semester: currentSem,
          isConstituent: true,
        ),
      ],
    );

    final sCs = Lesson(
      id: 2,
      name: 'Computer Science',
      short: 'CS',
      no: 2,
      hostClass: mainClass,
      teacher: tCs,
      grades: [
        Grade(
          id: 4,
          name: 'Flutter Project',
          value: '6',
          weight: 3,
          countsToAverage: true,
          date: today.subtract(const Duration(days: 1)),
          addDate: today.subtract(const Duration(days: 1)),
          addedBy: tCs,
          semester: currentSem,
          isConstituent: true,
          comments: const ['Great UI and clean architecture'],
        ),
        Grade(
          id: 5,
          name: 'Data Structures Quiz',
          value: '5',
          weight: 2,
          countsToAverage: true,
          date: today.subtract(const Duration(days: 8)),
          addDate: today.subtract(const Duration(days: 8)),
          addedBy: tCs,
          semester: currentSem,
          isConstituent: true,
        ),
      ],
    );

    final sEng = Lesson(
      id: 3,
      name: 'English',
      short: 'ENG',
      no: 3,
      hostClass: mainClass,
      teacher: tEng,
      grades: [
        Grade(
          id: 6,
          name: 'Essay',
          value: '5-',
          weight: 2,
          countsToAverage: true,
          date: today.subtract(const Duration(days: 3)),
          addDate: today.subtract(const Duration(days: 3)),
          addedBy: tEng,
          semester: currentSem,
          isConstituent: true,
        ),
        Grade(
          id: 7,
          name: 'Speaking Activity',
          value: '5',
          weight: 1,
          countsToAverage: true,
          date: today.subtract(const Duration(days: 10)),
          addDate: today.subtract(const Duration(days: 10)),
          addedBy: tEng,
          semester: currentSem,
          isConstituent: true,
        ),
      ],
    );

    final sPhys = Lesson(
      id: 4,
      name: 'Physics',
      short: 'PHYS',
      no: 4,
      hostClass: mainClass,
      teacher: tPhys,
      grades: [
        Grade(
          id: 8,
          name: 'Kinematics Test',
          value: '4',
          weight: 3,
          countsToAverage: true,
          date: today.subtract(const Duration(days: 4)),
          addDate: today.subtract(const Duration(days: 4)),
          addedBy: tPhys,
          semester: currentSem,
          isConstituent: true,
        ),
        Grade(
          id: 9,
          name: 'Lab Report',
          value: '5',
          weight: 2,
          countsToAverage: true,
          date: today.subtract(const Duration(days: 9)),
          addDate: today.subtract(const Duration(days: 9)),
          addedBy: tPhys,
          semester: currentSem,
          isConstituent: true,
        ),
      ],
    );

    final sHist = Lesson(
      id: 5,
      name: 'History',
      short: 'HIST',
      no: 5,
      hostClass: mainClass,
      teacher: tHist,
      grades: [
        Grade(
          id: 10,
          name: '20th Century Presentation',
          value: '5',
          weight: 2,
          countsToAverage: true,
          date: today.subtract(const Duration(days: 6)),
          addDate: today.subtract(const Duration(days: 6)),
          addedBy: tHist,
          semester: currentSem,
          isConstituent: true,
        ),
      ],
    );

    final sPol = Lesson(
      id: 6,
      name: 'Literature',
      short: 'LIT',
      no: 6,
      hostClass: mainClass,
      teacher: tPol,
      grades: [
        Grade(
          id: 11,
          name: 'Reading Comprehension',
          value: '4+',
          weight: 2,
          countsToAverage: true,
          date: today.subtract(const Duration(days: 7)),
          addDate: today.subtract(const Duration(days: 7)),
          addedBy: tPol,
          semester: currentSem,
          isConstituent: true,
        ),
      ],
    );

    final subjects = [sMath, sCs, sEng, sPhys, sHist, sPol];

    final timetableMap = <DateTime, TimetableDay>{};
    for (int offset = -14; offset <= 21; offset++) {
      final day = DateTime(today.year, today.month, today.day + offset);
      if (day.weekday == DateTime.saturday || day.weekday == DateTime.sunday) continue;

      final dayPattern = switch (day.weekday) {
        DateTime.monday => [
            (sMath, tMath, c101),
            (sCs, tCs, c204),
            (sEng, tEng, c302),
            (sPhys, tPhys, c105),
            (sPol, tPol, c101),
          ],
        DateTime.tuesday => [
            (sCs, tCs, c204),
            (sMath, tMath, c101),
            (sHist, tHist, c302),
            (sEng, tEng, c302),
            (sPhys, tPhys, c105),
          ],
        DateTime.wednesday => [
            (sEng, tEng, c302),
            (sMath, tMath, c101),
            (sCs, tCs, c204),
            (sPol, tPol, c101),
            (sHist, tHist, c302),
          ],
        DateTime.thursday => [
            (sPhys, tPhys, c105),
            (sCs, tCs, c204),
            (sMath, tMath, c101),
            (sEng, tEng, c302),
            (sPol, tPol, c101),
          ],
        _ => [
            (sMath, tMath, c101),
            (sHist, tHist, c302),
            (sCs, tCs, c204),
            (sEng, tEng, c302),
          ],
      };

      final lessonsForDay = <List<TimetableLesson>?>[
        null, // Lesson 0
      ];

      for (int i = 0; i < dayPattern.length; i++) {
        final item = dayPattern[i];
        final hours = lessonHours[i];
        lessonsForDay.add([
          TimetableLesson(
            url: 'sample://lesson/${day.toIso8601String()}/${i + 1}',
            lessonNo: i + 1,
            isCanceled: false,
            lessonClass: mainClass,
            subject: item.$1,
            teacher: item.$2,
            classroom: item.$3,
            modifiedSchedule: false,
            date: day,
            hourFrom: lessonTime(hours.$1, hours.$2, day),
            hourTo: lessonTime(hours.$3, hours.$4, day),
          ),
        ]);
      }

      timetableMap[day] = TimetableDay(lessons: lessonsForDay, calendarDay: day);
    }

    final attendances = <Attendance>[
      Attendance(
        id: 1,
        lessonNo: 1,
        date: today.subtract(const Duration(days: 1)),
        addDate: today.subtract(const Duration(days: 1)),
        type: AttendanceType.late,
        teacher: tMath,
        lesson: TimetableLesson(
          lessonNo: 1,
          subject: sMath,
          teacher: tMath,
          date: today.subtract(const Duration(days: 1)),
        ),
      ),
      Attendance(
        id: 2,
        lessonNo: 3,
        date: today.subtract(const Duration(days: 3)),
        addDate: today.subtract(const Duration(days: 3)),
        type: AttendanceType.excused,
        teacher: tEng,
        lesson: TimetableLesson(
          lessonNo: 3,
          subject: sEng,
          teacher: tEng,
          date: today.subtract(const Duration(days: 3)),
        ),
      ),
      Attendance(
        id: 3,
        lessonNo: 2,
        date: today.subtract(const Duration(days: 4)),
        addDate: today.subtract(const Duration(days: 4)),
        type: AttendanceType.absent,
        teacher: tCs,
        lesson: TimetableLesson(
          lessonNo: 2,
          subject: sCs,
          teacher: tCs,
          date: today.subtract(const Duration(days: 4)),
        ),
      ),
    ];

    final messages = Messages(
      receivers: teachers,
      received: [
        Message(
          id: 1,
          topic: 'Welcome to Oshi Test Mode!',
          preview: 'You are currently logged in with the sample test account. Feel free to explore all tabs!',
          content:
              'Hello Pomura!\n\nYou are currently logged in with the sample test account. You can browse your timetable, check grades and averages, view upcoming homework and tests, and test messaging.\n\nBest regards,\nSaeko Takami',
          sender: tMath,
          sendDate: today,
          readDate: null,
        ),
        Message(
          id: 2,
          topic: 'Flutter Project Feedback',
          preview: 'Great work on the Flutter application assignment! Your grade (6) has been posted.',
          content:
              'Hi Pomura,\n\nGreat work on the Flutter application assignment! Your grade (6) has been posted to the register.\n\nRegards,\nTadashi Satomi',
          sender: tCs,
          sendDate: today.subtract(const Duration(days: 1)),
          readDate: today.subtract(const Duration(hours: 12)),
        ),
      ],
      sent: [
        Message(
          id: 101,
          topic: 'Question about Calculus Homework',
          preview: 'Good afternoon Professor, should we include the proof for exercise 5?',
          content: 'Good afternoon Professor,\n\nShould we include the full proof for exercise 5 in tomorrow\'s homework?\n\nThank you,\nPomura Inpuff',
          sendDate: today.subtract(const Duration(days: 2)),
          receivers: const [tMath],
        ),
      ],
    );

    _data = ProviderData(
      student: Student(
        account: Account(id: 1, userId: 1001, number: 7, firstName: 'Pomura', lastName: 'Inpuff'),
        mainClass: mainClass,
        subjects: subjects,
        attendances: attendances,
      ),
      timetables: Timetables(timetable: timetableMap),
      messages: messages,
    );
  }

  @override
  Event<Value<String>> propertyChanged = Event<Value<String>>();

  @override
  Future<({Exception? message, bool success})> login(
      {Map<String, String>? credentials, IProgress<({double? progress, String? message})>? progress}) async {
    return (success: true, message: null);
  }

  @override
  Future<({Exception? message, bool success})> refresh(
      {DateTime? weekStart, IProgress<({String? message, double? progress})>? progress}) async {
    return (success: true, message: null);
  }

  @override
  Future<({Exception? message, bool success})> refreshMessages(
      {IProgress<({String? message, double? progress})>? progress}) async {
    return (success: true, message: null);
  }

  @override
  Future<({Exception? message, bool success})> sendMessage(
      {required List<Teacher> receivers, required String topic, required String content}) async {
    _data.messages.sent.insert(
      0,
      Message(
        id: DateTime.now().millisecondsSinceEpoch,
        topic: topic,
        preview: content,
        content: content,
        sendDate: DateTime.now(),
        receivers: receivers,
      ),
    );
    return (success: true, message: null);
  }

  @override
  Uri? get providerBannerUri => Uri.parse('https://media.tenor.com/QPvKS6-yrzUAAAAC/cirno-touhou.gif');

  @override
  String get providerDescription => '/Providers/Sample/Description'.localized;

  @override
  String get providerName => '/Providers/Sample/Name'.localized;

  @override
  ProviderData? get registerData => _data;

  @override
  Map<String, ({String name, bool obscure, ({String text, Uri link})? helper})> get credentialsConfig => {};

  @override
  Future<({Exception? message, Message? result, bool success})> fetchMessageContent(
      {required Message parent, required bool byMe}) async {
    final fullMessage = Message.from(
      other: parent,
      content: parent.content ?? parent.preview ?? 'Sample message content.',
      readDate: parent.readDate ?? DateTime.now(),
    );
    return (success: true, message: null, result: fullMessage);
  }

  @override
  Future<({Exception? message, bool success})> moveMessageToTrash({required Message parent, required bool byMe}) async {
    if (byMe) {
      _data.messages.sent.remove(parent);
    } else {
      _data.messages.received.remove(parent);
    }
    return (success: true, message: null);
  }

  @override
  Future<({Exception? message, bool success})> markEventAsDone({required models.Event parent}) async {
    final idx = _data.student.mainClass.events.indexOf(parent);
    if (idx != -1) {
      _data.student.mainClass.events[idx] = models.Event.from(other: parent, done: !parent.done);
    }
    return (success: true, message: null);
  }

  @override
  Future<({Exception? message, bool success})> markEventAsViewed({required models.Event parent}) async {
    return (success: true, message: null);
  }

  @override
  Future<({Exception? message, bool success})> markAnnouncementAsViewed({required Announcement parent}) async {
    final list = _data.student.mainClass.unit.announcements;
    if (list != null) {
      final idx = list.indexOf(parent);
      if (idx != -1) {
        list[idx] = Announcement.from(other: parent, read: true);
      }
    }
    return (success: true, message: null);
  }
}
