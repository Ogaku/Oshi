// ignore_for_file: prefer_const_constructors
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:format/format.dart';
import 'package:intl/intl.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:oshi/interface/components/cupertino/application.dart';
import 'package:oshi/interface/shared/containers.dart';
import 'package:oshi/interface/shared/input.dart';
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
      AdaptiveMenuButton(
          itemBuilder: (context) => [
                AdaptiveMenuItem(
                  onTap: () {
                    sharing.Share.share('/Page/Absences/Share'.localized.format(type.asPrep(), type.asStringLong(),
                        DateFormat("EEEE, MMM d, y").format(date), lesson.subject?.name, lessonNo));
                  },
                  icon: CupertinoIcons.share,
                  title: '/Share'.localized,
                ),
                AdaptiveMenuItem(
                    icon: CupertinoIcons.chat_bubble_2,
                    title: '/Inquiry'.localized,
                    onTap: () {
                      showMaterialModalBottomSheet(
                          context: context,
                          builder: (context) => MessageComposePage(
                              receivers: [teacher],
                              subject: '89BEEDA5-3774-4BC0-B827-72D3AA2E31CC'
                                  .localized
                                  .format(DateFormat("y.M.d").format(date), lessonNo),
                              signature:
                                  '${Share.session.data.student.account.name}, ${Share.session.data.student.mainClass.name}'));
                    }),
              ].appendIf(
                  AdaptiveMenuItem(
                      icon: CupertinoIcons.doc_on_clipboard,
                      title: 'Excuse',
                      onTap: () {
                        showMaterialModalBottomSheet(
                            context: context,
                            builder: (context) => MessageComposePage(
                                receivers: [Share.session.data.student.mainClass.classTutor],
                                subject: 'CC111EE5-B18F-46EB-A6FF-09E3ABFA1FA1'.localized,
                                message: '853265A9-1B40-43F2-82B5-E9E238EF8A5B'
                                    .localized
                                    .format(DateFormat("y.M.dd").format(date), lessonNo),
                                signature: 'F491D698-DFB6-4E62-B100-1546660AB6D1'.localized.format(
                                    Share.session.data.student.account.name, Share.session.data.student.mainClass.name)));
                        Navigator.of(context).pop();
                      }),
                  type == AttendanceType.absent),
          longPressOnly: true,
          child:
              attendanceBody(context, animation: null, markRemoved: markRemoved, markModified: markModified, onTap: onTap));

  Widget attendanceBody(BuildContext context,
      {Animation<double>? animation,
      bool markRemoved = false,
      bool markModified = false,
      bool useOnTap = false,
      bool disableTap = false,
      Function()? onTap}) {
    var tag = Uuid().v4();
    var body = AdaptiveCard(
        regular: true,
        click: disableTap
            ? null
            : ((useOnTap && onTap != null)
                ? onTap
                : () => showMaterialModalBottomSheet(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    expand: false,
                    context: context,
                    builder: (context) => Table(children: <TableRow>[
                          TableRow(children: [
                            Container(
                                margin: EdgeInsets.only(top: 15, left: 10, right: 10),
                                child: Hero(
                                    tag: tag,
                                    child: attendanceBody(context,
                                        useOnTap: onTap != null,
                                        markRemoved: markRemoved,
                                        markModified: markModified,
                                        disableTap: true,
                                        onTap: onTap)))
                          ]),
                          TableRow(children: [
                            CardContainer(
                                filled: false,
                                additionalDividerMargin: 5,
                                regularOverride: true,
                                children: [
                                  Divider(),
                                  AdaptiveCard(regular: true, child: '/Type'.localized, after: type.asStringLong()),
                                  AdaptiveCard(regular: true, child: '/AddedBy'.localized, after: teacher.name),
                                  AdaptiveCard(
                                    regular: true,
                                    child: '/Date'.localized,
                                    after: DateFormat.yMMMEd(Share.settings.appSettings.localeCode).format(date),
                                  ),
                                  AdaptiveCard(
                                    regular: true,
                                    child: '/Added'.localized,
                                    after:
                                        '${DateFormat.Hm(Share.settings.appSettings.localeCode).format(addDate)}, ${DateFormat.yMMMd(Share.settings.appSettings.localeCode).format(addDate)}',
                                  ),
                                ].appendIf(
                                    AdaptiveCard(
                                      regular: true,
                                      child: '/Lesson'.localized,
                                      after: lesson.subject?.name ?? '',
                                    ),
                                    lesson.subject?.name.isNotEmpty ?? false))
                          ])
                        ]))),
        margin: EdgeInsets.only(left: 15, top: 5, bottom: 5, right: 20),
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                            flex: 2,
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Visibility(
                                      visible: (lesson.subject?.name.isNotEmpty ?? false),
                                      child: Text(
                                        lesson.subject?.name ?? 'C1D03748-4568-4AB9-843A-86707294BCA5'.localized,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 2,
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w400,
                                            fontStyle: markModified ? FontStyle.italic : null,
                                            decoration: markRemoved ? TextDecoration.lineThrough : null),
                                      )),
                                  Opacity(
                                      opacity: 0.5,
                                      child: Container(
                                          margin: EdgeInsets.only(top: 4),
                                          child: Text(
                                            addedDateString,
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                            textAlign: TextAlign.start,
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontStyle: markModified ? FontStyle.italic : null,
                                                decoration: markRemoved ? TextDecoration.lineThrough : null),
                                          )))
                                ])),
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
                      ]))
            ])));

    return animation == null ? body : Hero(tag: tag, child: body);
  }
}
