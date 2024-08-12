// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables
import 'package:darq/darq.dart';
import 'package:event/event.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:format/format.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:oshi/share/appcenter.dart';
import 'package:oshi/share/notifications.dart';
import 'package:oshi/share/translator.dart';
import 'package:oshi/share/share.dart';
import 'package:oshi/share/platform.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:oshi/interface/cupertino/base_app.dart' show errorView;

import 'package:oshi/interface/cupertino/session_login.dart' show LoginPage;
import 'package:oshi/interface/cupertino/widgets/navigation_bar.dart' show SliverNavigationBar;
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

// Boiler: returned to the main application
StatefulWidget get newSessionPage => NewSessionPage(asApp: true);

class NewSessionPage extends StatefulWidget {
  const NewSessionPage({super.key, this.asApp = false});

  final bool asApp;

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
          (x, index) => CupertinoListTile(
              padding: EdgeInsets.all(0),
              title: Builder(
                  builder: (context) => CupertinoButton(
                        padding: EdgeInsets.only(left: 20),
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
                                borderRadius: BorderRadius.all(Radius.circular(10)), color: Color(0x33AAAAAA)),
                          ),
                          Flexible(
                              child: Container(
                                  margin: EdgeInsets.only(right: 20),
                                  child: Text(
                                    Share.providers[x]!.instance.providerName,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: CupertinoDynamicColor.resolve(
                                            CupertinoDynamicColor.withBrightness(
                                                color: CupertinoColors.black, darkColor: CupertinoColors.white),
                                            context)),
                                  )))
                        ]),
                        onPressed: () {
                          showCupertinoModalBottomSheet(
                              context: context,
                              builder: (context) => LoginPage(instance: Share.providers[x]!.instance, providerGuid: x));
                        },
                      ))),
        )
        .toList();

    var result = CupertinoPageScaffold(
        backgroundColor: CupertinoDynamicColor.withBrightness(
            color: const Color.fromARGB(255, 242, 242, 247), darkColor: const Color.fromARGB(255, 0, 0, 0)),
        child: CustomScrollView(controller: scrollController, slivers: [
          SliverNavigationBar(
            transitionBetweenRoutes: true,
            scrollController: scrollController,
            largeTitle: FittedBox(
                fit: BoxFit.fitWidth,
                child:
                    Container(margin: EdgeInsets.only(right: 20), child: Text('/Session/New/Register/Question'.localized))),
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
                              '/Session/New/Register/Info'.localized,
                              style: TextStyle(fontSize: 14),
                            ))),
                    CupertinoListSection.insetGrouped(
                        hasLeading: false,
                        margin: EdgeInsets.only(left: 15, right: 15, bottom: 10),
                        children: providersList),
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
                        child: GestureDetector(
                            onDoubleTap: () => setState(() => enableFake = true),
                            child: Text(
                              Share.buildNumber,
                              style: TextStyle(fontSize: 12),
                            ))),
                  ]),
            ),
          )
        ]));

    return !widget.asApp
        ? result
        : CupertinoApp(
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

              return result;
            }));
  }

  void _showAlertDialog(BuildContext context, Uri url) {
    if (kIsWeb) return;
    showCupertinoModalPopup<void>(
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
