// ignore_for_file: prefer_const_constructors
// ignore_for_file: prefer_const_literals_to_create_immutables

import 'dart:math';

import 'package:darq/darq.dart';
import 'package:flutter/cupertino.dart';
import 'package:format/format.dart';
import 'package:intl/intl.dart';
import 'package:oshi/interface/cupertino/pages/home.dart';
import 'package:oshi/interface/cupertino/widgets/searchable_bar.dart';
import 'package:oshi/models/data/attendances.dart';
import 'package:oshi/share/share.dart';
import 'package:oshi/share/translator.dart';

import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:oshi/interface/cupertino/views/message_compose.dart';
import 'package:uuid/v4.dart';
import 'package:share_plus/share_plus.dart' as sharing;

// Boiler: returned to the app tab builder
StatefulWidget get absencesPage => AbsencesPage();

class AbsencesPage extends StatefulWidget {
  const AbsencesPage({super.key});

  @override
  State<AbsencesPage> createState() => _AbsencesPageState();
}

class _AbsencesPageState extends State<AbsencesPage> {
  final searchController = TextEditingController();

  String selectedSegment = 'date';
  String? _progressMessage;

  bool showInbox = true;
  bool isWorking = false;

  @override
  Widget build(BuildContext context) {
    // Group by date, I know IT'S A DAMN STRING, but we're saving on custom controls
    var attendancesToDisplayByDate = Share.session.data.student.attendances
            ?.orderByDescending((x) => x.date)
            .groupBy((x) => DateFormat('EEEE, d MMMM y').format(x.date))
            .toList() ??
        [];

    // Group by subjects, or at least what we can access right now
    var attendancesToDisplayByLesson = Share.session.data.student.attendances
            ?.orderByDescending((x) => x.date)
            .groupBy((x) => x.lesson.subject?.name ?? 'Unknown subject')
            .select((x, index) => Grouping(
                x.elements,
                "${x.key}\n${(100 * x.elements.where((y) => y.type == AttendanceType.present).count() / x.elements.count()).round()}%",
                Random().nextInt(100)))
            .orderBy((x) => x.key)
            .toList() ??
        [];

    // Group by type, try to show absences first
    var attendancesToDisplayByType = Share.session.data.student.attendances
            ?.orderByDescending((x) => x.date)
            .groupBy((x) => x.type.asStringLong())
            .orderBy((x) => x.key)
            .toList() ??
        [];

    // This is gonna be a veeery long list, as there are no expanders in cupertino
    var attendanceWidgets = (switch (selectedSegment) {
      'date' => attendancesToDisplayByDate,
      'lesson' => attendancesToDisplayByLesson,
      'type' => attendancesToDisplayByType,
      _ => attendancesToDisplayByDate
    })
        .select((element, index) => CupertinoListSection.insetGrouped(
              margin: EdgeInsets.only(left: 15, right: 15, bottom: 10),
              header: element.key.contains('\n')
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Flexible(child: Text(element.key.split('\n').first, maxLines: 1, overflow: TextOverflow.ellipsis)),
                        Container(
                            margin: EdgeInsets.only(left: 3),
                            child: Text(element.key.split('\n').last,
                                style: TextStyle(
                                    color: CupertinoColors.inactiveGray, fontWeight: FontWeight.w400, fontSize: 16)))
                      ],
                    )
                  : Text(element.key),
              additionalDividerMargin: 5,
              children: element.isEmpty
                  // No messages to display
                  ? [
                      CupertinoListTile(
                          title: Opacity(
                              opacity: 0.5,
                              child: Container(
                                  alignment: Alignment.center,
                                  child: Text(
                                    '/Page/Absences/No'.localized,
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
                                  ))))
                    ]
                  // Bindable messages layout
                  : element
                      .select(
                          (x, index) => CupertinoListTile(padding: EdgeInsets.all(0), title: x.asAttendanceWidget(context)))
                      .toList(),
            ))
        .toList();

    return SearchableSliverNavigationBar(
        setState: setState,
        segments: {'date': 'By date', 'lesson': 'By lesson', 'type': 'By type'},
        largeTitle: Text('/Page/Absences/Attendance'.localized),
        middle: Visibility(visible: _progressMessage?.isEmpty ?? true, child: Text('/Page/Absences/Attendance'.localized)),
        onProgress: (progress) => setState(() => _progressMessage = progress?.message),
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
                      style: TextStyle(color: CupertinoColors.inactiveGray, fontSize: 13),
                    )))),
        searchController: searchController,
        onChanged: (s) => setState(() => selectedSegment = s),
        trailing: isWorking
            ? Container(margin: EdgeInsets.only(right: 5, top: 5), child: CupertinoActivityIndicator(radius: 12))
            : null,
        children: attendanceWidgets);
  }
}

extension AttendanceTypeExtension on AttendanceType {
  String asString() => switch (this) {
        AttendanceType.absent => 'nb',
        AttendanceType.late => 'sp',
        AttendanceType.excused => 'u',
        AttendanceType.duty => 'zw',
        AttendanceType.present => 'ob',
        AttendanceType.other => 'in',
      };

  String asStringLong() => switch (this) {
        AttendanceType.absent => '/Absence'.localized,
        AttendanceType.late => '/Late'.localized,
        AttendanceType.excused => '/Excused'.localized,
        AttendanceType.duty => '/Duty'.localized,
        AttendanceType.present => '/Presence'.localized,
        AttendanceType.other => '/Other'.localized,
      };

  String asPrep() => switch (this) {
        AttendanceType.absent => '/an'.localized,
        AttendanceType.late => '/a'.localized,
        AttendanceType.excused => '/an'.localized,
        AttendanceType.duty => '/a'.localized,
        AttendanceType.present => '/a'.localized,
        AttendanceType.other => '/an'.localized,
      };

  Color asColor() => switch (this) {
        AttendanceType.absent => CupertinoColors.systemRed,
        AttendanceType.late => CupertinoColors.systemYellow,
        AttendanceType.excused => CupertinoColors.systemTeal,
        AttendanceType.duty => CupertinoColors.systemIndigo,
        AttendanceType.present => CupertinoColors.systemGreen,
        AttendanceType.other => CupertinoColors.inactiveGray,
      };
}

extension LessonWidgetExtension on Attendance {
  Widget asAttendanceWidget(BuildContext context,
          {bool markRemoved = false, bool markModified = false, Function()? onTap}) =>
      CupertinoContextMenu.builder(
          enableHapticFeedback: true,
          actions: [
            CupertinoContextMenuAction(
              onPressed: () {
                sharing.Share.share('/Page/Absences/Share'.localized.format(type.asPrep(), type.asStringLong(),
                    DateFormat("EEEE, MMM d, y").format(date), lesson.subject?.name, lessonNo));
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
                          receivers: [teacher],
                          subject: 'Pytanie o obecność z dnia ${DateFormat("y.M.d").format(date)}, L$lessonNo',
                          signature:
                              '${Share.session.data.student.account.name}, ${Share.session.data.student.mainClass.name}'));
                }),
          ],
          builder: (BuildContext context, Animation<double> animation) => attendanceBody(context,
              animation: animation, markRemoved: markRemoved, markModified: markModified, onTap: onTap));

  Widget attendanceBody(BuildContext context,
      {Animation<double>? animation,
      bool markRemoved = false,
      bool markModified = false,
      bool useOnTap = false,
      Function()? onTap}) {
    var tag = UuidV4().generate();
    var body = GestureDetector(
        onTap: (useOnTap && onTap != null)
            ? onTap
            : (animation == null || animation.value >= CupertinoContextMenu.animationOpensAt)
                ? null
                : () => showCupertinoModalBottomSheet(
                    expand: false,
                    context: context,
                    builder: (context) => Container(
                        color: CupertinoDynamicColor.resolve(
                            CupertinoDynamicColor.withBrightness(
                                color: const Color.fromARGB(255, 242, 242, 247),
                                darkColor: const Color.fromARGB(255, 28, 28, 30)),
                            context),
                        child: Table(children: <TableRow>[
                          TableRow(children: [
                            Container(
                                margin: EdgeInsets.only(top: 20, left: 15, right: 15),
                                child: Hero(
                                    tag: tag,
                                    child: attendanceBody(context,
                                        useOnTap: onTap != null,
                                        markRemoved: markRemoved,
                                        markModified: markModified,
                                        onTap: onTap)))
                          ]),
                          TableRow(children: [
                            CupertinoListSection.insetGrouped(
                                margin: EdgeInsets.only(top: 20, left: 15, right: 15, bottom: 15),
                                additionalDividerMargin: 5,
                                children: [
                                  CupertinoListTile(
                                      title: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(margin: EdgeInsets.only(right: 3), child: Text('Type')),
                                      Flexible(
                                          child: Opacity(
                                              opacity: 0.5,
                                              child: Text(type.asStringLong(), maxLines: 2, textAlign: TextAlign.end)))
                                    ],
                                  )),
                                  CupertinoListTile(
                                      title: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(margin: EdgeInsets.only(right: 3), child: Text('Added by')),
                                      Flexible(
                                          child: Opacity(
                                              opacity: 0.5,
                                              child: Text(teacher.name, maxLines: 1, overflow: TextOverflow.ellipsis)))
                                    ],
                                  )),
                                  CupertinoListTile(
                                      title: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(margin: EdgeInsets.only(right: 3), child: Text('Date')),
                                      Flexible(
                                          child: Opacity(
                                              opacity: 0.5,
                                              child: Text(DateFormat('EEE, d MMM y').format(date),
                                                  maxLines: 1, overflow: TextOverflow.ellipsis)))
                                    ],
                                  )),
                                  CupertinoListTile(
                                      title: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(margin: EdgeInsets.only(right: 3), child: Text('Added')),
                                      Flexible(
                                          child: Opacity(
                                              opacity: 0.5,
                                              child: Text(DateFormat('hh:mm a, d MMM y').format(addDate),
                                                  maxLines: 1, overflow: TextOverflow.ellipsis)))
                                    ],
                                  )),
                                ].appendIf(
                                    CupertinoListTile(
                                        title: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('/Lesson'.localized),
                                        Flexible(
                                            child: Container(
                                                margin: EdgeInsets.only(left: 3, top: 5, bottom: 5),
                                                child: Opacity(
                                                    opacity: 0.5,
                                                    child: Text(lesson.subject?.name ?? '',
                                                        maxLines: 3, textAlign: TextAlign.end))))
                                      ],
                                    )),
                                    lesson.subject?.name.isNotEmpty ?? false))
                          ])
                        ]))),
        child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                color: (animation == null ||
                        animation.value >= CupertinoContextMenu.animationOpensAt ||
                        markModified ||
                        markRemoved ||
                        onTap != null)
                    ? CupertinoDynamicColor.resolve(CupertinoColors.tertiarySystemBackground, context)
                    : CupertinoDynamicColor.resolve(
                        CupertinoDynamicColor.withBrightness(
                            color: const Color.fromARGB(255, 255, 255, 255),
                            darkColor: const Color.fromARGB(255, 28, 28, 30)),
                        context)),
            padding: EdgeInsets.only(top: 15, bottom: 15, right: 15, left: 20),
            child: ConstrainedBox(
                constraints: BoxConstraints(
                    maxHeight: (animation?.value ?? 0) < CupertinoContextMenu.animationOpensAt ? double.infinity : 150,
                    maxWidth: (animation?.value ?? 0) < CupertinoContextMenu.animationOpensAt ? double.infinity : 250),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                          padding: EdgeInsets.only(bottom: 5),
                          child: Text(
                            type.asString(),
                            style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w600,
                                color: type.asColor(),
                                fontStyle: markModified ? FontStyle.italic : null,
                                decoration: markRemoved ? TextDecoration.lineThrough : null),
                          )),
                      Expanded(
                          flex: 2,
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Visibility(
                                    visible: (lesson.subject?.name.isNotEmpty ?? false),
                                    child: Opacity(
                                        opacity: 0.5,
                                        child: Container(
                                            margin: EdgeInsets.only(left: 35, top: 4),
                                            child: Text(
                                              lesson.subject?.name ?? 'Unknown lesson',
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 2,
                                              textAlign: TextAlign.end,
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  fontStyle: markModified ? FontStyle.italic : null,
                                                  decoration: markRemoved ? TextDecoration.lineThrough : null),
                                            )))),
                                Opacity(
                                    opacity: 0.5,
                                    child: Container(
                                        margin: EdgeInsets.only(top: 4),
                                        child: Text(
                                          addedDateString,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                          textAlign: TextAlign.end,
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontStyle: markModified ? FontStyle.italic : null,
                                              decoration: markRemoved ? TextDecoration.lineThrough : null),
                                        )))
                              ]))
                    ]))));

    return animation == null ? body : Hero(tag: tag, child: body);
  }
}
