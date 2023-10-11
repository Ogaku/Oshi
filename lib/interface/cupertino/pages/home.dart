// ignore_for_file: prefer_const_constructors
// ignore_for_file: prefer_const_literals_to_create_immutables

import 'package:flutter/cupertino.dart';
import 'package:flutter/scheduler.dart';
import 'package:intl/intl.dart';
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
                // Recent grades - always in the middle
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
                CupertinoListSection.insetGrouped(
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
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
