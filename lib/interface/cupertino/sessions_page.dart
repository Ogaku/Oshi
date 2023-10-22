// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:io';

import 'package:darq/darq.dart';
import 'package:flutter/cupertino.dart';
import 'package:event/event.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:oshi/interface/cupertino/new_session.dart';
import 'package:oshi/share/share.dart';
import 'package:oshi/interface/cupertino/base_app.dart';
import 'package:transparent_image/transparent_image.dart';

import 'package:oshi/interface/cupertino/widgets/navigation_bar.dart' show SliverNavigationBar;
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

  @override
  Widget build(BuildContext context) {
    var sessionsList = Share.settings.sessions.sessions.keys
        .select(
          (x, index) => CupertinoListTile(
              padding: EdgeInsets.all(0),
              title: Builder(
                  builder: (context) => CupertinoContextMenu(
                          actions: [
                            CupertinoContextMenuAction(
                              onPressed: () async {
                                setState(() {
                                  Share.settings.sessions.sessions.remove(x);
                                  if (Share.settings.sessions.lastSessionId == x) {
                                    Share.settings.sessions.lastSessionId =
                                        Share.settings.sessions.sessions.keys.firstOrDefault(defaultValue: null);
                                  }
                                  // Dismiss the context menu
                                  Navigator.of(context, rootNavigator: true).pop();
                                });

                                // Save our session changes
                                await Share.settings.save();
                              },
                              isDestructiveAction: true,
                              trailingIcon: CupertinoIcons.delete,
                              child: const Text('Delete'),
                            ),
                          ],
                          // I know there's onTap too, but we need an opaque background
                          child: CupertinoButton(
                            color: CupertinoDynamicColor.withBrightness(
                                color: const Color.fromARGB(255, 255, 255, 255),
                                darkColor: const Color.fromARGB(255, 28, 28, 30)),
                            padding: EdgeInsets.only(left: 20),
                            child: Row(children: [
                              ConstrainedBox(
                                  constraints: BoxConstraints(maxWidth: 120, maxHeight: 80, minWidth: 120, minHeight: 80),
                                  child: Container(
                                      margin: EdgeInsets.only(top: 20, bottom: 20),
                                      child: FadeInImage.memoryNetwork(
                                          height: 37,
                                          placeholder: kTransparentImage,
                                          image: Share.settings.sessions.sessions[x]!.provider.providerBannerUri
                                                  ?.toString() ??
                                              'https://i.pinimg.com/736x/6b/db/93/6bdb93f8d708c51e0431406f7e06f299.jpg'))),
                              Container(
                                width: 1,
                                height: 40,
                                margin: EdgeInsets.only(left: 20, right: 20),
                                decoration: const BoxDecoration(
                                    borderRadius: BorderRadius.all(Radius.circular(10)), color: Color(0x33AAAAAA)),
                              ),
                              Flexible(
                                  child: Container(
                                      margin: EdgeInsets.only(right: 20),
                                      child: Text(
                                        Share.settings.sessions.sessions[x]!.sessionName,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: CupertinoDynamicColor.resolve(
                                                CupertinoDynamicColor.withBrightness(
                                                    color: CupertinoColors.black, darkColor: CupertinoColors.white),
                                                context)),
                                      )))
                            ]),
                            onPressed: () async {
                              if (isWorking) return; // Already handling something, give up
                              setState(() {
                                // Mark as working, the 1st refresh is gonna take a while
                                isWorking = true;
                              });

                              // showCupertinoModalBottomSheet(context: context, builder: (context) => LoginPage(provider: x));
                              Share.settings.sessions.lastSessionId = x; // Update
                              Share.session = Share.settings.sessions.lastSession!;
                              var result = await Share.session.login(); // Log in now

                              if (!result.success) {
                                if (Platform.isAndroid || Platform.isIOS) {
                                  Fluttertoast.showToast(
                                    msg: '${result.message}',
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity.CENTER,
                                    timeInSecForIosWeb: 1,
                                  );
                                }
                                setState(() {
                                  // Reset the animation in case the login method hasn't finished
                                  isWorking = false;
                                });
                                return; // Give up, not this time
                              }

                              await Share.settings.save(); // Save our settings now
                              await Share.session.refresh(); // Refresh everything
                              await Share.session.refreshMessages(); // And messages

                              // Change the main page to the base application
                              Share.changeBase.broadcast(Value(() => baseApp));

                              // Reset the animation in case we go back somehow
                              isWorking = false;
                            },
                          )))),
        )
        .toList();

    return CupertinoApp(
        home: CupertinoPageScaffold(
            backgroundColor: CupertinoDynamicColor.withBrightness(
                color: const Color.fromARGB(255, 242, 242, 247), darkColor: const Color.fromARGB(255, 0, 0, 0)),
            child: CustomScrollView(controller: scrollController, slivers: [
              SliverNavigationBar(
                transitionBetweenRoutes: true,
                scrollController: scrollController,
                largeTitle: FittedBox(
                    fit: BoxFit.fitWidth,
                    child: Container(margin: EdgeInsets.only(right: 20), child: Text('E-register accounts'))),
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
                              "AZ_VERSION_CONFIG_BUILD",
                              style: TextStyle(fontSize: 12),
                            )),
                      ]),
                ),
              )
            ])));
  }
}
