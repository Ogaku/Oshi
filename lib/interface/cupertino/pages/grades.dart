// ignore_for_file: prefer_const_constructors
// ignore_for_file: prefer_const_literals_to_create_immutables

import 'package:darq/darq.dart';
import 'package:flutter/cupertino.dart';
import 'package:ogaku/interface/cupertino/views/searchable_bar.dart';
import 'package:ogaku/share/share.dart';

// Boiler: returned to the app tab builder
StatefulWidget get gradesPage => GradesPage();

class GradesPage extends StatefulWidget {
  const GradesPage({super.key});

  @override
  State<GradesPage> createState() => _GradesPageState();
}

class _GradesPageState extends State<GradesPage> {
  final searchController = TextEditingController();
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    var subjectsToDisplay = Share.session.data.student.subjects
        .where((x) =>
            x.name.contains(RegExp(searchQuery, caseSensitive: false)) ||
            x.teacher.name.contains(RegExp(searchQuery, caseSensitive: false)))
        .toList();

    var messagesWidget = CupertinoListSection.insetGrouped(
      margin: EdgeInsets.only(left: 20, right: 20, bottom: 10),
      additionalDividerMargin: 5,
      children: subjectsToDisplay.isEmpty
          // No messages to display
          ? [
              CupertinoListTile(
                  title: Opacity(
                      opacity: 0.5,
                      child: Container(
                          alignment: Alignment.center,
                          child: Text(
                            'No lessons matching the query',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
                          ))))
            ]
          // Bindable messages layout
          : subjectsToDisplay
              .select((x, index) => CupertinoListTile(
                  trailing: Container(margin: EdgeInsets.only(left: 3), child: CupertinoListTileChevron()),
                  title: Container(
                      padding: EdgeInsets.only(top: 15, bottom: 15),
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Text(
                              x.name,
                              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                            ),
                            Opacity(
                                opacity: 0.5,
                                child: Container(
                                    margin: EdgeInsets.only(top: 5),
                                    child: Text(
                                      x.teacher.name,
                                      style: TextStyle(fontSize: 16),
                                    ))),
                          ]))))
              .toList(),
    );

    return SearchableSliverNavigationBar(
      largeTitle: Text('Grades'),
      searchController: searchController,
      onChanged: (s) => setState(() => searchQuery = s),
      children: [messagesWidget],
    );
  }
}
