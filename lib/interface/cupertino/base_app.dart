// ignore_for_file: prefer_const_constructors
// ignore_for_file: prefer_const_literals_to_create_immutables

import 'dart:io';

import 'package:flutter/cupertino.dart';

import 'package:oshi/interface/cupertino/pages/home.dart' show homePage;
import 'package:oshi/interface/cupertino/pages/grades.dart' show gradesPage;
import 'package:oshi/interface/cupertino/pages/timetable.dart' show timetablePage;
import 'package:oshi/interface/cupertino/pages/messages.dart' show messagesPage;
import 'package:oshi/interface/cupertino/pages/absences.dart' show absencesPage;
import 'package:oshi/share/share.dart';

// Boiler: returned to the main application
StatefulWidget get baseApp => BaseApp();

class BaseApp extends StatefulWidget {
  const BaseApp({super.key});

  @override
  State<BaseApp> createState() => _BaseAppState();
}

class _BaseAppState extends State<BaseApp> {
  CupertinoTabController tabController = CupertinoTabController();

  @override
  Widget build(BuildContext context) {
    // Re-subscribe to all events
    Share.tabsNavigatePage.unsubscribeAll();
    Share.tabsNavigatePage.subscribe((args) {
      if (args?.value == null) return;
      setState(() => tabController.index = args!.value.clamp(0, 4));
    });

    return CupertinoApp(
      home: CupertinoTabScaffold(
        controller: tabController,
        tabBar: CupertinoTabBar(backgroundColor: CupertinoTheme.of(context).barBackgroundColor.withAlpha(0xFF), items: [
          BottomNavigationBarItem(icon: Icon(CupertinoIcons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(CupertinoIcons.rosette), label: 'Grades'),
          BottomNavigationBarItem(icon: Icon(CupertinoIcons.calendar), label: 'Schedule'),
          BottomNavigationBarItem(icon: Icon(CupertinoIcons.envelope_fill), label: 'Messages'),
          BottomNavigationBarItem(icon: Icon(CupertinoIcons.person_crop_circle_badge_minus), label: 'Absences'),
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

  void _showAlertDialog(BuildContext context) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: const Text('Please update 🤓'),
        content:
            Text('The download page of the newer app version for ${Platform.isAndroid ? "Android" : "iOS"} will be opened.'),
        actions: <CupertinoDialogAction>[
          CupertinoDialogAction(
            onPressed: () {
              
              Navigator.pop(context);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
