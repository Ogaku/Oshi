// ignore_for_file: prefer_const_constructors
// ignore_for_file: prefer_const_literals_to_create_immutables

import 'package:darq/darq.dart';
import 'package:flutter/cupertino.dart';
import 'package:ogaku/interface/cupertino/widgets/searchable_bar.dart';
import 'package:ogaku/models/data/lesson.dart';

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
        .toList();

    var gradesWidget = CupertinoListSection.insetGrouped(
      margin: EdgeInsets.only(left: 20, right: 20, bottom: 10),
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
                            'No grades matching the query',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
                          ))))
            ]
          // Bindable messages layout
          : gradesToDisplay
              .select((x, index) => CupertinoListTile(
                  padding: EdgeInsets.all(0),
                  title: CupertinoContextMenu(
                      actions: [
                        CupertinoContextMenuAction(
                          onPressed: () {},
                          isDestructiveAction: true,
                          trailingIcon: CupertinoIcons.delete,
                          child: const Text('Delete'),
                        ),
                      ],
                      child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(10)),
                              color: CupertinoDynamicColor.resolve(
                                  CupertinoDynamicColor.withBrightness(
                                      color: const Color.fromARGB(255, 255, 255, 255),
                                      darkColor: const Color.fromARGB(255, 28, 28, 30)),
                                  context)),
                          padding: EdgeInsets.only(top: 15, bottom: 15, right: 15, left: 20),
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
                                    flex: 0,
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
                                                    style: TextStyle(fontSize: 16),
                                                  ))),
                                        ]))
                              ])))))
              .toList(),
    );

    return SearchableSliverNavigationBar(
      largeTitle: Text(widget.lesson.name),
      searchController: searchController,
      onChanged: (s) => setState(() => searchQuery = s),
      children: [gradesWidget],
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}
