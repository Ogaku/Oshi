// ignore_for_file: curly_braces_in_flow_control_structures

import 'package:event/event.dart';
import 'package:szkolny/models/data/teacher.dart' show Teacher;
import 'package:szkolny/models/data/student.dart' show Student;
import 'package:szkolny/models/data/timetables.dart' show Timetables;
import 'package:szkolny/models/data/messages.dart' show Messages;
import 'package:szkolny/models/progress.dart' show IProgress;

abstract class IProvider {
  // All the accessible data - provided as models
  Student? get student;
  Timetables? get timetables;
  Messages? get messages;

  // Provider's header - distinct data
  String get providerName;
  String get providerDescription;
  String get loginAnnotation;
  String get passAnnotation;

  // Provider's decorations - shared data
  Uri? get providerIcon;
  Uri? get providerBanner;

  // Raised by providers to notify about updates
  // To subscribe: event.subscribe((args) => {})
  Event<Value<String>> propertyChanged = Event<Value<String>>();

  // Login and reset methods for early setup - implement as async
  Future<({bool success, Exception? message})> login({String? session, String? username, String? password});

  // Clear provider settings - login data, other custom settings
  Future<({bool success, Exception? message})> clearSettings({String? session});

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
  Future<({bool success, Exception? message})> sendMessage(List<Teacher> receivers, String topic, String content);
}
