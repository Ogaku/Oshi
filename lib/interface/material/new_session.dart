// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables
import 'package:darq/darq.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:event/event.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:oshi/share/notifications.dart';
import 'package:oshi/share/translator.dart';
import 'package:oshi/share/share.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:oshi/interface/material/session_login.dart' show LoginPage;
import 'package:url_launcher/url_launcher_string.dart';

// Boiler: returned to the main application
StatefulWidget get newSessionPage => NewSessionPage();

class NewSessionPage extends StatefulWidget {
  const NewSessionPage({super.key, this.routed = false});
  final bool routed;

  @override
  State<NewSessionPage> createState() => _NewSessionPageState();
}

class _NewSessionPageState extends State<NewSessionPage> {
  final scrollController = ScrollController();
  bool subscribed = false, enableFake = false;

  @override
  void initState() {
    super.initState();

    // Set up other stuff after the app's launched
    SchedulerBinding.instance.addPostFrameCallback((_) {
      Share.checkUpdates.broadcast(); // Check for updates
      NotificationController.requestNotificationAccess();

      if (Share.settingsLoadError != null) {
        Share.showErrorModal.broadcast(Value((
          title: 'Error loading data!',
          message:
              'An exception "${Share.settingsLoadError?.exception.toString()}" occurred and settings couldn\'t be read.\n\nStack trace:\n${Share.settingsLoadError?.trace.toString() ?? "Unavailable"}',
          actions: {
            'Copy Exception': () async =>
                await Clipboard.setData(ClipboardData(text: Share.settingsLoadError?.exception.toString() ?? '')),
            'Copy Stack Trace': () async =>
                await Clipboard.setData(ClipboardData(text: Share.settingsLoadError?.trace.toString() ?? '')),
          }
        )));

        Share.settingsLoadError = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var providersList = Share.providers.keys
        .where((x) => enableFake || x != 'PROVGUID-SHIM-SMPL-FAKE-DATAPROVIDER')
        .select(
          (x, index) => Container(
            margin: EdgeInsets.only(left: 20, right: 20, top: 5),
            child: Builder(
                builder: (context) => MaterialButton(
                      padding: EdgeInsets.only(left: 30),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      child: Row(children: [
                        ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: 120, maxHeight: 80, minWidth: 120, minHeight: 80),
                            child: Container(
                                margin: EdgeInsets.only(top: 20, bottom: 20),
                                child: FadeInImage.memoryNetwork(
                                    height: 37,
                                    placeholder: kTransparentImage,
                                    image: Share.providers[x]!.instance.providerBannerUri?.toString() ??
                                        'https://i.pinimg.com/736x/6b/db/93/6bdb93f8d708c51e0431406f7e06f299.jpg'))),
                        Container(
                          width: 1,
                          height: 40,
                          margin: EdgeInsets.only(left: 20, right: 20),
                          decoration: const BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(10)), color: Color(0x55AAAAAA)),
                        ),
                        Flexible(
                            child: Container(
                                margin: EdgeInsets.only(right: 20),
                                child: Text(
                                  Share.providers[x]!.instance.providerName,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                      color: CupertinoDynamicColor.resolve(
                                          CupertinoDynamicColor.withBrightness(
                                              color: CupertinoColors.black, darkColor: CupertinoColors.white),
                                          context)),
                                )))
                      ]),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LoginPage(instance: Share.providers[x]!.instance, providerGuid: x)));
                      },
                    )),
          ),
        )
        .selectMany((x, index) => [
              x,
              Padding(
                padding: const EdgeInsets.only(top: 5.0),
                child: Divider(indent: 28, endIndent: 28, height: 1, color: Color(0x55AAAAAA)),
              )
            ])
        .skipLast(1)
        .toList();

    var body = Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            pinned: true,
            snap: false,
            floating: false,
            expandedHeight: 130.0,
            flexibleSpace: FlexibleSpaceBar(
                centerTitle: false,
                titlePadding: EdgeInsets.only(left: 20, bottom: 15, right: 20),
                title: Text('/Session/New/Register/Question'.localized)),
            actions: [
              Container(
                padding: EdgeInsets.only(right: 10),
                child: TextButton(
                  onPressed: () async {
                    try {
                      await launchUrlString('https://github.com/Ogaku');
                    } catch (ex) {
                      // ignored
                    }
                  },
                  child: Icon(Icons.help_outline_rounded),
                ),
              )
            ],
          ),
          SliverToBoxAdapter(
            child: Container(
              margin: EdgeInsets.only(left: 20, bottom: 10, right: 20),
              child: Text('/Session/New/Register/Info'.localized),
            ),
          ),
          SliverList.list(
            children: providersList,
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
                  child: GestureDetector(
                      onDoubleTap: () => setState(() => enableFake = true),
                      child: Text(
                        Share.buildNumber,
                        style: TextStyle(fontSize: 12),
                      ))),
            ),
          ])
        ]),
      ),
    );

    return DynamicColorBuilder(
        builder: (lightColorScheme, darkColorScheme) => widget.routed
            ? body
            : MaterialApp(
                theme: ThemeData(
                  colorScheme: lightColorScheme,
                  useMaterial3: true,
                ),
                darkTheme: ThemeData(
                  colorScheme: darkColorScheme,
                  useMaterial3: true,
                ),
                home: body));
  }
}
