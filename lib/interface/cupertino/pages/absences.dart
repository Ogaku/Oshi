// ignore_for_file: prefer_const_constructors
// ignore_for_file: prefer_const_literals_to_create_immutables

import 'dart:math';

import 'package:darq/darq.dart';
import 'package:flutter/cupertino.dart';
import 'package:format/format.dart';
import 'package:intl/intl.dart';
import 'package:oshi/interface/cupertino/base_app.dart';
import 'package:oshi/interface/cupertino/pages/home.dart';
import 'package:oshi/interface/cupertino/widgets/searchable_bar.dart';
import 'package:oshi/models/data/attendances.dart';
import 'package:oshi/share/share.dart';
import 'package:oshi/share/translator.dart';

import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:oshi/interface/cupertino/views/message_compose.dart';
import 'package:pull_down_button/pull_down_button.dart';
import 'package:share_plus/share_plus.dart' as sharing;
import 'package:uuid/uuid.dart';

// Boiler: returned to the app tab builder
StatefulWidget get absencesPage => AbsencesPage();

class AbsencesPage extends StatefulWidget {
  const AbsencesPage({super.key});

  @override
  State<AbsencesPage> createState() => _AbsencesPageState();
}

class _AbsencesPageState extends State<AbsencesPage> {
  final searchController = TextEditingController();
  SegmentController segmentController = SegmentController(segment: AbsencesPageSegments.date);

  bool showInbox = true;
  bool isWorking = false;

  @override
  void dispose() {
    Share.refreshAll.unsubscribe(refresh);
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

    // Group by date, I know IT'S A DAMN STRING, but we're saving on custom controls
    var attendancesToDisplayByDate = Share.session.data.student.attendances
            ?.orderByDescending((x) => x.date)
            .groupBy((x) => DateFormat.yMMMMEEEEd(Share.settings.appSettings.localeCode).format(x.date))
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
    var attendances = (switch (segmentController.segment) {
      AbsencesPageSegments.lesson => attendancesToDisplayByLesson,
      AbsencesPageSegments.type => attendancesToDisplayByType,
      AbsencesPageSegments.date || _ => attendancesToDisplayByDate
    });

    return SearchableSliverNavigationBar(
        setState: setState,
        alwaysShowAddons: true,
        segments: {
          AbsencesPageSegments.date: '/ByDate'.localized,
          AbsencesPageSegments.lesson: '/ByLesson'.localized,
          AbsencesPageSegments.type: '/ByType'.localized
        },
        largeTitle: Text('/Page/Absences/Attendance'.localized),
        middle: Text('/Page/Absences/Attendance'.localized),
        searchController: searchController,
        segmentController: segmentController,
        trailing: isWorking
            ? Container(margin: EdgeInsets.only(right: 5, top: 5), child: CupertinoActivityIndicator(radius: 12))
            : PullDownButton(
                itemBuilder: (context) => [
                  PullDownMenuItem(
                    title: 'Mark as read',
                    icon: CupertinoIcons.checkmark_circle,
                    onTap: () => Share.session.unreadChanges.markAsRead(attendaceOnly: true),
                  ),
                  PullDownMenuItem(
                    title: 'Excuse all',
                    icon: CupertinoIcons.doc_on_clipboard,
                    onTap: () {
                      if (Share.session.data.student.attendances?.isEmpty ?? true) return;
                      showCupertinoModalBottomSheet(
                          context: context,
                          builder: (context) => MessageComposePage(
                              receivers: [Share.session.data.student.mainClass.classTutor],
                              subject: 'Usprawiedliwienie',
                              message:
                                  'Dzień dobry,\n\nProszę o usprawiedliwienie moich nieobencości w dniach:\n${Share.session.data.student.attendances!.where((x) => x.type == AttendanceType.absent).groupBy((x) => x.date).select((x, index) => ' - ${DateFormat("y.M.dd").format(x.key)} (${x.count > 1 ? '${x.orderBy((x) => x.lessonNo).first.lessonNo} - ${x.orderBy((x) => x.lessonNo).last.lessonNo} godzina lekcyjna' : '${x.first.lessonNo} godzina lekcyjna'}) \n').join()}',
                              signature:
                                  'Dziękuję,\n\nZ poważaniem,\n${Share.session.data.student.account.name}, ${Share.session.data.student.mainClass.name}'));
                    },
                  ),
                ],
                buttonBuilder: (context, showMenu) => GestureDetector(
                  onTap: showMenu,
                  child: const Icon(CupertinoIcons.ellipsis_circle),
                ),
              ),
        useSliverBox: true,
        children: [
          ListView.builder(
            shrinkWrap: true,
            primary: false,
            physics: NeverScrollableScrollPhysics(),
            itemCount: attendances.count(),
            itemBuilder: (BuildContext context, int index) => CupertinoListSection.insetGrouped(
              margin: EdgeInsets.only(left: 15, right: 15, bottom: 10),
              header: attendances[index].key.contains('\n')
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Flexible(
                            child: Text(attendances[index].key.split('\n').first,
                                maxLines: 1, overflow: TextOverflow.ellipsis)),
                        Container(
                            margin: EdgeInsets.only(left: 3),
                            child: Text(attendances[index].key.split('\n').last,
                                style: TextStyle(
                                    color: CupertinoColors.inactiveGray, fontWeight: FontWeight.w400, fontSize: 16)))
                      ],
                    )
                  : Text(attendances[index].key),
              additionalDividerMargin: 5,
              children: attendances[index].isEmpty
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
                  : attendances[index]
                      .select(
                          (x, index) => CupertinoListTile(padding: EdgeInsets.all(0), title: x.asAttendanceWidget(context)))
                      .toList(),
            ),
          ),
        ]);
  }
}

enum AbsencesPageSegments { date, lesson, type }

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
          ]
              .appendIf(
                  CupertinoContextMenuAction(
                      isDestructiveAction: true,
                      trailingIcon: CupertinoIcons.doc_on_clipboard,
                      child: Text('Excuse'),
                      onPressed: () {
                        Navigator.of(context, rootNavigator: true).pop();
                        showCupertinoModalBottomSheet(
                            context: context,
                            builder: (context) => MessageComposePage(
                                receivers: [Share.session.data.student.mainClass.classTutor],
                                subject: 'Usprawiedliwienie',
                                message:
                                    'Dzień dobry,\n\nProszę o usprawiedliwienie mojej nieobencości\nw dniu ${DateFormat("y.M.dd").format(date)} na $lessonNo godzinie lekcyjnej.',
                                signature:
                                    'Dziękuję,\n\nZ poważaniem,\n${Share.session.data.student.account.name}, ${Share.session.data.student.mainClass.name}'));
                      }),
                  type == AttendanceType.absent)
              .toList(),
          builder: (BuildContext context, Animation<double> animation) => attendanceBody(context,
              animation: animation, markRemoved: markRemoved, markModified: markModified, onTap: onTap));

  Widget attendanceBody(BuildContext context,
      {Animation<double>? animation,
      bool markRemoved = false,
      bool markModified = false,
      bool useOnTap = false,
      Function()? onTap}) {
    var tag = Uuid().v4();
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
                                      Container(margin: EdgeInsets.only(right: 3), child: Text('/Type'.localized)),
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
                                      Container(margin: EdgeInsets.only(right: 3), child: Text('/AddedBy'.localized)),
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
                                      Container(margin: EdgeInsets.only(right: 3), child: Text('/Date'.localized)),
                                      Flexible(
                                          child: Opacity(
                                              opacity: 0.5,
                                              child: Text(
                                                  DateFormat.yMMMEd(Share.settings.appSettings.localeCode).format(date),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis)))
                                    ],
                                  )),
                                  CupertinoListTile(
                                      title: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(margin: EdgeInsets.only(right: 3), child: Text('/Added'.localized)),
                                      Flexible(
                                          child: Opacity(
                                              opacity: 0.5,
                                              child: Text(
                                                  '${DateFormat.Hm(Share.settings.appSettings.localeCode).format(addDate)}, ${DateFormat.yMMMd(Share.settings.appSettings.localeCode).format(addDate)}',
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis)))
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
            padding: EdgeInsets.only(top: 10, bottom: 15, right: 15, left: 10),
            child: ConstrainedBox(
                constraints: BoxConstraints(
                    maxHeight: (animation?.value ?? 0) < CupertinoContextMenu.animationOpensAt ? double.infinity : 150,
                    maxWidth: (animation?.value ?? 0) < CupertinoContextMenu.animationOpensAt ? double.infinity : 250),
                child: Stack(alignment: Alignment.topLeft, children: [
                  UnreadDot(unseen: () => unseen, markAsSeen: markAsSeen),
                  Container(
                      padding: EdgeInsets.only(top: 5, left: 10),
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
                          ]))
                ]))));

    return animation == null ? body : Hero(tag: tag, child: body);
  }
}
