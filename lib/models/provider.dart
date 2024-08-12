// ignore_for_file: curly_braces_in_flow_control_structures

import 'package:event/event.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:oshi/models/data/announcement.dart' show Announcement;
import 'package:oshi/models/data/teacher.dart' show Teacher;
import 'package:oshi/models/data/student.dart' show Student;
import 'package:oshi/models/data/timetables.dart' show Timetables;
import 'package:oshi/models/data/messages.dart' show Messages, Message;
import 'package:oshi/models/data/event.dart' as models show Event;
import 'package:oshi/models/progress.dart' show IProgress;

import 'package:hive/hive.dart';
part 'provider.g.dart';

abstract class IProvider {
  // All the accessible data - provided as models
  ProviderData? get registerData;

  // Login, password, etc configuration
  // Maps KEY (data) to <(field name), (obscure?)?
  // Passed to login(...) as <KEY, value>
  Map<String, ({String name, bool obscure, ({String text, Uri link})? helper})> get credentialsConfig;

  // Provider's header - distinct data
  String get providerName;
  String get providerDescription;
  Uri? get providerBannerUri;

  // Raised by providers to notify about updates
  // To subscribe: event.subscribe((args) => {})
  Event<Value<String>> propertyChanged = Event<Value<String>>();

  // Login and reset methods for early setup - implement as async
  // Credentials are passed from credentialsConfig - make sure it's set up
  Future<({bool success, Exception? message})> login(
      {Map<String, String>? credentials, IProgress<({double? progress, String? message})>? progress});

  // Login and refresh methods for runtime - implement as async
  // For null 'weekStart' - get (only) the current week's data
  // For reporting 'progress' - mark 'Progress' as null for indeterminate status
  Future<({bool success, Exception? message})> refresh(
      {DateTime? weekStart, IProgress<({double? progress, String? message})>? progress});

  // Login and refresh methods for runtime - implement as async
  // For null 'weekStart' - get (only) the current week's data
  // For reporting 'progress' - mark 'Progress' as null for indeterminate status
  Future<({bool success, Exception? message})> refreshMessages({IProgress<({double? progress, String? message})>? progress});

  // Send a message to selected user/s, fetched from `Messages.Receivers`
  // Don't encode the strings, the provider will need to take care of that
  Future<({bool success, Exception? message})> sendMessage(
      {required List<Teacher> receivers, required String topic, required String content});

  // Fetch the actual content, sender details, and mark as read
  Future<({bool success, Exception? message, Message? result})> fetchMessageContent(
      {required Message parent, required bool byMe});

  // Move the message to trash
  Future<({bool success, Exception? message})> moveMessageToTrash({required Message parent, required bool byMe});

  // Mark event/homework as viewed (may be needed in some cases)
  Future<({bool success, Exception? message})> markEventAsViewed({required models.Event parent});

  // Mark event/homework as done (may be needed in some cases)
  Future<({bool success, Exception? message})> markEventAsDone({required models.Event parent});

  // Mark an announcement as viewed (may be needed in some cases)
  Future<({bool success, Exception? message})> markAnnouncementAsViewed({required Announcement parent});
}

@HiveType(typeId: 10)
@JsonSerializable(includeIfNull: false)
class ProviderData extends HiveObject {
  ProviderData({Student? student, Timetables? timetables, Messages? messages})
      : student = student ?? Student(),
        timetables = timetables ?? Timetables(),
        messages = messages ?? Messages();

  // All the accessible data - provided as models
  @HiveField(1)
  Student student;

  @HiveField(2)
  Timetables timetables;

  @HiveField(3)
  Messages messages;

  factory ProviderData.fromJson(Map<String, dynamic> json) => _$ProviderDataFromJson(json);

  Map<String, dynamic> toJson() => _$ProviderDataToJson(this);
}
