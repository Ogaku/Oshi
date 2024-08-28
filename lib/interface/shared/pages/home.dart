// ignore_for_file: prefer_const_constructors
// ignore_for_file: prefer_const_literals_to_create_immutables
import 'dart:async';
import 'package:darq/darq.dart';
import 'package:enum_flag/enum_flag.dart';
import 'package:event/event.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:oshi/interface/components/shim/elements/attendance.dart';
import 'package:oshi/interface/components/shim/elements/compact.dart';
import 'package:oshi/interface/components/shim/elements/event.dart';
import 'package:oshi/interface/components/shim/elements/grade.dart';
import 'package:oshi/interface/components/shim/page_routes.dart';
import 'package:oshi/interface/shared/containers.dart';
import 'package:oshi/interface/shared/input.dart';
import 'package:oshi/interface/components/shim/application_data_page.dart';
import 'package:oshi/interface/shared/session_management.dart';
import 'package:oshi/share/extensions.dart';
import 'package:oshi/interface/shared/pages/settings.dart';
import 'package:oshi/models/data/attendances.dart';
import 'package:oshi/models/data/event.dart';
import 'package:oshi/models/data/grade.dart';
import 'package:oshi/models/data/messages.dart';
import 'package:oshi/models/data/teacher.dart';
import 'package:oshi/share/resources.dart';
import 'package:oshi/share/share.dart';
import 'package:oshi/share/translator.dart';
import 'package:pull_down_button/pull_down_button.dart';
import 'package:visibility_aware_state/visibility_aware_state.dart';

// Boiler: returned to the app tab builder
StatefulWidget get homePage => HomePage();

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends VisibilityAwareState<HomePage> {
  Timer? _everySecond;
  SegmentController segmentController = SegmentController(segment: HomepageSegments.home);
  int timelineMaxChildren = 5;

  @override
  void dispose() {
    Share.refreshAll.unsubscribe(refresh);
    _everySecond?.cancel();
    super.dispose();
  }

  void refresh(args) {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // Re-subscribe to all events
    Share.refreshAll.unsubscribe(refresh);
    Share.refreshAll.subscribe(refresh);

    Share.openTimeline.unsubscribeAll();
    Share.openTimeline.subscribe((args) {
      setState(() => segmentController.segment = HomepageSegments.timeline);
    });

    if (!(_everySecond?.isActive ?? false)) {
      // Auto-refresh this view each second - it's static so it shouuuuld be safe...
      _everySecond = Timer.periodic(Duration(seconds: 1), (Timer t) => _setState(() {}));
    }

    var currentDay = Share.session.data.timetables[DateTime.now().asDate(utc: true).asDate()];
    var nextDay = Share.session.data.timetables[DateTime.now().asDate(utc: true).add(Duration(days: 1)).asDate()];

    var currentLesson = currentDay?.lessonsStrippedCancelled
        .firstWhereOrDefault((x) =>
            x?.any((y) => DateTime.now().isAfterOrSame(y.timeFrom) && DateTime.now().isBeforeOrSame(y.timeTo)) ?? false)
        ?.firstOrDefault();
    var nextLesson = currentDay?.lessonsStrippedCancelled
        .firstWhereOrDefault((x) => x?.any((y) => DateTime.now().isBeforeOrSame(y.timeFrom)) ?? false)
        ?.firstOrDefault();

    // Event list for the next 2 weeks (14 days), exc homeworks and teacher absences
    var eventsWeek = Share.session.events
        .where((x) => x.category != EventCategory.homework && x.category != EventCategory.teacher)
        .where((x) => (x.date ?? x.timeTo ?? x.timeFrom).isAfterOrSame(DateTime.now().asDate()))
        .where((x) => (x.date ?? x.timeTo ?? x.timeFrom).isBeforeOrSame(DateTime.now().add(Duration(days: 14)).asDate()))
        .orderBy((x) => x.date ?? x.timeTo ?? x.timeFrom)
        .toList();

    // Event list for the next week (7 days), exc homeworks and teacher absences
    var gradesWeek = Share.session.data.student.subjects
        .where((x) => x.allGrades.isNotEmpty)
        .select((x, index) => (
              lesson: x,
              grades:
                  x.allGrades.where((y) => y.addDate.isAfter(DateTime.now().subtract(Duration(days: 7)).asDate())).toList()
            ))
        .where((x) => x.grades.isNotEmpty)
        .orderByDescending((x) => x.grades.orderByDescending((y) => y.addDate).first.addDate)
        .toList();

    // Homework list for the next week (7 days)
    var homeworksWeek = Share.session.events
        .where((x) => x.category == EventCategory.homework)
        .where((x) => (x.date ?? x.timeTo ?? x.timeFrom).isAfterOrSame(DateTime.now().asDate()))
        .where((x) => (x.date ?? x.timeTo ?? x.timeFrom).isBeforeOrSame(DateTime.now().add(Duration(days: 7)).asDate()))
        .orderByDescending((x) => x.done ? 0 : 1)
        .thenBy((x) => x.date ?? x.timeTo ?? x.timeFrom)
        .toList();

    // Lucky number, checking wheter it exists is *somewhere* else
    var isLucky = (DateTime.now().isAfterOrSame(currentDay?.dayEnd) &&
            Share.session.data.student.account.number == Share.session.data.student.mainClass.unit.luckyNumber &&
            Share.session.data.student.mainClass.unit.luckyNumberTomorrow) ||
        (Share.session.data.student.account.number == Share.session.data.student.mainClass.unit.luckyNumber &&
            !Share.session.data.student.mainClass.unit.luckyNumberTomorrow);

    // Homeworks - first if any(), otherwise last
    var homeworksLast = homeworksWeek.isEmpty || homeworksWeek.all((x) => x.done);
    var homeworksWidget = Share.settings.appSettings.useCupertino
        ? CardContainer(
            regularOverride: true,
            filled: false,
            dividerMargin: 35,
            header: '/Homeworks'.localized,
            children: homeworksWeek.isEmpty
                // No homeworks to display
                ? [
                    AdaptiveCard(
                      regular: true,
                      secondary: true,
                      centered: true,
                      child: '/Homeworks/Done'.localized,
                    )
                  ]
                // Bindable homework layout
                : homeworksWeek.asCompactHomeworkList(context),
          )
        : CardContainer(
            radius: 25,
            backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
            margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            children: <Widget>[
                CardContainer(
                  regularOverride: true,
                  filled: false,
                  children: <Widget>[
                    AdaptiveCard(
                        regular: true,
                        secondary: true,
                        margin: EdgeInsets.only(left: 20, right: 20, top: 8, bottom: homeworksWeek.isEmpty ? 8 : 0),
                        child: Row(
                          children: [
                            Container(
                                decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.primaryContainer,
                                    borderRadius: BorderRadius.circular(100)),
                                padding: EdgeInsets.all(10),
                                margin: EdgeInsets.only(right: 18),
                                child: Icon(Icons.menu_book, color: Theme.of(context).colorScheme.primary)),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('/Homeworks'.localized,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: Theme.of(context).colorScheme.primary,
                                    )),
                                if (homeworksWeek.isEmpty) Text('/Homeworks/Done'.localized),
                                if (homeworksWeek.isNotEmpty) Text('Really gonna do \'em?'),
                              ],
                            ),
                          ],
                        ))
                  ].appendAllIf(homeworksWeek.asCompactHomeworkList(context), homeworksWeek.isNotEmpty).toList(),
                )
              ]);

    // Recent grades
    var gradesWidget = Share.settings.appSettings.useCupertino
        ? CardContainer(
            regularOverride: true,
            filled: false,
            additionalDividerMargin: 0,
            header: 'Recent grades',
            children: gradesWeek.isEmpty
                // No grades to display
                ? [
                    AdaptiveCard(
                      regular: true,
                      secondary: true,
                      centered: true,
                      child: 'No recent grades',
                    )
                  ]
                // Bindable grades layout
                : gradesWeek.asCompactGradeList(context),
          )
        : CardContainer(
            radius: 25,
            backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
            margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            children: <Widget>[
                CardContainer(
                  regularOverride: true,
                  filled: false,
                  children: <Widget>[
                    AdaptiveCard(
                        regular: true,
                        secondary: true,
                        margin: EdgeInsets.only(left: 20, right: 20, top: 8, bottom: gradesWeek.isEmpty ? 8 : 0),
                        child: Row(
                          children: [
                            Container(
                                decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.primaryContainer,
                                    borderRadius: BorderRadius.circular(100)),
                                padding: EdgeInsets.all(10),
                                margin: EdgeInsets.only(right: 18),
                                child: Icon(Icons.grade, color: Theme.of(context).colorScheme.primary)),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Recent grades',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: Theme.of(context).colorScheme.primary,
                                    )),
                                if (gradesWeek.isEmpty) Text('Nothing\'s here yet!'),
                                if (gradesWeek.isNotEmpty) Text('How\'s it going?'),
                              ],
                            ),
                          ],
                        ))
                  ].appendAllIf(gradesWeek.asCompactGradeList(context), gradesWeek.isNotEmpty).toList(),
                )
              ]);

    // Upcoming events
    var eventsWidget = Share.settings.appSettings.useCupertino
        ? CardContainer(
            regularOverride: true,
            filled: false,
            dividerMargin: 35,
            header: 'Upcoming events',
            children: eventsWeek.isEmpty
                // No events to display
                ? [
                    AdaptiveCard(
                      regular: true,
                      secondary: true,
                      centered: true,
                      child: 'It\'s quiet, too quiet...',
                    )
                  ]
                // Bindable event layout
                : eventsWeek.asCompactEventList(context),
          )
        : CardContainer(
            radius: 25,
            backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
            margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            children: <Widget>[
                CardContainer(
                  regularOverride: true,
                  filled: false,
                  children: <Widget>[
                    AdaptiveCard(
                        regular: true,
                        secondary: true,
                        margin: EdgeInsets.only(left: 20, right: 20, top: 8, bottom: eventsWeek.isEmpty ? 8 : 0),
                        child: Row(
                          children: [
                            Container(
                                decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.primaryContainer,
                                    borderRadius: BorderRadius.circular(100)),
                                padding: EdgeInsets.all(10),
                                margin: EdgeInsets.only(right: 18),
                                child: Icon(Icons.event, color: Theme.of(context).colorScheme.primary)),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Upcoming events',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: Theme.of(context).colorScheme.primary,
                                    )),
                                if (eventsWeek.isEmpty) Text('Nothing! You win!'),
                                if (eventsWeek.isNotEmpty) Text('Seems crowded, innit?'),
                              ],
                            ),
                          ],
                        ))
                  ].appendAllIf(eventsWeek.asCompactEventList(context), eventsWeek.isNotEmpty).toList(),
                )
              ]);

    // Widgets for the home page
    var homePageChildren = Share.settings.appSettings.useCupertino
        // ---------- Cupertino home screen ----------
        ? <Widget>[
            CardContainer(
                header: '/Summary'.localized,
                regularOverride: true,
                filled: false,
                children: <Widget>[
                  Padding(
                    padding: Share.settings.appSettings.useCupertino
                        ? EdgeInsets.only()
                        : EdgeInsets.symmetric(horizontal: 5, vertical: 0),
                    child: AdaptiveCard(
                        hideChevron: true,
                        regular: true,
                        margin: Share.settings.appSettings.useCupertino
                            ? null
                            : EdgeInsets.symmetric(horizontal: 17, vertical: 0),
                        click: () {
                          Share.tabsNavigatePage.broadcast(Value(2));
                          Future.delayed(Duration(milliseconds: 250)).then((arg) => Share.timetableNavigateDay.broadcast(
                              Value(DateTime.now().asDate(utc: true).add(Duration(
                                  days:
                                      (DateTime.now().isAfterOrSame(currentDay?.dayEnd) && (nextDay?.hasLessons ?? false)) ||
                                              (!(currentDay?.hasLessons ?? false) && (nextDay?.hasLessons ?? false))
                                          ? 1
                                          : 0)))));
                        },
                        child: Container(
                            margin: EdgeInsets.only(top: 3, bottom: 15),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                                  Expanded(
                                      child: Container(
                                    margin: EdgeInsets.only(top: 10),
                                    child: Text(glanceTitle,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 21,
                                        )),
                                  )),
                                  Container(
                                      margin: EdgeInsets.only(top: isLucky ? 0 : 5),
                                      child: Visibility(
                                          visible: Share.session.data.student.mainClass.unit.luckyNumber != null,
                                          child: Stack(alignment: Alignment.center, children: [
                                            Transform.scale(
                                                scale: isLucky ? 3.0 : 1.4,
                                                child: isLucky
                                                    ? Icon(CupertinoIcons.star_fill,
                                                        color: CupertinoColors.systemYellow.withAlpha(70))
                                                    : Icon(CupertinoIcons.circle_fill, color: Color(0x22777777))),
                                            Container(
                                                margin: EdgeInsets.only(),
                                                child: Text(
                                                    Share.session.data.student.mainClass.unit.luckyNumber?.toString() ??
                                                        '69',
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.w600,
                                                      color: CupertinoDynamicColor.resolve(
                                                          CupertinoDynamicColor.withBrightness(
                                                              color: CupertinoColors.black,
                                                              darkColor: CupertinoColors.white),
                                                          context),
                                                      shadows: [
                                                        Shadow(
                                                          color: CupertinoColors.black,
                                                          blurRadius: 3.0,
                                                          offset: Offset(0.0, 0.0),
                                                        ),
                                                      ],
                                                    ))),
                                          ])))
                                ]),
                                Container(
                                    margin: EdgeInsets.only(top: 2),
                                    child: Row(children: [
                                      Flexible(
                                          child: Container(
                                              margin: EdgeInsets.only(right: 3),
                                              child: Text(
                                                glanceSubtitle.flexible,
                                                style: TextStyle(fontWeight: FontWeight.w400),
                                              ))),
                                      Text(
                                        glanceSubtitle.standard,
                                        style: TextStyle(fontWeight: FontWeight.w400),
                                      )
                                    ])),
                              ],
                            ))),
                  )
                ]
                    .appendIf(
                        AdaptiveCard(
                            hideChevron: true,
                            click: () {
                              Share.tabsNavigatePage.broadcast(Value(2));
                              Future.delayed(Duration(milliseconds: 250)).then((arg) => Share.timetableNavigateDay.broadcast(
                                  Value(DateTime.now().asDate(utc: true).add(Duration(
                                      days: (DateTime.now().isAfterOrSame(currentDay?.dayEnd) &&
                                                  (nextDay?.hasLessons ?? false)) ||
                                              (!(currentDay?.hasLessons ?? false) && (nextDay?.hasLessons ?? false))
                                          ? 1
                                          : 0)))));
                            },
                            child: Container(
                                margin: EdgeInsets.only(top: 10, bottom: 10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Visibility(
                                        visible: currentLesson != null,
                                        child: Container(
                                            margin: EdgeInsets.only(bottom: 5),
                                            child: Row(
                                                children: [
                                              Text(
                                                '/Now'.localized,
                                                style: TextStyle(fontWeight: FontWeight.w500),
                                              ),
                                              Flexible(
                                                  child: Container(
                                                      margin: EdgeInsets.only(right: 3, left: 3),
                                                      child: Text(
                                                        currentLesson?.subject?.name ?? 'Other lesson',
                                                        style: TextStyle(fontWeight: FontWeight.w500),
                                                      ))),
                                            ].appendIf(
                                                    Text(
                                                      'in ${currentLesson?.classroom?.name ?? "the otherworld"}',
                                                      style: TextStyle(fontWeight: FontWeight.w400),
                                                    ),
                                                    currentLesson?.classroom?.name.isNotEmpty ?? false)))),
                                    Visibility(
                                        visible: nextLesson != null,
                                        child: Opacity(
                                            opacity: 0.5,
                                            child: Container(
                                                margin: EdgeInsets.only(),
                                                child: Row(
                                                    children: [
                                                  Text(
                                                    // If the "next" lesson is the first one
                                                    (nextLesson != null &&
                                                            (currentDay?.lessonsStrippedCancelled
                                                                    .firstWhereOrDefault(
                                                                        (l) => l?.any((x) => !x.isCanceled) ?? false)
                                                                    ?.any((x) => x == nextLesson) ??
                                                                false))
                                                        ? 'First:'
                                                        : // If the "next" lesson is the last one
                                                        (nextLesson != null &&
                                                                (currentDay?.lessonsStrippedCancelled
                                                                        .lastWhereOrDefault(
                                                                            (l) => l?.any((x) => !x.isCanceled) ?? false)
                                                                        ?.any((x) => x == nextLesson) ??
                                                                    false))
                                                            ? 'Last:'
                                                            : 'Next up:',
                                                    style: TextStyle(fontWeight: FontWeight.w500),
                                                  ),
                                                  Flexible(
                                                      child: Container(
                                                          margin: EdgeInsets.only(right: 3, left: 3),
                                                          child: Text(
                                                            nextLesson?.subject?.name ?? 'Other lesson',
                                                            style: TextStyle(fontWeight: FontWeight.w500),
                                                          ))),
                                                ].appendIf(
                                                        Text(
                                                          'in ${nextLesson?.classroom?.name ?? "the otherworld"}',
                                                          style: TextStyle(fontWeight: FontWeight.w400),
                                                        ),
                                                        nextLesson?.classroom?.name.isNotEmpty ?? false)))))
                                  ],
                                ))),
                        // Show during lessons and breaks (between lessons)
                        nextLesson != null || currentLesson != null)
                    .appendIf(
                        AdaptiveCard(
                            hideChevron: true,
                            click: () {
                              Share.tabsNavigatePage.broadcast(Value(2));
                              Future.delayed(Duration(milliseconds: 250)).then((arg) => Share.timetableNavigateDay.broadcast(
                                  Value(DateTime.now().asDate(utc: true).add(Duration(
                                      days: (DateTime.now().isAfterOrSame(currentDay?.dayEnd) &&
                                                  (nextDay?.hasLessons ?? false)) ||
                                              (!(currentDay?.hasLessons ?? false) && (nextDay?.hasLessons ?? false))
                                          ? 1
                                          : 0)))));
                            },
                            child: Container(
                                margin: EdgeInsets.only(top: 10, bottom: 10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                        children: [
                                      Text(
                                        'First:',
                                        style: TextStyle(fontWeight: FontWeight.w500),
                                      ),
                                      Flexible(
                                          child: Container(
                                              margin: EdgeInsets.only(right: 3, left: 3),
                                              child: Text(
                                                nextDay?.lessonsStrippedCancelled
                                                        .firstWhereOrDefault((x) => x?.any((y) => !y.isCanceled) ?? false)
                                                        ?.firstWhereOrDefault((x) => !x.isCanceled)
                                                        ?.subject
                                                        ?.name ??
                                                    'Other lesson',
                                                style: TextStyle(fontWeight: FontWeight.w500),
                                              ))),
                                    ].appendIf(
                                            Text(
                                              'in ${nextDay?.lessonsStrippedCancelled.firstWhereOrDefault((x) => x?.any((y) => !y.isCanceled) ?? false)?.firstWhereOrDefault((x) => !x.isCanceled)?.classroom?.name ?? "the otherworld"}',
                                              style: TextStyle(fontWeight: FontWeight.w400),
                                            ),
                                            nextDay?.lessonsStrippedCancelled
                                                    .firstWhereOrDefault((x) => x?.any((y) => !y.isCanceled) ?? false)
                                                    ?.firstWhereOrDefault((x) => !x.isCanceled)
                                                    ?.classroom
                                                    ?.name
                                                    .isNotEmpty ??
                                                false))
                                  ],
                                ))),
                        // Show >1h after the school day has ended, and if there are lessons tomorrow
                        (DateTime.now().isAfterOrSame(currentDay?.dayEnd) && (nextDay?.hasLessons ?? false)) &&
                            DateTime.now().difference(currentDay?.dayEnd ?? DateTime.now()).inHours > 1)
                    .appendIf(
                        AdaptiveCard(
                            hideChevron: true,
                            click: () {
                              Share.tabsNavigatePage.broadcast(Value(2));
                              Future.delayed(Duration(milliseconds: 250)).then((arg) => Share.timetableNavigateDay.broadcast(
                                  Value(DateTime.now().asDate(utc: true).add(Duration(
                                      days: (DateTime.now().isAfterOrSame(currentDay?.dayEnd) &&
                                                  (nextDay?.hasLessons ?? false)) ||
                                              (!(currentDay?.hasLessons ?? false) && (nextDay?.hasLessons ?? false))
                                          ? 1
                                          : 0)))));
                            },
                            child: Row(children: [
                              Expanded(
                                  child: Container(
                                      margin: EdgeInsets.only(right: 3),
                                      child: Text(
                                        DateTime.now().isAfterOrSame(currentDay?.dayEnd) && (nextDay?.hasLessons ?? false)
                                            ? 'Tomorrow: ${nextDay?.lessonsNumber.asLessonNumber()}'
                                            : 'Later: ${((currentDay?.lessonsStrippedCancelled.where((x) => x?.any((y) => DateTime.now().isBeforeOrSame(y.timeFrom)) ?? false).count((x) => (x?.isNotEmpty ?? false) && (x?.any((y) => !y.isCanceled) ?? false)) ?? 1) - 1).asLessonNumber()}',
                                        style: TextStyle(fontWeight: FontWeight.w400),
                                      ))),
                              Text(
                                DateTime.now().isAfterOrSame(currentDay?.dayEnd) && (nextDay?.hasLessons ?? false)
                                    ? 'until ${DateFormat("H:mm").format(nextDay?.dayEnd ?? DateTime.now())}'
                                    : 'until ${DateFormat("H:mm").format(currentDay?.dayEnd ?? DateTime.now())}',
                                style: TextStyle(
                                    fontWeight: FontWeight.w400, fontSize: 15, color: CupertinoColors.inactiveGray),
                              ),
                              Container(
                                  margin: EdgeInsets.only(left: 2),
                                  child: Transform.scale(
                                      scale: 0.7,
                                      child: Icon(CupertinoIcons.chevron_forward, color: CupertinoColors.inactiveGray)))
                            ])),
                        // Show if there's still any lessons left, and the next lesson is not the last lesson
                        (((DateTime.now().isBeforeOrSame(currentDay?.dayEnd) && (currentDay?.hasLessons ?? false)) &&
                                (nextLesson != null &&
                                    (currentDay?.lessonsStrippedCancelled.lastOrDefault()?.all((x) => x != nextLesson) ??
                                        false))) ||
                            // Or >1h after the school day has ended, and there are lessons tomorrow
                            ((DateTime.now().isAfterOrSame(currentDay?.dayEnd) && (nextDay?.hasLessons ?? false)) &&
                                DateTime.now().difference(currentDay?.dayEnd ?? DateTime.now()).inHours > 1))))
          ]
            // Homeworks, Events, Grades - first if any()
            .appendIf(homeworksWidget, !homeworksLast)
            .appendIf(eventsWidget, eventsWeek.isNotEmpty)
            .appendIf(gradesWidget, gradesWeek.isNotEmpty)
            // Events, Grades, Homeworks - if empty()
            .appendIf(eventsWidget, eventsWeek.isEmpty)
            .appendIf(gradesWidget, gradesWeek.isEmpty)
            .appendIf(homeworksWidget, homeworksLast)
            .toList()
        :
        // ---------- Material home screen ----------
        <Widget>[
            CardContainer(
                radius: 25,
                backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
                margin: EdgeInsets.only(left: 10, right: 10, bottom: 5, top: 15),
                children: <Widget>[
                  CardContainer(
                      regularOverride: true,
                      filled: false,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 5, vertical: 0),
                          child: AdaptiveCard(
                              hideChevron: true,
                              regular: true,
                              margin: EdgeInsets.symmetric(horizontal: 17, vertical: 0),
                              click: () {
                                Share.tabsNavigatePage.broadcast(Value(2));
                                Future.delayed(Duration(milliseconds: 250)).then((arg) => Share.timetableNavigateDay
                                    .broadcast(Value(DateTime.now().asDate(utc: true).add(Duration(
                                        days: (DateTime.now().isAfterOrSame(currentDay?.dayEnd) &&
                                                    (nextDay?.hasLessons ?? false)) ||
                                                (!(currentDay?.hasLessons ?? false) && (nextDay?.hasLessons ?? false))
                                            ? 1
                                            : 0)))));
                              },
                              child: Container(
                                  margin: EdgeInsets.only(top: 3, bottom: 15),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                                        Expanded(
                                            child: Container(
                                          margin: EdgeInsets.only(top: 10),
                                          child: Text(glanceTitle,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                                color: Theme.of(context).colorScheme.primary,
                                              )),
                                        )),
                                        Container(
                                            margin: EdgeInsets.only(top: isLucky ? 0 : 5),
                                            child: Visibility(
                                                visible: Share.session.data.student.mainClass.unit.luckyNumber != null,
                                                child: Stack(alignment: Alignment.center, children: [
                                                  Transform.scale(
                                                      scale: isLucky ? 4.5 : 1.4,
                                                      child: isLucky
                                                          ? Icon(CupertinoIcons.star_fill,
                                                              color: CupertinoColors.systemYellow.withAlpha(70))
                                                          : Icon(CupertinoIcons.circle_fill, color: Color(0x22777777))),
                                                  Container(
                                                      margin: EdgeInsets.only(),
                                                      child: Text(
                                                          Share.session.data.student.mainClass.unit.luckyNumber
                                                                  ?.toString() ??
                                                              '69',
                                                          style: TextStyle(
                                                            fontSize: 17,
                                                            fontWeight: FontWeight.w600,
                                                            color: CupertinoDynamicColor.resolve(
                                                                CupertinoDynamicColor.withBrightness(
                                                                    color: CupertinoColors.black,
                                                                    darkColor: CupertinoColors.white),
                                                                context),
                                                            shadows: [
                                                              Shadow(
                                                                color: CupertinoColors.black,
                                                                blurRadius: 3.0,
                                                                offset: Offset(0.0, 0.0),
                                                              ),
                                                            ],
                                                          ))),
                                                ])))
                                      ]),
                                      Container(
                                          margin: EdgeInsets.only(top: 2),
                                          child: Row(children: [
                                            Flexible(
                                                child: Container(
                                                    margin: EdgeInsets.only(right: 3),
                                                    child: Text(
                                                      glanceSubtitle.flexible,
                                                      style: TextStyle(fontWeight: FontWeight.w400),
                                                    ))),
                                            Text(
                                              glanceSubtitle.standard,
                                              style: TextStyle(fontWeight: FontWeight.w400),
                                            )
                                          ])),
                                    ],
                                  ))),
                        )
                      ]
                          .appendIf(
                              AdaptiveCard(
                                  hideChevron: true,
                                  click: () {
                                    Share.tabsNavigatePage.broadcast(Value(2));
                                    Future.delayed(Duration(milliseconds: 250)).then((arg) => Share.timetableNavigateDay
                                        .broadcast(Value(DateTime.now().asDate(utc: true).add(Duration(
                                            days: (DateTime.now().isAfterOrSame(currentDay?.dayEnd) &&
                                                        (nextDay?.hasLessons ?? false)) ||
                                                    (!(currentDay?.hasLessons ?? false) && (nextDay?.hasLessons ?? false))
                                                ? 1
                                                : 0)))));
                                  },
                                  child: Container(
                                      margin: EdgeInsets.only(top: 10, bottom: 10),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Visibility(
                                              visible: currentLesson != null,
                                              child: Container(
                                                  margin: EdgeInsets.only(bottom: 5),
                                                  child: Row(
                                                      children: [
                                                    Text(
                                                      '/Now'.localized,
                                                      style: TextStyle(fontWeight: FontWeight.w500),
                                                    ),
                                                    Flexible(
                                                        child: Container(
                                                            margin: EdgeInsets.only(right: 3, left: 3),
                                                            child: Text(
                                                              currentLesson?.subject?.name ?? 'Other lesson',
                                                              style: TextStyle(fontWeight: FontWeight.w500),
                                                            ))),
                                                  ].appendIf(
                                                          Text(
                                                            'in ${currentLesson?.classroom?.name ?? "the otherworld"}',
                                                            style: TextStyle(fontWeight: FontWeight.w400),
                                                          ),
                                                          currentLesson?.classroom?.name.isNotEmpty ?? false)))),
                                          Visibility(
                                              visible: nextLesson != null,
                                              child: Opacity(
                                                  opacity: 0.5,
                                                  child: Container(
                                                      margin: EdgeInsets.only(),
                                                      child: Row(
                                                          children: [
                                                        Text(
                                                          // If the "next" lesson is the first one
                                                          (nextLesson != null &&
                                                                  (currentDay?.lessonsStrippedCancelled
                                                                          .firstWhereOrDefault(
                                                                              (l) => l?.any((x) => !x.isCanceled) ?? false)
                                                                          ?.any((x) => x == nextLesson) ??
                                                                      false))
                                                              ? 'First:'
                                                              : // If the "next" lesson is the last one
                                                              (nextLesson != null &&
                                                                      (currentDay?.lessonsStrippedCancelled
                                                                              .lastWhereOrDefault((l) =>
                                                                                  l?.any((x) => !x.isCanceled) ?? false)
                                                                              ?.any((x) => x == nextLesson) ??
                                                                          false))
                                                                  ? 'Last:'
                                                                  : 'Next up:',
                                                          style: TextStyle(fontWeight: FontWeight.w500),
                                                        ),
                                                        Flexible(
                                                            child: Container(
                                                                margin: EdgeInsets.only(right: 3, left: 3),
                                                                child: Text(
                                                                  nextLesson?.subject?.name ?? 'Other lesson',
                                                                  style: TextStyle(fontWeight: FontWeight.w500),
                                                                ))),
                                                      ].appendIf(
                                                              Text(
                                                                'in ${nextLesson?.classroom?.name ?? "the otherworld"}',
                                                                style: TextStyle(fontWeight: FontWeight.w400),
                                                              ),
                                                              nextLesson?.classroom?.name.isNotEmpty ?? false)))))
                                        ],
                                      ))),
                              // Show during lessons and breaks (between lessons)
                              nextLesson != null || currentLesson != null)
                          .appendIf(
                              AdaptiveCard(
                                  hideChevron: true,
                                  click: () {
                                    Share.tabsNavigatePage.broadcast(Value(2));
                                    Future.delayed(Duration(milliseconds: 250)).then((arg) => Share.timetableNavigateDay
                                        .broadcast(Value(DateTime.now().asDate(utc: true).add(Duration(
                                            days: (DateTime.now().isAfterOrSame(currentDay?.dayEnd) &&
                                                        (nextDay?.hasLessons ?? false)) ||
                                                    (!(currentDay?.hasLessons ?? false) && (nextDay?.hasLessons ?? false))
                                                ? 1
                                                : 0)))));
                                  },
                                  child: Container(
                                      margin: EdgeInsets.only(top: 10, bottom: 10),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                              children: [
                                            Text(
                                              'First:',
                                              style: TextStyle(fontWeight: FontWeight.w500),
                                            ),
                                            Flexible(
                                                child: Container(
                                                    margin: EdgeInsets.only(right: 3, left: 3),
                                                    child: Text(
                                                      nextDay?.lessonsStrippedCancelled
                                                              .firstWhereOrDefault(
                                                                  (x) => x?.any((y) => !y.isCanceled) ?? false)
                                                              ?.firstWhereOrDefault((x) => !x.isCanceled)
                                                              ?.subject
                                                              ?.name ??
                                                          'Other lesson',
                                                      style: TextStyle(fontWeight: FontWeight.w500),
                                                    ))),
                                          ].appendIf(
                                                  Text(
                                                    'in ${nextDay?.lessonsStrippedCancelled.firstWhereOrDefault((x) => x?.any((y) => !y.isCanceled) ?? false)?.firstWhereOrDefault((x) => !x.isCanceled)?.classroom?.name ?? "the otherworld"}',
                                                    style: TextStyle(fontWeight: FontWeight.w400),
                                                  ),
                                                  nextDay?.lessonsStrippedCancelled
                                                          .firstWhereOrDefault((x) => x?.any((y) => !y.isCanceled) ?? false)
                                                          ?.firstWhereOrDefault((x) => !x.isCanceled)
                                                          ?.classroom
                                                          ?.name
                                                          .isNotEmpty ??
                                                      false))
                                        ],
                                      ))),
                              // Show >1h after the school day has ended, and if there are lessons tomorrow
                              (DateTime.now().isAfterOrSame(currentDay?.dayEnd) && (nextDay?.hasLessons ?? false)) &&
                                  DateTime.now().difference(currentDay?.dayEnd ?? DateTime.now()).inHours > 1)
                          .appendIf(
                              AdaptiveCard(
                                  hideChevron: true,
                                  click: () {
                                    Share.tabsNavigatePage.broadcast(Value(2));
                                    Future.delayed(Duration(milliseconds: 250)).then((arg) => Share.timetableNavigateDay
                                        .broadcast(Value(DateTime.now().asDate(utc: true).add(Duration(
                                            days: (DateTime.now().isAfterOrSame(currentDay?.dayEnd) &&
                                                        (nextDay?.hasLessons ?? false)) ||
                                                    (!(currentDay?.hasLessons ?? false) && (nextDay?.hasLessons ?? false))
                                                ? 1
                                                : 0)))));
                                  },
                                  child: Row(children: [
                                    Expanded(
                                        child: Container(
                                            margin: EdgeInsets.only(right: 3),
                                            child: Text(
                                              DateTime.now().isAfterOrSame(currentDay?.dayEnd) &&
                                                      (nextDay?.hasLessons ?? false)
                                                  ? 'Tomorrow: ${nextDay?.lessonsNumber.asLessonNumber()}'
                                                  : 'Later: ${((currentDay?.lessonsStrippedCancelled.where((x) => x?.any((y) => DateTime.now().isBeforeOrSame(y.timeFrom)) ?? false).count((x) => (x?.isNotEmpty ?? false) && (x?.any((y) => !y.isCanceled) ?? false)) ?? 1) - 1).asLessonNumber()}',
                                              style: TextStyle(fontWeight: FontWeight.w400),
                                            ))),
                                    Text(
                                      DateTime.now().isAfterOrSame(currentDay?.dayEnd) && (nextDay?.hasLessons ?? false)
                                          ? 'until ${DateFormat("H:mm").format(nextDay?.dayEnd ?? DateTime.now())}'
                                          : 'until ${DateFormat("H:mm").format(currentDay?.dayEnd ?? DateTime.now())}',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w400, fontSize: 15, color: CupertinoColors.inactiveGray),
                                    ),
                                    Container(
                                        margin: EdgeInsets.only(left: 2),
                                        child: Transform.scale(
                                            scale: 0.7,
                                            child:
                                                Icon(CupertinoIcons.chevron_forward, color: CupertinoColors.inactiveGray)))
                                  ])),
                              // Show if there's still any lessons left, and the next lesson is not the last lesson
                              (((DateTime.now().isBeforeOrSame(currentDay?.dayEnd) && (currentDay?.hasLessons ?? false)) &&
                                      (nextLesson != null &&
                                          (currentDay?.lessonsStrippedCancelled
                                                  .lastOrDefault()
                                                  ?.all((x) => x != nextLesson) ??
                                              false))) ||
                                  // Or >1h after the school day has ended, and there are lessons tomorrow
                                  ((DateTime.now().isAfterOrSame(currentDay?.dayEnd) && (nextDay?.hasLessons ?? false)) &&
                                      DateTime.now().difference(currentDay?.dayEnd ?? DateTime.now()).inHours > 1))))
                ])
          ]
            // Homeworks, Events, Grades - first if any()
            .appendIf(homeworksWidget, !homeworksLast)
            .appendIf(eventsWidget, eventsWeek.isNotEmpty)
            .appendIf(gradesWidget, gradesWeek.isNotEmpty)
            // Events, Grades, Homeworks - if empty()
            .appendIf(eventsWidget, eventsWeek.isEmpty)
            .appendIf(gradesWidget, gradesWeek.isEmpty)
            .appendIf(homeworksWidget, homeworksLast)
            .toList();

    // Widgets for the timeline page
    var timelineChanges = Share.session.changes.orderByDescending((x) => x.refreshDate);

    timelineChanges = timelineChanges
        .appendAll(timelineChanges)
        .appendAll(timelineChanges)
        .appendAll(timelineChanges)
        .appendAll(timelineChanges)
        .appendAll(timelineChanges)
        .appendAll(timelineChanges)
        .appendAll(timelineChanges)
        .appendAll(timelineChanges);

    var timelineChildren = timelineChanges
        .take(timelineMaxChildren) // Only last five refreshes by default, more can be loaded
        .select((x, _) => CardContainer(
            largeHeader: false,
            regularOverride: true,
            filled: false,
            header: Share.settings.appSettings.useCupertino
                ? (x.refreshDate.asDate() == DateTime.now().asDate() ? 'Today, ' : '') +
                    DateFormat(x.refreshDate.asDate() == DateTime.now().asDate() ? 'h:mm a' : 'EEE, MMM d, h:mm a')
                        .format(x.refreshDate)
                : Padding(
                    padding: const EdgeInsets.only(top: 55.0),
                    child: Text(
                      (x.refreshDate.asDate() == DateTime.now().asDate() ? 'Today, ' : '') +
                          DateFormat(x.refreshDate.asDate() == DateTime.now().asDate() ? 'h:mm a' : 'EEE, MMM d, h:mm a')
                              .format(x.refreshDate),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                  ),
            children: <Widget>[]
                // Added or updated lessons
                .appendIf(
                    AdaptiveCard(
                        regular: true,
                        child: CardContainer(
                            regularOverride: true,
                            noDivider: true,
                            largeHeader: false,
                            header: x.timetablesChanged
                                .count((element) => element.type != RegisterChangeTypes.removed)
                                .asTimetablesNumber(RegisterChangeTypes.added),
                            children: x.timetablesChanged
                                .take(5) // Take only the first 5 ones
                                .where((element) => element.type != RegisterChangeTypes.removed)
                                .select(
                                  (y, index) => AdaptiveCard(
                                      child: y.value.asLessonWidget(context, null, null, _setState,
                                          markModified: y.type == RegisterChangeTypes.changed, onTap: () {
                                    Share.tabsNavigatePage.broadcast(Value(2));
                                    Future.delayed(Duration(milliseconds: 250))
                                        .then((arg) => Share.timetableNavigateDay.broadcast(Value(y.value.date)));
                                  })),
                                )
                                .toList())),
                    x.timetablesChanged.any((element) => element.type != RegisterChangeTypes.removed))
                // Deleted lessons
                .appendIf(
                    AdaptiveCard(
                        regular: true,
                        child: CardContainer(
                            regularOverride: true,
                            noDivider: true,
                            largeHeader: false,
                            header: x.timetablesChanged
                                .count((element) => element.type == RegisterChangeTypes.removed)
                                .asTimetablesNumber(RegisterChangeTypes.removed),
                            children: x.timetablesChanged
                                .take(5) // Take only the first 5 ones
                                .where((element) => element.type == RegisterChangeTypes.removed)
                                .select(
                                  (y, index) => AdaptiveCard(
                                      child: y.value.asLessonWidget(context, null, null, _setState, markRemoved: true)),
                                )
                                .toList())),
                    x.timetablesChanged.any((element) => element.type == RegisterChangeTypes.removed))
                // Added or updated messages
                .appendIf(
                    AdaptiveCard(
                        regular: true,
                        child: CardContainer(
                            regularOverride: true,
                            noDivider: true,
                            largeHeader: false,
                            header: () {
                              var news = x.messagesChanged.count((element) => element.type == RegisterChangeTypes.added);
                              var changes =
                                  x.messagesChanged.count((element) => element.type == RegisterChangeTypes.changed);

                              return switch (news) {
                                // There's only new grades
                                > 0 when changes == 0 => news.asMessagesNumber(RegisterChangeTypes.added),
                                // There's only changed grades
                                0 when changes > 0 => changes.asMessagesNumber(RegisterChangeTypes.changed),
                                // Some are new, some are changed
                                > 0 when changes > 0 => (news + changes).asMessagesNumber(),
                                // Shouldn't happen, but we need a _ case
                                _ => 'No changes, WTF?!'
                              };
                            }(),
                            children: x.messagesChanged
                                .take(5) // Take only the first 5 ones
                                .where((element) => element.type != RegisterChangeTypes.removed)
                                .select(
                                  (y, index) => AdaptiveCard(
                                      child: GestureDetector(
                                          onTap: () {
                                            Share.tabsNavigatePage.broadcast(Value(3));
                                            Future.delayed(Duration(milliseconds: 250))
                                                .then((arg) => Share.messagesNavigate.broadcast(Value(y.value)));
                                          },
                                          child: Container(
                                              decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.all(Radius.circular(10)),
                                                  color: CupertinoDynamicColor.resolve(
                                                      CupertinoColors.tertiarySystemBackground, context)),
                                              padding: EdgeInsets.only(top: 15, bottom: 15, right: 15, left: 20),
                                              child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  mainAxisSize: MainAxisSize.max,
                                                  children: [
                                                    Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Expanded(
                                                              child: Container(
                                                                  margin: EdgeInsets.only(right: 10),
                                                                  child: Text(
                                                                    y.value.senderName,
                                                                    overflow: TextOverflow.ellipsis,
                                                                    style:
                                                                        TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                                                                  ))),
                                                          Visibility(
                                                            visible: y.value.hasAttachments,
                                                            child: Transform.scale(
                                                                scale: 0.6,
                                                                child: Icon(CupertinoIcons.paperclip,
                                                                    color: CupertinoColors.inactiveGray)),
                                                          ),
                                                          Container(
                                                              margin: EdgeInsets.only(top: 1),
                                                              child: Opacity(
                                                                  opacity: 0.5,
                                                                  child: Text(
                                                                    y.value.sendDateString,
                                                                    overflow: TextOverflow.ellipsis,
                                                                    style: TextStyle(
                                                                        fontSize: 16, fontWeight: FontWeight.normal),
                                                                  )))
                                                        ]),
                                                    Container(
                                                        margin: EdgeInsets.only(top: 3),
                                                        child: Text(
                                                          y.value.topic,
                                                          maxLines: 2,
                                                          overflow: TextOverflow.ellipsis,
                                                          style: TextStyle(fontSize: 16),
                                                        )),
                                                    Opacity(
                                                        opacity: 0.5,
                                                        child: Container(
                                                            margin: EdgeInsets.only(top: 5),
                                                            child: Text(
                                                              y.value.previewString
                                                                  .replaceAll('\n ', '\n')
                                                                  .replaceAll('\n\n', '\n')
                                                                  .replaceAll('\n\r', ''),
                                                              maxLines: 2,
                                                              overflow: TextOverflow.ellipsis,
                                                              style: TextStyle(fontSize: 16),
                                                            ))),
                                                  ])))),
                                )
                                .toList())),
                    x.messagesChanged.any((element) => element.type != RegisterChangeTypes.removed))
                // Added or updated attendances
                .appendIf(
                    AdaptiveCard(
                        regular: true,
                        child: CardContainer(
                            regularOverride: true,
                            noDivider: true,
                            largeHeader: false,
                            header: () {
                              var news = x.attendancesChanged.count((element) => element.type == RegisterChangeTypes.added);
                              var changes =
                                  x.attendancesChanged.count((element) => element.type == RegisterChangeTypes.changed);

                              return switch (news) {
                                // There's only new grades
                                > 0 when changes == 0 => news.asAttendancesNumber(RegisterChangeTypes.added),
                                // There's only changed grades
                                0 when changes > 0 => changes.asAttendancesNumber(RegisterChangeTypes.changed),
                                // Some are new, some are changed
                                > 0 when changes > 0 => (news + changes).asAttendancesNumber(),
                                // Shouldn't happen, but we need a _ case
                                _ => 'No changes, WTF?!'
                              };
                            }(),
                            children: x.attendancesChanged
                                .take(5) // Take only the first 5 ones
                                .orderByDescending((element) => element.value.addDate)
                                .where((element) => element.type != RegisterChangeTypes.removed)
                                .select(
                                  (y, index) => AdaptiveCard(
                                      child: y.value.asAttendanceWidget(context,
                                          markModified: y.type == RegisterChangeTypes.changed,
                                          onTap: () => Share.tabsNavigatePage.broadcast(Value(4)))),
                                )
                                .toList())),
                    x.attendancesChanged.any((element) => element.type != RegisterChangeTypes.removed))
                // Deleted attendances
                .appendIf(
                    AdaptiveCard(
                        regular: true,
                        child: CardContainer(
                            regularOverride: true,
                            noDivider: true,
                            largeHeader: false,
                            header: x.attendancesChanged
                                .count((element) => element.type == RegisterChangeTypes.removed)
                                .asAttendancesNumber(RegisterChangeTypes.removed),
                            children: x.attendancesChanged
                                .take(5) // Take only the first 5 ones
                                .where((element) => element.type == RegisterChangeTypes.removed)
                                .select(
                                  (y, index) => AdaptiveCard(child: y.value.asAttendanceWidget(context, markRemoved: true)),
                                )
                                .toList())),
                    x.attendancesChanged.any((element) => element.type == RegisterChangeTypes.removed))
                // Added or updated grades
                .appendIf(
                    AdaptiveCard(
                        regular: true,
                        child: CardContainer(
                            regularOverride: true,
                            noDivider: true,
                            largeHeader: false,
                            header: () {
                              var news = x.gradesChanged.count((element) => element.type == RegisterChangeTypes.added);
                              var changes = x.gradesChanged.count((element) => element.type == RegisterChangeTypes.changed);

                              return switch (news) {
                                // There's only new grades
                                > 0 when changes == 0 => news.asGradesNumber(RegisterChangeTypes.added),
                                // There's only changed grades
                                0 when changes > 0 => changes.asGradesNumber(RegisterChangeTypes.changed),
                                // Some are new, some are changed
                                > 0 when changes > 0 => (news + changes).asGradesNumber(),
                                // Shouldn't happen, but we need a _ case
                                _ => 'No changes, WTF?!'
                              };
                            }(),
                            children: x.gradesChanged
                                .take(5) // Take only the first 5 ones
                                .where((element) => element.type != RegisterChangeTypes.removed)
                                .select(
                                  (y, index) => AdaptiveCard(
                                      child: y.value.asGrade(context, setState,
                                          markModified: y.type == RegisterChangeTypes.changed, onTap: () {
                                    var lesson = Share.session.data.student.subjects
                                        .firstWhereOrDefault((value) => value.allGrades.contains(y.value));
                                    if (lesson == null) return;
                                    Share.tabsNavigatePage.broadcast(Value(1));
                                    Future.delayed(Duration(milliseconds: 250))
                                        .then((arg) => Share.gradesNavigate.broadcast(Value(lesson)));
                                  })),
                                )
                                .toList())),
                    x.gradesChanged.any((element) => element.type != RegisterChangeTypes.removed))
                // Deleted grades
                .appendIf(
                    AdaptiveCard(
                        regular: true,
                        child: CardContainer(
                            regularOverride: true,
                            noDivider: true,
                            largeHeader: false,
                            header: x.gradesChanged
                                .count((element) => element.type == RegisterChangeTypes.removed)
                                .asGradesNumber(RegisterChangeTypes.removed),
                            children: x.gradesChanged
                                .take(5) // Take only the first 5 ones
                                .where((element) => element.type == RegisterChangeTypes.removed)
                                .select(
                                  (y, index) => AdaptiveCard(child: y.value.asGrade(context, setState, markRemoved: true)),
                                )
                                .toList())),
                    x.gradesChanged.any((element) => element.type == RegisterChangeTypes.removed))
                // Added or updated announcements
                .appendIf(
                    AdaptiveCard(
                        regular: true,
                        child: CardContainer(
                            regularOverride: true,
                            noDivider: true,
                            largeHeader: false,
                            header: () {
                              var news =
                                  x.announcementsChanged.count((element) => element.type == RegisterChangeTypes.added);
                              var changes =
                                  x.announcementsChanged.count((element) => element.type == RegisterChangeTypes.changed);

                              return switch (news) {
                                // There's only new grades
                                > 0 when changes == 0 => news.asAnnouncementsNumber(RegisterChangeTypes.added),
                                // There's only changed grades
                                0 when changes > 0 => changes.asAnnouncementsNumber(RegisterChangeTypes.changed),
                                // Some are new, some are changed
                                > 0 when changes > 0 => (news + changes).asAnnouncementsNumber(),
                                // Shouldn't happen, but we need a _ case
                                _ => 'No changes, WTF?!'
                              };
                            }(),
                            children: x.announcementsChanged
                                .take(5) // Take only the first 5 ones
                                .where((element) => element.type != RegisterChangeTypes.removed)
                                .orderByDescending((x) => x.value.startDate)
                                .select((x, index) => (
                                      message: Message(
                                          id: x.value.read ? 1 : 0,
                                          topic: x.value.subject,
                                          content: x.value.content,
                                          sender: x.value.contact ??
                                              Teacher(firstName: Share.session.data.student.mainClass.unit.name),
                                          sendDate: x.value.startDate,
                                          readDate: x.value.endDate),
                                      parent: x.value
                                    ))
                                .toList()
                                .select(
                                  (y, index) => AdaptiveCard(
                                      child: GestureDetector(
                                          onTap: () {
                                            Share.tabsNavigatePage.broadcast(Value(3));
                                            Future.delayed(Duration(milliseconds: 250))
                                                .then((arg) => Share.messagesNavigateAnnouncement.broadcast(Value(y)));
                                          },
                                          child: Container(
                                              decoration: Share.settings.appSettings.useCupertino
                                                  ? BoxDecoration(
                                                      borderRadius: BorderRadius.all(Radius.circular(10)),
                                                      color: CupertinoDynamicColor.resolve(
                                                          CupertinoColors.tertiarySystemBackground, context))
                                                  : null,
                                              padding: Share.settings.appSettings.useCupertino
                                                  ? EdgeInsets.only(top: 15, bottom: 15, right: 15, left: 20)
                                                  : null,
                                              child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  mainAxisSize: MainAxisSize.max,
                                                  children: [
                                                    Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Expanded(
                                                              child: Container(
                                                                  margin: EdgeInsets.only(right: 10),
                                                                  child: Text(
                                                                    y.message.senderName,
                                                                    overflow: TextOverflow.ellipsis,
                                                                    style:
                                                                        TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                                                                  ))),
                                                          Visibility(
                                                            visible: y.message.hasAttachments,
                                                            child: Transform.scale(
                                                                scale: 0.6,
                                                                child: Icon(CupertinoIcons.paperclip,
                                                                    color: CupertinoColors.inactiveGray)),
                                                          ),
                                                          Container(
                                                              margin: EdgeInsets.only(top: 1),
                                                              child: Opacity(
                                                                  opacity: 0.5,
                                                                  child: Text(
                                                                    (y.message.sendDate.month == y.message.readDate?.month &&
                                                                            y.message.sendDate.year ==
                                                                                y.message.readDate?.year &&
                                                                            y.message.sendDate.day != y.message.readDate?.day
                                                                        ? '${DateFormat.MMMd(Share.settings.appSettings.localeCode).format(y.message.sendDate)} - ${DateFormat.d(Share.settings.appSettings.localeCode).format(y.message.readDate ?? DateTime.now())}'
                                                                        : '${DateFormat.MMMd(Share.settings.appSettings.localeCode).format(y.message.sendDate)} - ${DateFormat(y.message.sendDate.year == y.message.readDate?.year ? 'MMMd' : 'yMMMd', Share.settings.appSettings.localeCode).format(y.message.readDate ?? DateTime.now())}'),
                                                                    overflow: TextOverflow.ellipsis,
                                                                    style: TextStyle(
                                                                        fontSize: 16, fontWeight: FontWeight.normal),
                                                                  )))
                                                        ]),
                                                    Container(
                                                        margin: EdgeInsets.only(top: 3),
                                                        child: Text(
                                                          y.message.topic,
                                                          maxLines: 2,
                                                          overflow: TextOverflow.ellipsis,
                                                          style: TextStyle(fontSize: 16),
                                                        )),
                                                    Opacity(
                                                        opacity: 0.5,
                                                        child: Container(
                                                            margin: EdgeInsets.only(top: 5),
                                                            child: Text(
                                                              y.message.previewString
                                                                  .replaceAll('\n ', '\n')
                                                                  .replaceAll('\n\n', '\n')
                                                                  .replaceAll('\n\r', ''),
                                                              maxLines: 2,
                                                              overflow: TextOverflow.ellipsis,
                                                              style: TextStyle(fontSize: 16),
                                                            ))),
                                                  ])))),
                                )
                                .toList())),
                    x.announcementsChanged.any((element) => element.type != RegisterChangeTypes.removed))
                // Added or updated events
                .appendIf(
                    AdaptiveCard(
                        regular: true,
                        child: CardContainer(
                            regularOverride: true,
                            noDivider: true,
                            largeHeader: false,
                            header: () {
                              var news = x.eventsChanged.count((element) => element.type == RegisterChangeTypes.added);
                              var changes = x.eventsChanged.count((element) => element.type == RegisterChangeTypes.changed);

                              return switch (news) {
                                // There's only new grades
                                > 0 when changes == 0 => news.asEventsNumber(RegisterChangeTypes.added),
                                // There's only changed grades
                                0 when changes > 0 => changes.asEventsNumber(RegisterChangeTypes.changed),
                                // Some are new, some are changed
                                > 0 when changes > 0 => (news + changes).asEventsNumber(),
                                // Shouldn't happen, but we need a _ case
                                _ => 'D7969362-9ACF-403C-80E5-9C345711FF16'.localized
                              };
                            }(),
                            children: x.eventsChanged
                                .take(5) // Take only the first 5 ones
                                .where((element) => element.type != RegisterChangeTypes.removed)
                                .select(
                                  (y, index) => AdaptiveCard(
                                      child: y.value.asEventWidget(context, true, null, _setState,
                                          markModified: y.type == RegisterChangeTypes.changed, onTap: () {
                                    Share.tabsNavigatePage.broadcast(Value(2));
                                    Future.delayed(Duration(milliseconds: 250)).then((arg) =>
                                        Share.timetableNavigateDay.broadcast(Value(y.value.date ?? y.value.timeFrom)));
                                  })),
                                )
                                .toList())),
                    x.eventsChanged.any((element) => element.type != RegisterChangeTypes.removed))
                // Deleted events
                .appendIf(
                    AdaptiveCard(
                        regular: true,
                        child: CardContainer(
                            regularOverride: true,
                            noDivider: true,
                            largeHeader: false,
                            header: x.eventsChanged
                                .count((element) => element.type == RegisterChangeTypes.removed)
                                .asEventsNumber(RegisterChangeTypes.removed),
                            children: x.eventsChanged
                                .take(5) // Take only the first 5 ones
                                .where((element) => element.type == RegisterChangeTypes.removed)
                                .select(
                                  (y, index) => AdaptiveCard(
                                      child: y.value.asEventWidget(context, true, null, _setState, markRemoved: true)),
                                )
                                .toList())),
                    x.eventsChanged.any((element) => element.type == RegisterChangeTypes.removed))
                .toList()))
        .cast<Widget>()
        .appendIfNotEmptyAnd(
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Center(
                child: AdaptiveButton(
                    title: '3354CC3D-7A3D-4C61-99BB-D346D5755113'.localized,
                    click: () => _setState(() => timelineMaxChildren += 3)),
              ),
            ),
            timelineChanges.length > timelineMaxChildren)
        .appendIfEmpty(AdaptiveCard(
          secondary: true,
          centered: true,
          child: 'CEEC04F5-04C3-41B2-9DB8-CCC6B0C42CC8'.localized,
        ))
        .toList();

    return DataPageBase.adaptive(
      pageFlags: [
        DataPageType.segmented,
        DataPageType.withBase,
        DataPageType.refreshable,
        if (segmentController.segment == HomepageSegments.timeline) DataPageType.boxedPage,
        if (segmentController.segment == HomepageSegments.timeline) DataPageType.segmentedSticky,
      ].flag,
      setState: _setState,
      segments: {
        HomepageSegments.home: '/Titles/Pages/Home'.localized,
        HomepageSegments.timeline: '/Titles/Pages/Timeline'.localized
      },
      segmentController: segmentController,
      title: segmentController.segment == HomepageSegments.home
          ? '/Titles/Pages/Home'.localized
          : '/Titles/Pages/Timeline'.localized,
      trailing: Share.settings.appSettings.useCupertino
          ? AdaptiveMenuButton(
              itemBuilder: (context) => [
                AdaptiveMenuItem(
                    title: 'Settings',
                    icon: CupertinoIcons.gear,
                    onTap: () => Navigator.of(context, rootNavigator: true)
                        .push(AdaptivePageRoute(builder: (context) => SettingsPage()))),
                PullDownMenuDivider.large(),
                PullDownMenuTitle(title: Text('Accounts')),
                AdaptiveMenuItem(
                  title: 'Sessions',
                  icon: CupertinoIcons.rectangle_stack_person_crop,
                  onTap: () => Share.changeBase.broadcast(Value(() => sessionsPage)),
                ),
                AdaptiveMenuItem(
                  title: 'Mark as read',
                  icon: CupertinoIcons.checkmark_circle,
                  onTap: () => Share.session.unreadChanges.markAsRead(),
                ),
              ],
              child: _eventfulMenuButton,
            )
          : SafeArea(
              child: IconButton(
              onPressed: () =>
                  Navigator.of(context, rootNavigator: true).push(AdaptivePageRoute(builder: (context) => SettingsPage())),
              icon: Icon(
                Icons.settings,
                size: 25,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            )),
      children: segmentController.segment == HomepageSegments.home ? homePageChildren : timelineChildren,
    );
  }

  // Glance widget's subtitle
  ({String flexible, String standard}) get glanceSubtitle {
    var currentDay = Share.session.data.timetables[DateTime.now().asDate(utc: true).asDate()];
    var nextDay = Share.session.data.timetables[DateTime.now().asDate(utc: true).add(Duration(days: 1)).asDate()];

    var currentLesson = currentDay?.lessonsStrippedCancelled
        .firstWhereOrDefault((x) =>
            x?.any((y) => DateTime.now().isAfterOrSame(y.timeFrom) && DateTime.now().isBeforeOrSame(y.timeTo)) ?? false)
        ?.firstOrDefault();
    var nextLesson = currentDay?.lessonsStrippedCancelled
        .firstWhereOrDefault((x) => x?.any((y) => DateTime.now().isBeforeOrSame(y.timeFrom)) ?? false)
        ?.firstOrDefault();

    // Current lesson's end time
    if (currentLesson != null) {
      return (
        flexible: currentLesson.subject?.name ?? 'The current lesson',
        standard: 'ends in ${DateTime.now().difference(currentLesson.timeTo ?? DateTime.now()).prettyBellString}'
      );
    }

    // Next lesson's start time
    if (nextLesson != null) {
      return (
        flexible: nextLesson.subject?.name ?? 'The next lesson',
        standard: DateTime.now().difference(nextLesson.timeFrom ?? DateTime.now()).inMinutes.abs() < 20
            ? 'starts in ${DateTime.now().difference(nextLesson.timeFrom ?? DateTime.now()).prettyBellString}'
            : 'starts at ${DateFormat("HH:mm").format((nextLesson.timeFrom ?? DateTime.now()).add(Share.session.settings.bellOffset))}'
      );
    }

    // Lessons have just ended - 7
    if ((currentDay?.hasLessons ?? false) &&
        DateTime.now().isAfterOrSame(currentDay?.dayEnd) &&
        DateTime.now().difference(currentDay?.dayEnd ?? DateTime.now()).inHours < 2) {
      return (flexible: Share.currentEndingSplash.subtitle, standard: '');
    }

    // No lessons today or tomorrow - T5
    if (!(currentDay?.hasLessons ?? false) && !(nextDay?.hasLessons ?? false)) {
      return (flexible: "It's a free real estate!", standard: '');
    }

    // Or lessons tomorrow - T6
    if ((nextDay?.hasLessons ?? false) && nextDay?.dayEnd != null) {
      return (
        flexible:
            '${nextDay!.lessonsNumber.asLessonNumber()}, ${DateFormat("H:mm").format(nextDay.dayStart!)} to ${DateFormat("H:mm").format(nextDay.dayEnd!)}',
        standard: ''
      );
    }

    // Easter eggs?
    if (DateTime.now().weekday == DateTime.friday && DateTime.now().hour > 18) {
      return (flexible: "God, you're pathetic...", standard: '');
    }

    // Other options, possibly?
    return (flexible: 'C\'mon, do something...', standard: '');
  }

  // Glance widget's main title
  String get glanceTitle {
    var currentDay = Share.session.data.timetables[DateTime.now().asDate(utc: true).asDate()];
    var nextDay = Share.session.data.timetables[DateTime.now().asDate(utc: true).add(Duration(days: 1)).asDate()];

    var currentLesson = currentDay?.lessonsStrippedCancelled
        .firstWhereOrDefault((x) =>
            x?.any((y) => DateTime.now().isAfterOrSame(y.timeFrom) && DateTime.now().isBeforeOrSame(y.timeTo)) ?? false)
        ?.firstOrDefault();

    // Absent - current lesson - TOP
    if (currentLesson != null &&
        (Share.session.data.student.attendances?.any((x) =>
                x.date == DateTime.now().asDate() &&
                x.lessonNo == currentLesson.lessonNo &&
                x.type == AttendanceType.absent) ??
            false)) {
      return "${Share.session.data.student.account.firstName}, you're absent!";
    }

    // Halloween theme
    if (DateTime.now().month == DateTime.october && DateTime.now().day == 31) {
      return 'だって Happy Halloween!';
    }

    // Christmas theme
    if (DateTime.now().month == DateTime.december && (DateTime.now().day >= 20 && DateTime.now().day <= 30)) {
      return 'Merry Christmas!';
    }

    // Lessons have just ended - 7.1
    if ((currentDay?.hasLessons ?? false) &&
        DateTime.now().isAfterOrSame(currentDay?.dayEnd) &&
        DateTime.now().difference(currentDay?.dayEnd ?? DateTime.now()).inHours < 2) {
      return Share.currentEndingSplash.title;
    }

    // Lessons have ended - 7.2
    if ((currentDay?.hasLessons ?? false) &&
        (nextDay?.hasLessons ?? false) &&
        DateTime.now().isAfterOrSame(currentDay?.dayEnd) &&
        DateTime.now().difference(currentDay?.dayEnd ?? DateTime.now()).inHours >= 2) {
      return 'Prepare for tomorrow...';
    }

    // Lessons tomorrow - 6
    if ((DateTime.now().isAfterOrSame(currentDay?.dayEnd) || !(currentDay?.hasLessons ?? false)) &&
        (nextDay?.hasLessons ?? false)) {
      return "Back at it again, tomorrow...";
    }

    // No lessons today - 5
    if (!(currentDay?.hasLessons ?? false)) {
      return 'No lessons today!';
    }

    // Good morning - 3
    if (currentDay?.dayStart != null &&
        DateTime.now().isBeforeOrSame(currentDay!.dayStart) &&
        currentDay.dayStart!.difference(DateTime.now()) > Duration(hours: 1)) {
      return "Don't forget the obentō!";
    }

    // The last lesson - 2
    if (currentLesson != null &&
        (currentDay?.lessonsStrippedCancelled.lastOrDefault()?.any((x) => x == currentLesson) ?? false)) {
      return "You're on the finish line!";
    }

    // Lucy number - today - 0
    if (DateTime.now().isBeforeOrSame(currentDay?.dayStart) &&
        Share.session.data.student.account.number == Share.session.data.student.mainClass.unit.luckyNumber &&
        !Share.session.data.student.mainClass.unit.luckyNumberTomorrow) {
      return "You're the lucky one!";
    }

    // Lucy number - tomorrow - 0
    if (DateTime.now().isAfterOrSame(currentDay?.dayEnd) &&
        Share.session.data.student.account.number == Share.session.data.student.mainClass.unit.luckyNumber &&
        Share.session.data.student.mainClass.unit.luckyNumberTomorrow) {
      return "You'll be lucky tomorrow!";
    }

    // Easter eggs?
    if (DateTime.now().weekday == DateTime.friday && DateTime.now().hour > 18) {
      return "Alone on a friday night?";
    }

    // Other options, possibly?
    // Ambient - during the day - BTM
    return Share.currentIdleSplash;
  }

  Widget get _eventfulMenuButton {
    // Halloween theme
    if (DateTime.now().month == DateTime.october && DateTime.now().day == 31) {
      return const Text('🎃');
    }

    // St. Peter day theme
    if (DateTime.now().month == DateTime.july && DateTime.now().day == 12) {
      return const Text('🍀');
    }

    // Christmas theme
    if (DateTime.now().month == DateTime.december && (DateTime.now().day >= 20 && DateTime.now().day <= 30)) {
      return const Text('🎄');
    }

    // Default theme
    return Icon(Share.settings.appSettings.useCupertino ? CupertinoIcons.ellipsis_circle : Icons.more_vert);
  }

  void _setState(void Function() fn) {
    if (mounted) setState(fn);
  }
}

enum HomepageSegments { home, timeline }

extension DateTimeExtension on DateTime {
  DateTime asDate({bool utc = false}) => utc ? DateTime.utc(year, month, day) : DateTime(year, month, day);
}

extension ColorsExtension on Grade {
  Color asColor() => switch ((asValue - 0.01).round()) {
        6 => CupertinoColors.systemTeal,
        5 => CupertinoColors.systemGreen,
        4 => Color(0xFF76FF03),
        3 => CupertinoColors.systemOrange,
        2 => CupertinoColors.systemRed,
        1 => CupertinoColors.destructiveRed,
        _ => CupertinoColors.inactiveGray
      };
}
