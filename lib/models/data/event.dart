import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:event/event.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:oshi/interface/components/shim/elements/event.dart';
import 'package:oshi/interface/shared/pages/home.dart';
import 'package:oshi/interface/shared/views/grades_detailed.dart';
import 'package:oshi/models/data/classroom.dart';
import 'package:oshi/models/data/messages.dart';
import 'package:oshi/models/data/teacher.dart';

import 'package:hive/hive.dart';
import 'package:oshi/share/appcenter.dart';
import 'package:oshi/share/share.dart';
import 'package:oshi/share/translator.dart';
import 'package:platform_device_id/platform_device_id.dart';
part 'event.g.dart';

@HiveType(typeId: 25)
@JsonSerializable(includeIfNull: false)
class Event extends Equatable {
  Event(
      {this.id = -1,
      this.lessonNo,
      this.date,
      this.addDate,
      DateTime? timeFrom,
      this.timeTo,
      this.title,
      this.content = '',
      this.categoryName = '',
      this.category = EventCategory.other,
      this.done = false,
      this.sender,
      this.attachments,
      this.classroom,
      bool? isOwnEvent,
      bool? isSharedEvent,
      String? teamCode})
      : timeFrom = timeFrom ?? DateTime(2000),
        isOwnEvent = isOwnEvent ?? false,
        isSharedEvent = isSharedEvent ?? false,
        teamCode = teamCode ?? '';

  Event.from(
      {Event? other,
      int? id,
      int? lessonNo,
      DateTime? date,
      DateTime? addDate,
      DateTime? timeFrom,
      DateTime? timeTo,
      String? title,
      String? content,
      String? categoryName,
      EventCategory? category,
      bool? done,
      bool? isOwnEvent,
      bool? isSharedEvent,
      Teacher? sender,
      Classroom? classroom,
      List<Attachment>? attachments,
      String? teamCode})
      : id = id ?? other?.id ?? -1,
        lessonNo = lessonNo ?? other?.lessonNo,
        date = date ?? other?.date,
        addDate = addDate ?? other?.addDate,
        timeFrom = timeFrom ?? other?.timeFrom ?? DateTime(2000),
        timeTo = timeTo ?? other?.timeTo,
        title = title ?? other?.title,
        content = content ?? other?.content ?? '',
        categoryName = categoryName ?? other?.categoryName ?? '',
        category = category ?? other?.category ?? EventCategory.other,
        done = done ?? other?.done ?? false,
        sender = sender ?? other?.sender,
        attachments = attachments ?? other?.attachments,
        classroom = classroom ?? other?.classroom,
        isOwnEvent = isOwnEvent ?? other?.isOwnEvent ?? false,
        isSharedEvent = isSharedEvent ?? other?.isSharedEvent ?? false,
        teamCode = teamCode ?? other?.teamCode ?? '';

  @HiveField(0)
  final int id;

  @HiveField(1)
  final int? lessonNo;

  @HiveField(2)
  final DateTime? date;

  @HiveField(3)
  final DateTime? addDate;

  @HiveField(4)
  final DateTime timeFrom;

  @HiveField(5)
  final DateTime? timeTo;

  @HiveField(6)
  final String? title;

  @HiveField(7)
  final String content;

  @HiveField(8)
  final String categoryName;

  @HiveField(9)
  final bool done; // For homeworks

  @HiveField(10)
  final EventCategory category;

  @HiveField(11)
  final Teacher? sender;

  @HiveField(12)
  final Classroom? classroom;

  // Set to null for no attachments
  @HiveField(13)
  final List<Attachment>? attachments; // For homeworks

  @HiveField(14)
  final bool isOwnEvent;

  @HiveField(15, defaultValue: false)
  final bool isSharedEvent;

  @HiveField(16, defaultValue: '')
  final String teamCode;

  @JsonKey(includeToJson: false, includeFromJson: false)
  String get _categoryName => categoryName.isNotEmpty ? categoryName : category.asString();

  @JsonKey(includeToJson: false, includeFromJson: false)
  String get titleString => "${_categoryName.capitalize()}${(title ?? content).isNotEmpty ? ':' : ''} ${title ?? content}";

  @JsonKey(includeToJson: false, includeFromJson: false)
  String get subtitleString => (title != null && title != content) ? content : '';

  @JsonKey(includeToJson: false, includeFromJson: false)
  String get locationString =>
      (lessonNo != null ? 'Lesson no. $lessonNo • ' : '') +
      (isOwnEvent ? Share.session.data.student.account.name : (sender?.name ?? ''));

  @JsonKey(includeToJson: false, includeFromJson: false)
  String get locationTypeString =>
      (lessonNo != null ? 'Lesson no. $lessonNo • ' : '') +
      _categoryName +
      (classroom != null ? ' • ${classroom!.name}' : '') +
      (sender != null ? ' • Added by ${sender!.name}' : '');

  @JsonKey(includeToJson: false, includeFromJson: false)
  String get addedByString => (sender != null ? 'Added by ${sender!.name}' : '');

  @JsonKey(includeToJson: false, includeFromJson: false)
  bool get unseen => Share.session.unreadChanges.events.contains(hashCode);
  void markAsSeen() => Share.settings.save(() => Share.session.unreadChanges.events.remove(hashCode));

  @override
  List<Object> get props => [id, timeFrom, content, categoryName, done, category];

  factory Event.fromJson(Map<String, dynamic> json) => _$EventFromJson(json);

  Map<String, dynamic> toJson() => _$EventToJson(this);
}

@HiveType(typeId: 101)
enum EventCategory {
  @HiveField(0)
  gathering, // Zebranie
  @HiveField(1)
  lecture, // Lektura
  @HiveField(2)
  test, // Test
  @HiveField(3)
  classWork, // Praca Klasowa
  @HiveField(4)
  semCorrection, // Poprawka
  @HiveField(5)
  other, // Inne
  @HiveField(6)
  lessonWork, // Praca na Lekcji
  @HiveField(7)
  shortTest, // Kartkowka
  @HiveField(8)
  correction, // Poprawa
  @HiveField(9)
  onlineLesson, // Online
  @HiveField(10)
  homework, // Praca domowa (horror)
  @HiveField(11)
  teacher, // Nieobecnosc nauczyciela
  @HiveField(12)
  freeDay, // Dzien wolny (opis)
  @HiveField(13)
  conference, // Wywiadowka
  @HiveField(14)
  admin // Admin events
}

extension EventCategoryExtension on EventCategory {
  String asString() => '/Enums/EventCategory/$name'.localized;
}

extension SzkolnyExtensions on Event {
  // Unshare the event using the Szkolny.eu API
  // Assume it's already been removed from lists
  Future<bool> unshare() async {
    try {
      Share.session.refreshStatus.markAsStarted(); // Refresh started
      Share.session.refreshStatus.progressStatus = "Making you some Ereignislebensraum...";
      var data = (await Dio(BaseOptions(baseUrl: 'https://api.szkolny.eu')).post('/share',
              options: Options(headers: {
                "X-ApiKey": AppCenter.szkolnyAppKey,
                "X-AppBuild": Share.buildNumber.split('.').last.toString(),
                "X-AppFlavor": "Release",
                "X-AppVersion": Share.buildNumber.toString(),
                "X-DeviceId": (await PlatformDeviceId.getDeviceId)?.trim() ?? "UNKNOWN",
                // "X-Signature": "",
                // "X-Timestamp": timestamp.toString(),
                'Content-Type': 'application/json'
              }),
              data: jsonEncode({
                "eventId": id,
                "deviceId": (await PlatformDeviceId.getDeviceId)?.trim() ?? "UNKNOWN",
                "action": "event",
                "userCode": Share.session.data.student.userCode,
                "studentNameLong": Share.session.data.student.account.name,
                "shareTeamCode": null,
                "unshareTeamCode": teamCode.isNotEmpty ? teamCode : Share.session.data.student.teamCodes.keys.first,
                "requesterName": Share.session.data.student.account.name,
                "event": null
              })))
          .data;

      await Future.delayed(const Duration(seconds: 1));
      Share.session.refreshStatus.markAsDone(); // Done!
      return (data["success"] as bool?) ?? false;
    } catch (ex, stack) {
      Share.showErrorModal.broadcast(Value((
        title: 'Error unsharing the event!',
        message:
            'A fatal exception "$ex" occurred and the app couldn\'t make a valid Szkolny.eu API request.\n\nPlease try again later.\nConsider reporting this error.',
        actions: {
          'Copy Exception': () async => await Clipboard.setData(ClipboardData(text: ex.toString())),
          'Copy Stack Trace': () async => await Clipboard.setData(ClipboardData(text: stack.toString())),
        }
      )));
    }

    Share.session.refreshStatus.markAsDone(); // Done!
    return false;
  }

  // Share the event using the Szkolny.eu API
  // Assume it's already cached in the base app
  // Event ID is UNIX timestamp in milliseconds
  Future<bool> share({String teamCode = ''}) async {
    try {
      Share.session.refreshStatus.markAsStarted(); // Refresh started
      Share.session.refreshStatus.progressStatus = "Live, now! Broadcasting\n(Your fantastic event!)";
      var data = (await Dio(BaseOptions(baseUrl: 'https://api.szkolny.eu')).post('/share',
              options: Options(headers: {
                "X-ApiKey": AppCenter.szkolnyAppKey,
                "X-AppBuild": Share.buildNumber.split('.').last.toString(),
                "X-AppFlavor": "Release",
                "X-AppVersion": Share.buildNumber.toString(),
                "X-DeviceId": (await PlatformDeviceId.getDeviceId)?.trim() ?? "UNKNOWN",
                // "X-Signature": "",
                // "X-Timestamp": timestamp.toString(),
                'Content-Type': 'application/json'
              }),
              data: jsonEncode({
                "deviceId": (await PlatformDeviceId.getDeviceId)?.trim() ?? "UNKNOWN",
                "action": "event",
                "userCode": Share.session.data.student.userCode,
                "studentNameLong": Share.session.data.student.account.name,
                "shareTeamCode": teamCode.isNotEmpty ? teamCode : Share.session.data.student.teamCodes.keys.first,
                "unshareTeamCode": null,
                "requesterName": Share.session.data.student.account.name,
                "eventId": null,
                "event": {
                  "id": id,
                  "addedDate": DateTime.now().asDate().millisecondsSinceEpoch,
                  "eventDate": DateFormat('yyyyMMdd').format(date ?? timeFrom),
                  "startTime": DateFormat('HHmmss').format(timeFrom),
                  "sharedBy": Share.session.data.student.userCode,
                  "teamCode": teamCode.isNotEmpty ? teamCode : Share.session.data.student.teamCodes.keys.first,
                  "sharedByName": Share.session.data.student.account.name,
                  "topic": (title ?? '') + ((title?.isNotEmpty ?? false) ? ' - ' : '') + content,
                  "subjectId": -1,
                  "teacherId": -1,
                  "type": category.asEventCategory,
                  "color": -((~(asColor().value.toSigned(32))) + 1)
                }
              })))
          .data;

      await Future.delayed(const Duration(seconds: 1));
      Share.session.refreshStatus.markAsDone(); // Done!
      return (data["success"] as bool?) ?? false;
    } catch (ex, stack) {
      Share.showErrorModal.broadcast(Value((
        title: 'Error sharing the event!',
        message:
            'A fatal exception "$ex" occurred and the app couldn\'t make a valid Szkolny.eu API request.\n\nPlease try again later.\nConsider reporting this error.',
        actions: {
          'Copy Exception': () async => await Clipboard.setData(ClipboardData(text: ex.toString())),
          'Copy Stack Trace': () async => await Clipboard.setData(ClipboardData(text: stack.toString())),
        }
      )));
    }

    Share.session.refreshStatus.markAsDone(); // Done!
    return false;
  }
}
