// ignore_for_file: prefer_const_constructors
import 'package:darq/darq.dart';
import 'package:event/event.dart';
import 'package:extended_wrap/extended_wrap.dart';
import 'package:flutter/cupertino.dart';
import 'package:format/format.dart';
import 'package:intl/intl.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:oshi/interface/components/cupertino/widgets/text_chip.dart';
import 'package:oshi/interface/shared/containers.dart';
import 'package:oshi/interface/shared/pages/home.dart';
import 'package:oshi/interface/shared/views/grades_detailed.dart';
import 'package:oshi/interface/shared/views/message_compose.dart';
import 'package:oshi/models/data/event.dart' as data;
import 'package:oshi/models/data/grade.dart';
import 'package:oshi/models/data/lesson.dart';
import 'package:oshi/share/translator.dart';
import 'package:share_plus/share_plus.dart' as sharing;
import 'package:oshi/share/share.dart';
import 'dart:ui' as ui;

extension EventBodyExtension on List<data.Event> {
  List<Widget> asCompactEventList(BuildContext context) => select((x, index) => AdaptiveCard(
      padding: EdgeInsets.only(),
      child: CupertinoContextMenu.builder(
          enableHapticFeedback: true,
          actions: [
            CupertinoContextMenuAction(
              onPressed: () {
                sharing.Share.share('A70900F1-79A1-432D-AC6D-137794074CCE'.localized.format(
                    x.titleString,
                    DateFormat("EEEE, MMM d, y").format(x.timeFrom),
                    (x.classroom?.name.isNotEmpty ?? false)
                        ? ('C33F8288-5BAD-4574-9C53-B54FED6757AC'.localized.format(x.classroom?.name ?? ""))
                        : '55FCBDA9-6905-49C9-A3E8-426058041A8B'.localized));
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
                        subject: 'C834975A-FECF-4FA1-A099-242BC18FB55C'.localized.format(DateFormat("y.M.d").format(x.date ?? x.timeFrom)),
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
                          maxHeight: animation.value < CupertinoContextMenu.animationOpensAt ? double.infinity : 100,
                          maxWidth: animation.value < CupertinoContextMenu.animationOpensAt ? double.infinity : 260),
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                TextChip(
                                    text: DateFormat.Md(Share.settings.appSettings.localeCode).format(x.date ?? x.timeFrom),
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
                                                      color: CupertinoColors.black, darkColor: CupertinoColors.white),
                                                  context)),
                                        ))))
                          ]))))))).toList();

  List<Widget> asCompactHomeworkList(BuildContext context) => select((x, index) => AdaptiveCard(
      padding: EdgeInsets.only(),
      child: CupertinoContextMenu.builder(
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
                            '58F3C0BE-AC60-4176-A06D-CB9B58FE99B6'.localized.format(DateFormat("y.M.d").format(x.timeTo ?? x.date ?? x.timeFrom)),
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
                          .then((arg) => Share.timetableNavigateDay.broadcast(Value(x.timeTo ?? x.date ?? x.timeFrom)));
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
                          maxHeight: animation.value < CupertinoContextMenu.animationOpensAt ? double.infinity : 125,
                          maxWidth: animation.value < CupertinoContextMenu.animationOpensAt ? double.infinity : 260),
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
                                                  margin: EdgeInsets.only(left: 5), child: Icon(CupertinoIcons.check_mark)),
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
                                  ]))))))))).toList();
}

extension GradeBodyExtension on List<({List<Grade> grades, Lesson lesson})> {
  List<Widget> asCompactGradeList(BuildContext context) => select((x, index) => AdaptiveCard(
      padding: EdgeInsets.only(),
      child: CupertinoContextMenu.builder(
          enableHapticFeedback: true,
          actions: [
            CupertinoContextMenuAction(
              onPressed: () {
                sharing.Share.share(
                    '1D35A7A3-301A-48F7-9ACA-C1986E63D1CF'.localized.format(x.grades.select((y, s) => y.value).join(", "), x.lesson.name));
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
                            '7AE5B440-ADC8-49F7-AB1F-3E3CEDD78DC8'.localized.format(x.grades.length > 1 ? 'DA7A5A8C-9A1D-4378-8BC1-AB6A9E2E8B67'.localized : '6D0701F1-1754-4897-9902-B701EB2038CD'.localized, x.grades.select((y, index) => y.value).join(', '), x.lesson.name),
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
                          maxHeight: animation.value < CupertinoContextMenu.animationOpensAt ? double.infinity : 100,
                          maxWidth: animation.value < CupertinoContextMenu.animationOpensAt ? double.infinity : 260),
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
                                                    color: CupertinoColors.black, darkColor: CupertinoColors.white),
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
                                                          color: CupertinoColors.black, darkColor: CupertinoColors.white),
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
                                                            color: (y.isFinalProposition || y.isSemesterProposition)
                                                                ? CupertinoDynamicColor.resolve(
                                                                    CupertinoDynamicColor.withBrightness(
                                                                        color: CupertinoColors.black,
                                                                        darkColor: CupertinoColors.white),
                                                                    context)
                                                                : CupertinoColors.black)),
                                                  ))
                                              .toList())))
                            ],
                          )))))))).toList();
}
