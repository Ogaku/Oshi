// ignore_for_file: prefer_const_constructors
// ignore_for_file: prefer_const_literals_to_create_immutables

import 'package:darq/darq.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:oshi/interface/cupertino/base_app.dart';
import 'package:oshi/interface/cupertino/pages/home.dart';
import 'package:oshi/interface/cupertino/pages/messages.dart';
import 'package:oshi/interface/cupertino/views/message_compose.dart';
import 'package:oshi/interface/cupertino/views/new_grade.dart';
import 'package:oshi/interface/cupertino/widgets/searchable_bar.dart';
import 'package:oshi/models/data/grade.dart';
import 'package:oshi/models/data/lesson.dart';
import 'package:oshi/share/resources.dart';
import 'package:oshi/share/share.dart';
import 'package:uuid/uuid.dart';
import 'package:share_plus/share_plus.dart' as sharing;

class GradesDetailedPage extends StatefulWidget {
  const GradesDetailedPage({super.key, required this.lesson});

  final Lesson lesson;

  @override
  State<GradesDetailedPage> createState() => _GradesDetailedPageState();
}

class _GradesDetailedPageState extends State<GradesDetailedPage> {
  final searchController = TextEditingController();
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    var gradesToDisplay = widget.lesson.grades
        .where((x) => x.semester == 2)
        .appendAllIfEmpty(widget.lesson.grades)
        .where((x) => !x.major)
        .where((x) =>
            x.name.contains(RegExp(searchQuery, caseSensitive: false)) ||
            x.detailsDateString.contains(RegExp(searchQuery, caseSensitive: false)) ||
            x.commentsString.contains(RegExp(searchQuery, caseSensitive: false)) ||
            x.addedByString.contains(RegExp(searchQuery, caseSensitive: false)))
        .orderByDescending((x) => x.addDate)
        .distinct((x) => mapPropsToHashCode([x.resitPart ? 0 : UniqueKey(), x.name]))
        .toList();

    var secondSemester = widget.lesson.grades.any((x) => x.semester == 2 || x.isFinal || x.isFinalProposition);
    var gradesWidget = CupertinoListSection.insetGrouped(
      margin: EdgeInsets.only(left: 15, right: 15, bottom: 10),
      additionalDividerMargin: 5,
      children: gradesToDisplay.isEmpty
          // No messages to display
          ? [
              CupertinoListTile(
                  title: Opacity(
                      opacity: 0.5,
                      child: Container(
                          alignment: Alignment.center,
                          child: Text(
                            searchQuery.isNotEmpty ? 'No grades matching the query' : 'No grades',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
                          ))))
            ]
          // Bindable messages layout
          : gradesToDisplay.select((x, index) {
              return CupertinoListTile(
                  padding: EdgeInsets.all(0),
                  title: x.asGrade(context, setState,
                      corrected: widget.lesson.grades.firstWhereOrDefault(
                          (y) => x.resitPart && y.resitPart && y.name == x.name && x != y,
                          defaultValue: null)));
            }).toList(),
    );

    var gradesBottomWidgets = <Widget>[].appendIf(
        // Average (yearly)
        Visibility(
            visible: widget.lesson.gradesAverage >= 0,
            child: CupertinoListTile(
                padding: EdgeInsets.all(0),
                title: CupertinoContextMenu.builder(
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
          child: CupertinoListTile(
              padding: EdgeInsets.all(0),
              title: CupertinoContextMenu.builder(
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
    if (widget.lesson.grades
            .firstWhereOrDefault((x) => x.isFinalProposition || (x.isSemesterProposition && x.semester == 2))
            ?.value !=
        null) {
      gradesBottomWidgets.add(CupertinoListTile(
          padding: EdgeInsets.all(0),
          title: CupertinoContextMenu.builder(
              enableHapticFeedback: true,
              actions: [
                CupertinoContextMenuAction(
                  onPressed: () {
                    sharing.Share.share(
                        'I got a ${widget.lesson.grades.firstWhereOrDefault((x) => x.isFinalProposition || (x.semester == 2 && x.isSemesterProposition))?.value} proposition from ${widget.lesson.name}!');
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
                                        unseen: () => widget.lesson.grades.any((x) =>
                                            (x.isFinalProposition || (x.semester == 2 && x.isSemesterProposition)) &&
                                            x.unseen),
                                        markAsSeen: () => widget.lesson.grades
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
                                widget.lesson.grades
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
    if (widget.lesson.grades.firstWhereOrDefault((x) => x.isSemesterProposition && x.semester == 1)?.value != null) {
      gradesSemesterBottomWidgets.add(CupertinoListTile(
          padding: EdgeInsets.all(0),
          title: CupertinoContextMenu.builder(
              enableHapticFeedback: true,
              actions: [
                CupertinoContextMenuAction(
                  onPressed: () {
                    sharing.Share.share(
                        'I got a ${widget.lesson.grades.firstWhereOrDefault((x) => x.isSemesterProposition && x.semester == 1)?.value} semester proposition from ${widget.lesson.name}!');
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
                                        unseen: () => widget.lesson.grades
                                            .any((x) => (x.isSemesterProposition && x.semester == 1) && x.unseen),
                                        markAsSeen: () => widget.lesson.grades
                                            .where((x) => x.isSemesterProposition && x.semester == 1)
                                            .forEach((x) => x.markAsSeen()),
                                        margin: EdgeInsets.only(right: 8)),
                                    Text(
                                      'Proposed grade',
                                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                                    ),
                                  ]),
                              Text(
                                widget.lesson.grades
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
    if (widget.lesson.grades.firstWhereOrDefault((x) => x.isFinal || (x.isSemester && x.semester == 2))?.value != null) {
      gradesBottomWidgets.add(CupertinoListTile(
          padding: EdgeInsets.all(0),
          title: CupertinoContextMenu.builder(
              enableHapticFeedback: true,
              actions: [
                CupertinoContextMenuAction(
                  onPressed: () {
                    sharing.Share.share(
                        'I got a ${widget.lesson.grades.firstWhereOrDefault((x) => x.isFinal || (x.semester == 2 && x.isSemester))?.value} final from ${widget.lesson.name}!');
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
                                        unseen: () => widget.lesson.grades
                                            .any((x) => (x.isFinal || (x.semester == 2 && x.isSemester)) && x.unseen),
                                        markAsSeen: () => widget.lesson.grades
                                            .where((x) => x.isFinal || (x.semester == 2 && x.isSemester))
                                            .forEach((x) => x.markAsSeen()),
                                        margin: EdgeInsets.only(right: 8)),
                                    Text(
                                      'Final grade',
                                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                                    ),
                                  ]),
                              Text(
                                widget.lesson.grades
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
    if (widget.lesson.grades.firstWhereOrDefault((x) => x.isSemester && x.semester == 1)?.value != null) {
      gradesSemesterBottomWidgets.add(CupertinoListTile(
          padding: EdgeInsets.all(0),
          title: CupertinoContextMenu.builder(
              enableHapticFeedback: true,
              actions: [
                CupertinoContextMenuAction(
                  onPressed: () {
                    sharing.Share.share(
                        'I got a ${widget.lesson.grades.firstWhereOrDefault((x) => x.isSemester && x.semester == 1)?.value} semester from ${widget.lesson.name}!');
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
                                        unseen: () =>
                                            widget.lesson.grades.any((x) => (x.isSemester && x.semester == 1) && x.unseen),
                                        markAsSeen: () => widget.lesson.grades
                                            .where((x) => x.isSemester && x.semester == 1)
                                            .forEach((x) => x.markAsSeen()),
                                        margin: EdgeInsets.only(right: 8)),
                                    Text(
                                      'Semester grade',
                                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                                    ),
                                  ]),
                              Text(
                                widget.lesson.grades
                                        .firstWhereOrDefault((x) => x.isSemester && x.semester == 1)
                                        ?.value
                                        .toString() ??
                                    'Unknown',
                                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                              ),
                            ])));
              })));
    }

    return SearchableSliverNavigationBar(
        setState: setState,
        largeTitle: Text(widget.lesson.name, maxLines: 1, overflow: TextOverflow.ellipsis),
        middle: Container(
            margin: EdgeInsets.only(left: 10, right: 45),
            child: Text(widget.lesson.name, maxLines: 1, overflow: TextOverflow.ellipsis)),
        searchController: searchController,
        onChanged: (s) => setState(() => searchQuery = s),
        children: <Widget>[
          gradesWidget,
        ]
            .appendIf(
                Container(
                    margin: EdgeInsets.only(top: 20),
                    child: CupertinoListSection.insetGrouped(
                      margin: EdgeInsets.only(left: 15, right: 15, bottom: 10),
                      additionalDividerMargin: 5,
                      header: gradesSemesterBottomWidgets.isEmpty ? Container() : null,
                      children: gradesSemesterBottomWidgets,
                    )),
                gradesSemesterBottomWidgets.isNotEmpty)
            .appendIf(
                Container(
                    margin: EdgeInsets.only(top: 20),
                    child: CupertinoListSection.insetGrouped(
                      margin: EdgeInsets.only(left: 15, right: 15, bottom: 10),
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
              .append(CupertinoContextMenuAction(
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
              ))
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
                            CupertinoListSection.insetGrouped(
                                margin: EdgeInsets.only(top: 20, left: 15, right: 15, bottom: 15),
                                additionalDividerMargin: 5,
                                children: [
                                  CupertinoListTile(
                                      title: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(margin: EdgeInsets.only(right: 3), child: Text('Grade')),
                                      Flexible(
                                          child: Opacity(
                                              opacity: 0.5,
                                              child: Text('$value, weight $weight', maxLines: 2, textAlign: TextAlign.end)))
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
                                              child: Text(addedBy.name, maxLines: 1, overflow: TextOverflow.ellipsis)))
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
                                        CupertinoListTile(
                                            title: Row(
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
                                        CupertinoListTile(
                                            title: Row(
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
                                        CupertinoListTile(
                                            title: Row(
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
