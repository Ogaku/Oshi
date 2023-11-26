// ignore_for_file: prefer_const_constructors
// ignore_for_file: prefer_const_literals_to_create_immutables

import 'package:darq/darq.dart';
import 'package:extended_wrap/extended_wrap.dart';
import 'package:flutter/cupertino.dart';
import 'package:oshi/interface/cupertino/pages/home.dart';
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
                                Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Visibility(
                                          visible: x.hasUnseen,
                                          child: Container(
                                              margin: EdgeInsets.only(top: 5, right: 6),
                                              child: Container(
                                                height: 10,
                                                width: 10,
                                                decoration: BoxDecoration(
                                                    shape: BoxShape.circle, color: CupertinoTheme.of(context).primaryColor),
                                              ))),
                                      Expanded(
                                          child: Container(
                                              margin: EdgeInsets.only(right: 10),
                                              child: Text(
                                                x.name,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                                              ))),
                                    ]),
                                Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Visibility(
                                          visible: x.grades.isNotEmpty,
                                          child: Expanded(
                                              child: Container(
                                                  margin: EdgeInsets.only(top: 5),
                                                  child: ExtendedWrap(
                                                      maxLines: 1,
                                                      overflowWidget: Text('...'),
                                                      spacing: 5,
                                                      children: x.grades
                                                          .where((y) => !y.major)
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
                                                                        width: 1,
                                                                        strokeAlign: BorderSide.strokeAlignInside),
                                                                    borderRadius: BorderRadius.all(Radius.circular(6))),
                                                                child: Text(y.value,
                                                                    textAlign: TextAlign.center,
                                                                    style: TextStyle(
                                                                        fontSize: 13,
                                                                        color:
                                                                            (y.isFinalProposition || y.isSemesterProposition)
                                                                                ? CupertinoDynamicColor.resolve(
                                                                                    CupertinoDynamicColor.withBrightness(
                                                                                        color: CupertinoColors.black,
                                                                                        darkColor: CupertinoColors.white),
                                                                                    context)
                                                                                : CupertinoColors.black)),
                                                              ))
                                                          .prependIf(Container(width: 7), x.grades.any((y) => y.major))
                                                          .prependAll(x.grades
                                                              .where((y) => y.major)
                                                              .orderByDescending((y) => y.isFinal ? 1 : 0)
                                                              .orderByDescending((y) => y.isSemester ? 1 : 0)
                                                              .thenByDescending((y) => y.addDate)
                                                              .take(1)
                                                              .select((y, index) => Container(
                                                                    padding:
                                                                        EdgeInsets.symmetric(vertical: 1, horizontal: 6),
                                                                    decoration: BoxDecoration(
                                                                        color: y.major
                                                                            ? (y.isFinal || y.isSemester)
                                                                                ? y.asColor()
                                                                                : null
                                                                            : y.asColor(),
                                                                        border: Border.all(
                                                                            color: y.asColor(),
                                                                            width: 1,
                                                                            strokeAlign: BorderSide.strokeAlignInside),
                                                                        borderRadius: BorderRadius.all(Radius.circular(6))),
                                                                    child: Text(y.value,
                                                                        textAlign: TextAlign.center,
                                                                        style: TextStyle(
                                                                            fontSize: 13,
                                                                            color: (y.isFinalProposition ||
                                                                                    y.isSemesterProposition)
                                                                                ? CupertinoDynamicColor.resolve(
                                                                                    CupertinoDynamicColor.withBrightness(
                                                                                        color: CupertinoColors.black,
                                                                                        darkColor: CupertinoColors.white),
                                                                                    context)
                                                                                : CupertinoColors.black)),
                                                                  )))
                                                          .toList()))))
                                    ]),
                                Visibility(
                                    visible: x.grades.isEmpty,
                                    child: Opacity(
                                        opacity: 0.5,
                                        child: Container(
                                            margin: EdgeInsets.only(top: 5),
                                            child: Text(
                                              x.teacher.name,
                                              style: TextStyle(fontSize: 16),
                                            )))),
                              ])))))
              .toList(),
    );

    return SearchableSliverNavigationBar(
      setState: setState,
      largeTitle: Text('/Grades'.localized),
      middle: Text('/Grades'.localized),
      searchController: searchController,
      onChanged: (s) => setState(() => searchQuery = s),
      children: [subjectsWidget],
    );
  }
}
