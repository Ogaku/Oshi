// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:darq/darq.dart';
import 'package:dio/dio.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:event/event.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_shake_animated/flutter_shake_animated.dart';
import 'package:flutter_swipe_action_cell/core/cell.dart';
import 'package:format/format.dart';
import 'package:oshi/interface/components/material/application.dart';
import 'package:oshi/interface/components/shim/session_management.dart';
import 'package:oshi/interface/shared/containers.dart';
import 'package:oshi/interface/shared/session_management.dart';
import 'package:oshi/models/progress.dart';
import 'package:oshi/share/appcenter.dart';
import 'package:oshi/share/notifications.dart';
import 'package:oshi/share/platform.dart';
import 'package:oshi/share/share.dart';
import 'package:oshi/share/translator.dart';
import 'package:transparent_image/transparent_image.dart';
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
    return DynamicColorBuilder(builder: (lightDynamic, darkDynamic) {
      ColorScheme? lightColorScheme, darkColorScheme;

      if (lightDynamic != null && darkDynamic != null) {
        (lightColorScheme, darkColorScheme) = generateDynamicColourSchemes(lightDynamic, darkDynamic);
      }

      return Builder(builder: (context) {
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
                                Share.changeBase.broadcast(Value(() => baseApplication));
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
                                              Share.settings.sessions.lastSessionId =
                                                  Share.settings.sessions.sessions.keys.firstOrDefault(defaultValue: null);
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
                                                        visible: Share
                                                                .settings.sessions.sessions[x]?.provider.providerBannerUri !=
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
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: lightColorScheme,
            useMaterial3: true,
            pageTransitionsTheme: const PageTransitionsTheme(
              builders: <TargetPlatform, PageTransitionsBuilder>{
                TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
              },
            ),
          ),
          darkTheme: ThemeData(
            colorScheme: darkColorScheme,
            useMaterial3: true,
            pageTransitionsTheme: const PageTransitionsTheme(
              builders: <TargetPlatform, PageTransitionsBuilder>{
                TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
              },
            ),
          ),
          home: Builder(builder: (context) {
            ErrorWidget.builder = (e) => errorView(context, e);

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
              // ignore: use_build_context_synchronously
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
                          child: isWorking
                              ? SizedBox(height: 20, width: 20, child: CircularProgressIndicator())
                              : Icon(Icons.help_outline_rounded),
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
                                        Navigator.push(
                                            context, MaterialPageRoute(builder: (context) => NewSessionPage(routed: true)));
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
                    Align(
                        alignment: Alignment.bottomCenter,
                        child: Opacity(
                            opacity: 0.5,
                            child: Container(
                                margin: EdgeInsets.only(right: 30, left: 30, bottom: 10),
                                child: Text(
                                  '/TrademarkInfo'.localized,
                                  style: TextStyle(fontSize: 12),
                                  textAlign: TextAlign.center,
                                )))),
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
      });
    });
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
          title: 'FA15D556-4A83-487B-B9C2-8ABCD1DC5C90'.localized,
          message: 'EFB7E8DF-1BBC-442F-9D83-DAF1C70A028E'.localized.format(
              Share.settingsLoadError?.exception.toString() ?? '',
              Share.settingsLoadError?.trace.toString() ?? 'E91C42DF-7471-47E1-BAB8-7E3C63713154'.localized),
          actions: {
            '/Session/Login/Error/Exception'.localized: () async =>
                await Clipboard.setData(ClipboardData(text: Share.settingsLoadError?.exception.toString() ?? '')),
            '/Session/Login/Error/Stack'.localized: () async =>
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
                                builder: (context) =>
                                    LoginPageBase.adaptive(instance: Share.providers[x]!.instance, providerGuid: x)));
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
            Align(
                alignment: Alignment.bottomCenter,
                child: Opacity(
                    opacity: 0.5,
                    child: Container(
                        margin: EdgeInsets.only(right: 30, left: 30, bottom: 10),
                        child: Text(
                          '/TrademarkInfo'.localized,
                          style: TextStyle(fontSize: 12),
                          textAlign: TextAlign.center,
                        )))),
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

    return DynamicColorBuilder(builder: (lightDynamic, darkDynamic) {
      ColorScheme? lightColorScheme, darkColorScheme;

      if (lightDynamic != null && darkDynamic != null) {
        (lightColorScheme, darkColorScheme) = generateDynamicColourSchemes(lightDynamic, darkDynamic);
      }

      return widget.routed
          ? body
          : MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: ThemeData(
                colorScheme: lightColorScheme,
                useMaterial3: true,
                pageTransitionsTheme: const PageTransitionsTheme(
                  builders: <TargetPlatform, PageTransitionsBuilder>{
                    TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
                  },
                ),
              ),
              darkTheme: ThemeData(
                colorScheme: darkColorScheme,
                useMaterial3: true,
                pageTransitionsTheme: const PageTransitionsTheme(
                  builders: <TargetPlatform, PageTransitionsBuilder>{
                    TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
                  },
                ),
              ),
              home: body);
    });
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
        .map((x) => Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: TextFormField(
                enabled: !isWorking,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: x.value.name,
                  hintText: '/Required'.localized,
                ),
                obscureText: x.value.obscure,
                autofillHints: [x.value.obscure ? AutofillHints.password : AutofillHints.username],
                controller: credentialControllers![x.key],
                onChanged: (s) => setState(() {}),
              ),
            ))
        .toList();

    return PopScope(
      canPop: !isWorking,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            _progressMessage ?? 'F7C404C2-2C11-452C-9267-623A5E1B76C0'.localized.format(widget.instance.providerName),
            style: TextStyle(fontSize: _progressMessage != null ? 14 : 22),
          ),
          actions: [
            Container(
              padding: EdgeInsets.only(right: 10),
              child: TextButton(
                  child: isWorking
                      ? SizedBox(height: 20, width: 20, child: CircularProgressIndicator())
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
                  }),
            )
          ],
        ),
        body: Column(
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
                  margin: EdgeInsets.only(top: 35),
                  child: credentialEntries.isNotEmpty
                      ? ShakeWidget(
                          shakeConstant: ShakeHorizontalConstant2(),
                          autoPlay: shakeFields,
                          enableWebMouseHover: false,
                          child: AutofillGroup(
                              child: Container(
                                  margin: EdgeInsets.only(left: 20, right: 20), child: Column(children: credentialEntries))))
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
      ),
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
