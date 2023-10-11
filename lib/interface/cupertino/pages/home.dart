// ignore_for_file: prefer_const_constructors
// ignore_for_file: prefer_const_literals_to_create_immutables

import 'package:darq/darq.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/scheduler.dart';
import 'package:intl/intl.dart';
import 'package:ogaku/models/data/event.dart';
import 'package:ogaku/share/share.dart';

import 'package:ogaku/interface/cupertino/views/text_chip.dart' show TextChip;
import 'package:ogaku/interface/cupertino/views/navigation_bar.dart' show SliverNavigationBar;

// Boiler: returned to the app tab builder
StatefulWidget get homePage => HomePage();

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final scrollController = ScrollController();
  bool subscribed = false;

  bool get isLucky =>
      Share.session.data.student.mainClass.unit.luckyNumber != null &&
      Share.session.data.student.account.number == Share.session.data.student.mainClass.unit.luckyNumber;

  @override
  Widget build(BuildContext context) {
    if (!subscribed) {
      SchedulerBinding.instance.platformDispatcher.onPlatformBrightnessChanged = () => setState(() {});
      subscribed = true;
    }

    // Event list for the next week (7 days), exc homeworks and teacher absences
    var eventsWeek = Share.session.data.student.mainClass.events
        .where((x) => x.category != EventCategory.homework && x.category != EventCategory.teacher)
        .where((x) => x.date?.isAfter(DateTime.now().asDate()) ?? false)
        .where((x) => x.date?.isBefore(DateTime.now().add(Duration(days: 7)).asDate()) ?? false)
        .toList();

    // Event list for the next week (7 days), exc homeworks and teacher absences
    var gradesWeek = Share.session.data.student.subjects
        .where((x) => x.grades.isNotEmpty)
        .select((x, index) => x.grades)
        .flatten()
        .where((x) => x.addDate.isAfter(DateTime.now().subtract(Duration(days: 7)).asDate()))
        .toList();

    // Homework list for the next week (7 days)
    var homeworksWeek = Share.session.data.student.mainClass.events
        .where((x) => x.category == EventCategory.homework)
        .where((x) => x.timeTo?.isAfter(DateTime.now().asDate()) ?? false)
        .where((x) => x.timeTo?.isBefore(DateTime.now().add(Duration(days: 7)).asDate()) ?? false)
        .toList();

    // Homeworks - first if any(), otherwise last
    var homeworksLast = homeworksWeek.isEmpty || homeworksWeek.all((x) => x.done);
    var homeworksWidget = CupertinoListSection.insetGrouped(
      header: Text('Homeworks'),
      children: [
        CupertinoListTile(
            title: Opacity(
                opacity: 0.5,
                child: Container(
                    alignment: Alignment.center,
                    child: Text(
                      'All done, yay!',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
                    )))),
      ],
    );

    return CupertinoPageScaffold(
      backgroundColor:
          Color(WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark ? 0x00000000 : 0xFFF2F2F7),
      child: CustomScrollView(
        controller: scrollController,
        slivers: [
          SliverNavigationBar(
              scrollController: scrollController,
              largeTitle: Text('Home'),
              trailing: Icon(CupertinoIcons.gear),
              leading: TextChip(
                text: DateFormat('y.M.d').format(DateTime.now()),
                margin: EdgeInsets.only(top: 6, bottom: 6),
              )),
          SliverFillRemaining(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                CupertinoListSection.insetGrouped(
                  header: Text('Summary'),
                  // margin: EdgeInsets.only(right: 20, left: 20, bottom: 15),
                  children: [
                    CupertinoListTile(
                        title: Container(
                            margin: EdgeInsets.only(top: 10, bottom: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('TODO Conditional lesson text'),
                                Visibility(
                                    visible: Share.session.data.student.mainClass.unit.luckyNumber != null,
                                    child: Opacity(
                                        opacity: 0.5,
                                        child: Container(
                                            margin: EdgeInsets.only(top: 5), child: Text("You're the lucky one today!"))))
                              ],
                            ))),
                    CupertinoListTile(title: Text('TODO Conditional lesson text')),
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
                // Recent grades - in the middle, or top
                CupertinoListSection.insetGrouped(
                  header: Text('Recent grades'),
                  children: [
                    CupertinoListTile(
                        title: Opacity(
                            opacity: 0.5,
                            child: Container(
                                alignment: Alignment.center,
                                child: Text(
                                  'No recent grades',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
                                )))),
                  ],
                ),
                // Upcoming events - always below grades
                CupertinoListSection.insetGrouped(
                  header: Text('Upcoming events'),
                  children: [
                    CupertinoListTile(
                        title: Opacity(
                            opacity: 0.5,
                            child: Container(
                                alignment: Alignment.center,
                                child: Text(
                                  'No events to display',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
                                )))),
                  ],
                ),
                // Homeworks - first if any(), otherwise last
                Visibility(visible: homeworksLast, child: homeworksWidget)
              ],
            ),
          )
        ],
      ),
    );
  }
}

extension DateTimeExtension on DateTime {
  DateTime asDate() => DateTime(year, month, day);
}
