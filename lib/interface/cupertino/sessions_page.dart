// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:io';

import 'package:darq/darq.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:event/event.dart';
import 'package:oshi/interface/cupertino/new_session.dart';
import 'package:oshi/models/progress.dart';
import 'package:oshi/share/share.dart';
import 'package:oshi/interface/cupertino/base_app.dart';
import 'package:transparent_image/transparent_image.dart';

import 'package:oshi/interface/cupertino/widgets/navigation_bar.dart' show SliverNavigationBar;
import 'package:url_launcher/url_launcher_string.dart';
import 'package:version/version.dart';

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
  Widget build(BuildContext context) {
    var sessionsList = Share.settings.sessions.sessions.keys
        .select(
          (x, index) => CupertinoListTile(
              padding: EdgeInsets.all(0),
              title: Builder(
                  builder: (context) => CupertinoContextMenu.builder(
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
                              child: const Text('Delete'),
                            ),
                          ],
                          // I know there's onTap too, but we need an opaque background
                          builder: (BuildContext context, Animation<double> animation) => Visibility(
                              visible: Share.settings.sessions.sessions[x] != null,
                              child: CupertinoButton(
                                color: CupertinoDynamicColor.withBrightness(
                                    color: const Color.fromARGB(255, 255, 255, 255),
                                    darkColor: const Color.fromARGB(255, 28, 28, 30)),
                                padding: EdgeInsets.only(left: 20),
                                child: Container(
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(Radius.circular(10)),
                                        color: CupertinoDynamicColor.resolve(
                                            CupertinoDynamicColor.withBrightness(
                                                color: const Color.fromARGB(255, 255, 255, 255),
                                                darkColor: const Color.fromARGB(255, 28, 28, 30)),
                                            context)),
                                    padding: EdgeInsets.only(right: 10, left: 6),
                                    child: ConstrainedBox(
                                        constraints: BoxConstraints(
                                            maxHeight: animation.value < CupertinoContextMenu.animationOpensAt
                                                ? double.infinity
                                                : 100,
                                            maxWidth: animation.value < CupertinoContextMenu.animationOpensAt
                                                ? double.infinity
                                                : 300),
                                        child: Row(children: [
                                          ConstrainedBox(
                                              constraints:
                                                  BoxConstraints(maxWidth: 120, maxHeight: 80, minWidth: 120, minHeight: 80),
                                              child: Container(
                                                  margin: EdgeInsets.only(top: 20, bottom: 20),
                                                  child: Visibility(
                                                      visible:
                                                          Share.settings.sessions.sessions[x]?.provider.providerBannerUri !=
                                                              null,
                                                      child: FadeInImage.memoryNetwork(
                                                          height: 37,
                                                          placeholder: kTransparentImage,
                                                          image: Share
                                                                  .settings.sessions.sessions[x]?.provider.providerBannerUri
                                                                  ?.toString() ??
                                                              'https://i.pinimg.com/736x/6b/db/93/6bdb93f8d708c51e0431406f7e06f299.jpg')))),
                                          Visibility(
                                              visible:
                                                  Share.settings.sessions.sessions[x]?.provider.providerBannerUri != null,
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
                                                                color: CupertinoColors.black,
                                                                darkColor: CupertinoColors.white),
                                                            context)),
                                                  )))
                                        ]))),
                                onPressed: () async {
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
                                  var result =
                                      await Share.session.tryLogin(progress: progress, showErrors: true); // Log in now

                                  if (!result.success) {
                                    setState(() {
                                      // Reset the animation in case the login method hasn't finished
                                      isWorking = false;

                                      progress.progressChanged.unsubscribeAll();
                                      _progressMessage = null; // Reset the message
                                    });
                                    return; // Give up, not this time
                                  }

                                  await Share.settings.save(); // Save our settings now
                                  result = await Share.session.refreshAll(progress: progress); // Refresh everything

                                  if (!result.success) {
                                    setState(() {
                                      // Reset the animation in case the login method hasn't finished
                                      isWorking = false;

                                      progress.progressChanged.unsubscribeAll();
                                      _progressMessage = null; // Reset the message
                                    });
                                    return; // Give up, not this time
                                  }

                                  // Reset the animation in case we go back somehow
                                  setState(() => isWorking = false);
                                  progress.progressChanged.unsubscribeAll();
                                  _progressMessage = null; // Reset the message

                                  // Change the main page to the base application
                                  Share.changeBase.broadcast(Value(() => baseApp));
                                },
                              ))))),
        )
        .toList();

    return CupertinoApp(
        theme: _eventfulColorTheme,
        home: Builder(builder: (context) {
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

          if (!Share.hasCheckedForUpdates) {
            try {
              (Dio().get('https://api.github.com/repos/Ogaku/Oshi/releases/latest')).then((value) {
                try {
                  if (Version.parse(value.data['tag_name']) <= Version.parse(Share.buildNumber)) return;
                  var download = (value.data['assets'] as List<dynamic>?)
                      ?.firstWhereOrDefault((x) =>
                          x['name']?.toString().contains(Platform.isAndroid ? '.apk' : '.ipa') ??
                          false)?['browser_download_url']
                      ?.toString();

                  if (download?.isNotEmpty ?? false) _showAlertDialog(context, download ?? 'https://youtu.be/dQw4w9WgXcQ');
                } catch (ex) {
                  // ignored
                }
              });
            } catch (ex) {
              // ignored
            }

            Share.hasCheckedForUpdates = true;
          }

          return CupertinoPageScaffold(
              backgroundColor: CupertinoDynamicColor.withBrightness(
                  color: const Color.fromARGB(255, 242, 242, 247), darkColor: const Color.fromARGB(255, 0, 0, 0)),
              child: CustomScrollView(controller: scrollController, slivers: [
                SliverNavigationBar(
                  transitionBetweenRoutes: true,
                  scrollController: scrollController,
                  largeTitle: FittedBox(
                      fit: BoxFit.fitWidth,
                      child: Container(margin: EdgeInsets.only(right: 20), child: Text('E-register accounts'))),
                  middle: Visibility(visible: _progressMessage?.isEmpty ?? true, child: Text('E-register accounts')),
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
                                    'These are your e-register accounts. Choose one of the currently logged-in sessions, or go create a new one.',
                                    style: TextStyle(fontSize: 14),
                                  ))),
                          Visibility(
                              visible: sessionsList.isNotEmpty,
                              child: CupertinoListSection.insetGrouped(
                                  margin: EdgeInsets.only(left: 15, right: 15, bottom: 10),
                                  hasLeading: false,
                                  header: sessionsList.isEmpty ? Text('Sessions') : null,
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
                                            "All trademarks featured in this app remain the property of their rightful owners, and are used for informational purposes only.",
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

  void _showAlertDialog(BuildContext context, String url) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: const Text('Please update 🤓'),
        content:
            Text('The download page of the newer app version for ${Platform.isAndroid ? "Android" : "iOS"} will be opened.'),
        actions: <CupertinoDialogAction>[
          CupertinoDialogAction(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await launchUrlString(url);
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
    if (DateTime.now().month == DateTime.december &&
        (DateTime.now().day == 24 || DateTime.now().day == 25 || DateTime.now().day == 26)) {
      return CupertinoThemeData(primaryColor: CupertinoColors.systemRed);
    }
    // Default colors - should be changeable through settings TODO
    return CupertinoThemeData(primaryColor: CupertinoColors.systemRed);
  }
}
