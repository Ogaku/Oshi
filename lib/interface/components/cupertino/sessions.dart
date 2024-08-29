// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables
import 'package:darq/darq.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:event/event.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_shake_animated/flutter_shake_animated.dart';
import 'package:format/format.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:oshi/interface/components/shim/page_routes.dart';
import 'package:oshi/interface/components/shim/session_management.dart';
import 'package:oshi/interface/shared/session_management.dart';
import 'package:oshi/models/progress.dart';
import 'package:oshi/share/appcenter.dart';
import 'package:oshi/share/notifications.dart';
import 'package:oshi/share/share.dart';
import 'package:oshi/share/translator.dart';
import 'package:oshi/interface/components/cupertino/application.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:oshi/share/platform.dart';

import 'package:oshi/interface/components/cupertino/widgets/navigation_bar.dart' show SliverNavigationBar;
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:uuid/uuid.dart';

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
                                    Share.changeBase.broadcast(Value(() => baseApplication));
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
            ErrorWidget.builder = (e) => errorView(context, e);

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
                                                    context, AdaptivePageRoute(builder: (context) => NewSessionPage()));
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
                              builder: (context) =>
                                  LoginPageBase.adaptive(instance: Share.providers[x]!.instance, providerGuid: x));
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
            ErrorWidget.builder = (e) => errorView(context, e);

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

class LoginPage extends LoginPageBase {
  const LoginPage({super.key, required super.instance, required super.providerGuid});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  Map<String, TextEditingController>? credentialControllers;
  String? _progressMessage;

  bool isWorking = false; // Logging in right now?
  bool shakeFields = false; // Shake login fields

  @override
  Widget build(BuildContext context) {
    // Generate a map of credential controllers for the login page
    credentialControllers ??= widget.instance.credentialsConfig.keys.toMap((x) => MapEntry(x, TextEditingController()));

    var credentialEntries = widget.instance.credentialsConfig.entries
        .select((x, index) => CupertinoFormRow(
            prefix: SizedBox(width: 90, child: Text(x.value.name)),
            helper: Align(
              alignment: Alignment.centerLeft,
              child: x.value.helper != null
                  ? CupertinoButton(
                      padding: EdgeInsets.only(),
                      onPressed: () async {
                        try {
                          await launchUrl(x.value.helper!.link);
                        } catch (ex) {
                          // ignored
                        }
                      },
                      child: Text(x.value.helper!.text, maxLines: 1, overflow: TextOverflow.ellipsis))
                  : null,
            ),
            child: CupertinoTextFormFieldRow(
              enabled: !isWorking,
              placeholder: '/Required'.localized,
              obscureText: x.value.obscure,
              autofillHints: [x.value.obscure ? AutofillHints.password : AutofillHints.username],
              controller: credentialControllers![x.key],
              onChanged: (s) => setState(() {}),
            )))
        .toList();

    return CupertinoPageScaffold(
      backgroundColor: CupertinoDynamicColor.withBrightness(
          color: const Color.fromARGB(255, 242, 242, 247), darkColor: const Color.fromARGB(255, 28, 28, 30)),
      navigationBar: CupertinoNavigationBar(
          transitionBetweenRoutes: false,
          automaticallyImplyLeading: true,
          leading: (_progressMessage?.isNotEmpty ?? false)
              ? Container(
                  margin: EdgeInsets.only(top: 7),
                  child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: 150),
                      child: Text(
                        _progressMessage ?? '',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: CupertinoColors.inactiveGray, fontSize: 13),
                      )))
              : null,
          border: null,
          backgroundColor: CupertinoDynamicColor.withBrightness(
              color: const Color.fromARGB(255, 242, 242, 247), darkColor: const Color.fromARGB(255, 28, 28, 30)),
          trailing: CupertinoButton(
              padding: EdgeInsets.all(0),
              alignment: Alignment.centerRight,
              child: isWorking
                  ? CupertinoActivityIndicator()
                  : Text('/Next'.localized,
                      style: TextStyle(
                          color: (credentialControllers!.values.every((x) => x.text.isNotEmpty))
                              ? CupertinoTheme.of(context).primaryColor
                              : CupertinoColors.inactiveGray)),
              onPressed: () async {
                if (isWorking) return; // Already handling something, give up
                if (credentialControllers!.values.every((x) => x.text.isNotEmpty)) {
                  TextInput.finishAutofillContext(); // Hide autofill if present
                  setState(() {
                    // Mark as working, the 1st refresh is gonna take a while
                    isWorking = true;
                  });

                  var progress = Progress<({double? progress, String? message})>();
                  progress.progressChanged.subscribe((args) => setState(() => _progressMessage = args?.value.message));

                  if (!await tryLogin(
                      progress: progress,
                      guid: widget.providerGuid,
                      credentials: credentialControllers!.entries.toMap((x) => MapEntry(x.key, x.value.text)))) {
                    setState(() {
                      // Reset the animation in case the login method hasn't finished
                      isWorking = false;
                      shakeFields = true;

                      progress.progressChanged.unsubscribeAll();
                      _progressMessage = null; // Reset the message
                    });

                    // Reset the shake
                    Future.delayed(Duration(milliseconds: 300)).then((value) => setState(() => shakeFields = false));
                  }
                }
              })),
      child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            Visibility(
                visible: widget.instance.providerBannerUri != null,
                child: Container(
                    margin: EdgeInsets.only(top: 30, left: 100, right: 100),
                    child: FadeInImage.memoryNetwork(
                        placeholder: kTransparentImage,
                        image: widget.instance.providerBannerUri?.toString() ??
                            'https://i.pinimg.com/736x/6b/db/93/6bdb93f8d708c51e0431406f7e06f299.jpg'))),
            Container(
                margin: EdgeInsets.only(top: 50),
                child: credentialEntries.isNotEmpty
                    ? ShakeWidget(
                        shakeConstant: ShakeHorizontalConstant2(),
                        autoPlay: shakeFields,
                        enableWebMouseHover: false,
                        child: AutofillGroup(child: CupertinoFormSection.insetGrouped(children: credentialEntries)))
                    : Opacity(opacity: 0.5, child: Text('/Session/Login/Data/Complete'.localized))),
            Opacity(
                opacity: 0.7,
                child: Container(
                    margin: EdgeInsets.only(top: 10, left: 20, right: 20),
                    child: Text(widget.instance.providerDescription, style: TextStyle(fontSize: 14)))),
            Expanded(
                child: Align(
              alignment: Alignment.bottomCenter,
              child: Opacity(
                  opacity: 0.5,
                  child: Container(
                      margin: EdgeInsets.only(right: 20, left: 20, bottom: 20),
                      child: Text(
                        '/Session/Login/Data/Info'.localized,
                        style: TextStyle(fontSize: 12),
                        textAlign: TextAlign.justify,
                      ))),
            )),
          ]),
    );
  }

  Future<bool> tryLogin(
      {required Map<String, String> credentials,
      required String guid,
      IProgress<({double? progress, String? message})>? progress}) async {
    try {
      // Create a new session: ID/name/provider are automatic
      progress?.report((progress: 0.1, message: '/Session/Login/Splash/Session'.localized));
      var session = Session(providerGuid: guid);
      var result = await session.tryLogin(credentials: credentials, progress: progress, showErrors: true);

      if (!result.success && result.message != null) {
        return false; // Didn't work, uh
      } else {
        var id = Uuid().v4(); // Genereate a new session identifier
        Share.settings.sessions.sessions.update(id, (s) => session, ifAbsent: () => session);
        Share.settings.sessions.lastSessionId = id; // Update
        Share.session = session; // Set as the currently active one

        progress?.report((progress: 0.2, message: '/Session/Login/Splash/Settings'.localized));
        await Share.settings.save(); // Save our settings now
        var result = await Share.session.refreshAll(progress: progress, saveChanges: false);
        if (!result.success && result.message != null) return false; // Didn't work, uh

        // Change the main page to the base application
        Share.changeBase.broadcast(Value(() => baseApplication));
        return true; // Mark the operation as succeeded
      }
    } on DioException catch (ex, stack) {
      Share.showErrorModal.broadcast(Value((
        title: '/Session/Login/Error/Title'.localized,
        message: '/Session/Login/Error/Message'.localized.format(ex.message ?? ex),
        actions: {
          '/Session/Login/Error/Exception'.localized: () async =>
              await Clipboard.setData(ClipboardData(text: ex.toString())),
          '/Session/Login/Error/Stack'.localized: () async => await Clipboard.setData(ClipboardData(text: stack.toString())),
        }
      )));
    } on Exception catch (ex, stack) {
      Share.showErrorModal.broadcast(Value((
        title: '/Session/Login/Error/Title'.localized,
        message: '/Session/Login/Error/Message'.localized.format(ex),
        actions: {
          '/Session/Login/Error/Exception'.localized: () async =>
              await Clipboard.setData(ClipboardData(text: ex.toString())),
          '/Session/Login/Error/Stack'.localized: () async => await Clipboard.setData(ClipboardData(text: stack.toString())),
        }
      )));
    }
    return false;
  }
}
