// ignore_for_file: prefer_const_constructors
// ignore_for_file: prefer_const_literals_to_create_immutables

import 'dart:io';

import 'package:appcenter_sdk_flutter/appcenter_sdk_flutter.dart' as apps;
import 'package:darq/darq.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:format/format.dart';
import 'package:oshi/share/appcenter.dart';
import 'package:oshi/share/notifications.dart';
import 'package:oshi/share/translator.dart';
import 'package:path/path.dart' as path;

import 'package:oshi/interface/cupertino/pages/home.dart' show homePage;
import 'package:oshi/interface/cupertino/pages/grades.dart' show gradesPage;
import 'package:oshi/interface/cupertino/pages/timetable.dart' show timetablePage;
import 'package:oshi/interface/cupertino/pages/messages.dart' show messagesPage;
import 'package:oshi/interface/cupertino/pages/absences.dart' show absencesPage;
import 'package:oshi/share/share.dart';
import 'package:show_fps/show_fps.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:visibility_detector/visibility_detector.dart';

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
  void initState() {
    super.initState();

    // Set up a filesystem watcher
    if (kDebugMode && Platform.isWindows) {
      File(path.join(Directory.current.path, 'assets/resources/strings')).watch().listen((event) =>
          Share.translator.loadResources(Share.settings.appSettings.languageCode).then((value) => setState(() {})));
    }

    // Set up other stuff after the app's launched
    SchedulerBinding.instance.addPostFrameCallback((_) {
      Share.checkUpdates.broadcast(); // Check for updates
      NotificationController.requestNotificationAccess();
    });
  }

  @override
  void dispose() {
    Share.refreshAll.unsubscribe(refresh);
    super.dispose();
  }

  void refresh(args) {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // Re-subscribe to all events - navigation
    Share.refreshAll.unsubscribe(refresh);
    Share.refreshAll.subscribe(refresh);

    Share.tabsNavigatePage.unsubscribeAll();
    Share.tabsNavigatePage.subscribe((args) {
      if (args?.value == null) return;
      setState(() => tabController.index = args!.value.clamp(0, 4));
    });

    // Re-subscribe to all events - refresh
    Share.refreshBase.unsubscribeAll();
    Share.refreshBase.subscribe((args) => setState(() {}));

    return CupertinoApp(
        theme: _eventfulColorTheme,
        debugShowCheckedModeBanner: false,
        home: Builder(builder: (context) {
          ErrorWidget.builder = errorView;

          // Re-subscribe to all events - update
          Share.checkUpdates.unsubscribeAll();
          Share.checkUpdates.subscribe((args) => _checkforUpdates(context));

          return ShowFPS(
              alignment: Alignment.topLeft,
              visible: Share.session.settings.devMode,
              showChart: Share.session.settings.devMode,
              borderRadius: BorderRadius.all(Radius.circular(11)),
              child: Builder(builder: (context) {
                // Re-subscribe to all events - modals
                Share.showErrorModal.unsubscribeAll();
                Share.showErrorModal.subscribe((args) async {
                  if (args?.value == null) return;
                  await showCupertinoModalPopup(
                      context: context,
                      useRootNavigator: true,
                      builder: (s) => CupertinoActionSheet(
                          title: Text(args!.value.title),
                          message: Text(args.value.message),
                          actions: args.value.actions.isEmpty
                              ? null
                              : args.value.actions.entries
                                  .select(
                                    (x, index) => CupertinoActionSheetAction(
                                      child: Text(x.key),
                                      onPressed: () {
                                        try {
                                          x.value();
                                        } catch (ex) {
                                          // ignored
                                        }
                                        Navigator.of(context, rootNavigator: true).pop();
                                      },
                                    ),
                                  )
                                  .toList()));
                });

                return CupertinoTabScaffold(
                    controller: tabController,
                    tabBar: CupertinoTabBar(
                        backgroundColor: CupertinoTheme.of(context).barBackgroundColor.withAlpha(255),
                        border: Border(
                          bottom: BorderSide(
                            color: CupertinoDynamicColor.resolve(
                                CupertinoDynamicColor.withBrightness(
                                    color: const Color(0xFFBCBBC0), darkColor: const Color(0xFF262626)),
                                context),
                            width: 0.0,
                          ),
                        ),
                        items: [
                          BottomNavigationBarItem(
                              icon: Stack(alignment: Alignment.bottomRight, children: [
                                Container(
                                    padding: EdgeInsets.only(bottom: 3, right: 3),
                                    margin: EdgeInsets.only(top: 3, left: 3),
                                    child: Icon(CupertinoIcons.home))
                              ]),
                              label: '/Titles/Pages/Home'.localized),
                          BottomNavigationBarItem(
                              icon: Stack(alignment: Alignment.bottomRight, children: [
                                Container(
                                    padding: EdgeInsets.only(bottom: 3, right: 3),
                                    margin: EdgeInsets.only(top: 3, left: 3),
                                    child: Icon(CupertinoIcons.rosette)),
                                AnimatedOpacity(
                                    duration: const Duration(milliseconds: 500),
                                    opacity: Share.session.unreadChanges.gradesCount > 0 ? 1.0 : 0.0,
                                    child: Container(
                                        margin: EdgeInsets.only(),
                                        child: Container(
                                          height: 10,
                                          width: 10,
                                          decoration: BoxDecoration(
                                              shape: BoxShape.circle, color: CupertinoTheme.of(context).primaryColor),
                                        )))
                              ]),
                              label: '/Titles/Pages/Grades'.localized),
                          BottomNavigationBarItem(
                              icon: Stack(alignment: Alignment.bottomRight, children: [
                                Container(
                                    padding: EdgeInsets.only(bottom: 3, right: 3),
                                    margin: EdgeInsets.only(top: 3, left: 3),
                                    child: Icon(CupertinoIcons.calendar)),
                                AnimatedOpacity(
                                    duration: const Duration(milliseconds: 500),
                                    opacity: (Share.session.unreadChanges.timetablesCount +
                                                Share.session.unreadChanges.eventsCount) >
                                            0
                                        ? 1.0
                                        : 0.0,
                                    child: Container(
                                        margin: EdgeInsets.only(),
                                        child: Container(
                                          height: 10,
                                          width: 10,
                                          decoration: BoxDecoration(
                                              shape: BoxShape.circle, color: CupertinoTheme.of(context).primaryColor),
                                        )))
                              ]),
                              label: '/Titles/Pages/Schedule'.localized),
                          BottomNavigationBarItem(
                              icon: Stack(alignment: Alignment.bottomRight, children: [
                                Container(
                                    padding: EdgeInsets.only(bottom: 3, right: 3),
                                    margin: EdgeInsets.only(top: 3, left: 3),
                                    child: Icon(CupertinoIcons.envelope)),
                                AnimatedOpacity(
                                    duration: const Duration(milliseconds: 500),
                                    opacity: (Share.session.unreadChanges.announcementsCount +
                                                Share.session.unreadChanges.messagesCount >
                                            0)
                                        ? 1.0
                                        : 0.0,
                                    child: Container(
                                        margin: EdgeInsets.only(),
                                        child: Container(
                                          height: 10,
                                          width: 10,
                                          decoration: BoxDecoration(
                                              shape: BoxShape.circle, color: CupertinoTheme.of(context).primaryColor),
                                        )))
                              ]),
                              label: '/Titles/Pages/Messages'.localized),
                          BottomNavigationBarItem(
                              icon: Stack(alignment: Alignment.bottomRight, children: [
                                Container(
                                    padding: EdgeInsets.only(bottom: 3, right: 3),
                                    margin: EdgeInsets.only(top: 3, left: 3),
                                    child: Icon(CupertinoIcons.person_crop_circle_badge_minus)),
                                AnimatedOpacity(
                                    duration: const Duration(milliseconds: 500),
                                    opacity: Share.session.unreadChanges.attendancesCount > 0 ? 1.0 : 0.0,
                                    child: Container(
                                        margin: EdgeInsets.only(),
                                        child: Container(
                                          height: 10,
                                          width: 10,
                                          decoration: BoxDecoration(
                                              shape: BoxShape.circle, color: CupertinoTheme.of(context).primaryColor),
                                        )))
                              ]),
                              label: '/Titles/Pages/Absences'.localized),
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
                        ));
              }));
        }));
  }

  void _showAlertDialog(BuildContext context, Uri url) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: Text('/BaseApp/Update/AlertHeader'.localized),
        content: Text('/BaseApp/Update/Alert'.localized.format(Platform.isAndroid ? 'Android' : 'iOS')),
        actions: <CupertinoDialogAction>[
          CupertinoDialogAction(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await launchUrl(url);
              } catch (ex) {
                // ignored
              }
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _checkforUpdates(BuildContext context) {
    AppCenter.checkForUpdates().then((value) {
      if (value.result) _showAlertDialog(context, value.download);
    }).catchError((ex) {});
  }

  CupertinoThemeData get _eventfulColorTheme {
    // Halloween colors
    if (DateTime.now().month == DateTime.october && DateTime.now().day == 31) {
      return CupertinoThemeData(primaryColor: CupertinoColors.systemOrange);
    }
    // St. Peter day colors
    if (DateTime.now().month == DateTime.july && DateTime.now().day == 12) {
      return CupertinoThemeData(primaryColor: CupertinoColors.systemGreen);
    }
    // Christmas colors
    if (DateTime.now().month == DateTime.december && (DateTime.now().day >= 20 && DateTime.now().day <= 30)) {
      return CupertinoThemeData(primaryColor: CupertinoColors.systemRed);
    }
    // Default colors - should be changeable through settings
    return CupertinoThemeData(primaryColor: Share.session.settings.cupertinoAccentColor.color);
  }
}

class UnreadDot extends StatefulWidget {
  const UnreadDot({super.key, required this.unseen, this.markAsSeen, this.margin = EdgeInsets.zero});

  final EdgeInsets margin;
  final bool Function() unseen;
  final void Function()? markAsSeen;

  @override
  State<UnreadDot> createState() => _UnreadDotState();
}

class _UnreadDotState extends State<UnreadDot> {
  late bool unseen;

  @override
  void initState() {
    super.initState();
    unseen = widget.unseen();
  }

  @override
  void dispose() {
    Share.refreshAll.unsubscribe(refresh);
    super.dispose();
  }

  void refresh(args) => setState(() => unseen = widget.unseen());

  @override
  Widget build(BuildContext context) {
    Share.refreshAll.unsubscribe(refresh);
    Share.refreshAll.subscribe(refresh);

    return AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        child: unseen
            ? VisibilityDetector(
                key: UniqueKey(),
                onVisibilityChanged: (s) => Future.delayed(Duration(seconds: 1)).then((value) {
                      if (s.visibleFraction >= 1 && widget.markAsSeen != null) {
                        setState(() {
                          widget.markAsSeen!();
                          unseen = widget.unseen();
                          Share.refreshBase.broadcast();
                          Share.refreshAll.broadcast();
                        });
                      }
                    }),
                child: Container(
                    margin: widget.margin,
                    child: Container(
                      height: 10,
                      width: 10,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: CupertinoTheme.of(context).primaryColor),
                    )))
            : null);
  }
}

/* 

        child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            child: opacity
                ? VisibilityDetector(
                    key: UniqueKey(),
                    onVisibilityChanged: (s) {},
                    child: Container(
                        margin: widget.margin,
                        child: Container(
                          height: 10,
                          width: 10,
                          decoration: BoxDecoration(shape: BoxShape.circle, color: CupertinoTheme.of(context).primaryColor),
                        )))
                : null));
  }


 */

Widget errorView(FlutterErrorDetails details) => CupertinoAlertDialog(
      title: Text('A fucksy-wucksie occurd!'),
      content: Column(children: [
        Container(margin: EdgeInsets.only(top: 15, bottom: 10), child: Text(details.exceptionAsString())),
        Opacity(opacity: 0.6, child: Text(details.stack.toString())),
      ]),
      actions: [
        CupertinoButton(
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: '${details.exceptionAsString()}\n\n${details.stack.toString()}'));
              await apps.AppCenterCrashes.trackException(message: details.exceptionAsString(), stackTrace: details.stack);
            },
            child: const Text('Press F to pay respects', style: TextStyle(color: CupertinoColors.destructiveRed)))
      ],
    );
