// @id PROVGUID-SHIM-SMPL-FAKE-DATAPROVIDER
// @name /Providers/Sample/Name
// @version 1.1.0
// @lang all
// @author Ogaku
// @icon https://media.tenor.com/QPvKS6-yrzUAAAAC/cirno-touhou.gif
// @banner https://media.tenor.com/QPvKS6-yrzUAAAAC/cirno-touhou.gif
// @baseUrl https://github.com/Ogaku/Oshi
// @loginType 20
// @description /Providers/Sample/Description

import 'package:oshi/bridge_lib.dart';

class SampleRegisterExtension extends OProvider {
  SampleRegisterExtension({required this.source}) : _driver = OProtocolDriver('sample');

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
    return await _driver.login(credentials);
  }

  @override
  Future<Map<String, dynamic>> refresh(String? weekStartIso) async {
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

SampleRegisterExtension main(dynamic source) {
  return SampleRegisterExtension(source: source as OSource);
}

