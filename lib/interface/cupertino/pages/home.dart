// ignore_for_file: prefer_const_constructors
// ignore_for_file: prefer_const_literals_to_create_immutables

import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:darq/darq.dart';
import 'package:duration/duration.dart';
import 'package:duration/locale.dart';
import 'package:event/event.dart';
import 'package:extended_wrap/extended_wrap.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:format/format.dart';
import 'package:intl/intl.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:oshi/interface/cupertino/pages/absences.dart';
import 'package:oshi/interface/cupertino/pages/settings.dart';
import 'package:oshi/interface/cupertino/pages/timetable.dart';
import 'package:oshi/interface/cupertino/sessions_page.dart';
import 'package:oshi/interface/cupertino/views/grades_detailed.dart';
import 'package:oshi/interface/cupertino/views/message_compose.dart';
import 'package:oshi/interface/cupertino/widgets/searchable_bar.dart';
import 'package:oshi/models/data/attendances.dart';
import 'package:oshi/models/data/event.dart';
import 'package:oshi/models/data/grade.dart';
import 'package:oshi/models/data/messages.dart';
import 'package:oshi/models/data/teacher.dart';
import 'package:oshi/share/resources.dart';
import 'package:oshi/share/share.dart';

import 'package:oshi/interface/cupertino/widgets/text_chip.dart' show TextChip;
import 'package:oshi/share/translator.dart';
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
  SegmentController segmentController = SegmentController(segment: HomepageSegments.home);

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
              grades: x.allGrades.where((y) => y.addDate.isAfter(DateTime.now().subtract(Duration(days: 7)).asDate())).toList()
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
    var homeworksWidget = CupertinoListSection.insetGrouped(
      margin: EdgeInsets.only(left: 15, right: 15, bottom: 10),
      dividerMargin: 35,
      header: Text('/Homeworks'.localized),
      children: homeworksWeek.isEmpty
          // No homeworks to display
          ? [
              CupertinoListTile(
                  title: Opacity(
                      opacity: 0.5,
                      child: Container(
                          alignment: Alignment.center,
                          child: Text(
                            '/Homeworks/Done'.localized,
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
                          ))))
            ]
          // Bindable homework layout
          : homeworksWeek
              .select((x, index) => CupertinoListTile(
                  padding: EdgeInsets.all(0),
                  title: CupertinoContextMenu.builder(
                      enableHapticFeedback: true,
                      actions: [
                        CupertinoContextMenuAction(
                          onPressed: () {
                            sharing.Share.share('/Page/Home/Homework/share'
                                .localized
                                .format(x.titleString, DateFormat("EEEE, MMM d, y").format(x.timeFrom)));
                            Navigator.of(context, rootNavigator: true).pop();
                          },
                          trailingIcon: CupertinoIcons.share,
                          child: Text('/Share'.localized),
                        ),
                        CupertinoContextMenuAction(
                          isDestructiveAction: true,
                          trailingIcon: CupertinoIcons.chat_bubble_2,
                          child: Text('/Inquiry'.localized),
                          onPressed: () {
                            Navigator.of(context, rootNavigator: true).pop();
                            showCupertinoModalBottomSheet(
                                context: context,
                                builder: (context) => MessageComposePage(
                                    receivers: x.sender != null ? [x.sender!] : [],
                                    subject:
                                        'Pytanie o pracę domową na dzień ${DateFormat("y.M.d").format(x.timeTo ?? x.date ?? x.timeFrom)}',
                                    signature:
                                        '${Share.session.data.student.account.name}, ${Share.session.data.student.mainClass.name}'));
                          },
                        ),
                      ],
                      builder: (BuildContext context, Animation<double> animation) => CupertinoButton(
                          onPressed: animation.value >= CupertinoContextMenu.animationOpensAt
                              ? null
                              : () {
                                  Share.tabsNavigatePage.broadcast(Value(2));
                                  Future.delayed(Duration(milliseconds: 250)).then((arg) =>
                                      Share.timetableNavigateDay.broadcast(Value(x.timeTo ?? x.date ?? x.timeFrom)));
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
                              padding: EdgeInsets.only(right: 5, left: 7),
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
                                                        text: DateFormat.Md(Share.settings.appSettings.localeCode)
                                                            .format(x.timeTo ?? x.date ?? x.timeFrom),
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
                                                              '/Notes'.localized.format(x.content),
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

    // Recent grades
    var gradesWidget = CupertinoListSection.insetGrouped(
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
                      enableHapticFeedback: true,
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
                          onPressed: animation.value >= CupertinoContextMenu.animationOpensAt
                              ? null
                              : () {
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
                              padding: EdgeInsets.only(right: 5, left: 7, top: 13, bottom: 13),
                              child: ConstrainedBox(
                                  constraints: BoxConstraints(
                                      maxHeight:
                                          animation.value < CupertinoContextMenu.animationOpensAt ? double.infinity : 100,
                                      maxWidth:
                                          animation.value < CupertinoContextMenu.animationOpensAt ? double.infinity : 260),
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
                                                  child: ExtendedWrap(
                                                      maxLines: 1,
                                                      textDirection: ui.TextDirection.rtl,
                                                      overflowWidget: Text('...',
                                                          style: TextStyle(
                                                              color: CupertinoDynamicColor.resolve(
                                                                  CupertinoDynamicColor.withBrightness(
                                                                      color: CupertinoColors.black,
                                                                      darkColor: CupertinoColors.white),
                                                                  context))),
                                                      spacing: 6,
                                                      children: x.grades
                                                          .orderByDescending((y) => y.addDate)
                                                          .select((y, index) => Container(
                                                                padding: EdgeInsets.symmetric(horizontal: 5),
                                                                decoration: BoxDecoration(
                                                                    color: y.major
                                                                        ? (y.isFinal || y.isSemester)
                                                                            ? y.asColor()
                                                                            : null
                                                                        : y.asColor(),
                                                                    border: Border.all(
                                                                        color: y.asColor(),
                                                                        width: 2,
                                                                        strokeAlign: BorderSide.strokeAlignInside),
                                                                    borderRadius: BorderRadius.all(Radius.circular(6))),
                                                                child: Text(y.value,
                                                                    textAlign: TextAlign.center,
                                                                    style: TextStyle(
                                                                        fontSize: 17,
                                                                        color:
                                                                            (y.isFinalProposition || y.isSemesterProposition)
                                                                                ? CupertinoDynamicColor.resolve(
                                                                                    CupertinoDynamicColor.withBrightness(
                                                                                        color: CupertinoColors.black,
                                                                                        darkColor: CupertinoColors.white),
                                                                                    context)
                                                                                : CupertinoColors.black)),
                                                              ))
                                                          .toList())))
                                        ],
                                      ))))))))
              .toList(),
    );

    // Upcoming events
    var eventsWidget = CupertinoListSection.insetGrouped(
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
                            'It\'s quiet, too quiet...',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
                          ))))
            ]
          // Bindable event layout
          : eventsWeek
              .select((x, index) => CupertinoListTile(
                  padding: EdgeInsets.all(0),
                  title: CupertinoContextMenu.builder(
                      enableHapticFeedback: true,
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
                          onPressed: animation.value >= CupertinoContextMenu.animationOpensAt
                              ? null
                              : () {
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
                              padding: EdgeInsets.only(right: 5, left: 7),
                              child: ConstrainedBox(
                                  constraints: BoxConstraints(
                                      maxHeight:
                                          animation.value < CupertinoContextMenu.animationOpensAt ? double.infinity : 100,
                                      maxWidth:
                                          animation.value < CupertinoContextMenu.animationOpensAt ? double.infinity : 260),
                                  child: Column(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            TextChip(
                                                text: DateFormat.Md(Share.settings.appSettings.localeCode)
                                                    .format(x.date ?? x.timeFrom),
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
                                                          color: CupertinoColors.black, darkColor: CupertinoColors.white),
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
    );

    // Widgets for the home page
    var homePageChildren = [
      CupertinoListSection.insetGrouped(
          margin: EdgeInsets.only(left: 15, right: 15, bottom: 10),
          additionalDividerMargin: 5,
          hasLeading: false,
          header: Text('/Summary'.localized),
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
                    )))
          ]
              .appendIf(
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
                      title: Container(
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
                      title: Container(
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
                      padding: EdgeInsets.only(left: 20, right: 5),
                      title: Row(children: [
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
                          style: TextStyle(fontWeight: FontWeight.w400, fontSize: 15, color: CupertinoColors.inactiveGray),
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
        .toList();

    // Widgets for the timeline page
    var timelineChanges = Share.session.changes.orderByDescending((x) => x.refreshDate).toList();

    var timelineChildren = [
      ListView.builder(
          shrinkWrap: true,
          primary: false,
          physics: NeverScrollableScrollPhysics(),
          itemCount: timelineChanges.count(),
          itemBuilder: (BuildContext context, int index) {
            var x = timelineChanges[index];
            return CupertinoListSection.insetGrouped(
                margin: EdgeInsets.only(left: 15, right: 15, bottom: 10),
                separatorColor: Colors.transparent,
                header: Container(
                    margin: EdgeInsets.only(left: 5),
                    child: Text(
                        (x.refreshDate.asDate() == DateTime.now().asDate() ? 'Today, ' : '') +
                            DateFormat(x.refreshDate.asDate() == DateTime.now().asDate() ? 'h:mm a' : 'EEE, MMM d, h:mm a')
                                .format(x.refreshDate),
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.normal, color: CupertinoColors.inactiveGray))),
                children: <Widget>[]
                    // Added or updated lessons
                    .appendIf(
                        CupertinoListTile(
                            padding: EdgeInsets.only(left: 10, right: 10, bottom: 5),
                            title: CupertinoListSection.insetGrouped(
                                separatorColor: Colors.transparent,
                                backgroundColor: Colors.transparent,
                                margin: EdgeInsets.zero,
                                hasLeading: false,
                                header: Text(
                                    x.timetablesChanged
                                        .count((element) => element.type != RegisterChangeTypes.removed)
                                        .asTimetablesNumber(RegisterChangeTypes.added),
                                    style: TextStyle(
                                        fontSize: 15, fontWeight: FontWeight.normal, color: CupertinoColors.inactiveGray)),
                                children: x.timetablesChanged
                                    .where((element) => element.type != RegisterChangeTypes.removed)
                                    .select(
                                      (y, index) => CupertinoListTile(
                                          padding: EdgeInsets.only(top: 5, bottom: 5),
                                          title: y.value.asLessonWidget(context, null, null, _setState,
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
                        CupertinoListTile(
                            padding: EdgeInsets.only(left: 10, right: 10, bottom: 5),
                            title: CupertinoListSection.insetGrouped(
                                separatorColor: Colors.transparent,
                                backgroundColor: Colors.transparent,
                                margin: EdgeInsets.zero,
                                hasLeading: false,
                                header: Text(
                                    x.timetablesChanged
                                        .count((element) => element.type == RegisterChangeTypes.removed)
                                        .asTimetablesNumber(RegisterChangeTypes.removed),
                                    style:
                                        TextStyle(fontSize: 15, fontWeight: FontWeight.normal, color: CupertinoColors.inactiveGray)),
                                children: x.timetablesChanged
                                    .where((element) => element.type == RegisterChangeTypes.removed)
                                    .select(
                                      (y, index) => CupertinoListTile(
                                          padding: EdgeInsets.only(top: 5, bottom: 5),
                                          title: y.value.asLessonWidget(context, null, null, _setState, markRemoved: true)),
                                    )
                                    .toList())),
                        x.timetablesChanged.any((element) => element.type == RegisterChangeTypes.removed))
                    // Added or updated messages
                    .appendIf(
                        CupertinoListTile(
                            padding: EdgeInsets.only(left: 10, right: 10, bottom: 5),
                            title: CupertinoListSection.insetGrouped(
                                separatorColor: Colors.transparent,
                                backgroundColor: Colors.transparent,
                                margin: EdgeInsets.zero,
                                hasLeading: false,
                                header: () {
                                  var news = x.messagesChanged.count((element) => element.type == RegisterChangeTypes.added);
                                  var changes =
                                      x.messagesChanged.count((element) => element.type == RegisterChangeTypes.changed);

                                  return Text(
                                      switch (news) {
                                        // There's only new grades
                                        > 0 when changes == 0 => news.asMessagesNumber(RegisterChangeTypes.added),
                                        // There's only changed grades
                                        0 when changes > 0 => changes.asMessagesNumber(RegisterChangeTypes.changed),
                                        // Some are new, some are changed
                                        > 0 when changes > 0 => (news + changes).asMessagesNumber(),
                                        // Shouldn't happen, but we need a _ case
                                        _ => 'No changes, WTF?!'
                                      },
                                      style: TextStyle(
                                          fontSize: 15, fontWeight: FontWeight.normal, color: CupertinoColors.inactiveGray));
                                }(),
                                children: x.messagesChanged
                                    .where((element) => element.type != RegisterChangeTypes.removed)
                                    .select(
                                      (y, index) => CupertinoListTile(
                                          padding: EdgeInsets.only(top: 5, bottom: 5),
                                          title: CupertinoListTile(
                                              padding: EdgeInsets.all(0),
                                              title: GestureDetector(
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
                                                                            style: TextStyle(
                                                                                fontSize: 17, fontWeight: FontWeight.w600),
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
                                                                          .replaceAll('\n\n', '\n'),
                                                                      maxLines: 2,
                                                                      overflow: TextOverflow.ellipsis,
                                                                      style: TextStyle(fontSize: 16),
                                                                    ))),
                                                          ]))))),
                                    )
                                    .toList())),
                        x.messagesChanged.any((element) => element.type != RegisterChangeTypes.removed))
                    // Added or updated attendances
                    .appendIf(
                        CupertinoListTile(
                            padding: EdgeInsets.only(left: 10, right: 10, bottom: 5),
                            title: CupertinoListSection.insetGrouped(
                                separatorColor: Colors.transparent,
                                backgroundColor: Colors.transparent,
                                margin: EdgeInsets.zero,
                                hasLeading: false,
                                header: () {
                                  var news =
                                      x.attendancesChanged.count((element) => element.type == RegisterChangeTypes.added);
                                  var changes =
                                      x.attendancesChanged.count((element) => element.type == RegisterChangeTypes.changed);

                                  return Text(
                                      switch (news) {
                                        // There's only new grades
                                        > 0 when changes == 0 => news.asAttendancesNumber(RegisterChangeTypes.added),
                                        // There's only changed grades
                                        0 when changes > 0 => changes.asAttendancesNumber(RegisterChangeTypes.changed),
                                        // Some are new, some are changed
                                        > 0 when changes > 0 => (news + changes).asAttendancesNumber(),
                                        // Shouldn't happen, but we need a _ case
                                        _ => 'No changes, WTF?!'
                                      },
                                      style: TextStyle(
                                          fontSize: 15, fontWeight: FontWeight.normal, color: CupertinoColors.inactiveGray));
                                }(),
                                children: x.attendancesChanged
                                    .orderByDescending((element) => element.value.addDate)
                                    .where((element) => element.type != RegisterChangeTypes.removed)
                                    .select(
                                      (y, index) => CupertinoListTile(
                                          padding: EdgeInsets.only(top: 5, bottom: 5),
                                          title: y.value.asAttendanceWidget(context,
                                              markModified: y.type == RegisterChangeTypes.changed,
                                              onTap: () => Share.tabsNavigatePage.broadcast(Value(4)))),
                                    )
                                    .toList())),
                        x.attendancesChanged.any((element) => element.type != RegisterChangeTypes.removed))
                    // Deleted attendances
                    .appendIf(
                        CupertinoListTile(
                            padding: EdgeInsets.only(left: 10, right: 10, bottom: 5),
                            title: CupertinoListSection.insetGrouped(
                                separatorColor: Colors.transparent,
                                backgroundColor: Colors.transparent,
                                margin: EdgeInsets.zero,
                                hasLeading: false,
                                header: Text(x.attendancesChanged.count((element) => element.type == RegisterChangeTypes.removed).asAttendancesNumber(RegisterChangeTypes.removed), style: TextStyle(fontSize: 15, fontWeight: FontWeight.normal, color: CupertinoColors.inactiveGray)),
                                children: x.attendancesChanged
                                    .where((element) => element.type == RegisterChangeTypes.removed)
                                    .select(
                                      (y, index) => CupertinoListTile(
                                          padding: EdgeInsets.only(top: 5, bottom: 5),
                                          title: y.value.asAttendanceWidget(context, markRemoved: true)),
                                    )
                                    .toList())),
                        x.attendancesChanged.any((element) => element.type == RegisterChangeTypes.removed))
                    // Added or updated grades
                    .appendIf(
                        CupertinoListTile(
                            padding: EdgeInsets.only(left: 10, right: 10, bottom: 5),
                            title: CupertinoListSection.insetGrouped(
                                separatorColor: Colors.transparent,
                                backgroundColor: Colors.transparent,
                                margin: EdgeInsets.zero,
                                hasLeading: false,
                                header: () {
                                  var news = x.gradesChanged.count((element) => element.type == RegisterChangeTypes.added);
                                  var changes =
                                      x.gradesChanged.count((element) => element.type == RegisterChangeTypes.changed);

                                  return Text(
                                      switch (news) {
                                        // There's only new grades
                                        > 0 when changes == 0 => news.asGradesNumber(RegisterChangeTypes.added),
                                        // There's only changed grades
                                        0 when changes > 0 => changes.asGradesNumber(RegisterChangeTypes.changed),
                                        // Some are new, some are changed
                                        > 0 when changes > 0 => (news + changes).asGradesNumber(),
                                        // Shouldn't happen, but we need a _ case
                                        _ => 'No changes, WTF?!'
                                      },
                                      style: TextStyle(
                                          fontSize: 15, fontWeight: FontWeight.normal, color: CupertinoColors.inactiveGray));
                                }(),
                                children: x.gradesChanged
                                    .where((element) => element.type != RegisterChangeTypes.removed)
                                    .select(
                                      (y, index) => CupertinoListTile(
                                          padding: EdgeInsets.only(top: 5, bottom: 5),
                                          title: y.value.asGrade(context, setState,
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
                        CupertinoListTile(
                            padding: EdgeInsets.only(left: 10, right: 10, bottom: 5),
                            title: CupertinoListSection.insetGrouped(
                                separatorColor: Colors.transparent,
                                backgroundColor: Colors.transparent,
                                margin: EdgeInsets.zero,
                                hasLeading: false,
                                header: Text(x.gradesChanged.count((element) => element.type == RegisterChangeTypes.removed).asGradesNumber(RegisterChangeTypes.removed), style: TextStyle(fontSize: 15, fontWeight: FontWeight.normal, color: CupertinoColors.inactiveGray)),
                                children: x.gradesChanged
                                    .where((element) => element.type == RegisterChangeTypes.removed)
                                    .select(
                                      (y, index) => CupertinoListTile(
                                          padding: EdgeInsets.only(top: 5, bottom: 5),
                                          title: y.value.asGrade(context, setState, markRemoved: true)),
                                    )
                                    .toList())),
                        x.gradesChanged.any((element) => element.type == RegisterChangeTypes.removed))
                    // Added or updated announcements
                    .appendIf(
                        CupertinoListTile(
                            padding: EdgeInsets.only(left: 10, right: 10, bottom: 5),
                            title: CupertinoListSection.insetGrouped(
                                separatorColor: Colors.transparent,
                                backgroundColor: Colors.transparent,
                                margin: EdgeInsets.zero,
                                hasLeading: false,
                                header: () {
                                  var news =
                                      x.announcementsChanged.count((element) => element.type == RegisterChangeTypes.added);
                                  var changes =
                                      x.announcementsChanged.count((element) => element.type == RegisterChangeTypes.changed);

                                  return Text(
                                      switch (news) {
                                        // There's only new grades
                                        > 0 when changes == 0 => news.asAnnouncementsNumber(RegisterChangeTypes.added),
                                        // There's only changed grades
                                        0 when changes > 0 => changes.asAnnouncementsNumber(RegisterChangeTypes.changed),
                                        // Some are new, some are changed
                                        > 0 when changes > 0 => (news + changes).asAnnouncementsNumber(),
                                        // Shouldn't happen, but we need a _ case
                                        _ => 'No changes, WTF?!'
                                      },
                                      style: TextStyle(
                                          fontSize: 15, fontWeight: FontWeight.normal, color: CupertinoColors.inactiveGray));
                                }(),
                                children: x.announcementsChanged
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
                                      (y, index) => CupertinoListTile(
                                          padding: EdgeInsets.only(top: 5, bottom: 5),
                                          title: CupertinoListTile(
                                              padding: EdgeInsets.all(0),
                                              title: GestureDetector(
                                                  onTap: () {
                                                    Share.tabsNavigatePage.broadcast(Value(3));
                                                    Future.delayed(Duration(milliseconds: 250)).then(
                                                        (arg) => Share.messagesNavigateAnnouncement.broadcast(Value(y)));
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
                                                                            y.message.senderName,
                                                                            overflow: TextOverflow.ellipsis,
                                                                            style: TextStyle(
                                                                                fontSize: 17, fontWeight: FontWeight.w600),
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
                                                                            (y.message.sendDate.month ==
                                                                                        y.message.readDate?.month &&
                                                                                    y.message.sendDate.year ==
                                                                                        y.message.readDate?.year &&
                                                                                    y.message.sendDate.day !=
                                                                                        y.message.readDate?.day
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
                                                                          .replaceAll('\n\n', '\n'),
                                                                      maxLines: 2,
                                                                      overflow: TextOverflow.ellipsis,
                                                                      style: TextStyle(fontSize: 16),
                                                                    ))),
                                                          ]))))),
                                    )
                                    .toList())),
                        x.announcementsChanged.any((element) => element.type != RegisterChangeTypes.removed))
                    // Added or updated events
                    .appendIf(
                        CupertinoListTile(
                            padding: EdgeInsets.only(left: 10, right: 10, bottom: 5),
                            title: CupertinoListSection.insetGrouped(
                                separatorColor: Colors.transparent,
                                backgroundColor: Colors.transparent,
                                margin: EdgeInsets.zero,
                                hasLeading: false,
                                header: () {
                                  var news = x.eventsChanged.count((element) => element.type == RegisterChangeTypes.added);
                                  var changes =
                                      x.eventsChanged.count((element) => element.type == RegisterChangeTypes.changed);

                                  return Text(
                                      switch (news) {
                                        // There's only new grades
                                        > 0 when changes == 0 => news.asEventsNumber(RegisterChangeTypes.added),
                                        // There's only changed grades
                                        0 when changes > 0 => changes.asEventsNumber(RegisterChangeTypes.changed),
                                        // Some are new, some are changed
                                        > 0 when changes > 0 => (news + changes).asEventsNumber(),
                                        // Shouldn't happen, but we need a _ case
                                        _ => 'No changes, WTF?!'
                                      },
                                      style: TextStyle(
                                          fontSize: 15, fontWeight: FontWeight.normal, color: CupertinoColors.inactiveGray));
                                }(),
                                children: x.eventsChanged
                                    .where((element) => element.type != RegisterChangeTypes.removed)
                                    .select(
                                      (y, index) => CupertinoListTile(
                                          padding: EdgeInsets.only(top: 5, bottom: 5),
                                          title: y.value.asEventWidget(context, true, null, _setState,
                                              markModified: y.type == RegisterChangeTypes.changed, onTap: () {
                                            Share.tabsNavigatePage.broadcast(Value(2));
                                            Future.delayed(Duration(milliseconds: 250)).then((arg) => Share
                                                .timetableNavigateDay
                                                .broadcast(Value(y.value.date ?? y.value.timeFrom)));
                                          })),
                                    )
                                    .toList())),
                        x.eventsChanged.any((element) => element.type != RegisterChangeTypes.removed))
                    // Deleted events
                    .appendIf(
                        CupertinoListTile(
                            padding: EdgeInsets.only(left: 10, right: 10, bottom: 5),
                            title: CupertinoListSection.insetGrouped(
                                separatorColor: Colors.transparent,
                                backgroundColor: Colors.transparent,
                                margin: EdgeInsets.zero,
                                hasLeading: false,
                                header: Text(x.eventsChanged.count((element) => element.type == RegisterChangeTypes.removed).asEventsNumber(RegisterChangeTypes.removed), style: TextStyle(fontSize: 15, fontWeight: FontWeight.normal, color: CupertinoColors.inactiveGray)),
                                children: x.eventsChanged
                                    .where((element) => element.type == RegisterChangeTypes.removed)
                                    .select(
                                      (y, index) => CupertinoListTile(
                                          padding: EdgeInsets.only(top: 5, bottom: 5),
                                          title: y.value.asEventWidget(context, true, null, _setState, markRemoved: true)),
                                    )
                                    .toList())),
                        x.eventsChanged.any((element) => element.type == RegisterChangeTypes.removed))
                    .toList());
          })
    ]
        .appendIf(
            CupertinoListTile(
                title: Opacity(
                    opacity: 0.5,
                    child: Container(
                        alignment: Alignment.center,
                        child: Text(
                          'No changes to display',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
                        )))),
            timelineChanges.isEmpty)
        .toList();

    return CupertinoPageScaffold(
      backgroundColor: CupertinoDynamicColor.withBrightness(
          color: const Color.fromARGB(255, 242, 242, 247), darkColor: const Color.fromARGB(255, 0, 0, 0)),
      child: SearchableSliverNavigationBar(
        useSliverBox: segmentController.segment == HomepageSegments.timeline,
        alwaysShowAddons: segmentController.segment == HomepageSegments.timeline,
        setState: _setState,
        segments: {
          HomepageSegments.home: '/Titles/Pages/Home'.localized,
          HomepageSegments.timeline: '/Titles/Pages/Timeline'.localized
        },
        searchController: searchController,
        segmentController: segmentController,
        largeTitle: GestureDetector(
            onDoubleTap: () {
              if (!Platform.isWindows) return;
              Share.session.refreshStatus.refreshMutex.protect<void>(() async {
                await Share.session.refreshAll();
                setState(() {});
              });
            },
            child: Text(segmentController.segment == HomepageSegments.home
                ? '/Titles/Pages/Home'.localized
                : '/Titles/Pages/Timeline'.localized)),
        middle: Text(segmentController.segment == HomepageSegments.home
            ? '/Titles/Pages/Home'.localized
            : '/Titles/Pages/Timeline'.localized),
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
            ),
            PullDownMenuItem(
              title: 'Mark as read',
              icon: CupertinoIcons.checkmark_circle,
              onTap: () => Share.session.unreadChanges.markAsRead(),
            ),
          ],
          buttonBuilder: (context, showMenu) => GestureDetector(
            onTap: showMenu,
            child: _eventfulMenuButton,
          ),
        ),
        children: segmentController.segment == HomepageSegments.home ? homePageChildren : timelineChildren,
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
    if (DateTime.now().month == DateTime.december &&
        (DateTime.now().day >= 20 && DateTime.now().day <= 30)) {
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
    if (DateTime.now().month == DateTime.december &&
        (DateTime.now().day >= 20 && DateTime.now().day <= 30)) {
      return const Text('🎄');
    }
    // Default theme
    return const Icon(CupertinoIcons.ellipsis_circle);
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

extension ListExtension<T> on List<T> {
  Iterable<T> intersperse(T element) sync* {
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
        1 => '$this ${"/Home/Counters/Lessons/Singular".localized}', // "lekcja"
        >= 2 && < 5 ||
        _ when this % 10 >= 2 && this % 10 < 5 =>
          '$this ${"/Home/Counters/Lessons/Plural/Start".localized}', // "lekcje"
        >= 5 && < 22 ||
        _ when (this % 10 >= 5 && this % 10 < 9) || (this % 10 >= 0 && this % 10 < 2) =>
          '$this ${"/Home/Counters/Lessons/Plural/End".localized}', // "lekcji"
        _ => '$this ${"/Home/Counters/Lessons/Plural/End".localized}' // "lekcji"
        // Note for other languages:
        // stackoverflow.com/a/76413634
      };

  String asTimetablesNumber([RegisterChangeTypes? changeType]) {
    var modifier = switch (changeType) {
      RegisterChangeTypes.added => '/New',
      RegisterChangeTypes.changed => '/Updated',
      RegisterChangeTypes.removed => '/Removed',
      _ => '/Both',
    };
    return switch (this) {
      1 => '$this ${"/Timeline/Lang/Counters/Timetables$modifier/Singular".localized}', // "lekcja"
      >= 2 && < 5 ||
      _ when this % 10 >= 2 && this % 10 < 5 =>
        '$this ${"/Timeline/Lang/Counters/Timetables$modifier/Plural/Start".localized}', // "lekcje"
      >= 5 && < 22 ||
      _ when (this % 10 >= 5 && this % 10 < 9) || (this % 10 >= 0 && this % 10 < 2) =>
        '$this ${"/Timeline/Lang/Counters/Timetables$modifier/Plural/End".localized}', // "lekcji"
      _ => '$this ${"/Timeline/Lang/Counters/Timetables$modifier/Plural/End".localized}' // "lekcji"
      // Note for other languages:
      // stackoverflow.com/a/76413634
    };
  }

  String asGradesNumber([RegisterChangeTypes? changeType]) {
    var modifier = switch (changeType) {
      RegisterChangeTypes.added => '/New',
      RegisterChangeTypes.changed => '/Updated',
      RegisterChangeTypes.removed => '/Removed',
      _ => '/Both',
    };
    return switch (this) {
      1 => '$this ${"/Timeline/Lang/Counters/Grades$modifier/Singular".localized}', // "lekcja"
      >= 2 && < 5 ||
      _ when this % 10 >= 2 && this % 10 < 5 =>
        '$this ${"/Timeline/Lang/Counters/Grades$modifier/Plural/Start".localized}', // "lekcje"
      >= 5 && < 22 ||
      _ when (this % 10 >= 5 && this % 10 < 9) || (this % 10 >= 0 && this % 10 < 2) =>
        '$this ${"/Timeline/Lang/Counters/Grades$modifier/Plural/End".localized}', // "lekcji"
      _ => '$this ${"/Timeline/Lang/Counters/Grades$modifier/Plural/End".localized}' // "lekcji"
      // Note for other languages:
      // stackoverflow.com/a/76413634
    };
  }

  String asEventsNumber([RegisterChangeTypes? changeType]) {
    var modifier = switch (changeType) {
      RegisterChangeTypes.added => '/New',
      RegisterChangeTypes.changed => '/Updated',
      RegisterChangeTypes.removed => '/Removed',
      _ => '/Both',
    };
    return switch (this) {
      1 => '$this ${"/Timeline/Lang/Counters/Events$modifier/Singular".localized}', // "lekcja"
      >= 2 && < 5 ||
      _ when this % 10 >= 2 && this % 10 < 5 =>
        '$this ${"/Timeline/Lang/Counters/Events$modifier/Plural/Start".localized}', // "lekcje"
      >= 5 && < 22 ||
      _ when (this % 10 >= 5 && this % 10 < 9) || (this % 10 >= 0 && this % 10 < 2) =>
        '$this ${"/Timeline/Lang/Counters/Events$modifier/Plural/End".localized}', // "lekcji"
      _ => '$this ${"/Timeline/Lang/Counters/Events$modifier/Plural/End".localized}' // "lekcji"
      // Note for other languages:
      // stackoverflow.com/a/76413634
    };
  }

  String asAnnouncementsNumber([RegisterChangeTypes? changeType]) {
    var modifier = switch (changeType) {
      RegisterChangeTypes.added => '/New',
      RegisterChangeTypes.changed => '/Updated',
      RegisterChangeTypes.removed => '/Removed',
      _ => '/Both',
    };
    return switch (this) {
      1 => '$this ${"/Timeline/Lang/Counters/Announcements$modifier/Singular".localized}', // "lekcja"
      >= 2 && < 5 ||
      _ when this % 10 >= 2 && this % 10 < 5 =>
        '$this ${"/Timeline/Lang/Counters/Announcements$modifier/Plural/Start".localized}', // "lekcje"
      >= 5 && < 22 ||
      _ when (this % 10 >= 5 && this % 10 < 9) || (this % 10 >= 0 && this % 10 < 2) =>
        '$this ${"/Timeline/Lang/Counters/Announcements$modifier/Plural/End".localized}', // "lekcji"
      _ => '$this ${"/Timeline/Lang/Counters/Announcements$modifier/Plural/End".localized}' // "lekcji"
      // Note for other languages:
      // stackoverflow.com/a/76413634
    };
  }

  String asMessagesNumber([RegisterChangeTypes? changeType]) {
    var modifier = switch (changeType) {
      RegisterChangeTypes.added => '/New',
      RegisterChangeTypes.changed => '/Updated',
      RegisterChangeTypes.removed => '/Removed',
      _ => '/Both',
    };
    return switch (this) {
      1 => '$this ${"/Timeline/Lang/Counters/Messages$modifier/Singular".localized}', // "lekcja"
      >= 2 && < 5 ||
      _ when this % 10 >= 2 && this % 10 < 5 =>
        '$this ${"/Timeline/Lang/Counters/Messages$modifier/Plural/Start".localized}', // "lekcje"
      >= 5 && < 22 ||
      _ when (this % 10 >= 5 && this % 10 < 9) || (this % 10 >= 0 && this % 10 < 2) =>
        '$this ${"/Timeline/Lang/Counters/Messages$modifier/Plural/End".localized}', // "lekcji"
      _ => '$this ${"/Timeline/Lang/Counters/Messages$modifier/Plural/End".localized}' // "lekcji"
      // Note for other languages:
      // stackoverflow.com/a/76413634
    };
  }

  String asAttendancesNumber([RegisterChangeTypes? changeType]) {
    var modifier = switch (changeType) {
      RegisterChangeTypes.added => '/New',
      RegisterChangeTypes.changed => '/Updated',
      RegisterChangeTypes.removed => '/Removed',
      _ => '/Both',
    };
    return switch (this) {
      1 => '$this ${"/Timeline/Lang/Counters/Attendances$modifier/Singular".localized}', // "lekcja"
      >= 2 && < 5 ||
      _ when this % 10 >= 2 && this % 10 < 5 =>
        '$this ${"/Timeline/Lang/Counters/Attendances$modifier/Plural/Start".localized}', // "lekcje"
      >= 5 && < 22 ||
      _ when (this % 10 >= 5 && this % 10 < 9) || (this % 10 >= 0 && this % 10 < 2) =>
        '$this ${"/Timeline/Lang/Counters/Attendances$modifier/Plural/End".localized}', // "lekcji"
      _ => '$this ${"/Timeline/Lang/Counters/Attendances$modifier/Plural/End".localized}' // "lekcji"
      // Note for other languages:
      // stackoverflow.com/a/76413634
    };
  }
}

extension Pretty on Duration {
  String get prettyBellString => prettyDuration(abs() + Share.session.settings.bellOffset,
      tersity: abs() < Duration(minutes: 1) ? DurationTersity.second : DurationTersity.minute,
      upperTersity: DurationTersity.minute,
      abbreviated: abs() < Duration(minutes: 1),
      conjunction: ', ',
      locale: DurationLocale.fromLanguageCode(Share.settings.appSettings.localeCode) ?? EnglishDurationLocale());
}
