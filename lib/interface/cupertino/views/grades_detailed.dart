// ignore_for_file: prefer_const_constructors
// ignore_for_file: prefer_const_literals_to_create_immutables

import 'package:darq/darq.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:oshi/interface/cupertino/pages/home.dart';
import 'package:oshi/interface/cupertino/views/message_compose.dart';
import 'package:oshi/interface/cupertino/widgets/searchable_bar.dart';
import 'package:oshi/models/data/grade.dart';
import 'package:oshi/models/data/lesson.dart';
import 'package:oshi/share/share.dart';
import 'package:uuid/v4.dart';

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
        .where((x) =>
            x.name.contains(RegExp(searchQuery, caseSensitive: false)) ||
            x.detailsDateString.contains(RegExp(searchQuery, caseSensitive: false)) ||
            x.commentsString.contains(RegExp(searchQuery, caseSensitive: false)) ||
            x.addedByString.contains(RegExp(searchQuery, caseSensitive: false)))
        .orderByDescending((x) => x.addDate)
        .toList();

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
              return CupertinoListTile(padding: EdgeInsets.all(0), title: x.asGrade(context));
            }).toList(),
    );

    var gradesBottomWidgets = <Widget>[
      // Average (yearly - for now)
      Visibility(
          visible: widget.lesson.gradesAverage >= 0,
          child: CupertinoListTile(
              padding: EdgeInsets.all(0),
              title: CupertinoContextMenu.builder(
                  actions: [
                    CupertinoContextMenuAction(
                      onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
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
                  })))
    ];

    // Proposed grade (semester / year)
    if (widget.lesson.grades.firstWhereOrDefault((x) => x.isFinalProposition || x.isSemesterProposition)?.value != null) {
      gradesBottomWidgets.add(CupertinoListTile(
          padding: EdgeInsets.all(0),
          title: CupertinoContextMenu.builder(
              actions: [
                CupertinoContextMenuAction(
                  onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
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
                              Container(
                                  padding: EdgeInsets.only(bottom: 5),
                                  child: Text(
                                    'Proposed grade',
                                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                                  )),
                              Container(
                                  padding: EdgeInsets.only(bottom: 5),
                                  child: Text(
                                    widget.lesson.grades
                                            .firstWhereOrDefault((x) => x.isFinalProposition || x.isSemesterProposition)
                                            ?.value
                                            .toString() ??
                                        'Unknown',
                                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                                  )),
                            ])));
              })));
    }

    // Final grade (semester / year)
    if (widget.lesson.grades.firstWhereOrDefault((x) => x.isFinal || x.isSemester)?.value != null) {
      gradesBottomWidgets.add(CupertinoListTile(
          padding: EdgeInsets.all(0),
          title: CupertinoContextMenu.builder(
              actions: [
                CupertinoContextMenuAction(
                  onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
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
                              Container(
                                  padding: EdgeInsets.only(bottom: 5),
                                  child: Text(
                                    'Final grade',
                                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                                  )),
                              Container(
                                  padding: EdgeInsets.only(bottom: 5),
                                  child: Text(
                                    widget.lesson.grades
                                            .firstWhereOrDefault((x) => x.isFinal || x.isSemester)
                                            ?.value
                                            .toString() ??
                                        'Unknown',
                                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                                  )),
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
      children: [
        gradesWidget,
        Container(
            margin: EdgeInsets.only(top: 20),
            child: CupertinoListSection.insetGrouped(
              margin: EdgeInsets.only(left: 15, right: 15, bottom: 10),
              additionalDividerMargin: 5,
              children: gradesBottomWidgets,
            ))
      ],
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}

extension GradeBodyExtension on Grade {
  double get cardHeight {
    var height = 315.0;

    if (commentsString.isNotEmpty) height += 70;
    if (name.isNotEmpty) height += 45;

    return height;
  }

  Widget asGrade(BuildContext context) => CupertinoContextMenu.builder(actions: [
        CupertinoContextMenuAction(
          onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
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
                    receivers: [addedBy],
                    subject: 'Pytanie o ocenę $value z dnia ${DateFormat("y.M.d").format(addDate)}',
                    signature: '${Share.session.data.student.account.name}, ${Share.session.data.student.mainClass.name}'));
          },
        ),
      ], builder: (BuildContext context, Animation<double> animation) => gradeBody(context, animation));

  Widget gradeBody(BuildContext context, [Animation<double>? animation]) {
    var tag = UuidV4().generate();
    var body = GestureDetector(
        onTap: animation == null || animation.value >= CupertinoContextMenu.animationOpensAt
            ? null
            : () => showCupertinoModalBottomSheet(
                expand: false,
                context: context,
                builder: (context) => ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: cardHeight),
                    child: Container(
                        color: CupertinoDynamicColor.resolve(
                            CupertinoDynamicColor.withBrightness(
                                color: const Color.fromARGB(255, 242, 242, 247),
                                darkColor: const Color.fromARGB(255, 28, 28, 30)),
                            context),
                        child: Column(children: [
                          Container(
                              margin: EdgeInsets.only(top: 20, left: 15, right: 15),
                              child: Hero(tag: tag, child: gradeBody(context))),
                          CupertinoListSection.insetGrouped(
                              margin: EdgeInsets.only(top: 20, left: 15, right: 15),
                              additionalDividerMargin: 5,
                              children: [
                                CupertinoListTile(
                                  title: Text('Grade'),
                                  trailing: Opacity(opacity: 0.5, child: Text('$value, weight $weight')),
                                ),
                                CupertinoListTile(
                                  title: Text('Added by'),
                                  trailing: Opacity(opacity: 0.5, child: Text(addedBy.name)),
                                ),
                                CupertinoListTile(
                                  title: Text('Add date'),
                                  trailing: Opacity(opacity: 0.5, child: Text(DateFormat('EEE, d MMM y').format(addDate))),
                                ),
                              ]
                                  .appendIf(
                                      CupertinoListTile(
                                        title: Text('Description'),
                                        trailing: ConstrainedBox(
                                            constraints: BoxConstraints(maxWidth: 180),
                                            child: Flexible(
                                                child: Opacity(
                                                    opacity: 0.5,
                                                    child: Text(
                                                      name.capitalize(),
                                                      overflow: TextOverflow.ellipsis,
                                                    )))),
                                      ),
                                      name.isNotEmpty)
                                  .appendIf(
                                      CupertinoListTile(
                                        title: Text('Comments'),
                                        trailing: ConstrainedBox(
                                            constraints: BoxConstraints(maxWidth: 180),
                                            child: Flexible(
                                                child: Opacity(
                                                    opacity: 0.5,
                                                    child: Text(
                                                      commentsString,
                                                      overflow: TextOverflow.ellipsis,
                                                    )))),
                                      ),
                                      commentsString.isNotEmpty)
                                  .appendIf(
                                      CupertinoListTile(
                                        title: Text('Counts to the average'),
                                        trailing: Opacity(opacity: 0.5, child: Text(countsToAverage.toString())),
                                      ),
                                      true))
                        ])))),
        child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                color: animation == null
                    ? CupertinoDynamicColor.resolve(CupertinoColors.tertiarySystemGroupedBackground, context)
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
                            style: TextStyle(fontSize: 32, fontWeight: FontWeight.w600, color: asColor()),
                          )),
                      Expanded(
                          flex: 2,
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Opacity(
                                    opacity: name.isNotEmpty ? 1.0 : 0.5,
                                    child: Text(
                                      name.isNotEmpty ? name.capitalize() : 'No description',
                                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                                    )),
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
                                              style: TextStyle(fontSize: 16),
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
                                          style: TextStyle(fontSize: 16),
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
                                              style: TextStyle(fontSize: 16),
                                            )))),
                              ]))
                    ]))));

    return animation == null ? body : Hero(tag: tag, child: body);
  }
}
