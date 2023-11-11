// ignore_for_file: prefer_const_constructors
// ignore_for_file: prefer_const_literals_to_create_immutables

import 'package:darq/darq.dart';
import 'package:flutter/cupertino.dart';
import 'package:oshi/interface/cupertino/views/grades_detailed.dart';
import 'package:oshi/interface/cupertino/widgets/searchable_bar.dart';
import 'package:oshi/share/share.dart';
import 'package:oshi/share/translator.dart';

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
  String? _progressMessage;

  @override
  Widget build(BuildContext context) {
    // Re-subscribe to all events
    Share.gradesNavigate.unsubscribeAll();
    Share.gradesNavigate.subscribe((args) {
      if (args?.value == null) return;
      if (Navigator.of(context).canPop()) Navigator.of(context).pop();
      Navigator.push(
          context,
          CupertinoPageRoute(
              builder: (context) => GradesDetailedPage(
                    lesson: args!.value,
                  )));
    });

    var subjectsToDisplay = Share.session.data.student.subjects
        .where((x) =>
            x.name.contains(RegExp(searchQuery, caseSensitive: false)) ||
            x.teacher.name.contains(RegExp(searchQuery, caseSensitive: false)))
        .orderBy((x) => x.name)
        .toList();

    var subjectsWidget = CupertinoListSection.insetGrouped(
      margin: EdgeInsets.only(left: 15, right: 15, bottom: 10),
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
                            '/Grades/NoLessons'.localized,
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
                          ))))
            ]
          // Bindable messages layout
          : subjectsToDisplay
              .select((x, index) => Builder(
                  builder: (context) => CupertinoListTile(
                      onTap: () => Navigator.push(
                          context,
                          CupertinoPageRoute(
                              builder: (context) => GradesDetailedPage(
                                    lesson: x,
                                  ))),
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
                              ])))))
              .toList(),
    );

    return SearchableSliverNavigationBar(
      setState: setState,
      largeTitle: Text('/Grades'.localized),
      middle: Visibility(visible: _progressMessage?.isEmpty ?? true, child: Text('/Grades'.localized)),
      onProgress: (progress) => setState(() => _progressMessage = progress?.message),
      leading: Visibility(
          visible: _progressMessage?.isNotEmpty ?? false,
          child: Container(
              margin: EdgeInsets.only(top: 7),
              child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 150),
                  child: Text(
                    _progressMessage ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: CupertinoColors.inactiveGray, fontSize: 13),
                  )))),
      searchController: searchController,
      onChanged: (s) => setState(() => searchQuery = s),
      children: [subjectsWidget],
    );
  }
}
