// ignore_for_file: prefer_const_constructors

import 'dart:async';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:oshi/share/share.dart';

class NotificationController {
  static final StreamController<ReceivedNotification> didReceiveLocalNotificationStream =
      StreamController<ReceivedNotification>.broadcast();

  /// Use this method to detect when the user taps on a notification or action button
  @pragma('vm:entry-point')
  static void notificationResponseReceived(NotificationResponse notificationResponse) async {
    final String? payload = notificationResponse.payload;
    if (notificationResponse.payload != null) {
      debugPrint('notification payload: $payload');
    }

    // await Navigator.push(
    //   context,
    //   MaterialPageRoute<void>(builder: (context) => SecondScreen(payload)),
    // );
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
      String? data}) async {
    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails('status_notifications', 'Status notifications',
            channelDescription: 'Notification channel for status updates',
            actions: switch (category) {
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
            threadIdentifier: category.toString(), categoryIdentifier: notificationCategories[category]?.identifier),
        macOS: DarwinNotificationDetails(
            threadIdentifier: category.toString(), categoryIdentifier: notificationCategories[category]?.identifier));
    await Share.notificationsPlugin.show(Random().nextInt(999999), title, content, notificationDetails, payload: data);
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
