// ignore_for_file: prefer_const_constructors
// ignore_for_file: prefer_const_literals_to_create_immutables

import 'package:flutter/cupertino.dart';

import 'package:ogaku/interface/cupertino/pages/home.dart' show homePage;
import 'package:ogaku/interface/cupertino/pages/grades.dart' show gradesPage;
import 'package:ogaku/interface/cupertino/pages/timetable.dart' show timetablePage;
import 'package:ogaku/interface/cupertino/pages/messages.dart' show messagesPage;
import 'package:ogaku/interface/cupertino/pages/absences.dart' show absencesPage;

// Boiler: returned to the main application
StatefulWidget get baseApp => BaseApp();

class BaseApp extends StatefulWidget {
  const BaseApp({super.key});

  @override
  State<BaseApp> createState() => _BaseAppState();
}

class _BaseAppState extends State<BaseApp> {
  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      home: CupertinoTabScaffold(
        tabBar: CupertinoTabBar(items: [
          BottomNavigationBarItem(icon: Icon(CupertinoIcons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(CupertinoIcons.rosette), label: 'Grades'),
          BottomNavigationBarItem(icon: Icon(CupertinoIcons.calendar), label: 'Timetable'),
          BottomNavigationBarItem(icon: Icon(CupertinoIcons.envelope_fill), label: 'Messages'),
          BottomNavigationBarItem(icon: Icon(CupertinoIcons.person_crop_circle_badge_checkmark), label: 'Absences'),
        ]),
        tabBuilder: (context, index) => CupertinoTabView(
          builder: (context) => switch (index) {
            0 => homePage,
            1 => gradesPage,
            2 => timetablePage,
            3 => messagesPage,
            4 => absencesPage,
            _ => homePage,
          },
        ),
      ),
    );
  }
}
