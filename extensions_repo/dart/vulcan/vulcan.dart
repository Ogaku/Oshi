// @id PROVGUID-RGLR-PROV-VULC-EDUVULCANAPI
// @name eduVULCAN / UONET+
// @version 1.1.0
// @lang pl
// @author Ogaku
// @icon https://eduvulcan.pl/Content/images/favicon/apple-touch-icon.png
// @banner https://eduvulcan.pl/Content/images/favicon/apple-touch-icon.png
// @baseUrl https://lekcjaplus.vulcan.net.pl
// @loginType 20
// @description /Providers/Vulcan/Description

import 'package:oshi/bridge_lib.dart';

class EduVulcanExtension extends OProvider {
  EduVulcanExtension({required this.source}) : _driver = OProtocolDriver('vulcan');

  final OSource source;
  final OProtocolDriver _driver;

  static const Map<String, String> tokenPrefixes = {
    '3S1': 'https://lekcjaplus.vulcan.net.pl',
    'TA1': 'https://uonetplus-komunikacja.umt.tarnow.pl',
    'OP1': 'https://uonetplus-komunikacja.eszkola.opolskie.pl',
    'RZ1': 'https://uonetplus-komunikacja.resman.pl',
    'GD1': 'https://uonetplus-komunikacja.edu.gdansk.pl',
    'KA1': 'https://uonetplus-komunikacja.mcuw.katowice.eu',
    'KA2': 'https://uonetplus-komunikacja-test.mcuw.katowice.eu',
    'LU1': 'https://uonetplus-komunikacja.edu.lublin.eu',
    'LU2': 'https://test-uonetplus-komunikacja.edu.lublin.eu',
    'KO1': 'https://uonetplus-komunikacja.eduportal.koszalin.pl',
    'FK1': 'http://api.fakelog.tk',
  };

  @override
  String get providerName => source.name;

  @override
  String get providerDescription => source.description;

  @override
  String get providerBannerUrl => source.bannerUrl ?? source.iconUrl;

  @override
  Future<Map<String, dynamic>> login(Map<String, String> credentials) async {
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

EduVulcanExtension main(dynamic source) {
  return EduVulcanExtension(source: source as OSource);
}

