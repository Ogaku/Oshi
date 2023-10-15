// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:darq/darq.dart';
import 'package:flutter/cupertino.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:ogaku/share/share.dart';
import 'package:transparent_image/transparent_image.dart';

import 'package:ogaku/interface/cupertino/session_login.dart' show LoginPage;
import 'package:ogaku/interface/cupertino/widgets/navigation_bar.dart' show SliverNavigationBar;
import 'package:url_launcher/url_launcher_string.dart';

// Boiler: returned to the main application
StatefulWidget get newSessionPage => NewSessionPage();

class NewSessionPage extends StatefulWidget {
  const NewSessionPage({super.key});

  @override
  State<NewSessionPage> createState() => _NewSessionPageState();
}

class _NewSessionPageState extends State<NewSessionPage> {
  final scrollController = ScrollController();
  bool subscribed = false;

  @override
  Widget build(BuildContext context) {
    var providersList = Share.providers.keys
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
                                    image: Share.providers[x]!.instance.providerBannerUri?.toString() ??
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
                                      Share.providers[x]!.instance.providerName,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: CupertinoDynamicColor.resolve(
                                              CupertinoDynamicColor.withBrightness(
                                                  color: CupertinoColors.black, darkColor: CupertinoColors.white),
                                              context)),
                                    ))))
                          ],
                        ),
                        onPressed: () {
                          showCupertinoModalBottomSheet(
                              context: context,
                              builder: (context) => LoginPage(instance: Share.providers[x]!.instance, providerGuid: x));
                        },
                      ))),
        )
        .toList();

    return CupertinoPageScaffold(
        backgroundColor: CupertinoDynamicColor.withBrightness(
            color: const Color.fromARGB(255, 242, 242, 247), darkColor: const Color.fromARGB(255, 0, 0, 0)),
        child: CustomScrollView(controller: scrollController, slivers: [
          SliverNavigationBar(
            transitionBetweenRoutes: true,
            scrollController: scrollController,
            largeTitle: FittedBox(
                fit: BoxFit.fitWidth,
                child: Container(margin: EdgeInsets.only(right: 20), child: Text('What is your e-register?'))),
            trailing: GestureDetector(
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
                              'Choose the e-register system, depending on which one your school uses. You will be able to set up more accounts later.',
                              style: TextStyle(fontSize: 14),
                            ))),
                    CupertinoListSection.insetGrouped(hasLeading: false, children: providersList),
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
        ]));
  }
}
