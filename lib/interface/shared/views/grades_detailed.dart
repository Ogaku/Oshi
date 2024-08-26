// ignore_for_file: prefer_const_constructors
// ignore_for_file: prefer_const_literals_to_create_immutables

import 'package:darq/darq.dart';
import 'package:enum_flag/enum_flag.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:oshi/interface/components/cupertino/application.dart';
import 'package:oshi/interface/components/shim/elements/grade.dart';
import 'package:oshi/interface/shared/containers.dart';
import 'package:oshi/interface/shared/views/message_compose.dart';
import 'package:oshi/interface/components/shim/application_data_page.dart';
import 'package:oshi/models/data/lesson.dart';
import 'package:oshi/share/extensions.dart';
import 'package:oshi/share/resources.dart';
import 'package:oshi/share/share.dart';
import 'package:share_plus/share_plus.dart' as sharing;

class GradesDetailedPage extends StatefulWidget {
  const GradesDetailedPage({super.key, required this.lesson});

  final Lesson lesson;

  @override
  State<GradesDetailedPage> createState() => _GradesDetailedPageState();
}

class _GradesDetailedPageState extends State<GradesDetailedPage> {
  Widget gradesWidget([String query = '', bool filled = true]) {
    var gradesToDisplay = widget.lesson.allGrades
        .where((x) => x.semester == 2)
        .appendAllIfEmpty(widget.lesson.allGrades)
        .where((x) => !x.major)
        .where((x) =>
            x.name.contains(RegExp(query, caseSensitive: false)) ||
            x.detailsDateString.contains(RegExp(query, caseSensitive: false)) ||
            x.commentsString.contains(RegExp(query, caseSensitive: false)) ||
            x.addedByString.contains(RegExp(query, caseSensitive: false)))
        .orderByDescending((x) => x.addDate)
        .distinct((x) => mapPropsToHashCode([x.resitPart ? 0 : UniqueKey(), x.name]))
        .toList();

    return CardContainer(
      additionalDividerMargin: 5,
      filled: false,
      regularOverride: true,
      children: gradesToDisplay.isEmpty
          // No messages to display
          ? [
              AdaptiveCard(
                centered: true,
                secondary: true,
                child: query.isNotEmpty ? 'No grades matching the query' : 'No grades',
              )
            ]
          // Bindable messages layout
          : gradesToDisplay
              .select((x, index) {
                return AdaptiveCard(
                    child: x.asGrade(context, setState,
                        corrected: widget.lesson.allGrades.firstWhereOrDefault(
                            (y) => x.resitPart && y.resitPart && y.name == x.name && x != y,
                            defaultValue: null)));
              })
              .toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    var secondSemester = widget.lesson.allGrades.any((x) => x.semester == 2 || x.isFinal || x.isFinalProposition);
    var gradesBottomWidgets = <Widget>[].appendIf(
        // Average (yearly)
        Visibility(
            visible: widget.lesson.gradesAverage >= 0,
            child: AdaptiveCard(
                child: CupertinoContextMenu.builder(
                    enableHapticFeedback: true,
                    actions: [
                      CupertinoContextMenuAction(
                        onPressed: () {
                          sharing.Share.share('My average from ${widget.lesson.name} is ${widget.lesson.gradesAverage}!');
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
                                  receivers: [widget.lesson.teacher],
                                  subject: 'Pytanie o średnią ocen z przedmiotu ${widget.lesson.name}',
                                  signature:
                                      '${Share.session.data.student.account.name}, ${Share.session.data.student.mainClass.name}'));
                        },
                      ),
                    ],
                    builder: (BuildContext context, Animation<double> animation) {
                      return Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(10)),
                              color: CupertinoDynamicColor.resolve(
                                  CupertinoDynamicColor.withBrightness(
                                      color: const Color.fromARGB(255, 255, 255, 255),
                                      darkColor: const Color.fromARGB(255, 28, 28, 30)),
                                  context)),
                          padding: EdgeInsets.only(top: 18, bottom: 15, right: 15, left: 20),
                          child: ConstrainedBox(
                              constraints: BoxConstraints(
                                  maxHeight: animation.value < CupertinoContextMenu.animationOpensAt ? double.infinity : 100,
                                  maxWidth: animation.value < CupertinoContextMenu.animationOpensAt ? double.infinity : 250),
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                        padding: EdgeInsets.only(bottom: 5),
                                        child: Text(
                                          'Average',
                                          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                                        )),
                                    Container(
                                        padding: EdgeInsets.only(bottom: 5),
                                        child: Text(
                                          widget.lesson.gradesAverage.toStringAsFixed(2),
                                          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                                        )),
                                  ])));
                    }))),
        secondSemester);

    var gradesSemesterBottomWidgets = <Widget>[
      // Average (1st semester)
      Visibility(
          visible: widget.lesson.gradesSemAverage >= 0,
          child: AdaptiveCard(
              child: CupertinoContextMenu.builder(
                  enableHapticFeedback: true,
                  actions: [
                    CupertinoContextMenuAction(
                      onPressed: () {
                        sharing.Share.share(
                            'My 1st semester average from ${widget.lesson.name} is ${widget.lesson.gradesSemAverage}!');
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
                                receivers: [widget.lesson.teacher],
                                subject: 'Pytanie o średnią ocen z pierwszego semestru z przedmiotu ${widget.lesson.name}',
                                signature:
                                    '${Share.session.data.student.account.name}, ${Share.session.data.student.mainClass.name}'));
                      },
                    ),
                  ],
                  builder: (BuildContext context, Animation<double> animation) {
                    return Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            color: CupertinoDynamicColor.resolve(
                                CupertinoDynamicColor.withBrightness(
                                    color: const Color.fromARGB(255, 255, 255, 255),
                                    darkColor: const Color.fromARGB(255, 28, 28, 30)),
                                context)),
                        padding: EdgeInsets.only(top: 18, bottom: 15, right: 15, left: 20),
                        child: ConstrainedBox(
                            constraints: BoxConstraints(
                                maxHeight: animation.value < CupertinoContextMenu.animationOpensAt ? double.infinity : 100,
                                maxWidth: animation.value < CupertinoContextMenu.animationOpensAt ? double.infinity : 250),
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                      padding: EdgeInsets.only(bottom: 5),
                                      child: Text(
                                        'Semester average',
                                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                                      )),
                                  Container(
                                      padding: EdgeInsets.only(bottom: 5),
                                      child: Text(
                                        widget.lesson.gradesSemAverage.toStringAsFixed(2),
                                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                                      )),
                                ])));
                  })))
    ];

    // Proposed grade (2nd semester / year)
    if (widget.lesson.allGrades
            .firstWhereOrDefault((x) => x.isFinalProposition || (x.isSemesterProposition && x.semester == 2))
            ?.value !=
        null) {
      gradesBottomWidgets.add(AdaptiveCard(
          child: CupertinoContextMenu.builder(
              enableHapticFeedback: true,
              actions: [
                CupertinoContextMenuAction(
                  onPressed: () {
                    sharing.Share.share(
                        'I got a ${widget.lesson.allGrades.firstWhereOrDefault((x) => x.isFinalProposition || (x.semester == 2 && x.isSemesterProposition))?.value} proposition from ${widget.lesson.name}!');
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
                            receivers: [widget.lesson.teacher],
                            subject: 'Pytanie o ocenę proponowaną z przedmiotu ${widget.lesson.name}',
                            signature:
                                '${Share.session.data.student.account.name}, ${Share.session.data.student.mainClass.name}'));
                  },
                ),
              ],
              builder: (BuildContext context, Animation<double> animation) {
                return Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        color: CupertinoDynamicColor.resolve(
                            CupertinoDynamicColor.withBrightness(
                                color: const Color.fromARGB(255, 255, 255, 255),
                                darkColor: const Color.fromARGB(255, 28, 28, 30)),
                            context)),
                    padding: EdgeInsets.only(top: 15, bottom: 15, right: 15, left: 20),
                    child: ConstrainedBox(
                        constraints: BoxConstraints(
                            maxHeight: animation.value < CupertinoContextMenu.animationOpensAt ? double.infinity : 100,
                            maxWidth: animation.value < CupertinoContextMenu.animationOpensAt ? double.infinity : 250),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    UnreadDot(
                                        unseen: () => widget.lesson.allGrades.any((x) =>
                                            (x.isFinalProposition || (x.semester == 2 && x.isSemesterProposition)) &&
                                            x.unseen),
                                        markAsSeen: () => widget.lesson.allGrades
                                            .where(
                                                (x) => x.isFinalProposition || (x.semester == 2 && x.isSemesterProposition))
                                            .forEach((x) => x.markAsSeen()),
                                        margin: EdgeInsets.only(right: 8)),
                                    Text(
                                      'Proposed grade',
                                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                                    ),
                                  ]),
                              Text(
                                widget.lesson.allGrades
                                        .firstWhereOrDefault(
                                            (x) => x.isFinalProposition || (x.semester == 2 && x.isSemesterProposition))
                                        ?.value
                                        .toString() ??
                                    'Unknown',
                                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                              ),
                            ])));
              })));
    }

    // Proposed grade (1st semester)
    if (widget.lesson.allGrades.firstWhereOrDefault((x) => x.isSemesterProposition && x.semester == 1)?.value != null) {
      gradesSemesterBottomWidgets.add(AdaptiveCard(
          child: CupertinoContextMenu.builder(
              enableHapticFeedback: true,
              actions: [
                CupertinoContextMenuAction(
                  onPressed: () {
                    sharing.Share.share(
                        'I got a ${widget.lesson.allGrades.firstWhereOrDefault((x) => x.isSemesterProposition && x.semester == 1)?.value} semester proposition from ${widget.lesson.name}!');
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
                            receivers: [widget.lesson.teacher],
                            subject: 'Pytanie o ocenę proponowaną na semestr 1 z przedmiotu ${widget.lesson.name}',
                            signature:
                                '${Share.session.data.student.account.name}, ${Share.session.data.student.mainClass.name}'));
                  },
                ),
              ],
              builder: (BuildContext context, Animation<double> animation) {
                return Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        color: CupertinoDynamicColor.resolve(
                            CupertinoDynamicColor.withBrightness(
                                color: const Color.fromARGB(255, 255, 255, 255),
                                darkColor: const Color.fromARGB(255, 28, 28, 30)),
                            context)),
                    padding: EdgeInsets.only(top: 15, bottom: 15, right: 15, left: 20),
                    child: ConstrainedBox(
                        constraints: BoxConstraints(
                            maxHeight: animation.value < CupertinoContextMenu.animationOpensAt ? double.infinity : 100,
                            maxWidth: animation.value < CupertinoContextMenu.animationOpensAt ? double.infinity : 250),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    UnreadDot(
                                        unseen: () => widget.lesson.allGrades
                                            .any((x) => (x.isSemesterProposition && x.semester == 1) && x.unseen),
                                        markAsSeen: () => widget.lesson.allGrades
                                            .where((x) => x.isSemesterProposition && x.semester == 1)
                                            .forEach((x) => x.markAsSeen()),
                                        margin: EdgeInsets.only(right: 8)),
                                    Text(
                                      'Proposed grade',
                                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                                    ),
                                  ]),
                              Text(
                                widget.lesson.allGrades
                                        .firstWhereOrDefault((x) => x.isSemesterProposition && x.semester == 1)
                                        ?.value
                                        .toString() ??
                                    'Unknown',
                                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                              ),
                            ])));
              })));
    }

    // Final grade (2nd semester / year)
    if (widget.lesson.allGrades.firstWhereOrDefault((x) => x.isFinal || (x.isSemester && x.semester == 2))?.value != null) {
      gradesBottomWidgets.add(AdaptiveCard(
          child: CupertinoContextMenu.builder(
              enableHapticFeedback: true,
              actions: [
                CupertinoContextMenuAction(
                  onPressed: () {
                    sharing.Share.share(
                        'I got a ${widget.lesson.allGrades.firstWhereOrDefault((x) => x.isFinal || (x.semester == 2 && x.isSemester))?.value} final from ${widget.lesson.name}!');
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
                            receivers: [widget.lesson.teacher],
                            subject: 'Pytanie o ocenę końcową z przedmiotu ${widget.lesson.name}',
                            signature:
                                '${Share.session.data.student.account.name}, ${Share.session.data.student.mainClass.name}'));
                  },
                ),
              ],
              builder: (BuildContext context, Animation<double> animation) {
                return Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        color: CupertinoDynamicColor.resolve(
                            CupertinoDynamicColor.withBrightness(
                                color: const Color.fromARGB(255, 255, 255, 255),
                                darkColor: const Color.fromARGB(255, 28, 28, 30)),
                            context)),
                    padding: EdgeInsets.only(top: 15, bottom: 15, right: 15, left: 20),
                    child: ConstrainedBox(
                        constraints: BoxConstraints(
                            maxHeight: animation.value < CupertinoContextMenu.animationOpensAt ? double.infinity : 100,
                            maxWidth: animation.value < CupertinoContextMenu.animationOpensAt ? double.infinity : 250),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    UnreadDot(
                                        unseen: () => widget.lesson.allGrades
                                            .any((x) => (x.isFinal || (x.semester == 2 && x.isSemester)) && x.unseen),
                                        markAsSeen: () => widget.lesson.allGrades
                                            .where((x) => x.isFinal || (x.semester == 2 && x.isSemester))
                                            .forEach((x) => x.markAsSeen()),
                                        margin: EdgeInsets.only(right: 8)),
                                    Text(
                                      'Final grade',
                                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                                    ),
                                  ]),
                              Text(
                                widget.lesson.allGrades
                                        .firstWhereOrDefault((x) => x.isFinal || (x.semester == 2 && x.isSemester))
                                        ?.value
                                        .toString() ??
                                    'Unknown',
                                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                              ),
                            ])));
              })));
    }

    // Final grade (1st semester)
    if (widget.lesson.allGrades.firstWhereOrDefault((x) => x.isSemester && x.semester == 1)?.value != null) {
      gradesSemesterBottomWidgets.add(AdaptiveCard(
          child: CupertinoContextMenu.builder(
              enableHapticFeedback: true,
              actions: [
                CupertinoContextMenuAction(
                  onPressed: () {
                    sharing.Share.share(
                        'I got a ${widget.lesson.allGrades.firstWhereOrDefault((x) => x.isSemester && x.semester == 1)?.value} semester from ${widget.lesson.name}!');
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
                            receivers: [widget.lesson.teacher],
                            subject: 'Pytanie o ocenę semestralną z przedmiotu ${widget.lesson.name}',
                            signature:
                                '${Share.session.data.student.account.name}, ${Share.session.data.student.mainClass.name}'));
                  },
                ),
              ],
              builder: (BuildContext context, Animation<double> animation) {
                return Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        color: CupertinoDynamicColor.resolve(
                            CupertinoDynamicColor.withBrightness(
                                color: const Color.fromARGB(255, 255, 255, 255),
                                darkColor: const Color.fromARGB(255, 28, 28, 30)),
                            context)),
                    padding: EdgeInsets.only(top: 15, bottom: 15, right: 15, left: 20),
                    child: ConstrainedBox(
                        constraints: BoxConstraints(
                            maxHeight: animation.value < CupertinoContextMenu.animationOpensAt ? double.infinity : 100,
                            maxWidth: animation.value < CupertinoContextMenu.animationOpensAt ? double.infinity : 250),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    UnreadDot(
                                        unseen: () => widget.lesson.allGrades
                                            .any((x) => (x.isSemester && x.semester == 1) && x.unseen),
                                        markAsSeen: () => widget.lesson.allGrades
                                            .where((x) => x.isSemester && x.semester == 1)
                                            .forEach((x) => x.markAsSeen()),
                                        margin: EdgeInsets.only(right: 8)),
                                    Text(
                                      'Semester grade',
                                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                                    ),
                                  ]),
                              Text(
                                widget.lesson.allGrades
                                        .firstWhereOrDefault((x) => x.isSemester && x.semester == 1)
                                        ?.value
                                        .toString() ??
                                    'Unknown',
                                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                              ),
                            ])));
              })));
    }

    return DataPageBase.adaptive(
        pageFlags: [
          DataPageType.searchable,
          DataPageType.refreshable,
        ].flag,
        setState: setState,
        title: widget.lesson.name,
        searchBuilder: (_, controller) => [gradesWidget(controller.text, false)],
        children: <Widget>[
          gradesWidget(),
        ]
            .appendIf(
                Container(
                    margin: EdgeInsets.only(top: 20),
                    child: CardContainer(
                      additionalDividerMargin: 5,
                      header: gradesSemesterBottomWidgets.isEmpty ? Container() : null,
                      children: gradesSemesterBottomWidgets,
                    )),
                gradesSemesterBottomWidgets.isNotEmpty)
            .appendIf(
                Container(
                    margin: EdgeInsets.only(top: 20),
                    child: CardContainer(
                      additionalDividerMargin: 5,
                      header: gradesBottomWidgets.isEmpty ? Container() : null,
                      children: gradesBottomWidgets,
                    )),
                gradesBottomWidgets.isNotEmpty));
  }
}

extension StringExtension on String {
  String capitalize() {
    try {
      return "${this[0].toUpperCase()}${substring(1)}";
    } catch (ex) {
      return this;
    }
  }
}
