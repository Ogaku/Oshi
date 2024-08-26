import 'package:event/src/event.dart';
import 'package:event/src/eventargs.dart';
import 'package:oshi/models/data/announcement.dart';
import 'package:oshi/models/data/class.dart';
import 'package:oshi/models/data/messages.dart';
import 'package:oshi/models/data/student.dart';
import 'package:oshi/models/data/teacher.dart';
import 'package:oshi/models/data/unit.dart';
import 'package:oshi/models/progress.dart';
import 'package:oshi/models/provider.dart';
import 'package:oshi/models/data/event.dart' as models;

class FakeDataReader implements IProvider {
  @override
  Event<Value<String>> propertyChanged = Event<Value<String>>();

  @override
  Future<({Exception? message, bool success})> login(
      {Map<String, String>? credentials, IProgress<({double? progress, String? message})>? progress}) async {
    return (success: true, message: null);
  }

  @override
  Future<({Exception? message, bool success})> refresh(
      {DateTime? weekStart, IProgress<({String? message, double? progress})>? progress}) async {
    return (success: true, message: null);
  }

  @override
  Future<({Exception? message, bool success})> refreshMessages(
      {IProgress<({String? message, double? progress})>? progress}) async {
    return (success: true, message: null);
  }

  @override
  Future<({Exception? message, bool success})> sendMessage(
      {required List<Teacher> receivers, required String topic, required String content}) async {
    return (success: true, message: null);
  }

  @override
  Uri? get providerBannerUri => Uri.parse('https://media.tenor.com/QPvKS6-yrzUAAAAC/cirno-touhou.gif');

  @override
  String get providerDescription =>
      "This is a sample provider, it's still here for debugging purposes only. You could say hello, I guess? Please be prepared for no actual response, though.";

  @override
  String get providerName => 'Sample Provider';

  @override
  ProviderData? get registerData => ProviderData(
      student: Student(
          account: Account(firstName: 'Pomura', lastName: 'Inpuff'),
          mainClass: Class(symbol: '3c', unit: Unit(name: 'St. Hermelin High'))),);

  @override
  Map<String, ({String name, bool obscure, ({String text, Uri link})? helper})> get credentialsConfig => {};

  @override
  Future<({Exception? message, Message? result, bool success})> fetchMessageContent(
      {required Message parent, required bool byMe}) async {
    return (success: true, message: null, result: null);
  }

  @override
  Future<({Exception? message, bool success})> moveMessageToTrash({required Message parent, required bool byMe}) async {
    return (success: true, message: null);
  }

  @override
  Future<({Exception? message, bool success})> markEventAsDone({required models.Event parent}) async {
    return (success: true, message: null);
  }

  @override
  Future<({Exception? message, bool success})> markEventAsViewed({required models.Event parent}) async {
    return (success: true, message: null);
  }

  @override
  Future<({Exception? message, bool success})> markAnnouncementAsViewed({required Announcement parent}) async {
    return (success: true, message: null);
  }
}
