// ignore_for_file: prefer_const_constructors
// ignore_for_file: prefer_const_literals_to_create_immutables

import 'package:darq/darq.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:oshi/interface/cupertino/widgets/searchable_bar.dart';
import 'package:oshi/models/data/attendances.dart';
import 'package:oshi/share/share.dart';

// Boiler: returned to the app tab builder
StatefulWidget get absencesPage => AbsencesPage();

class AbsencesPage extends StatefulWidget {
  const AbsencesPage({super.key});

  @override
  State<AbsencesPage> createState() => _AbsencesPageState();
}

class _AbsencesPageState extends State<AbsencesPage> {
  final searchController = TextEditingController();

  String selectedSegment = 'date';
  bool showInbox = true;
  bool isWorking = false;

  @override
  Widget build(BuildContext context) {
    // Group by date, I know IT'S A DAMN STRING, but we're saving on custom controls
    var attendancesToDisplayByDate = Share.session.data.student.attendances
            ?.orderByDescending((x) => x.date)
            .groupBy((x) => DateFormat('EEEE, d MMMM y').format(x.date))
            .toList() ??
        [];

    // Group by subjects, or at least what we can access right now
    var attendancesToDisplayByLesson = Share.session.data.student.attendances
            ?.orderByDescending((x) => x.date)
            .groupBy((x) => x.lesson.subject?.name ?? 'Unknown subject')
            .orderBy((x) => x.key)
            .toList() ??
        [];

    // Group by type, try to show absences first
    var attendancesToDisplayByType = Share.session.data.student.attendances
            ?.orderByDescending((x) => x.date)
            .groupBy((x) => x.type.asStringLong())
            .orderBy((x) => x.key)
            .toList() ??
        [];

    // This is gonna be a veeery long list, as there are no expanders in cupertino
    var attendanceWidgets = (switch (selectedSegment) {
      'date' => attendancesToDisplayByDate,
      'lesson' => attendancesToDisplayByLesson,
      'type' => attendancesToDisplayByType,
      _ => attendancesToDisplayByDate
    })
        .select((element, index) => CupertinoListSection.insetGrouped(
              margin: EdgeInsets.only(left: 15, right: 15, bottom: 10),
              header: Text(element.key),
              additionalDividerMargin: 5,
              children: element.isEmpty
                  // No messages to display
                  ? [
                      CupertinoListTile(
                          title: Opacity(
                              opacity: 0.5,
                              child: Container(
                                  alignment: Alignment.center,
                                  child: Text(
                                    'No attendances',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
                                  ))))
                    ]
                  // Bindable messages layout
                  : element
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
                                            maxHeight: animation.value < CupertinoContextMenu.animationOpensAt
                                                ? double.infinity
                                                : 150,
                                            maxWidth: animation.value < CupertinoContextMenu.animationOpensAt
                                                ? double.infinity
                                                : 250),
                                        child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Container(
                                                  padding: EdgeInsets.only(bottom: 5),
                                                  child: Text(
                                                    x.type.asString(),
                                                    style: TextStyle(
                                                        fontSize: 32, fontWeight: FontWeight.w600, color: x.type.asColor()),
                                                  )),
                                              Expanded(
                                                  flex: 2,
                                                  child: Column(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      crossAxisAlignment: CrossAxisAlignment.end,
                                                      mainAxisSize: MainAxisSize.max,
                                                      children: [
                                                        Visibility(
                                                            visible: (x.lesson.subject?.name.isNotEmpty ?? false),
                                                            child: Opacity(
                                                                opacity: 0.5,
                                                                child: Container(
                                                                    margin: EdgeInsets.only(left: 35, top: 4),
                                                                    child: Text(
                                                                      x.lesson.subject?.name ?? 'Unknown lesson',
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
                                                                  x.addedDateString,
                                                                  overflow: TextOverflow.ellipsis,
                                                                  maxLines: 1,
                                                                  textAlign: TextAlign.end,
                                                                  style: TextStyle(fontSize: 16),
                                                                )))
                                                      ]))
                                            ])));
                              })))
                      .toList(),
            ))
        .toList();

    return SearchableSliverNavigationBar(
        segments: {'date': 'By date', 'lesson': 'By lesson', 'type': 'By type'},
        largeTitle: Text('Attendance'),
        searchController: searchController,
        onChanged: (s) => setState(() => selectedSegment = s),
        trailing: isWorking
            ? Container(margin: EdgeInsets.only(right: 5, top: 5), child: CupertinoActivityIndicator(radius: 12))
            : null,
        children: attendanceWidgets);
  }
}

extension AttendanceTypeExtension on AttendanceType {
  String asString() => switch (this) {
        AttendanceType.absent => 'nb',
        AttendanceType.late => 'sp',
        AttendanceType.excused => 'u',
        AttendanceType.duty => 'zw',
        AttendanceType.present => 'ob',
        AttendanceType.other => 'in',
      };

  String asStringLong() => switch (this) {
        AttendanceType.absent => 'Absence',
        AttendanceType.late => 'Late',
        AttendanceType.excused => 'Excused',
        AttendanceType.duty => 'Duty',
        AttendanceType.present => 'Present',
        AttendanceType.other => 'Other',
      };

  Color asColor() => switch (this) {
        AttendanceType.absent => CupertinoColors.systemRed,
        AttendanceType.late => CupertinoColors.systemYellow,
        AttendanceType.excused => CupertinoColors.systemTeal,
        AttendanceType.duty => CupertinoColors.systemIndigo,
        AttendanceType.present => CupertinoColors.systemGreen,
        AttendanceType.other => CupertinoColors.inactiveGray,
      };
}
