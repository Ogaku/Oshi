// @id PROVGUID-RGLR-PROV-LIBR-LIBRSYNERGIA
// @name Librus Synergia
// @version 1.2.0
// @lang pl
// @author Ogaku
// @icon https://play-lh.googleusercontent.com/s277392B31t33M3G5hG8R7bB4z5vM8dJ4X9fP3qN1cT6wY8kU2aV5eR0iO7pL3sA1g
// @banner https://api.librus.pl/images/logo-synergia.png
// @baseUrl https://synergia.librus.pl
// @loginType 2
// @description /Providers/Librus/Description

import 'package:oshi/bridge_lib.dart';

class LibrusSynergiaExtension extends OProvider {
  LibrusSynergiaExtension({required this.source}) : _driver = OProtocolDriver('librus');

  final OSource source;
  final OProtocolDriver _driver;

  static const String gatewayBaseUrl = 'https://synergia.librus.pl/gateway/api/2.0';
  static const String portalOAuthUrl = 'https://synergia.librus.pl/loguj/portalRodzina';

  @override
  String get providerName => source.name;

  @override
  String get providerDescription => source.description;

  @override
  String get providerBannerUrl => source.bannerUrl ?? source.iconUrl;

  @override
  Future<Map<String, dynamic>> login(Map<String, String> credentials) async {
    reportProgress(0.05, localized('D870CFEB-F16B-4091-9084-9620E5BACE22'));
    final normalized = <String, String>{
      'login': (credentials['login'] ?? '').trim(),
      'pass': credentials['pass'] ?? '',
      if (credentials['proxy'] != null) 'proxy': credentials['proxy']!.trim(),
    };
    return await _driver.login(normalized);
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

LibrusSynergiaExtension main(dynamic source) {
  return LibrusSynergiaExtension(source: source as OSource);
}
