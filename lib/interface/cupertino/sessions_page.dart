// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:darq/darq.dart';
import 'package:flutter/cupertino.dart';
import 'package:ogaku/interface/cupertino/new_session.dart';
import 'package:ogaku/share/share.dart';
import 'package:transparent_image/transparent_image.dart';

import 'package:ogaku/interface/cupertino/views/navigation_bar.dart' show SliverNavigationBar;

// Boiler: returned to the main application
StatefulWidget get sessionsPage => SessionsPage();

class SessionsPage extends StatefulWidget {
  const SessionsPage({super.key});

  @override
  State<SessionsPage> createState() => _SessionsPageState();
}

class _SessionsPageState extends State<SessionsPage> {
  final scrollController = ScrollController();
  bool subscribed = false;

  @override
  Widget build(BuildContext context) {
    var providersList = Share.sessions
        .select(
          (x, index) => CupertinoListTile(
              padding: EdgeInsets.all(0),
              title: Builder(
                  builder: (context) => CupertinoButton(
                        padding: EdgeInsets.only(left: 20),
                        child: Row(
                          children: [
                            Container(
                                width: 120,
                                margin: EdgeInsets.only(top: 20, bottom: 20),
                                child: FadeInImage.memoryNetwork(
                                    height: 37,
                                    placeholder: kTransparentImage,
                                    image: x.provider.providerBannerUri?.toString() ??
                                        'https://i.pinimg.com/736x/6b/db/93/6bdb93f8d708c51e0431406f7e06f299.jpg')),
                            Container(
                              width: 1,
                              height: 40,
                              margin: EdgeInsets.only(left: 20, right: 20),
                              decoration: const BoxDecoration(
                                  borderRadius: BorderRadius.all(Radius.circular(10)), color: Color(0x33AAAAAA)),
                            ),
                            Expanded(
                                child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Flexible(
                                        child: Text(
                                      x.sessionName,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: WidgetsBinding.instance.platformDispatcher.platformBrightness ==
                                                  Brightness.dark
                                              ? CupertinoColors.white
                                              : CupertinoColors.black),
                                    ))))
                          ],
                        ),
                        onPressed: () {
                          // showCupertinoModalBottomSheet(context: context, builder: (context) => LoginPage(provider: x));
                        },
                      ))),
        )
        .toList();

    return CupertinoApp(
        home: CupertinoPageScaffold(
            backgroundColor: WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark
                ? CupertinoColors.systemBackground
                : CupertinoColors.secondarySystemBackground,
            child: CustomScrollView(controller: scrollController, slivers: [
              SliverNavigationBar(
                transitionBetweenRoutes: true,
                scrollController: scrollController,
                largeTitle: FittedBox(
                    fit: BoxFit.fitWidth,
                    child: Container(margin: EdgeInsets.only(right: 20), child: Text('E-register accounts'))),
                trailing: GestureDetector(
                  child: Icon(CupertinoIcons.question_circle),
                  onTap: () {},
                ),
              ),
              //leading: TextChip(text: DateFormat('y.M.d').format(DateTime.now()), margin: EdgeInsets.only(top: 6, bottom: 6))
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
                                  'These are your currently set up e-register accounts. Choose one of currently logged-in sessions, or go on and create a new one.',
                                  style: TextStyle(fontSize: 14),
                                ))),
                        CupertinoListSection.insetGrouped(children: providersList),
                        CupertinoListSection.insetGrouped(margin: EdgeInsets.only(left: 20, right: 20, top: 5), children: [
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
                                          "All trademarks featured in this application remain the property of their rightful owners, and are used for informational purposes only.",
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
