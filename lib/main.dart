// ignore_for_file: curly_braces_in_flow_control_structures

import 'dart:io';
import 'package:background_fetch/background_fetch.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:oshi/share/background.dart';
import 'package:oshi/share/notifications.dart';
import 'package:oshi/share/share.dart';

import 'package:oshi/interface/material/sessions_page.dart' as materialapp show sessionsPage;
import 'package:oshi/interface/cupertino/sessions_page.dart' as cupertinoapp show sessionsPage;
import 'package:oshi/interface/cupertino/base_app.dart' as cupertinoapp show baseApp;

Future<void> main() async {
  // Setup routine, see background.dart
  await setupBaseApplication();

  // Start the actual application
  runApp(const MainApp());

  // Register to receive BackgroundFetch events after app is terminated
  // Requires {stopOnTerminate: false, enableHeadless: true}
  if (Platform.isAndroid || Platform.isIOS) {
    BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);
  }
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  StatefulWidget Function() child = Share.settings.appSettings.useCupertino
      ? () => (Share.settings.sessions.lastSession != null ? cupertinoapp.baseApp : cupertinoapp.sessionsPage)
      : () => materialapp.sessionsPage;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting();

    if (Platform.isAndroid || Platform.isIOS) initPlatformState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      // Check whether the app was launched by a notification, parse the payload
      Share.notificationsPlugin.getNotificationAppLaunchDetails().then((value) {
        if (value?.didNotificationLaunchApp ?? false) {
          NotificationController.handleJsonNotificationPayload(value?.notificationResponse);
        }
      });
    });
  }

  Future<void> initPlatformState() async {
    // Configure BackgroundFetch
    Share.backgroundSyncActive = false;
    await BackgroundFetch.configure(
        BackgroundFetchConfig(
            minimumFetchInterval: Share.session.settings.backgroundSyncInterval,
            stopOnTerminate: false,
            enableHeadless: true,
            requiresBatteryNotLow: false,
            requiresCharging: false,
            requiresStorageNotLow: false,
            requiresDeviceIdle: false,
            requiredNetworkType: NetworkType.ANY), (String taskId) async {
      // <-- Event handler
      // This is the fetch-event callback

      // Validate our internet connection
      if (Share.session.settings.backgroundSyncWiFiOnly &&
          (await (Connectivity().checkConnectivity())) != ConnectivityResult.wifi) return;

      // Validate our session data
      if (Share.settings.sessions.lastSession == null || !Share.session.settings.enableBackgroundSync) return;

      // Try to log in and refresh everything
      await Share.session.tryLogin(); // Auto-login on restart if valid
      await Share.session.refreshAll(); // Refresh everything

      // IMPORTANT:  You must signal completion of your task
      // or the OS can punish your app for taking too long
      BackgroundFetch.finish(taskId);
    }, (String taskId) async {
      // <-- Task timeout handler.
      BackgroundFetch.finish(taskId);
    });

    Share.backgroundSyncActive = true;
    if (!mounted) return;
  }

  @override
  Widget build(BuildContext context) {
    // Re-subscribe to all events
    Share.changeBase.unsubscribeAll();
    Share.changeBase.subscribe((args) {
      setState(() {
        if (args != null) child = args.value;
      });
    });

    return child();
  }
}
