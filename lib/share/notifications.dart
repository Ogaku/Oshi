// ignore_for_file: prefer_const_constructors

import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:event/event.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:open_file_plus/open_file_plus.dart';
import 'package:oshi/share/share.dart';

class NotificationController {
  static final StreamController<ReceivedNotification> didReceiveLocalNotificationStream =
      StreamController<ReceivedNotification>.broadcast();

  /// Use this method to detect when the user taps on a notification or action button
  @pragma('vm:entry-point')
  static void notificationResponseReceived(NotificationResponse notificationResponse) async {
    try {
      if (notificationResponse.payload?.startsWith('update_android') ?? false) {
        await OpenFile.open(notificationResponse.payload!.substring(notificationResponse.payload!.indexOf('\n') + 1));
      }

      // await Navigator.push(
      //   context,
      //   MaterialPageRoute<void>(builder: (context) => SecondScreen(payload)),
      // );
    } catch (ex) {
      // ignored
    }
  }

  @pragma('vm:entry-point')
  static void notificationTapBackground(NotificationResponse notificationResponse) {
    // TODO handle action
  }

  @pragma('vm:entry-point')
  static void onNotificationResponse(int id, String? title, String? body, String? payload) async {
    didReceiveLocalNotificationStream.add(
      ReceivedNotification(
        id: id,
        title: title,
        body: body,
        payload: payload,
      ),
    );
  }

  static Future<void> sendNotification(
      {required String title,
      required String content,
      NotificationCategories category = NotificationCategories.register,
      String? data,
      int? id,
      double? progress}) async {
    if (Platform.isWindows || Platform.isFuchsia) return;

    try {
      AndroidNotificationDetails androidNotificationDetails =
          AndroidNotificationDetails('status_notifications', 'Status notifications',
              showProgress: progress != null,
              playSound: progress == null,
              enableVibration: progress == null,
              progress: (progress != null ? progress * 100 : 1).round(),
              maxProgress: progress != null ? 100 : 1,
              channelDescription: 'Notification channel for status updates',
              actions: switch (NotificationCategories.other /* category */) {
                NotificationCategories.register => [
                    AndroidNotificationAction('id_1', 'Share'),
                    AndroidNotificationAction('id_2', 'Inquiry')
                  ],
                NotificationCategories.messages => [
                    AndroidNotificationAction('id_1', 'Share'),
                    AndroidNotificationAction('id_2', 'Forward'),
                    AndroidNotificationAction('id_3', 'Reply')
                  ],
                _ => null
              });

      NotificationDetails notificationDetails = NotificationDetails(
          android: androidNotificationDetails,
          iOS: DarwinNotificationDetails(
              threadIdentifier: category.toString(),
              categoryIdentifier: notificationCategories[NotificationCategories.other /* category */]?.identifier),
          macOS: DarwinNotificationDetails(
              threadIdentifier: category.toString(),
              categoryIdentifier: notificationCategories[NotificationCategories.other /* category */]?.identifier));
      await Share.notificationsPlugin
          .show(id ?? Random().nextInt(999999), title, content, notificationDetails, payload: data);
    } catch (ex) {
      // ignore
    }
  }

  static final Map<NotificationCategories, DarwinNotificationCategory> notificationCategories = {
    NotificationCategories.register: DarwinNotificationCategory(
      'registerChange',
      actions: <DarwinNotificationAction>[
        DarwinNotificationAction.plain(
          'id_1',
          'Share',
          options: <DarwinNotificationActionOption>{
            DarwinNotificationActionOption.foreground,
          },
        ),
        DarwinNotificationAction.plain(
          'id_2',
          'Inquiry',
          options: <DarwinNotificationActionOption>{
            DarwinNotificationActionOption.destructive,
          },
        ),
      ],
      options: <DarwinNotificationCategoryOption>{
        DarwinNotificationCategoryOption.hiddenPreviewShowTitle,
      },
    ),
    NotificationCategories.messages: DarwinNotificationCategory(
      'newMessage',
      actions: <DarwinNotificationAction>[
        DarwinNotificationAction.plain(
          'id_1',
          'Share',
          options: <DarwinNotificationActionOption>{
            DarwinNotificationActionOption.foreground,
          },
        ),
        DarwinNotificationAction.plain(
          'id_2',
          'Forward',
          options: <DarwinNotificationActionOption>{
            DarwinNotificationActionOption.destructive,
          },
        ),
        DarwinNotificationAction.plain(
          'id_3',
          'Reply',
          options: <DarwinNotificationActionOption>{
            DarwinNotificationActionOption.destructive,
          },
        ),
      ],
      options: <DarwinNotificationCategoryOption>{
        DarwinNotificationCategoryOption.hiddenPreviewShowTitle,
      },
    )
  };

  static void requestNotificationAccess() {
    try {
      // Check notification access and request if not allowed : Android
      Share.notificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.areNotificationsEnabled()
          .then((value) {
        try {
          if (!Share.settings.config.notificationsAskedOnce && !(value ?? true)) {
            Share.showErrorModal.broadcast(Value((
              title: 'Allow Oshi to send you notifications?',
              message:
                  'Oshi needs access to send you notifications regarding timetable changes, new or updated grades, and other school events.',
              actions: {
                'Allow': () async => Share.notificationsPlugin
                    .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
                    ?.requestNotificationsPermission()
                    .then((value) => Share.settings.config.notificationsAskedOnce = true),
                'Later': () async {},
                'Never': () async => Share.settings.config.notificationsAskedOnce = true
              }
            )));
          }
        } catch (ex) {
          // ignored
        }
      });
    } catch (ex) {
      // ignored
    }

    try {
      // Check notification access and request if not allowed : iOS
      Share.notificationsPlugin
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true)
          .then((value) {
        try {
          if (!Share.settings.config.notificationsAskedOnce && !(value ?? true)) {
            Share.showErrorModal.broadcast(Value((
              title: 'Allow Oshi to send you notifications?',
              message:
                  'Oshi needs access to send you notifications regarding timetable changes, new or updated grades, and other school events.',
              actions: {
                'Allow': () async => Share.notificationsPlugin
                    .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
                    ?.requestNotificationsPermission()
                    .then((value) => Share.settings.config.notificationsAskedOnce = true),
                'Later': () async {},
                'Never': () async => Share.settings.config.notificationsAskedOnce = true
              }
            )));
          }
        } catch (ex) {
          // ignored
        }
      });
    } catch (ex) {
      // ignored
    }

    try {
      // Check notification access and request if not allowed : macOS
      Share.notificationsPlugin
          .resolvePlatformSpecificImplementation<MacOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true)
          .then((value) {
        try {
          if (!Share.settings.config.notificationsAskedOnce && !(value ?? true)) {
            Share.showErrorModal.broadcast(Value((
              title: 'Allow Oshi to send you notifications?',
              message:
                  'Oshi needs access to send you notifications regarding timetable changes, new or updated grades, and other school events.',
              actions: {
                'Allow': () async => Share.notificationsPlugin
                    .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
                    ?.requestNotificationsPermission()
                    .then((value) => Share.settings.config.notificationsAskedOnce = true),
                'Later': () async {},
                'Never': () async => Share.settings.config.notificationsAskedOnce = true
              }
            )));
          }
        } catch (ex) {
          // ignored
        }
      });
    } catch (ex) {
      // ignored
    }
  }
}

class ReceivedNotification {
  ReceivedNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.payload,
  });

  final int id;
  final String? title;
  final String? body;
  final String? payload;
}

enum NotificationCategories { register, messages, other }
