// ignore_for_file: prefer_const_constructors
// ignore_for_file: prefer_const_literals_to_create_immutables

import 'package:darq/darq.dart';
import 'package:flutter/cupertino.dart';
import 'package:oshi/interface/cupertino/widgets/searchable_bar.dart';
import 'package:oshi/models/data/lesson.dart';

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
          : gradesToDisplay
              .select((x, index) => CupertinoListTile(
                  padding: EdgeInsets.all(0),
                  title: CupertinoContextMenu.builder(
                      actions: [
                        CupertinoContextMenuAction(
                          onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
                          trailingIcon: CupertinoIcons.share,
                          child: const Text('Share'),
                        ),
                        CupertinoContextMenuAction(
                          onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
                          isDestructiveAction: true,
                          trailingIcon: CupertinoIcons.chat_bubble_2,
                          child: const Text('Inquiry'),
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
                                    maxHeight:
                                        animation.value < CupertinoContextMenu.animationOpensAt ? double.infinity : 150,
                                    maxWidth:
                                        animation.value < CupertinoContextMenu.animationOpensAt ? double.infinity : 250),
                                child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                          padding: EdgeInsets.only(bottom: 5),
                                          child: Text(
                                            x.value,
                                            style: TextStyle(fontSize: 32, fontWeight: FontWeight.w600),
                                          )),
                                      Expanded(
                                          flex: 2,
                                          child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              crossAxisAlignment: CrossAxisAlignment.end,
                                              mainAxisSize: MainAxisSize.max,
                                              children: [
                                                Opacity(
                                                    opacity: x.name.isNotEmpty ? 1.0 : 0.5,
                                                    child: Text(
                                                      x.name.isNotEmpty ? x.name.capitalize() : 'No description',
                                                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                                                    )),
                                                Visibility(
                                                    visible: x.commentsString.isNotEmpty,
                                                    child: Opacity(
                                                        opacity: 0.5,
                                                        child: Container(
                                                            margin: EdgeInsets.only(left: 35, top: 4),
                                                            child: Text(
                                                              x.commentsString,
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
                                                          x.detailsDateString,
                                                          overflow: TextOverflow.ellipsis,
                                                          maxLines: 1,
                                                          textAlign: TextAlign.end,
                                                          style: TextStyle(fontSize: 16),
                                                        ))),
                                                Visibility(
                                                    visible: animation.value >= CupertinoContextMenu.animationOpensAt,
                                                    child: Opacity(
                                                        opacity: 0.5,
                                                        child: Container(
                                                            margin: EdgeInsets.only(top: 4),
                                                            child: Text(
                                                              x.addedDateString,
                                                              overflow: TextOverflow.ellipsis,
                                                              maxLines: 1,
                                                              textAlign: TextAlign.end,
                                                              style: TextStyle(fontSize: 16),
                                                            )))),
                                              ]))
                                    ])));
                      })))
              .toList(),
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
                      onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
                      isDestructiveAction: true,
                      trailingIcon: CupertinoIcons.chat_bubble_2,
                      child: const Text('Inquiry'),
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
                  onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
                  isDestructiveAction: true,
                  trailingIcon: CupertinoIcons.chat_bubble_2,
                  child: const Text('Inquiry'),
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
                  onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
                  isDestructiveAction: true,
                  trailingIcon: CupertinoIcons.chat_bubble_2,
                  child: const Text('Inquiry'),
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
      largeTitle: Text(widget.lesson.name),
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
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}
