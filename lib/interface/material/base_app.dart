// ignore_for_file: prefer_const_constructors
// ignore_for_file: prefer_const_literals_to_create_immutables

import 'dart:io';

import 'package:appcenter_sdk_flutter/appcenter_sdk_flutter.dart' as apps;
import 'package:darq/darq.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:format/format.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:oshi/share/appcenter.dart';
import 'package:oshi/share/notifications.dart';
import 'package:oshi/share/translator.dart';
import 'package:path/path.dart' as path;
import 'package:oshi/share/platform.dart';

import 'package:oshi/interface/material/pages/home.dart' show homePage;
import 'package:oshi/interface/material/pages/grades.dart' show gradesPage;
import 'package:oshi/interface/material/pages/timetable.dart' show timetablePage;
import 'package:oshi/interface/material/pages/messages.dart' show messagesPage;
import 'package:oshi/interface/material/pages/absences.dart' show absencesPage;
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
  int currentPageIndex = 0;

  @override
  void initState() {
    super.initState();

    // Set up a filesystem watcher
    if (kDebugMode && isWindows) {
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
      setState(() => currentPageIndex = args!.value.clamp(0, 4));
    });

    // Re-subscribe to all events - refresh
    Share.refreshBase.unsubscribeAll();
    Share.refreshBase.subscribe((args) => setState(() {}));

    return DynamicColorBuilder(
        builder: (lightColorScheme, darkColorScheme) => MaterialApp(
            theme: ThemeData(
              colorScheme: lightColorScheme,
              useMaterial3: true,
            ),
            darkTheme: ThemeData(
              colorScheme: darkColorScheme,
              useMaterial3: true,
            ),
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
                    await showMaterialModalBottomSheet(
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

                  return Scaffold(
                    bottomNavigationBar: NavigationBar(
                      onDestinationSelected: (int index) {
                        setState(() {
                          currentPageIndex = index;
                        });
                      },
                      selectedIndex: currentPageIndex,
                      destinations: <Widget>[
                        NavigationDestination(
                          selectedIcon: Icon(Icons.home),
                          icon: Icon(Icons.home_outlined),
                          label: '/Titles/Pages/Home'.localized,
                        ),
                        NavigationDestination(
                          selectedIcon: Stack(children: <Widget>[
                            Icon(Icons.grade),
                            AnimatedOpacity(
                                duration: const Duration(milliseconds: 500),
                                opacity: Share.session.unreadChanges.gradesCount > 0 ? 1.0 : 0.0,
                                child: Positioned(
                                  top: 0.0,
                                  right: 0.0,
                                  child: Icon(Icons.brightness_1, size: 8.0, color: Colors.redAccent),
                                ))
                          ]),
                          icon: Stack(children: <Widget>[
                            Icon(Icons.grade_outlined),
                            AnimatedOpacity(
                                duration: const Duration(milliseconds: 500),
                                opacity: Share.session.unreadChanges.gradesCount > 0 ? 1.0 : 0.0,
                                child: Positioned(
                                  top: 0.0,
                                  right: 0.0,
                                  child: Icon(Icons.brightness_1, size: 8.0, color: Colors.redAccent),
                                ))
                          ]),
                          label: '/Titles/Pages/Grades'.localized,
                        ),
                        NavigationDestination(
                          selectedIcon: Stack(children: <Widget>[
                            Icon(Icons.schedule),
                            AnimatedOpacity(
                                duration: const Duration(milliseconds: 500),
                                opacity:
                                    (Share.session.unreadChanges.timetablesCount + Share.session.unreadChanges.eventsCount) >
                                            0
                                        ? 1.0
                                        : 0.0,
                                child: Positioned(
                                  top: 0.0,
                                  right: 0.0,
                                  child: Icon(Icons.brightness_1, size: 8.0, color: Colors.redAccent),
                                ))
                          ]),
                          icon: Stack(children: <Widget>[
                            Icon(Icons.schedule_outlined),
                            AnimatedOpacity(
                                duration: const Duration(milliseconds: 500),
                                opacity:
                                    (Share.session.unreadChanges.timetablesCount + Share.session.unreadChanges.eventsCount) >
                                            0
                                        ? 1.0
                                        : 0.0,
                                child: Positioned(
                                  top: 0.0,
                                  right: 0.0,
                                  child: Icon(Icons.brightness_1, size: 8.0, color: Colors.redAccent),
                                ))
                          ]),
                          label: '/Titles/Pages/Schedule'.localized,
                        ),
                        NavigationDestination(
                          selectedIcon: Stack(children: <Widget>[
                            Icon(Icons.message),
                            AnimatedOpacity(
                                duration: const Duration(milliseconds: 500),
                                opacity: (Share.session.unreadChanges.announcementsCount +
                                            Share.session.unreadChanges.messagesCount >
                                        0)
                                    ? 1.0
                                    : 0.0,
                                child: Positioned(
                                  top: 0.0,
                                  right: 0.0,
                                  child: Icon(Icons.brightness_1, size: 8.0, color: Colors.redAccent),
                                ))
                          ]),
                          icon: Stack(children: <Widget>[
                            Icon(Icons.message_outlined),
                            AnimatedOpacity(
                                duration: const Duration(milliseconds: 500),
                                opacity: (Share.session.unreadChanges.announcementsCount +
                                            Share.session.unreadChanges.messagesCount >
                                        0)
                                    ? 1.0
                                    : 0.0,
                                child: Positioned(
                                  top: 0.0,
                                  right: 0.0,
                                  child: Icon(Icons.brightness_1, size: 8.0, color: Colors.redAccent),
                                ))
                          ]),
                          label: '/Titles/Pages/Messages'.localized,
                        ),
                        NavigationDestination(
                          selectedIcon: Stack(children: <Widget>[
                            Icon(Icons.person_remove),
                            AnimatedOpacity(
                                duration: const Duration(milliseconds: 500),
                                opacity: Share.session.unreadChanges.attendancesCount > 0 ? 1.0 : 0.0,
                                child: Positioned(
                                  top: 0.0,
                                  right: 0.0,
                                  child: Icon(Icons.brightness_1, size: 8.0, color: Colors.redAccent),
                                ))
                          ]),
                          icon: Stack(children: <Widget>[
                            Icon(Icons.person_remove_outlined),
                            AnimatedOpacity(
                                duration: const Duration(milliseconds: 500),
                                opacity: Share.session.unreadChanges.attendancesCount > 0 ? 1.0 : 0.0,
                                child: Positioned(
                                  top: 0.0,
                                  right: 0.0,
                                  child: Icon(Icons.brightness_1, size: 8.0, color: Colors.redAccent),
                                ))
                          ]),
                          label: '/Titles/Pages/Absences'.localized,
                        ),
                      ],
                    ),
                    body: <Widget>[
                      homePage,
                      gradesPage,
                      timetablePage,
                      messagesPage,
                      absencesPage,
                    ][currentPageIndex],
                  );
                }),
              );
            })));
  }

  void _showAlertDialog(BuildContext context, Uri url) {
    if (kIsWeb) return;
    showMaterialModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: Text('/BaseApp/Update/AlertHeader'.localized),
        content: Text('/BaseApp/Update/Alert'.localized.format(isAndroid ? 'Android' : 'iOS')),
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
