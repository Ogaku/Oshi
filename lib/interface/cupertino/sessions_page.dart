// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables
import 'dart:io';

import 'package:darq/darq.dart';
import 'package:flutter/cupertino.dart';
import 'package:event/event.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:format/format.dart';
import 'package:oshi/interface/cupertino/new_session.dart';
import 'package:oshi/models/progress.dart';
import 'package:oshi/share/appcenter.dart';
import 'package:oshi/share/notifications.dart';
import 'package:oshi/share/share.dart';
import 'package:oshi/share/translator.dart';
import 'package:oshi/interface/cupertino/base_app.dart';
import 'package:transparent_image/transparent_image.dart';

import 'package:oshi/interface/cupertino/widgets/navigation_bar.dart' show SliverNavigationBar;
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

// Boiler: returned to the main application
StatefulWidget get sessionsPage => SessionsPage();

class SessionsPage extends StatefulWidget {
  const SessionsPage({super.key});

  @override
  State<SessionsPage> createState() => _SessionsPageState();
}

class _SessionsPageState extends State<SessionsPage> {
  final scrollController = ScrollController();
  bool isWorking = false; // Logging in right now?
  String? _progressMessage;

  @override
  void initState() {
    super.initState();

    // Set up other stuff after the app's launched
    SchedulerBinding.instance.addPostFrameCallback((_) {
      Share.checkUpdates.broadcast(); // Check for updates
      NotificationController.requestNotificationAccess();
    });
  }

  @override
  Widget build(BuildContext context) {
    var sessionsList = Share.settings.sessions.sessions.keys
        .select(
          (x, index) => CupertinoListTile(
              padding: EdgeInsets.all(0),
              title: Builder(
                  builder: (context) => CupertinoContextMenu.builder(
                      enableHapticFeedback: true,
                      actions: [
                        CupertinoContextMenuAction(
                          onPressed: () async {
                            // Dismiss the context menu
                            Navigator.of(context, rootNavigator: true).pop();

                            // Remove the session
                            Share.settings.sessions.sessions.remove(x);
                            if (Share.settings.sessions.lastSessionId == x) {
                              Share.settings.sessions.lastSessionId =
                                  Share.settings.sessions.sessions.keys.firstOrDefault(defaultValue: null);
                            }

                            // Save our session changes
                            await Share.settings.save();
                            setState(() {}); // Reload
                          },
                          isDestructiveAction: true,
                          trailingIcon: CupertinoIcons.delete,
                          child: Text('/Delete'.localized),
                        ),
                      ],
                      // I know there's onTap too, but we need an opaque background
                      builder: (BuildContext context, Animation<double> animation) => Visibility(
                          visible: Share.settings.sessions.sessions[x] != null,
                          child: CupertinoButton(
                            color: CupertinoDynamicColor.withBrightness(
                                color: const Color.fromARGB(255, 255, 255, 255),
                                darkColor: const Color.fromARGB(255, 28, 28, 30)),
                            padding: EdgeInsets.zero,
                            onPressed: animation.value < CupertinoContextMenu.animationOpensAt
                                ? () async {
                                    if (isWorking) return; // Already handling something, give up
                                    setState(() {
                                      // Mark as working, the 1st refresh is gonna take a while
                                      isWorking = true;
                                    });

                                    var progress = Progress<({double? progress, String? message})>();
                                    progress.progressChanged
                                        .subscribe((args) => setState(() => _progressMessage = args?.value.message));

                                    // showCupertinoModalBottomSheet(context: context, builder: (context) => LoginPage(provider: x));
                                    Share.settings.sessions.lastSessionId = x; // Update
                                    Share.session = Share.settings.sessions.lastSession!;
                                    await Share.settings.save(); // Save our settings now

                                    // Suppress all errors, we must have already logged in at least once
                                    await Share.session.tryLogin(progress: progress, showErrors: false);
                                    await Share.session.refreshAll(progress: progress, showErrors: false);

                                    // Reset the animation in case we go back somehow
                                    setState(() => isWorking = false);
                                    progress.progressChanged.unsubscribeAll();
                                    _progressMessage = null; // Reset the message

                                    // Change the main page to the base application
                                    Share.changeBase.broadcast(Value(() => baseApp));
                                  }
                                : null,
                            child: Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.all(Radius.circular(10)),
                                    color: CupertinoDynamicColor.resolve(
                                        CupertinoDynamicColor.withBrightness(
                                            color: const Color.fromARGB(255, 255, 255, 255),
                                            darkColor: const Color.fromARGB(255, 28, 28, 30)),
                                        context)),
                                padding: EdgeInsets.only(right: 10, left: 22),
                                child: ConstrainedBox(
                                    constraints: BoxConstraints(
                                        maxHeight:
                                            animation.value < CupertinoContextMenu.animationOpensAt ? double.infinity : 100,
                                        maxWidth:
                                            animation.value < CupertinoContextMenu.animationOpensAt ? double.infinity : 300),
                                    child: Row(children: [
                                      ConstrainedBox(
                                          constraints:
                                              BoxConstraints(maxWidth: 120, maxHeight: 80, minWidth: 120, minHeight: 80),
                                          child: Container(
                                              margin: EdgeInsets.only(top: 20, bottom: 20),
                                              child: Visibility(
                                                  visible: Share.settings.sessions.sessions[x]?.provider.providerBannerUri !=
                                                      null,
                                                  child: FadeInImage.memoryNetwork(
                                                      height: 37,
                                                      placeholder: kTransparentImage,
                                                      image: Share.settings.sessions.sessions[x]?.provider.providerBannerUri
                                                              ?.toString() ??
                                                          'https://i.pinimg.com/736x/6b/db/93/6bdb93f8d708c51e0431406f7e06f299.jpg')))),
                                      Visibility(
                                          visible: Share.settings.sessions.sessions[x]?.provider.providerBannerUri != null,
                                          child: Container(
                                            width: 1,
                                            height: 40,
                                            margin: EdgeInsets.only(left: 20, right: 20),
                                            decoration: const BoxDecoration(
                                                borderRadius: BorderRadius.all(Radius.circular(10)),
                                                color: Color(0x33AAAAAA)),
                                          )),
                                      Flexible(
                                          child: Container(
                                              margin: EdgeInsets.only(right: 20),
                                              child: Text(
                                                Share.settings.sessions.sessions[x]?.sessionName ?? '',
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    color: CupertinoDynamicColor.resolve(
                                                        CupertinoDynamicColor.withBrightness(
                                                            color: CupertinoColors.black, darkColor: CupertinoColors.white),
                                                        context)),
                                              )))
                                    ]))),
                          ))))),
        )
        .toList();

    return CupertinoApp(
        theme: _eventfulColorTheme,
        debugShowCheckedModeBanner: false,
        home: Builder(builder: (context) {
          ErrorWidget.builder = errorView;

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

          AppCenter.checkForUpdates().then((value) {
            if (value.result) _showAlertDialog(context, value.download);
          }).catchError((ex) {});

          return CupertinoPageScaffold(
              backgroundColor: CupertinoDynamicColor.withBrightness(
                  color: const Color.fromARGB(255, 242, 242, 247), darkColor: const Color.fromARGB(255, 0, 0, 0)),
              child: CustomScrollView(controller: scrollController, slivers: [
                SliverNavigationBar(
                  transitionBetweenRoutes: true,
                  scrollController: scrollController,
                  largeTitle: FittedBox(
                      fit: BoxFit.fitWidth,
                      child:
                          Container(margin: EdgeInsets.only(right: 20), child: Text('/Session/Page/RegisterAcc'.localized))),
                  middle: Visibility(
                      visible: _progressMessage?.isEmpty ?? true, child: Text('/Session/Page/RegisterAcc'.localized)),
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
                                style: TextStyle(
                                    color: CupertinoColors.inactiveGray, fontSize: 13, fontWeight: FontWeight.w300),
                              )))),
                  trailing: isWorking
                      ? CupertinoActivityIndicator()
                      : GestureDetector(
                          child: Icon(CupertinoIcons.question_circle),
                          onTap: () async {
                            try {
                              await launchUrlString('https://github.com/Ogaku');
                            } catch (ex) {
                              // ignored
                            }
                          },
                        ),
                ),
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Container(
                    padding: EdgeInsets.only(bottom: 20),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Align(
                              alignment: Alignment.centerLeft,
                              child: Container(
                                  margin: EdgeInsets.only(right: 20, left: 20, bottom: 20),
                                  child: Text(
                                    '/Session/Page/RegisterLog'.localized,
                                    style: TextStyle(fontSize: 14),
                                  ))),
                          Visibility(
                              visible: sessionsList.isNotEmpty,
                              child: CupertinoListSection.insetGrouped(
                                  margin: EdgeInsets.only(left: 15, right: 15, bottom: 10),
                                  hasLeading: false,
                                  header: sessionsList.isEmpty ? Text('/Sessions'.localized) : null,
                                  children: sessionsList)),
                          CupertinoListSection.insetGrouped(
                              hasLeading: false,
                              margin: EdgeInsets.only(left: 15, right: 15, bottom: 10, top: 5),
                              children: [
                                CupertinoListTile(
                                    padding: EdgeInsets.all(0),
                                    title: Builder(
                                        builder: (context) => CupertinoButton(
                                              padding: EdgeInsets.only(left: 20),
                                              child: Align(
                                                  alignment: Alignment.center,
                                                  child: Container(
                                                    margin: EdgeInsets.all(25),
                                                    child: Icon(CupertinoIcons.add_circled),
                                                  )),
                                              onPressed: () {
                                                Navigator.push(
                                                    context, CupertinoPageRoute(builder: (context) => NewSessionPage()));
                                              },
                                            )))
                              ]),
                          Expanded(
                              child: Align(
                                  alignment: Alignment.bottomCenter,
                                  child: Opacity(
                                      opacity: 0.5,
                                      child: Container(
                                          margin: EdgeInsets.only(right: 30, left: 30, bottom: 10),
                                          child: Text(
                                            '/TrademarkInfo'.localized,
                                            style: TextStyle(fontSize: 12),
                                            textAlign: TextAlign.center,
                                          ))))),
                          Opacity(
                              opacity: 0.25,
                              child: Text(
                                Share.buildNumber,
                                style: TextStyle(fontSize: 12),
                              )),
                        ]),
                  ),
                )
              ]));
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
    return CupertinoThemeData(primaryColor: const Color(0xFFbe72e1));
  }
}
