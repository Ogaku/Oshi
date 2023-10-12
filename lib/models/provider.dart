// ignore_for_file: curly_braces_in_flow_control_structures

import 'package:event/event.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:ogaku/models/data/teacher.dart' show Teacher;
import 'package:ogaku/models/data/student.dart' show Student;
import 'package:ogaku/models/data/timetables.dart' show Timetables;
import 'package:ogaku/models/data/messages.dart' show Messages;
import 'package:ogaku/models/progress.dart' show IProgress;

part 'provider.g.dart';

abstract class IProvider {
  // All the accessible data - provided as models
  ProviderData? get registerData;

  // Provider's header - distinct data
  String get providerName;
  String get providerDescription;
  Uri? get providerBannerUri;

  // Raised by providers to notify about updates
  // To subscribe: event.subscribe((args) => {})
  Event<Value<String>> propertyChanged = Event<Value<String>>();

  // Login and reset methods for early setup - implement as async
  Future<({bool success, Exception? message})> login({String? session, String? username, String? password});

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
}

@JsonSerializable(includeIfNull: false)
class ProviderData {
  ProviderData({Student? student, Timetables? timetables, Messages? messages})
      : student = student ?? Student(),
        timetables = timetables ?? Timetables(),
        messages = messages ?? Messages();

  // All the accessible data - provided as models
  Student student;
  Timetables timetables;
  Messages messages;

  factory ProviderData.fromJson(Map<String, dynamic> json) => _$ProviderDataFromJson(json);

  Map<String, dynamic> toJson() => _$ProviderDataToJson(this);
}
