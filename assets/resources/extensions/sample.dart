// @id PROVGUID-CUSTOM-TEMPLATE-REGISTER
// @name Template Register Provider
// @version 1.2.0
// @lang pl
// @author YourName
// @icon https://raw.githubusercontent.com/Ogaku/Oshi/main/assets/resources/images/logo_fit.png
// @banner https://raw.githubusercontent.com/Ogaku/Oshi/main/assets/resources/images/logo_fit.png
// @baseUrl https://register.myschool.edu.pl
// @loginType 20
// @description Starter template and reference implementation for Oshi register extensions.

import 'package:oshi/bridge_lib.dart';

/// Template register extension for Oshi.
/// Developers can copy this file into their own GitHub repository as `extension.dart`,
/// add the GitHub topic `oshi-extension`, and it will be discovered automatically by Oshi worldwide!
class CustomRegisterExtension extends OProvider {
  CustomRegisterExtension({required this.source}) : _driver = OProtocolDriver('sample');

  final OSource source;
  final OProtocolDriver _driver;

  @override
  String get providerName => source.name;

  @override
  String get providerDescription => source.description;

  @override
  String get providerBannerUrl => source.bannerUrl ?? source.iconUrl;

  @override
  Future<Map<String, dynamic>> login(Map<String, String> credentials) async {
    // Implement your authentication here using httpGet / httpPost:
    // final username = credentials['login'];
    // final password = credentials['pass'];
    // final res = await httpPost('${source.baseUrl}/api/login', body: {'u': username, 'p': password});
    return await _driver.login(credentials);
  }

  @override
  Future<Map<String, dynamic>> refresh(String? weekStartIso) async {
    // Fetch timetable, grades, attendance, and events:
    return await _driver.refresh(weekStartIso);
  }

  @override
  Future<Map<String, dynamic>> refreshMessages() async {
    return await _driver.refreshMessages();
  }

  @override
  Future<Map<String, dynamic>> sendMessage(
    List<Map<String, dynamic>> receivers,
    String topic,
    String content,
  ) async {
    return await _driver.sendMessage(receivers, topic, content);
  }

  @override
  Future<Map<String, dynamic>> fetchMessageContent(Map<String, dynamic> parent, bool byMe) async {
    return await _driver.fetchMessageContent(parent, byMe);
  }

  @override
  Future<Map<String, dynamic>> moveMessageToTrash(Map<String, dynamic> parent, bool byMe) async {
    return await _driver.moveMessageToTrash(parent, byMe);
  }

  @override
  Future<Map<String, dynamic>> markEventAsViewed(Map<String, dynamic> parent) async {
    return await _driver.markEventAsViewed(parent);
  }

  @override
  Future<Map<String, dynamic>> markEventAsDone(Map<String, dynamic> parent) async {
    return await _driver.markEventAsDone(parent);
  }

  @override
  Future<Map<String, dynamic>> markAnnouncementAsViewed(Map<String, dynamic> parent) async {
    return await _driver.markAnnouncementAsViewed(parent);
  }

  @override
  Map<String, dynamic> getRegisterDataJson() => <String, dynamic>{};
}

CustomRegisterExtension main(dynamic source) {
  return CustomRegisterExtension(source: source as OSource);
}
