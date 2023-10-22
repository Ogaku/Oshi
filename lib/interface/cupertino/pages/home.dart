// ignore_for_file: prefer_const_constructors
// ignore_for_file: prefer_const_literals_to_create_immutables

import 'package:darq/darq.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:oshi/interface/cupertino/widgets/searchable_bar.dart';
import 'package:oshi/models/data/event.dart';
import 'package:oshi/share/share.dart';

import 'package:oshi/interface/cupertino/widgets/text_chip.dart' show TextChip;

// Boiler: returned to the app tab builder
StatefulWidget get homePage => HomePage();

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final searchController = TextEditingController();

  bool get isLucky =>
      Share.session.data.student.mainClass.unit.luckyNumber != null &&
      Share.session.data.student.account.number == Share.session.data.student.mainClass.unit.luckyNumber;

  @override
  Widget build(BuildContext context) {
    // Event list for the next week (7 days), exc homeworks and teacher absences
    var eventsWeek = Share.session.data.student.mainClass.events
        .where((x) => x.category != EventCategory.homework && x.category != EventCategory.teacher)
        .where((x) => x.date?.isAfter(DateTime.now().asDate()) ?? false)
        .where((x) => x.date?.isBefore(DateTime.now().add(Duration(days: 7)).asDate()) ?? false)
        .orderBy((x) => x.date ?? x.timeTo ?? x.timeFrom)
        .toList();

    // Event list for the next week (7 days), exc homeworks and teacher absences
    var gradesWeek = Share.session.data.student.subjects
        .where((x) => x.grades.isNotEmpty)
        .select((x, index) => (
              lesson: x.name,
              grades: x.grades.where((y) => y.addDate.isAfter(DateTime.now().subtract(Duration(days: 7)).asDate())).toList()
            ))
        .where((x) => x.grades.isNotEmpty)
        .orderByDescending((x) => x.grades.orderByDescending((y) => y.addDate).first.addDate)
        .toList();

    // Homework list for the next week (7 days)
    var homeworksWeek = Share.session.data.student.mainClass.events
        .where((x) => x.category == EventCategory.homework)
        .where((x) => x.timeTo?.isAfter(DateTime.now().asDate()) ?? false)
        .where((x) => x.timeTo?.isBefore(DateTime.now().add(Duration(days: 7)).asDate()) ?? false)
        .orderByDescending((x) => x.done ? 0 : 1)
        .thenBy((x) => x.date ?? x.timeTo ?? x.timeFrom)
        .toList();

    // Homeworks - first if any(), otherwise last
    var homeworksLast = homeworksWeek.isEmpty || homeworksWeek.all((x) => x.done);
    var homeworksWidget = CupertinoListSection.insetGrouped(
      margin: EdgeInsets.only(left: 15, right: 15, bottom: 10),
      dividerMargin: 35,
      header: Text('Homeworks'),
      children: homeworksWeek.isEmpty
          // No homeworks to display
          ? [
              CupertinoListTile(
                  title: Opacity(
                      opacity: 0.5,
                      child: Container(
                          alignment: Alignment.center,
                          child: Text(
                            'All done, yay!',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
                          ))))
            ]
          // Bindable homework layout
          : homeworksWeek
              .select((x, index) => CupertinoListTile(
                  padding: EdgeInsets.only(left: 7),
                  title: Opacity(
                      opacity: x.done ? 0.5 : 1.0,
                      child: Container(
                          margin: EdgeInsets.only(right: 10),
                          alignment: Alignment.centerLeft,
                          child: Row(
                            children: [
                              TextChip(
                                  text: DateFormat('d/M').format(x.timeTo ?? x.timeFrom),
                                  margin: EdgeInsets.only(top: 6, bottom: 6, right: 10)),
                              Expanded(
                                  child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Flexible(
                                          child: Text(
                                        x.title ?? x.content,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(fontWeight: FontWeight.w600),
                                      )))),
                              Align(
                                  alignment: Alignment.centerRight,
                                  child: Visibility(
                                    visible: x.done,
                                    child:
                                        Container(margin: EdgeInsets.only(left: 5), child: Icon(CupertinoIcons.check_mark)),
                                  ))
                            ],
                          )))))
              .toList(),
    );

    return CupertinoPageScaffold(
      backgroundColor: CupertinoDynamicColor.withBrightness(
          color: const Color.fromARGB(255, 242, 242, 247), darkColor: const Color.fromARGB(255, 0, 0, 0)),
      child: SearchableSliverNavigationBar(
        searchController: searchController,
        largeTitle: Text('Home'),
        trailing: Icon(CupertinoIcons.gear),
        children: [
          CupertinoListSection.insetGrouped(
            margin: EdgeInsets.only(left: 15, right: 15, bottom: 10),
            hasLeading: false,
            header: Text('Summary'),
            children: [
              CupertinoListTile(
                  title: Container(
                      margin: EdgeInsets.only(top: 10, bottom: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'TODO Conditional lesson text',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Visibility(
                              visible: Share.session.data.student.mainClass.unit.luckyNumber != null,
                              child: Opacity(
                                  opacity: 0.5,
                                  child: Container(
                                      margin: EdgeInsets.only(top: 5), child: Text("You're the lucky one today!"))))
                        ],
                      ))),
              CupertinoListTile(
                  title: Text(
                'TODO Conditional lesson text',
                style: TextStyle(fontWeight: FontWeight.w600),
              )),
              CupertinoListTile(
                  title: Container(
                      margin: EdgeInsets.only(top: 10, bottom: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('TODO Conditional lesson text'),
                          Visibility(
                              visible: Share.session.data.student.mainClass.unit.luckyNumber == null,
                              child: Opacity(
                                  opacity: 0.5,
                                  child: Container(
                                      margin: EdgeInsets.only(top: 5), child: Text('TODO Conditional lesson text'))))
                        ],
                      ))),
              CupertinoListTile(title: Text('TODO Conditional lesson text')),
            ],
          ),
          // Homeworks - first if any(), otherwise last
          Visibility(visible: !homeworksLast, child: homeworksWidget),
          // Upcoming events - in the middle, or top
          CupertinoListSection.insetGrouped(
            margin: EdgeInsets.only(left: 15, right: 15, bottom: 10),
            dividerMargin: 35,
            header: Text('Upcoming events'),
            children: eventsWeek.isEmpty
                // No events to display
                ? [
                    CupertinoListTile(
                        title: Opacity(
                            opacity: 0.5,
                            child: Container(
                                alignment: Alignment.center,
                                child: Text(
                                  'No events to display',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
                                ))))
                  ]
                // Bindable event layout
                : eventsWeek
                    .select((x, index) => CupertinoListTile(
                        padding: EdgeInsets.only(left: 7),
                        title: Container(
                            margin: EdgeInsets.only(right: 10),
                            alignment: Alignment.centerLeft,
                            child: Row(
                              children: [
                                TextChip(
                                    text: DateFormat('d/M').format(x.date ?? x.timeFrom),
                                    margin: EdgeInsets.only(top: 6, bottom: 6, right: 10)),
                                Flexible(
                                    child: Text(
                                  x.title ?? x.content,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ))
                              ],
                            ))))
                    .toList(),
          ),
          // Recent grades - always below events
          CupertinoListSection.insetGrouped(
            margin: EdgeInsets.only(left: 15, right: 15, bottom: 10),
            additionalDividerMargin: 5,
            header: Text('Recent grades'),
            children: gradesWeek.isEmpty
                // No grades to display
                ? [
                    CupertinoListTile(
                        title: Opacity(
                            opacity: 0.5,
                            child: Container(
                                alignment: Alignment.center,
                                child: Text(
                                  'No recent grades',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
                                ))))
                  ]
                // Bindable grades layout
                : gradesWeek
                    .select((x, index) => CupertinoListTile(
                        padding: EdgeInsets.only(left: 18, right: 8, top: 8, bottom: 10),
                        title: Container(
                            margin: EdgeInsets.only(right: 10),
                            alignment: Alignment.centerLeft,
                            child: Row(
                              children: [
                                Expanded(
                                    flex: 2,
                                    child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          x.lesson,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                        ))),
                                Expanded(
                                    child: Align(
                                        alignment: Alignment.centerRight,
                                        child: Text(
                                          x.grades.select((y, index) => y.value).join(', '),
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(fontSize: 25),
                                        )))
                              ],
                            ))))
                    .toList(),
          ),
          // Homeworks - first if any(), otherwise last
          Visibility(visible: homeworksLast, child: homeworksWidget)
        ],
      ),
    );
  }
}

extension DateTimeExtension on DateTime {
  DateTime asDate() => DateTime(year, month, day);
}
