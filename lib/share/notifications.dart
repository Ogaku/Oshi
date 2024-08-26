// ignore_for_file: prefer_const_constructors

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:event/event.dart';
import 'package:oshi/interface/shared/session_management.dart';
import 'package:oshi/share/platform.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:mutex/mutex.dart';
import 'package:oshi/interface/shared/pages/home.dart';
import 'package:oshi/share/share.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'package:flutter_app_installer/flutter_app_installer.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:oshi/models/data/lesson.dart' as models;
import 'package:oshi/models/data/timetables.dart' as models;
import 'package:oshi/models/data/messages.dart' as models;
import 'package:oshi/models/data/announcement.dart' as models;
import 'package:oshi/models/data/teacher.dart' as models;
import 'package:oshi/models/data/event.dart' as models;
import 'package:oshi/models/data/attendances.dart' as models;

part 'notifications.g.dart';

class RefreshStatus with ChangeNotifier {
  bool _isRefreshing = false;
  String? _progressStatus;

  bool get isRefreshing => _isRefreshing;
  String? get progressStatus => _progressStatus;
  final Mutex refreshMutex = Mutex();

  set isRefreshing(bool value) {
    _isRefreshing = value;
    notifyListeners();
  }

  set progressStatus(String? value) {
    _progressStatus = value;
    notifyListeners();
  }

  void markAsStarted() {
    isRefreshing = true;
    progressStatus = null;
  }

  void markAsDone() {
    isRefreshing = false;
    progressStatus = null;
  }
}

class NotificationController {
  static final StreamController<ReceivedNotification> didReceiveLocalNotificationStream =
      StreamController<ReceivedNotification>.broadcast();

  /// Use this method to detect when the user taps on a notification or action button
  @pragma('vm:entry-point')
  static void notificationResponseReceived(NotificationResponse notificationResponse) async {
    try {
      if (notificationResponse.payload?.startsWith('update_android') ?? false) {
        await Permission.storage.request();
        await Permission.requestInstallPackages.request();

        await FlutterAppInstaller().installApk(
            filePath: (await copyFileToExternalStorage(
                    File(notificationResponse.payload!.substring(notificationResponse.payload!.indexOf('\n') + 1))))
                .path);
      } else if (notificationResponse.payload?.startsWith('url') ?? false) {
        await launchUrlString(notificationResponse.payload!.substring(notificationResponse.payload!.indexOf('\n') + 1));
      } else if (notificationResponse.payload?.isNotEmpty ?? false) {
        // Assume the notification is a json payload of [TimelineNotification]
        await handleJsonNotificationPayload(notificationResponse);
      }
    } catch (ex) {
      // ignored
    }
  }

  @pragma('vm:entry-point')
  static void notificationTapBackground(NotificationResponse notificationResponse) {
    // TODO handle action
  }

  static Future<void> handleJsonNotificationPayload(NotificationResponse? notificationResponse) async {
    if (notificationResponse != null && (notificationResponse.payload?.isNotEmpty ?? false)) {
      // Assume the notification is a json payload of [TimelineNotification]
      try {
        var payload = TimelineNotification.fromJson(jsonDecode(notificationResponse.payload!));
        if (!payload.isValid && !Share.settings.sessions.sessions.containsKey(payload.sessionGuid)) return;

        // If the notification was sent from another session, log into it now
        if (Share.settings.sessions.lastSessionId != payload.sessionGuid) {
          Share.settings.sessions.lastSessionId = payload.sessionGuid;
          Share.session = Share.settings.sessions.lastSession!;
          await Share.settings.save(); // Save our settings now

          // Change the main page to the base application
          await Share.session.tryLogin(showErrors: false);
          Share.changeBase.broadcast(Value(() => baseApplication));
          await Future.delayed(const Duration(milliseconds: 500));
        }

        // The notification payload is invalid, but contains a session GUID
        // Open the timeline for the session it was sent from (may be many)
        if (!payload.isValid && payload.type == null) {
          Share.tabsNavigatePage.broadcast(Value(0)); // Go home now!
          await Future.delayed(const Duration(milliseconds: 500));
          Share.openTimeline.broadcast(); // Should be enough for now
        }
        // The notification payload is valid, and contains a session GUID
        // Open the according page for each payload object, try to navigate
        else {
          Share.tabsNavigatePage.broadcast(Value(switch (payload.type!) {
            TimelineNotificationType.grade => 1,
            TimelineNotificationType.timetable || TimelineNotificationType.event => 2,
            TimelineNotificationType.message || TimelineNotificationType.announcement => 3,
            TimelineNotificationType.attendance => 4,
          })); // Go to the page described by the type, wait a bit...
          await Future.delayed(const Duration(milliseconds: 500));

          // Perform additional actions for each supported (as of now) type
          if (payload.type == TimelineNotificationType.grade && tryParse(payload.data, models.Lesson.fromJson) != null) {
            Share.gradesNavigate.broadcast(Value(tryParse(payload.data, models.Lesson.fromJson)!)); // Navigate grades
          } else if (payload.type == TimelineNotificationType.timetable &&
              tryParse(payload.data, models.TimetableLesson.fromJson) != null) {
            Share.timetableNavigateDay
                .broadcast(Value((tryParse(payload.data, models.TimetableLesson.fromJson))!.date.asDate()));
          } else if (payload.type == TimelineNotificationType.event &&
              tryParse(payload.data, models.Event.fromJson) != null) {
            Share.timetableNavigateDay.broadcast(Value(((tryParse(payload.data, models.Event.fromJson))!.date ??
                    (tryParse(payload.data, models.Event.fromJson))!.timeFrom)
                .asDate()));
          } else if (payload.type == TimelineNotificationType.message &&
              tryParse(payload.data, models.Message.fromJson) != null) {
            Share.messagesNavigate.broadcast(Value(tryParse(payload.data, models.Message.fromJson)!));
          } else if (payload.type == TimelineNotificationType.announcement &&
              tryParse(payload.data, models.Announcement.fromJson) != null) {
            var x = tryParse(payload.data, models.Announcement.fromJson)!;
            Share.messagesNavigateAnnouncement.broadcast(Value((
              message: models.Message(
                  id: x.read ? 1 : 0,
                  topic: x.subject,
                  content: x.content,
                  sender: x.contact ?? models.Teacher(firstName: Share.session.data.student.mainClass.unit.name),
                  sendDate: x.startDate,
                  readDate: x.endDate),
              parent: x
            )));
          }
        }
      } catch (ex) {
        // ignored
      }
    }
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
      double? progress,
      bool? playSoundforce}) async {
    if (isWindows || isFuchsia) return;

    try {
      AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
          (playSoundforce ?? (progress == null)) ? 'status_notifications' : 'silent_notifications', 'status_notifications',
          showProgress: progress != null,
          playSound: playSoundforce ?? progress == null,
          enableVibration: playSoundforce ?? progress == null,
          importance: (playSoundforce ?? (progress == null)) ? Importance.defaultImportance : Importance.low,
          priority: (playSoundforce ?? (progress == null)) ? Priority.defaultPriority : Priority.low,
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
              interruptionLevel:
                  (playSoundforce ?? (progress == null)) ? InterruptionLevel.active : InterruptionLevel.passive,
              categoryIdentifier: notificationCategories[NotificationCategories.other /* category */]?.identifier),
          macOS: DarwinNotificationDetails(
              threadIdentifier: category.toString(),
              interruptionLevel:
                  (playSoundforce ?? (progress == null)) ? InterruptionLevel.active : InterruptionLevel.passive,
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
          if (!Share.session.settings.notificationsAskedOnce && !(value ?? true)) {
            Share.showErrorModal.broadcast(Value((
              title: 'Allow Oshi to send you notifications?',
              message:
                  'Oshi needs access to send you notifications regarding timetable changes, new or updated grades, and other school events.',
              actions: {
                'Allow': () async => Share.notificationsPlugin
                    .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
                    ?.requestNotificationsPermission()
                    .then((value) => Share.session.settings.notificationsAskedOnce = true),
                'Later': () async {},
                'Never': () async => Share.session.settings.notificationsAskedOnce = true
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
          if (!Share.session.settings.notificationsAskedOnce && !(value ?? true)) {
            Share.showErrorModal.broadcast(Value((
              title: 'Allow Oshi to send you notifications?',
              message:
                  'Oshi needs access to send you notifications regarding timetable changes, new or updated grades, and other school events.',
              actions: {
                'Allow': () async => Share.notificationsPlugin
                    .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
                    ?.requestNotificationsPermission()
                    .then((value) => Share.session.settings.notificationsAskedOnce = true),
                'Later': () async {},
                'Never': () async => Share.session.settings.notificationsAskedOnce = true
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
          if (!Share.session.settings.notificationsAskedOnce && !(value ?? true)) {
            Share.showErrorModal.broadcast(Value((
              title: 'Allow Oshi to send you notifications?',
              message:
                  'Oshi needs access to send you notifications regarding timetable changes, new or updated grades, and other school events.',
              actions: {
                'Allow': () async => Share.notificationsPlugin
                    .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
                    ?.requestNotificationsPermission()
                    .then((value) => Share.session.settings.notificationsAskedOnce = true),
                'Later': () async {},
                'Never': () async => Share.session.settings.notificationsAskedOnce = true
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

Future<File> copyFileToExternalStorage(File sourceFile) async {
  String fileName = sourceFile.path.split('/').last; // Extract the file name
  Directory? externalDir = await getExternalStorageDirectory(); // Get external directory

  if (externalDir == null) {
    throw Exception("External storage directory not found");
  }

  File destinationFile = File('${externalDir.path}/$fileName'); // Create new file at destination path
  await sourceFile.copy(destinationFile.path); // Copy source file to destination
  return destinationFile; // Return the new file object
}

@JsonSerializable(includeIfNull: false)
class TimelineNotification {
  TimelineNotification({this.data, String? sessionGuid, TimelineNotificationType? type})
      : sessionGuid = sessionGuid ?? Share.settings.sessions.lastSessionId ?? '',
        type = type ??
            switch (data.runtimeType) {
              models.Lesson => TimelineNotificationType.grade,
              models.TimetableLesson => TimelineNotificationType.timetable,
              models.Event => TimelineNotificationType.event,
              models.Message => TimelineNotificationType.message,
              models.Attendance => TimelineNotificationType.attendance,
              models.Announcement => TimelineNotificationType.announcement,
              _ => null
            };

  final TimelineNotificationType? type;
  final String sessionGuid;
  final dynamic data;

  @JsonKey(includeFromJson: false, includeToJson: false)
  bool get isValid => type != null && data != null && sessionGuid.isNotEmpty;

  factory TimelineNotification.fromJson(Map<String, dynamic> json) => _$TimelineNotificationFromJson(json);
  Map<String, dynamic> toJson() => _$TimelineNotificationToJson(this);
}

enum TimelineNotificationType {
  grade, // Subject/lesson
  timetable, // Substitutions
  event, // Agenda/timetables
  message, // New message
  attendance, // Attendance
  announcement // Messages^
}

T? tryParse<T>(Map<String, dynamic> input, T Function(Map<String, dynamic> json) parser) {
  try {
    return parser(input);
  } catch (ex) {
    return null;
  }
}
