// ignore_for_file: prefer_const_constructors
// ignore_for_file: prefer_const_literals_to_create_immutables

import 'dart:async';

import 'package:darq/darq.dart';
import 'package:event/event.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:oshi/interface/cupertino/pages/settings.dart';
import 'package:oshi/interface/cupertino/pages/timetable.dart';
import 'package:oshi/interface/cupertino/sessions_page.dart';
import 'package:oshi/interface/cupertino/views/grades_detailed.dart';
import 'package:oshi/interface/cupertino/views/message_compose.dart';
import 'package:oshi/interface/cupertino/widgets/searchable_bar.dart';
import 'package:oshi/models/data/attendances.dart';
import 'package:oshi/models/data/event.dart';
import 'package:oshi/models/data/grade.dart';
import 'package:oshi/share/share.dart';

import 'package:oshi/interface/cupertino/widgets/text_chip.dart' show TextChip;
import 'package:pull_down_button/pull_down_button.dart';
import 'package:visibility_aware_state/visibility_aware_state.dart';
import 'package:share_plus/share_plus.dart' as sharing;

// Boiler: returned to the app tab builder
StatefulWidget get homePage => HomePage();

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends VisibilityAwareState<HomePage> {
  final searchController = TextEditingController();
  Timer? _everySecond;
  String? _progressMessage;

  bool get isLucky =>
      Share.session.data.student.mainClass.unit.luckyNumber != null &&
      Share.session.data.student.account.number == Share.session.data.student.mainClass.unit.luckyNumber;

  @override
  void dispose() {
    _everySecond?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!(_everySecond?.isActive ?? false)) {
      // Auto-refresh this view each second - it's static so it shouuuuld be safe...
      _everySecond = Timer.periodic(Duration(seconds: 1), (Timer t) => setState(() {}));
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

    // Event list for the next week (7 days), exc homeworks and teacher absences
    var eventsWeek = Share.session.data.student.mainClass.events
        .where((x) => x.category != EventCategory.homework && x.category != EventCategory.teacher)
        .where((x) => x.date?.isAfterOrSame(DateTime.now().asDate()) ?? false)
        .where((x) => x.date?.isBeforeOrSame(DateTime.now().add(Duration(days: 7)).asDate()) ?? false)
        .orderBy((x) => x.date ?? x.timeTo ?? x.timeFrom)
        .toList();

    // Event list for the next week (7 days), exc homeworks and teacher absences
    var gradesWeek = Share.session.data.student.subjects
        .where((x) => x.grades.isNotEmpty)
        .select((x, index) => (
              lesson: x,
              grades: x.grades.where((y) => y.addDate.isAfter(DateTime.now().subtract(Duration(days: 7)).asDate())).toList()
            ))
        .where((x) => x.grades.isNotEmpty)
        .orderByDescending((x) => x.grades.orderByDescending((y) => y.addDate).first.addDate)
        .toList();

    // Homework list for the next week (7 days)
    var homeworksWeek = Share.session.data.student.mainClass.events
        .where((x) => x.category == EventCategory.homework)
        .where((x) => x.timeTo?.isAfterOrSame(DateTime.now().asDate()) ?? false)
        .where((x) => x.timeTo?.isBeforeOrSame(DateTime.now().add(Duration(days: 7)).asDate()) ?? false)
        .orderByDescending((x) => x.done ? 0 : 1)
        .thenBy((x) => x.date ?? x.timeTo ?? x.timeFrom)
        .toList();

    // Homeworks - first if any(), otherwise last
    var homeworksLast = homeworksWeek.isEmpty || homeworksWeek.all((x) => x.done);
    var homeworksWidget = CupertinoListSection.insetGrouped(
      margin: EdgeInsets.only(left: 15, right: 15, bottom: 10),
      dividerMargin: 35,
      header: Text('Homeworks'),
      children: homeworksWeek.isEmpty
          // No homeworks to display
          ? [
              CupertinoListTile(
                  title: Opacity(
                      opacity: 0.5,
                      child: Container(
                          alignment: Alignment.center,
                          child: Text(
                            'All done, yay!',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
                          ))))
            ]
          // Bindable homework layout
          : homeworksWeek
              .select((x, index) => CupertinoListTile(
                  padding: EdgeInsets.all(0),
                  title: CupertinoContextMenu.builder(
                      actions: [
                        CupertinoContextMenuAction(
                          onPressed: () {
                            sharing.Share.share(
                                'There\'s a "${x.titleString}" for ${DateFormat("EEEE, MMM d, y").format(x.timeFrom)}');
                            Navigator.of(context, rootNavigator: true).pop();
                          },
                          trailingIcon: CupertinoIcons.share,
                          child: const Text('Share'),
                        ),
                        CupertinoContextMenuAction(
                          isDestructiveAction: true,
                          trailingIcon: CupertinoIcons.chat_bubble_2,
                          child: const Text('Inquiry'),
                          onPressed: () {
                            Navigator.of(context, rootNavigator: true).pop();
                            showCupertinoModalBottomSheet(
                                context: context,
                                builder: (context) => MessageComposePage(
                                    receivers: x.sender != null ? [x.sender!] : [],
                                    subject:
                                        'Pytanie o pracę domową na dzień ${DateFormat("y.M.d").format(x.timeTo ?? x.timeFrom)}',
                                    signature:
                                        '${Share.session.data.student.account.name}, ${Share.session.data.student.mainClass.name}'));
                          },
                        ),
                      ],
                      builder: (BuildContext context, Animation<double> animation) => CupertinoButton(
                          onPressed: () {
                            Share.tabsNavigatePage.broadcast(Value(2));
                            Future.delayed(Duration(milliseconds: 250))
                                .then((arg) => Share.timetableNavigateDay.broadcast(Value(x.timeTo ?? x.timeFrom)));
                          },
                          padding: EdgeInsets.zero,
                          child: Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(Radius.circular(10)),
                                  color: CupertinoDynamicColor.resolve(
                                      CupertinoDynamicColor.withBrightness(
                                          color: const Color.fromARGB(255, 255, 255, 255),
                                          darkColor: const Color.fromARGB(255, 28, 28, 30)),
                                      context)),
                              padding: EdgeInsets.only(right: 10, left: 6),
                              child: ConstrainedBox(
                                  constraints: BoxConstraints(
                                      maxHeight:
                                          animation.value < CupertinoContextMenu.animationOpensAt ? double.infinity : 125,
                                      maxWidth:
                                          animation.value < CupertinoContextMenu.animationOpensAt ? double.infinity : 260),
                                  child: Opacity(
                                      opacity: x.done ? 0.5 : 1.0,
                                      child: Container(
                                          margin: EdgeInsets.only(right: 10),
                                          alignment: Alignment.centerLeft,
                                          child: Column(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    TextChip(
                                                        text: DateFormat('d/M').format(x.timeTo ?? x.timeFrom),
                                                        margin: EdgeInsets.only(top: 6, bottom: 6, right: 10)),
                                                    Flexible(
                                                        child: Align(
                                                            alignment: Alignment.centerLeft,
                                                            child: Text(
                                                              maxLines: 1,
                                                              x.title ?? x.content,
                                                              overflow: TextOverflow.ellipsis,
                                                              style: TextStyle(
                                                                  fontWeight: FontWeight.w600,
                                                                  color: CupertinoDynamicColor.resolve(
                                                                      CupertinoDynamicColor.withBrightness(
                                                                          color: CupertinoColors.black,
                                                                          darkColor: CupertinoColors.white),
                                                                      context)),
                                                            ))),
                                                    Align(
                                                        alignment: Alignment.centerRight,
                                                        child: Visibility(
                                                          visible: x.done,
                                                          child: Container(
                                                              margin: EdgeInsets.only(left: 5),
                                                              child: Icon(CupertinoIcons.check_mark)),
                                                        ))
                                                  ],
                                                ),
                                                Visibility(
                                                    visible: animation.value >= CupertinoContextMenu.animationOpensAt,
                                                    child: Flexible(
                                                        child: Container(
                                                            margin: EdgeInsets.only(left: 5, right: 5),
                                                            child: Text(
                                                              'Notes: ${x.content}',
                                                              maxLines: 2,
                                                              overflow: TextOverflow.ellipsis,
                                                              style: TextStyle(
                                                                  fontSize: 15,
                                                                  fontWeight: FontWeight.w500,
                                                                  color: CupertinoDynamicColor.resolve(
                                                                      CupertinoDynamicColor.withBrightness(
                                                                          color: CupertinoColors.black,
                                                                          darkColor: CupertinoColors.white),
                                                                      context)),
                                                            )))),
                                                Visibility(
                                                    visible: animation.value >= CupertinoContextMenu.animationOpensAt,
                                                    child: Flexible(
                                                        child: Container(
                                                            margin: EdgeInsets.only(left: 5, right: 5, bottom: 7),
                                                            child: Text(
                                                              x.addedByString,
                                                              maxLines: 2,
                                                              overflow: TextOverflow.ellipsis,
                                                              style: TextStyle(
                                                                  fontSize: 15,
                                                                  fontWeight: FontWeight.w500,
                                                                  color: CupertinoDynamicColor.resolve(
                                                                      CupertinoDynamicColor.withBrightness(
                                                                          color: CupertinoColors.black,
                                                                          darkColor: CupertinoColors.white),
                                                                      context)),
                                                            ))))
                                              ])))))))))
              .toList(),
    );

    return CupertinoPageScaffold(
      backgroundColor: CupertinoDynamicColor.withBrightness(
          color: const Color.fromARGB(255, 242, 242, 247), darkColor: const Color.fromARGB(255, 0, 0, 0)),
      child: SearchableSliverNavigationBar(
        onProgress: (progress) => setState(() => _progressMessage = progress?.message),
        setState: setState,
        // segments: {'home': 'Home', 'timeline': 'Timeline'},
        searchController: searchController,
        largeTitle: Text('Home'),
        middle: Visibility(visible: _progressMessage?.isEmpty ?? true, child: Text('Home')),
        leading: Visibility(
            visible: _progressMessage?.isNotEmpty ?? false,
            child: Container(
                margin: EdgeInsets.only(top: 7),
                child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 150),
                    child: Text(
                      _progressMessage ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: CupertinoColors.inactiveGray, fontSize: 13, fontWeight: FontWeight.w300),
                    )))),
        trailing: PullDownButton(
          itemBuilder: (context) => [
            PullDownMenuItem(
                title: 'Settings',
                icon: CupertinoIcons.gear,
                onTap: () => Navigator.of(context, rootNavigator: true)
                    .push(CupertinoPageRoute(builder: (context) => SettingsPage()))),
            PullDownMenuDivider.large(),
            PullDownMenuTitle(title: Text('Accounts')),
            PullDownMenuItem(
              title: 'Sessions',
              icon: CupertinoIcons.rectangle_stack_person_crop,
              onTap: () => Share.changeBase.broadcast(Value(() => sessionsPage)),
            )
          ],
          buttonBuilder: (context, showMenu) => GestureDetector(
            onTap: showMenu,
            child: _eventfulMenuButton,
          ),
        ),
        children: [
          CupertinoListSection.insetGrouped(
              margin: EdgeInsets.only(left: 15, right: 15, bottom: 10),
              additionalDividerMargin: 5,
              hasLeading: false,
              header: Text('Summary'),
              children: [
                CupertinoListTile(
                    onTap: () {
                      Share.tabsNavigatePage.broadcast(Value(2));
                      Future.delayed(Duration(milliseconds: 250)).then((arg) => Share.timetableNavigateDay.broadcast(Value(
                          DateTime.now().asDate(utc: true).add(Duration(
                              days: (DateTime.now().isAfterOrSame(currentDay?.dayEnd) && (nextDay?.hasLessons ?? false)) ||
                                      (!(currentDay?.hasLessons ?? false) && (nextDay?.hasLessons ?? false))
                                  ? 1
                                  : 0)))));
                    },
                    padding: EdgeInsets.only(left: 20, right: 10),
                    title: Container(
                        margin: EdgeInsets.only(top: 3, bottom: 15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                              Expanded(
                                  child: Container(
                                margin: EdgeInsets.only(top: 8),
                                child: Text(glanceTitle,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 21,
                                    )),
                              )),
                              Visibility(
                                  visible: Share.session.data.student.mainClass.unit.luckyNumber != null,
                                  child: Stack(alignment: Alignment.center, children: [
                                    Text(
                                        (DateTime.now().isAfterOrSame(currentDay?.dayEnd) &&
                                                    Share.session.data.student.account.number ==
                                                        Share.session.data.student.mainClass.unit.luckyNumber &&
                                                    Share.session.data.student.mainClass.unit.luckyNumberTomorrow) ||
                                                (DateTime.now().isBeforeOrSame(currentDay?.dayStart) &&
                                                    Share.session.data.student.account.number ==
                                                        Share.session.data.student.mainClass.unit.luckyNumber &&
                                                    !Share.session.data.student.mainClass.unit.luckyNumberTomorrow)
                                            ? '🌟'
                                            : '⭐',
                                        style: TextStyle(fontSize: 32)),
                                    Container(
                                        margin: EdgeInsets.only(top: 1),
                                        child:
                                            Text(Share.session.data.student.mainClass.unit.luckyNumber?.toString() ?? '69',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                  color: CupertinoDynamicColor.resolve(
                                                      CupertinoDynamicColor.withBrightness(
                                                          color: CupertinoColors.black, darkColor: CupertinoColors.white),
                                                      context),
                                                  shadows: [
                                                    Shadow(
                                                      color: CupertinoColors.black,
                                                      blurRadius: 3.0,
                                                      offset: Offset(0.0, 0.0),
                                                    ),
                                                  ],
                                                ))),
                                  ]))
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
                        )))
              ]
                  .appendIf(
                      CupertinoListTile(
                          onTap: () {
                            Share.tabsNavigatePage.broadcast(Value(2));
                            Future.delayed(Duration(milliseconds: 250)).then((arg) => Share.timetableNavigateDay.broadcast(
                                Value(DateTime.now().asDate(utc: true).add(Duration(
                                    days: (DateTime.now().isAfterOrSame(currentDay?.dayEnd) &&
                                                (nextDay?.hasLessons ?? false)) ||
                                            (!(currentDay?.hasLessons ?? false) && (nextDay?.hasLessons ?? false))
                                        ? 1
                                        : 0)))));
                          },
                          title: Container(
                              margin: EdgeInsets.only(top: 10, bottom: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Visibility(
                                      visible: currentLesson != null,
                                      child: Row(children: [
                                        Text(
                                          'Now:',
                                          style: TextStyle(fontWeight: FontWeight.w500),
                                        ),
                                        Flexible(
                                            child: Container(
                                                margin: EdgeInsets.only(right: 3, left: 3),
                                                child: Text(
                                                  currentLesson?.subject?.name ?? 'Your mom',
                                                  style: TextStyle(fontWeight: FontWeight.w500),
                                                ))),
                                        Text(
                                          'in ${currentLesson?.classroom?.name ?? "the otherworld"}',
                                          style: TextStyle(fontWeight: FontWeight.w400),
                                        )
                                      ])),
                                  Visibility(
                                      visible: nextLesson != null,
                                      child: Opacity(
                                          opacity: 0.5,
                                          child: Container(
                                              margin: EdgeInsets.only(top: 5),
                                              child: Row(children: [
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
                                                          nextLesson?.subject?.name ?? 'Your mom',
                                                          style: TextStyle(fontWeight: FontWeight.w500),
                                                        ))),
                                                Text(
                                                  'in ${nextLesson?.classroom?.name ?? "the otherworld"}',
                                                  style: TextStyle(fontWeight: FontWeight.w400),
                                                )
                                              ]))))
                                ],
                              ))),
                      // Show during lessons and breaks (between lessons)
                      nextLesson != null || currentLesson != null)
                  .appendIf(
                      CupertinoListTile(
                          onTap: () {
                            Share.tabsNavigatePage.broadcast(Value(2));
                            Future.delayed(Duration(milliseconds: 250)).then((arg) => Share.timetableNavigateDay.broadcast(
                                Value(DateTime.now().asDate(utc: true).add(Duration(
                                    days: (DateTime.now().isAfterOrSame(currentDay?.dayEnd) &&
                                                (nextDay?.hasLessons ?? false)) ||
                                            (!(currentDay?.hasLessons ?? false) && (nextDay?.hasLessons ?? false))
                                        ? 1
                                        : 0)))));
                          },
                          title: Container(
                              margin: EdgeInsets.only(top: 10, bottom: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(children: [
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
                                                  'Your mom',
                                              style: TextStyle(fontWeight: FontWeight.w500),
                                            ))),
                                    Text(
                                      'in ${nextDay?.lessonsStrippedCancelled.firstWhereOrDefault((x) => x?.any((y) => !y.isCanceled) ?? false)?.firstWhereOrDefault((x) => !x.isCanceled)?.classroom?.name ?? "the otherworld"}',
                                      style: TextStyle(fontWeight: FontWeight.w400),
                                    )
                                  ])
                                ],
                              ))),
                      // Show >1h after the school day has ended, and if there are lessons tomorrow
                      (DateTime.now().isAfterOrSame(currentDay?.dayEnd) && (nextDay?.hasLessons ?? false)) &&
                          DateTime.now().difference(currentDay?.dayEnd ?? DateTime.now()).inHours > 1)
                  .appendIf(
                      CupertinoListTile(
                          onTap: () {
                            Share.tabsNavigatePage.broadcast(Value(2));
                            Future.delayed(Duration(milliseconds: 250)).then((arg) => Share.timetableNavigateDay.broadcast(
                                Value(DateTime.now().asDate(utc: true).add(Duration(
                                    days: (DateTime.now().isAfterOrSame(currentDay?.dayEnd) &&
                                                (nextDay?.hasLessons ?? false)) ||
                                            (!(currentDay?.hasLessons ?? false) && (nextDay?.hasLessons ?? false))
                                        ? 1
                                        : 0)))));
                          },
                          padding: EdgeInsets.only(left: 20, right: 5),
                          title: Row(children: [
                            Expanded(
                                child: Container(
                                    margin: EdgeInsets.only(right: 3),
                                    child: Text(
                                      DateTime.now().isAfterOrSame(currentDay?.dayEnd) && (nextDay?.hasLessons ?? false)
                                          ? 'Tomorrow: ${nextDay?.lessonsNumber.asLessonNumber()}'
                                          : 'Later: ${((currentDay?.lessonsStrippedCancelled.where((x) => x?.any((y) => DateTime.now().isBeforeOrSame(y.timeFrom)) ?? false).count((x) => (x?.isNotEmpty ?? false) && (x?.all((y) => !y.isCanceled) ?? false)) ?? 1) - 1).asLessonNumber()}',
                                      style: TextStyle(fontWeight: FontWeight.w400),
                                    ))),
                            Text(
                              DateTime.now().isAfterOrSame(currentDay?.dayEnd) && (nextDay?.hasLessons ?? false)
                                  ? 'until ${DateFormat("H:mm").format(nextDay?.dayEnd ?? DateTime.now())}'
                                  : 'until ${DateFormat("H:mm").format(currentDay?.dayEnd ?? DateTime.now())}',
                              style:
                                  TextStyle(fontWeight: FontWeight.w400, fontSize: 15, color: CupertinoColors.inactiveGray),
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
                              DateTime.now().difference(currentDay?.dayEnd ?? DateTime.now()).inHours > 1)))),
          // Homeworks - first if any(), otherwise last
          Visibility(visible: !homeworksLast, child: homeworksWidget),
          // Upcoming events - in the middle, or top
          CupertinoListSection.insetGrouped(
            margin: EdgeInsets.only(left: 15, right: 15, bottom: 10),
            dividerMargin: 35,
            header: Text('Upcoming events'),
            children: eventsWeek.isEmpty
                // No events to display
                ? [
                    CupertinoListTile(
                        title: Opacity(
                            opacity: 0.5,
                            child: Container(
                                alignment: Alignment.center,
                                child: Text(
                                  'No events to display',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
                                ))))
                  ]
                // Bindable event layout
                : eventsWeek
                    .select((x, index) => CupertinoListTile(
                        padding: EdgeInsets.all(0),
                        title: CupertinoContextMenu.builder(
                            actions: [
                              CupertinoContextMenuAction(
                                onPressed: () {
                                  sharing.Share.share(
                                      'There\'s a "${x.titleString}" on ${DateFormat("EEEE, MMM d, y").format(x.timeFrom)} ${(x.classroom?.name.isNotEmpty ?? false) ? ("in ${x.classroom?.name ?? ""}") : "at school"}');
                                  Navigator.of(context, rootNavigator: true).pop();
                                },
                                trailingIcon: CupertinoIcons.share,
                                child: const Text('Share'),
                              ),
                              CupertinoContextMenuAction(
                                isDestructiveAction: true,
                                trailingIcon: CupertinoIcons.chat_bubble_2,
                                child: const Text('Inquiry'),
                                onPressed: () {
                                  Navigator.of(context, rootNavigator: true).pop();
                                  showCupertinoModalBottomSheet(
                                      context: context,
                                      builder: (context) => MessageComposePage(
                                          receivers: x.sender != null ? [x.sender!] : [],
                                          subject:
                                              'Pytanie o wydarzenie w dniu ${DateFormat("y.M.d").format(x.date ?? x.timeFrom)}',
                                          signature:
                                              '${Share.session.data.student.account.name}, ${Share.session.data.student.mainClass.name}'));
                                },
                              ),
                            ],
                            builder: (BuildContext context, Animation<double> animation) => CupertinoButton(
                                onPressed: () {
                                  Share.tabsNavigatePage.broadcast(Value(2));
                                  Future.delayed(Duration(milliseconds: 250))
                                      .then((arg) => Share.timetableNavigateDay.broadcast(Value(x.date ?? x.timeFrom)));
                                },
                                padding: EdgeInsets.zero,
                                child: Container(
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(Radius.circular(10)),
                                        color: CupertinoDynamicColor.resolve(
                                            CupertinoDynamicColor.withBrightness(
                                                color: const Color.fromARGB(255, 255, 255, 255),
                                                darkColor: const Color.fromARGB(255, 28, 28, 30)),
                                            context)),
                                    padding: EdgeInsets.only(right: 10, left: 6),
                                    child: ConstrainedBox(
                                        constraints: BoxConstraints(
                                            maxHeight: animation.value < CupertinoContextMenu.animationOpensAt
                                                ? double.infinity
                                                : 100,
                                            maxWidth: animation.value < CupertinoContextMenu.animationOpensAt
                                                ? double.infinity
                                                : 260),
                                        child: Column(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  TextChip(
                                                      text: DateFormat('d/M').format(x.date ?? x.timeFrom),
                                                      margin: EdgeInsets.only(top: 6, bottom: 6, right: 10)),
                                                  Flexible(
                                                      child: Text(
                                                    maxLines: 1,
                                                    (x.title ?? x.content).capitalize(),
                                                    overflow: TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                        fontWeight: FontWeight.w600,
                                                        color: CupertinoDynamicColor.resolve(
                                                            CupertinoDynamicColor.withBrightness(
                                                                color: CupertinoColors.black,
                                                                darkColor: CupertinoColors.white),
                                                            context)),
                                                  ))
                                                ],
                                              ),
                                              Visibility(
                                                  visible: animation.value >= CupertinoContextMenu.animationOpensAt,
                                                  child: Flexible(
                                                      child: Container(
                                                          margin: EdgeInsets.only(left: 5, right: 5, bottom: 7),
                                                          child: Text(
                                                            x.locationTypeString,
                                                            maxLines: 2,
                                                            overflow: TextOverflow.ellipsis,
                                                            style: TextStyle(
                                                                fontSize: 15,
                                                                fontWeight: FontWeight.w500,
                                                                color: CupertinoDynamicColor.resolve(
                                                                    CupertinoDynamicColor.withBrightness(
                                                                        color: CupertinoColors.black,
                                                                        darkColor: CupertinoColors.white),
                                                                    context)),
                                                          ))))
                                            ])))))))
                    .toList(),
          ),
          // Recent grades - always below events
          CupertinoListSection.insetGrouped(
            margin: EdgeInsets.only(left: 15, right: 15, bottom: 10),
            additionalDividerMargin: 0,
            header: Text('Recent grades'),
            children: gradesWeek.isEmpty
                // No grades to display
                ? [
                    CupertinoListTile(
                        title: Opacity(
                            opacity: 0.5,
                            child: Container(
                                alignment: Alignment.center,
                                child: Text(
                                  'No recent grades',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
                                ))))
                  ]
                // Bindable grades layout
                : gradesWeek
                    .select((x, index) => CupertinoListTile(
                        padding: EdgeInsets.all(0),
                        title: CupertinoContextMenu.builder(
                            actions: [
                              CupertinoContextMenuAction(
                                onPressed: () {
                                  sharing.Share.share(
                                      'I got ${x.grades.select((y, s) => y.value).join(", ")} from ${x.lesson.name} last week!');
                                  Navigator.of(context, rootNavigator: true).pop();
                                },
                                trailingIcon: CupertinoIcons.share,
                                child: const Text('Share'),
                              ),
                              CupertinoContextMenuAction(
                                isDestructiveAction: true,
                                trailingIcon: CupertinoIcons.chat_bubble_2,
                                child: const Text('Inquiry'),
                                onPressed: () {
                                  Navigator.of(context, rootNavigator: true).pop();
                                  showCupertinoModalBottomSheet(
                                      context: context,
                                      builder: (context) => MessageComposePage(
                                          receivers: [x.lesson.teacher],
                                          subject:
                                              'Pytanie o ${x.grades.length > 1 ? "oceny" : "ocenę"} ${x.grades.select((y, index) => y.value).join(', ')} z przedmiotu ${x.lesson.name}',
                                          signature:
                                              '${Share.session.data.student.account.name}, ${Share.session.data.student.mainClass.name}'));
                                },
                              ),
                            ],
                            builder: (BuildContext context, Animation<double> animation) => CupertinoButton(
                                onPressed: () {
                                  Share.tabsNavigatePage.broadcast(Value(1));
                                  Future.delayed(Duration(milliseconds: 250))
                                      .then((arg) => Share.gradesNavigate.broadcast(Value(x.lesson)));
                                },
                                padding: EdgeInsets.zero,
                                child: Container(
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(Radius.circular(10)),
                                        color: CupertinoDynamicColor.resolve(
                                            CupertinoDynamicColor.withBrightness(
                                                color: const Color.fromARGB(255, 255, 255, 255),
                                                darkColor: const Color.fromARGB(255, 28, 28, 30)),
                                            context)),
                                    padding: EdgeInsets.only(right: 10, left: 6),
                                    child: ConstrainedBox(
                                        constraints: BoxConstraints(
                                            maxHeight: animation.value < CupertinoContextMenu.animationOpensAt
                                                ? double.infinity
                                                : 100,
                                            maxWidth: animation.value < CupertinoContextMenu.animationOpensAt
                                                ? double.infinity
                                                : 260),
                                        child: Container(
                                            margin: EdgeInsets.only(right: 10, left: 7),
                                            alignment: Alignment.centerLeft,
                                            child: Row(
                                              children: [
                                                Expanded(
                                                    flex: 2,
                                                    child: Align(
                                                        alignment: Alignment.centerLeft,
                                                        child: Text(
                                                          x.lesson.name,
                                                          overflow: TextOverflow.ellipsis,
                                                          style: TextStyle(
                                                              fontSize: 18,
                                                              fontWeight: FontWeight.w700,
                                                              color: CupertinoDynamicColor.resolve(
                                                                  CupertinoDynamicColor.withBrightness(
                                                                      color: CupertinoColors.black,
                                                                      darkColor: CupertinoColors.white),
                                                                  context)),
                                                        ))),
                                                Expanded(
                                                    child: Align(
                                                        alignment: Alignment.centerRight,
                                                        child: RichText(
                                                            overflow: TextOverflow.ellipsis,
                                                            text: TextSpan(
                                                                text: '',
                                                                children: x.grades
                                                                    .select((y, index) => TextSpan(
                                                                        text: y.value,
                                                                        style: TextStyle(fontSize: 25, color: y.asColor())))
                                                                    .toList()
                                                                    .intersperse(TextSpan(
                                                                        text: ', ',
                                                                        style: TextStyle(
                                                                            fontSize: 25,
                                                                            fontWeight: FontWeight.w600,
                                                                            color: CupertinoDynamicColor.resolve(
                                                                                CupertinoDynamicColor.withBrightness(
                                                                                    color: CupertinoColors.black,
                                                                                    darkColor: CupertinoColors.white),
                                                                                context))))
                                                                    .toList()))))
                                              ],
                                            ))))))))
                    .toList(),
          ),
          // Homeworks - first if any(), otherwise last
          Visibility(visible: homeworksLast, child: homeworksWidget)
        ],
      ),
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
        standard: 'ends in ${DateTime.now().difference(currentLesson.timeTo ?? DateTime.now()).inMinutes.abs()} min'
      );
    }

    // Next lesson's start time
    if (nextLesson != null) {
      return (
        flexible: nextLesson.subject?.name ?? 'The next lesson',
        standard: DateTime.now().difference(nextLesson.timeFrom ?? DateTime.now()).inMinutes.abs() < 20
            ? 'starts in ${DateTime.now().difference(nextLesson.timeFrom ?? DateTime.now()).inMinutes.abs() < 1 ? "${DateTime.now().difference(nextLesson.timeFrom ?? DateTime.now()).inSeconds.abs()}s" : "${DateTime.now().difference(nextLesson.timeFrom ?? DateTime.now()).inMinutes.abs()} min"}'
            : 'starts at ${DateFormat("HH:mm").format(nextLesson.timeFrom ?? DateTime.now())}'
      );
    }

    // Lessons have just ended - 7
    if ((currentDay?.hasLessons ?? false) &&
        DateTime.now().isAfterOrSame(currentDay?.dayEnd) &&
        DateTime.now().difference(currentDay?.dayEnd ?? DateTime.now()).inHours < 2) {
      return (flexible: "You've survived all ${currentDay!.lessonsNumber.asLessonNumber()}!", standard: '');
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
    if (DateTime.now().month == DateTime.december &&
        (DateTime.now().day == 24 || DateTime.now().day == 25 || DateTime.now().day == 26)) {
      return 'Merry Christmas!';
    }

    // Lessons have just ended - 7.1
    if ((currentDay?.hasLessons ?? false) &&
        DateTime.now().isAfterOrSame(currentDay?.dayEnd) &&
        DateTime.now().difference(currentDay?.dayEnd ?? DateTime.now()).inHours < 2) {
      return 'Way to go!';
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
    return "Keep yourself safe...";
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
    if (DateTime.now().month == DateTime.december &&
        (DateTime.now().day == 24 || DateTime.now().day == 25 || DateTime.now().day == 26)) {
      return const Text('🎄');
    }
    // Default theme
    return const Icon(CupertinoIcons.ellipsis_circle);
  }
}

extension DateTimeExtension on DateTime {
  DateTime asDate({bool utc = false}) => utc ? DateTime.utc(year, month, day) : DateTime(year, month, day);
}

extension ColorsExtension on Grade {
  Color asColor() => switch (asValue.round()) {
        6 => CupertinoColors.systemTeal,
        5 => CupertinoColors.systemGreen,
        4 => Color(0xFF76FF03),
        3 => CupertinoColors.systemOrange,
        2 => CupertinoColors.systemRed,
        1 => CupertinoColors.destructiveRed,
        _ => CupertinoColors.inactiveGray
      };
}

extension ListExtension on List<TextSpan> {
  Iterable<TextSpan> intersperse(TextSpan element) sync* {
    for (int i = 0; i < length; i++) {
      yield this[i];
      if (length != i + 1) yield element;
    }
  }
}

extension ListAppendExtension on Iterable<Widget> {
  List<Widget> appendIf(Widget element, bool condition) {
    if (!condition) return toList();
    return append(element).toList();
  }

  List<Widget> prependIf(Widget element, bool condition) {
    if (!condition) return toList();
    return prepend(element).toList();
  }

  List<Widget> appendIfEmpty(Widget element) {
    return appendIf(element, isEmpty).toList();
  }

  List<Widget> prependIfEmpty(Widget element) {
    return prependIf(element, isEmpty).toList();
  }
}

extension TableAppendExtension on Iterable<TableRow> {
  List<TableRow> appendIf(TableRow element, bool condition) {
    if (!condition) return toList();
    return append(element).toList();
  }

  List<TableRow> appendAllIf(List<TableRow> elements, bool condition) {
    if (!condition) return toList();
    return appendAll(elements).toList();
  }
}

extension LessonNumber on int {
  String asLessonNumber() => switch (this) {
        0 => '$this lessons',
        1 => '$this lesson',
        _ => '$this lessons'
        // Note for other languages:
        // stackoverflow.com/a/76413634
      };
}
