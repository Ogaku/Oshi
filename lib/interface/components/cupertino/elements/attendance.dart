// ignore_for_file: prefer_const_constructors
import 'package:flutter/cupertino.dart';
import 'package:format/format.dart';
import 'package:intl/intl.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:oshi/interface/components/cupertino/application.dart';
import 'package:oshi/interface/shared/containers.dart';
import 'package:oshi/interface/shared/views/message_compose.dart';
import 'package:oshi/models/data/attendances.dart';
import 'package:oshi/share/extensions.dart';
import 'package:oshi/share/share.dart';
import 'package:oshi/share/translator.dart';
import 'package:share_plus/share_plus.dart' as sharing;
import 'package:uuid/uuid.dart';

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
                          subject: '89BEEDA5-3774-4BC0-B827-72D3AA2E31CC'.localized.format(DateFormat("y.M.d").format(date), lessonNo),
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
                                subject: 'CC111EE5-B18F-46EB-A6FF-09E3ABFA1FA1'.localized,
                                message:
                                    '853265A9-1B40-43F2-82B5-E9E238EF8A5B'.localized.format(DateFormat("y.M.dd").format(date), lessonNo),
                                signature:
                                    'F491D698-DFB6-4E62-B100-1546660AB6D1'.localized.format(Share.session.data.student.account.name, Share.session.data.student.mainClass.name)));
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
                            CardContainer(
                                additionalDividerMargin: 5,
                                children: [
                                  AdaptiveCard(
                                      child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(margin: EdgeInsets.only(right: 3), child: Text('/Type'.localized)),
                                      Flexible(
                                          child: Opacity(
                                              opacity: 0.5,
                                              child: Text(type.asStringLong(), maxLines: 2, textAlign: TextAlign.end)))
                                    ],
                                  )),
                                  AdaptiveCard(
                                      child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(margin: EdgeInsets.only(right: 3), child: Text('/AddedBy'.localized)),
                                      Flexible(
                                          child: Opacity(
                                              opacity: 0.5,
                                              child: Text(teacher.name, maxLines: 1, overflow: TextOverflow.ellipsis)))
                                    ],
                                  )),
                                  AdaptiveCard(
                                      child: Row(
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
                                  AdaptiveCard(
                                      child: Row(
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
                                    AdaptiveCard(
                                        child: Row(
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
                                                    lesson.subject?.name ?? 'C1D03748-4568-4AB9-843A-86707294BCA5'.localized,
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
