// ignore_for_file: prefer_const_constructors
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:oshi/interface/components/cupertino/application.dart';
import 'package:oshi/interface/shared/containers.dart';
import 'package:oshi/interface/shared/input.dart';
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
      AdaptiveMenuButton(
          itemBuilder: (context) => [
                AdaptiveMenuItem(
                  onTap: () => sharing.Share.share('I got a $value on ${DateFormat("EEEE, MMM d, y").format(date)}!'),
                  icon: CupertinoIcons.share,
                  title: 'Share',
                ),
              ]
                  .appendIf(
                      AdaptiveMenuItem(
                        icon: CupertinoIcons.pencil,
                        title: 'Edit',
                        onTap: () {
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
                      AdaptiveMenuItem(
                        icon: CupertinoIcons.chat_bubble_2,
                        title: 'Inquiry',
                        onTap: () => showCupertinoModalBottomSheet(
                            context: context,
                            builder: (context) => MessageComposePage(
                                receivers: [addedBy],
                                subject: 'Pytanie o ocenę $value z dnia ${DateFormat("y.M.d").format(addDate)}',
                                signature:
                                    '${Share.session.data.student.account.name}, ${Share.session.data.student.mainClass.name}')),
                      ),
                      !isOwnGrade)
                  .appendIf(
                      AdaptiveMenuItem(
                        icon: CupertinoIcons.delete,
                        title: 'Delete',
                        onTap: () {
                          setState(() {
                            Share.session.customGrades[customLesson]?.remove(this);
                            Share.session.customGrades[customLesson]?.removeWhere((x) => x.id != -1 && x.id == id);
                          });
                          Share.settings.save();
                        },
                      ),
                      isOwnGrade),
          longPressOnly: true,
          child: Column(
              children: [
            gradeBody(context, animation: null, markRemoved: markRemoved, markModified: markModified, onTap: onTap),
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
      bool disableTap = false,
      Grade? corrected}) {
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
                    builder: (context) => Table(children: [
                          TableRow(children: [
                            Container(
                                margin: EdgeInsets.only(top: 15, left: 10, right: 10),
                                child: Hero(
                                    tag: tag,
                                    child: gradeBody(context,
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
                                  AdaptiveCard(
                                    regular: true,
                                    child: 'Grade',
                                    after: '$value, weight $weight',
                                  ),
                                  AdaptiveCard(
                                    regular: true,
                                    child: 'Added by',
                                    after: addedBy.name,
                                  ),
                                  AdaptiveCard(
                                    regular: true,
                                    child: 'Date',
                                    after: DateFormat.yMMMEd(Share.settings.appSettings.localeCode).format(date),
                                  ),
                                  AdaptiveCard(
                                    regular: true,
                                    child: 'Added',
                                    after:
                                        '${DateFormat.Hm(Share.settings.appSettings.localeCode).format(addDate)}, ${DateFormat.yMMMd(Share.settings.appSettings.localeCode).format(addDate)}',
                                  ),
                                ]
                                    .appendIf(
                                        AdaptiveCard(
                                          regular: true,
                                          child: 'Description',
                                          after: name.capitalize(),
                                        ),
                                        name.isNotEmpty)
                                    .appendIf(
                                        AdaptiveCard(
                                          regular: true,
                                          child: 'Comments',
                                          after: commentsString,
                                        ),
                                        commentsString.isNotEmpty)
                                    .appendIf(
                                        AdaptiveCard(
                                            regular: true,
                                            child: 'Counts to the average',
                                            after: countsToAverage.toString()),
                                        true))
                          ])
                        ]))),
        margin: EdgeInsets.only(left: 15, top: 5, bottom: 5, right: 20),
        child: ConstrainedBox(
            constraints: BoxConstraints(
                maxHeight: (animation?.value ?? 0) < CupertinoContextMenu.animationOpensAt ? double.infinity : 150,
                maxWidth: (animation?.value ?? 0) < CupertinoContextMenu.animationOpensAt ? double.infinity : 250),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                      flex: 2,
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
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
                                            textAlign: TextAlign.start,
                                            style: TextStyle(
                                                fontSize: 17,
                                                fontWeight: FontWeight.w600,
                                                fontStyle: markModified ? FontStyle.italic : null,
                                                decoration: markRemoved ? TextDecoration.lineThrough : null),
                                          ))),
                                  UnreadDot(unseen: () => unseen, markAsSeen: markAsSeen, margin: EdgeInsets.only(left: 8)),
                                ]),
                            Visibility(
                                visible: commentsString.isNotEmpty,
                                child: Opacity(
                                    opacity: 0.5,
                                    child: Container(
                                        margin: EdgeInsets.only(right: 35, top: 4),
                                        child: Text(
                                          commentsString,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 2,
                                          textAlign: TextAlign.start,
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
                                      textAlign: TextAlign.start,
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
                                          textAlign: TextAlign.start,
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontStyle: markModified ? FontStyle.italic : null,
                                              decoration: markRemoved ? TextDecoration.lineThrough : null),
                                        )))),
                          ])),
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
                      ))
                ])));

    return animation == null ? body : Hero(tag: tag, child: body);
  }
}
