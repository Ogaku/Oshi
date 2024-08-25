// ignore_for_file: prefer_const_constructors
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:oshi/interface/components/cupertino/application.dart';
import 'package:oshi/interface/shared/containers.dart';
import 'package:oshi/interface/shared/pages/home.dart';
import 'package:oshi/interface/shared/views/grades_detailed.dart';
import 'package:oshi/interface/shared/views/message_compose.dart';
import 'package:oshi/interface/shared/views/new_grade.dart';
import 'package:oshi/models/data/grade.dart';
import 'package:oshi/share/extensions.dart';
import 'package:oshi/share/share.dart';
import 'package:share_plus/share_plus.dart' as sharing;
import 'package:uuid/uuid.dart';

extension GradeBodyExtension on Grade {
  Widget asGrade(BuildContext context, void Function(VoidCallback fn) setState,
          {bool markRemoved = false, bool markModified = false, Function()? onTap, Grade? corrected}) =>
      CupertinoContextMenu.builder(
          enableHapticFeedback: true,
          actions: [
            CupertinoContextMenuAction(
              onPressed: () {
                sharing.Share.share('I got a $value on ${DateFormat("EEEE, MMM d, y").format(date)}!');
                Navigator.of(context, rootNavigator: true).pop();
              },
              trailingIcon: CupertinoIcons.share,
              child: const Text('Share'),
            ),
          ]
              .appendIf(
                  CupertinoContextMenuAction(
                    trailingIcon: CupertinoIcons.pencil,
                    child: const Text('Edit'),
                    onPressed: () {
                      Navigator.of(context, rootNavigator: true).pop();
                      try {
                        showCupertinoModalBottomSheet(
                            context: context,
                            builder: (context) => GradeComposePage(
                                  previous: (grade: this, lesson: customLesson),
                                )).then((value) => setState(() {}));
                      } catch (ex) {
                        // ignored
                      }
                    },
                  ),
                  isOwnGrade)
              .appendIf(
                  CupertinoContextMenuAction(
                    isDestructiveAction: true,
                    trailingIcon: CupertinoIcons.chat_bubble_2,
                    child: const Text('Inquiry'),
                    onPressed: () {
                      Navigator.of(context, rootNavigator: true).pop();
                      showCupertinoModalBottomSheet(
                          context: context,
                          builder: (context) => MessageComposePage(
                              receivers: [addedBy],
                              subject: 'Pytanie o ocenę $value z dnia ${DateFormat("y.M.d").format(addDate)}',
                              signature:
                                  '${Share.session.data.student.account.name}, ${Share.session.data.student.mainClass.name}'));
                    },
                  ),
                  !isOwnGrade)
              .appendIf(
                  CupertinoContextMenuAction(
                    isDestructiveAction: true,
                    trailingIcon: CupertinoIcons.delete,
                    child: const Text('Delete'),
                    onPressed: () {
                      Navigator.of(context, rootNavigator: true).pop();
                      setState(() {
                        Share.session.customGrades[customLesson]?.remove(this);
                        Share.session.customGrades[customLesson]?.removeWhere((x) => x.id != -1 && x.id == id);
                      });
                      Share.settings.save();
                    },
                  ),
                  isOwnGrade),
          builder: (BuildContext context, Animation<double> animation) => Column(
                  children: [
                gradeBody(context, animation: animation, markRemoved: markRemoved, markModified: markModified, onTap: onTap)
              ].appendIf(
                      Container(
                          padding: EdgeInsets.only(left: 20, right: 10, top: 5, bottom: 10),
                          child: corrected?.asGrade(context, setState, markRemoved: true, markModified: true) ?? SizedBox()),
                      corrected != null)));

  Widget gradeBody(BuildContext context,
      {Animation<double>? animation,
      bool markRemoved = false,
      bool markModified = false,
      bool useOnTap = false,
      Function()? onTap,
      Grade? corrected}) {
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
                        child: Table(children: [
                          TableRow(children: [
                            Container(
                                margin: EdgeInsets.only(top: 20, left: 15, right: 15),
                                child: Hero(
                                    tag: tag,
                                    child: gradeBody(context,
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
                                      Container(margin: EdgeInsets.only(right: 3), child: Text('Grade')),
                                      Flexible(
                                          child: Opacity(
                                              opacity: 0.5,
                                              child: Text('$value, weight $weight', maxLines: 2, textAlign: TextAlign.end)))
                                    ],
                                  )),
                                  AdaptiveCard(
                                      child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(margin: EdgeInsets.only(right: 3), child: Text('Added by')),
                                      Flexible(
                                          child: Opacity(
                                              opacity: 0.5,
                                              child: Text(addedBy.name, maxLines: 1, overflow: TextOverflow.ellipsis)))
                                    ],
                                  )),
                                  AdaptiveCard(
                                      child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(margin: EdgeInsets.only(right: 3), child: Text('Date')),
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
                                      Container(margin: EdgeInsets.only(right: 3), child: Text('Added')),
                                      Flexible(
                                          child: Opacity(
                                              opacity: 0.5,
                                              child: Text(
                                                  '${DateFormat.Hm(Share.settings.appSettings.localeCode).format(addDate)}, ${DateFormat.yMMMd(Share.settings.appSettings.localeCode).format(addDate)}',
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis)))
                                    ],
                                  )),
                                ]
                                    .appendIf(
                                        AdaptiveCard(
                                            child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text('Description'),
                                            Flexible(
                                                child: Container(
                                                    margin: EdgeInsets.only(left: 3, top: 5, bottom: 5),
                                                    child: Opacity(
                                                        opacity: 0.5,
                                                        child:
                                                            Text(name.capitalize(), maxLines: 3, textAlign: TextAlign.end))))
                                          ],
                                        )),
                                        name.isNotEmpty)
                                    .appendIf(
                                        AdaptiveCard(
                                            child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text('Comments'),
                                            Flexible(
                                                child: Container(
                                                    margin: EdgeInsets.only(left: 3, top: 5, bottom: 5),
                                                    child: Opacity(
                                                        opacity: 0.5,
                                                        child: Text(commentsString, maxLines: 3, textAlign: TextAlign.end))))
                                          ],
                                        )),
                                        commentsString.isNotEmpty)
                                    .appendIf(
                                        AdaptiveCard(
                                            child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Flexible(
                                                child: Container(
                                                    margin: EdgeInsets.only(right: 3),
                                                    child: Text('Counts to the average'))),
                                            Opacity(opacity: 0.5, child: Text(countsToAverage.toString()))
                                          ],
                                        )),
                                        true))
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
                            value,
                            style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w600,
                                color: asColor(),
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
                                Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Expanded(
                                          child: Opacity(
                                              opacity: name.isNotEmpty ? 1.0 : 0.5,
                                              child: Text(
                                                name.isNotEmpty ? name.capitalize() : 'No description',
                                                textAlign: TextAlign.end,
                                                style: TextStyle(
                                                    fontSize: 17,
                                                    fontWeight: FontWeight.w600,
                                                    fontStyle: markModified ? FontStyle.italic : null,
                                                    decoration: markRemoved ? TextDecoration.lineThrough : null),
                                              ))),
                                      UnreadDot(
                                          unseen: () => unseen, markAsSeen: markAsSeen, margin: EdgeInsets.only(left: 8)),
                                    ]),
                                Visibility(
                                    visible: commentsString.isNotEmpty,
                                    child: Opacity(
                                        opacity: 0.5,
                                        child: Container(
                                            margin: EdgeInsets.only(left: 35, top: 4),
                                            child: Text(
                                              commentsString,
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
                                          detailsDateString,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                          textAlign: TextAlign.end,
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontStyle: markModified ? FontStyle.italic : null,
                                              decoration: markRemoved ? TextDecoration.lineThrough : null),
                                        ))),
                                Visibility(
                                    visible: (animation?.value ?? 0) >= CupertinoContextMenu.animationOpensAt,
                                    child: Opacity(
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
                                            )))),
                              ]))
                    ]))));

    return animation == null ? body : Hero(tag: tag, child: body);
  }
}
