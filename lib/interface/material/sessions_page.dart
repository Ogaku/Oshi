// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:darq/darq.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:event/event.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_swipe_action_cell/core/cell.dart';
import 'package:format/format.dart';
import 'package:oshi/interface/material/base_app.dart';
import 'package:oshi/interface/material/new_session.dart';
import 'package:oshi/models/progress.dart';
import 'package:oshi/share/appcenter.dart';
import 'package:oshi/share/notifications.dart';
import 'package:oshi/share/platform.dart';
import 'package:oshi/share/share.dart';
import 'package:oshi/share/translator.dart';
import 'package:transparent_image/transparent_image.dart';
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
    return DynamicColorBuilder(
        builder: (lightColorScheme, darkColorScheme) => Builder(builder: (context) {
              var sessionsList = Share.settings.sessions.sessions.keys
                  .select(
                    (x, index) => Container(
                        margin: EdgeInsets.only(left: 20, right: 20, top: 5),
                        child: Builder(
                            builder: (context) => Visibility(
                                visible: Share.settings.sessions.sessions[x] != null,
                                child: MaterialButton(
                                    padding: EdgeInsets.only(),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(Radius.circular(10)),
                                      ),
                                      child: SwipeActionCell(
                                          key: UniqueKey(),
                                          backgroundColor: Colors.transparent,
                                          trailingActions: <SwipeAction>[
                                            SwipeAction(
                                                performsFirstActionWithFullSwipe: true,
                                                content: Container(
                                                  width: 50,
                                                  height: 50,
                                                  decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(25),
                                                    color: Colors.red,
                                                  ),
                                                  child: Icon(
                                                    Icons.delete,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                onTap: (CompletionHandler handler) async {
                                                  // Remove the session
                                                  Share.settings.sessions.sessions.remove(x);
                                                  if (Share.settings.sessions.lastSessionId == x) {
                                                    Share.settings.sessions.lastSessionId = Share
                                                        .settings.sessions.sessions.keys
                                                        .firstOrDefault(defaultValue: null);
                                                  }

                                                  // Save our session changes
                                                  await Share.settings.save();
                                                  setState(() {}); // Reload
                                                },
                                                color: CupertinoColors.destructiveRed)
                                          ],
                                          child: Container(
                                            padding: EdgeInsets.only(right: 10, left: 22),
                                            child: ConstrainedBox(
                                                constraints: BoxConstraints(maxHeight: 100, maxWidth: 300),
                                                child: Row(children: [
                                                  ConstrainedBox(
                                                      constraints: BoxConstraints(
                                                          maxWidth: 120, maxHeight: 80, minWidth: 120, minHeight: 80),
                                                      child: Container(
                                                          margin: EdgeInsets.only(top: 20, bottom: 20),
                                                          child: Visibility(
                                                              visible: Share.settings.sessions.sessions[x]?.provider
                                                                      .providerBannerUri !=
                                                                  null,
                                                              child: FadeInImage.memoryNetwork(
                                                                  height: 37,
                                                                  placeholder: kTransparentImage,
                                                                  image: Share.settings.sessions.sessions[x]?.provider
                                                                          .providerBannerUri
                                                                          ?.toString() ??
                                                                      'https://i.pinimg.com/736x/6b/db/93/6bdb93f8d708c51e0431406f7e06f299.jpg')))),
                                                  Visibility(
                                                      visible:
                                                          Share.settings.sessions.sessions[x]?.provider.providerBannerUri !=
                                                              null,
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
                                                                fontSize: 15,
                                                                color: CupertinoDynamicColor.resolve(
                                                                    CupertinoDynamicColor.withBrightness(
                                                                        color: CupertinoColors.black,
                                                                        darkColor: CupertinoColors.white),
                                                                    context)),
                                                          )))
                                                ])),
                                          )),
                                    ))))),
                  )
                  .toList();

              return MaterialApp(
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

                  // Re-subscribe to all events - modals
                  Share.showErrorModal.unsubscribeAll();
                  Share.showErrorModal.subscribe((args) async {
                    if (args?.value == null) return;
                    await showDialog<void>(
                      context: context,
                      builder: (BuildContext context) => AlertDialog(
                          title: Text(args!.value.title),
                          content: Text(args.value.message),
                          actions: args.value.actions.isEmpty
                              ? []
                              : args.value.actions.entries
                                  .select(
                                    (x, index) => TextButton(
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
                                  .toList()),
                    );
                  });

                  AppCenter.checkForUpdates().then((value) {
                    if (value.result) _showAlertDialog(context, value.download);
                  }).catchError((ex) {});

                  return Scaffold(
                    body: CustomScrollView(
                      slivers: <Widget>[
                        SliverAppBar(
                          title: _progressMessage != null
                              ? Text(
                                  _progressMessage!,
                                  style: TextStyle(fontSize: 14),
                                )
                              : null,
                          actions: [
                            Container(
                              padding: EdgeInsets.only(right: 10),
                              child: TextButton(
                                onPressed: isWorking
                                    ? null
                                    : () async {
                                        try {
                                          await launchUrlString('https://github.com/Ogaku');
                                        } catch (ex) {
                                          // ignored
                                        }
                                      },
                                child: isWorking ? CupertinoActivityIndicator() : Icon(Icons.help_outline_rounded),
                              ),
                            )
                          ],
                          pinned: true,
                          snap: false,
                          floating: false,
                          expandedHeight: 130.0,
                          flexibleSpace: FlexibleSpaceBar(
                              centerTitle: false,
                              titlePadding: EdgeInsets.only(left: 20, bottom: 15, right: 20),
                              title: Text('/Session/Page/RegisterAcc'.localized)),
                        ),
                        SliverToBoxAdapter(
                          child: Container(
                            margin: EdgeInsets.only(left: 20, bottom: 10, right: 20),
                            child: Text(
                              '/Session/Page/RegisterLog'.localized,
                            ),
                          ),
                        ),
                        SliverList.list(
                          children: sessionsList
                              .append(Container(
                                  margin: EdgeInsets.only(left: 20, right: 20, top: 5),
                                  child: Builder(
                                      builder: (context) => MaterialButton(
                                            padding: EdgeInsets.only(left: 20),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                            child: Align(
                                                alignment: Alignment.center,
                                                child: Container(
                                                  margin: EdgeInsets.all(25),
                                                  child: Icon(
                                                    CupertinoIcons.add_circled,
                                                    color: Theme.of(context).colorScheme.primary,
                                                  ),
                                                )),
                                            onPressed: () {
                                              Navigator.push(context,
                                                  MaterialPageRoute(builder: (context) => NewSessionPage(routed: true)));
                                            },
                                          ))))
                              .toList(),
                        ),
                      ],
                    ),
                    bottomNavigationBar: Container(
                      padding: EdgeInsets.only(bottom: 20),
                      child: Table(children: <TableRow>[
                        TableRow(children: [
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
                        ]),
                        TableRow(children: [
                          Center(
                            child: Opacity(
                                opacity: 0.25,
                                child: Text(
                                  Share.buildNumber,
                                  style: TextStyle(fontSize: 12),
                                )),
                          ),
                        ])
                      ]),
                    ),
                  );
                }),
              );
            }));
  }

  void _showAlertDialog(BuildContext context, Uri url) {
    if (kIsWeb) return;

    showDialog<void>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text('/BaseApp/Update/AlertHeader'.localized),
        content: Text('/BaseApp/Update/Alert'.localized.format(isAndroid ? 'Android' : 'iOS')),
        actions: [
          TextButton(
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
}
