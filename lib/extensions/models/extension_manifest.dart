import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:oshi/share/translator.dart';

class ExtensionCredentialField {
  const ExtensionCredentialField({
    required this.key,
    required this.name,
    this.obscure = false,
    this.optional = false,
    this.webOnly = false,
    this.helperText,
    this.helperUrl,
  });

  final String key;
  final String name;
  final bool obscure;
  final bool optional;
  final bool webOnly;
  final String? helperText;
  final String? helperUrl;

  String get localizedName => name.startsWith('/') ? name.localized : name;

  ({String text, Uri link})? get helper {
    if (helperText == null || helperUrl == null) return null;
    final uri = Uri.tryParse(helperUrl!);
    if (uri == null) return null;
    final text = helperText!.startsWith('/') ? helperText!.localized : helperText!;
    return (text: text, link: uri);
  }

  factory ExtensionCredentialField.fromJson(Map<String, dynamic> json) {
    return ExtensionCredentialField(
      key: (json['key'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      obscure: json['obscure'] == true,
      optional: json['optional'] == true,
      webOnly: json['webOnly'] == true,
      helperText: json['helperText']?.toString(),
      helperUrl: json['helperUrl']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'key': key,
        'name': name,
        'obscure': obscure,
        'optional': optional,
        'webOnly': webOnly,
        if (helperText != null) 'helperText': helperText,
        if (helperUrl != null) 'helperUrl': helperUrl,
      };
}

class ExtensionManifest {
  const ExtensionManifest({
    required this.id,
    required this.name,
    required this.description,
    required this.version,
    required this.sourceCodeUrl,
    this.lang = 'pl',
    this.author = 'Ogaku',
    this.iconUrl = '',
    this.bannerUrl,
    this.baseUrl = '',
    this.sha256,
    this.minAppVersion = '1.1.0',
    this.loginType = 20,
    this.isDevOnly = false,
    this.credentials = const [],
    this.repoUrl,
    this.sourceCode,
    this.installedAt,
  });

  final String id;
  final String name;
  final String description;
  final String version;
  final String lang;
  final String author;
  final String iconUrl;
  final String? bannerUrl;
  final String baseUrl;
  final String sourceCodeUrl;
  final String? sha256;
  final String minAppVersion;
  final int loginType;
  final bool isDevOnly;
  final List<ExtensionCredentialField> credentials;
  final String? repoUrl;
  final String? sourceCode;
  final DateTime? installedAt;

  String get localizedName => name.startsWith('/') ? name.localized : name;
  String get localizedDescription => description.startsWith('/') ? description.localized : description;

  Uri? get effectiveBannerUri {
    final raw = (bannerUrl != null && bannerUrl!.isNotEmpty) ? bannerUrl! : iconUrl;
    if (raw.isEmpty) return null;
    return Uri.tryParse(raw);
  }

  Map<String, ({String name, bool obscure, ({String text, Uri link})? helper})> get credentialsConfigMap {
    final result = <String, ({String name, bool obscure, ({String text, Uri link})? helper})>{};
    for (final field in credentials) {
      if (field.webOnly && !kIsWeb) continue;
      result[field.key] = (
        name: field.localizedName,
        obscure: field.obscure,
        helper: field.helper,
      );
    }
    return result;
  }

  ExtensionManifest copyWith({
    String? id,
    String? name,
    String? description,
    String? version,
    String? lang,
    String? author,
    String? iconUrl,
    String? bannerUrl,
    String? baseUrl,
    String? sourceCodeUrl,
    String? sha256,
    String? minAppVersion,
    int? loginType,
    bool? isDevOnly,
    List<ExtensionCredentialField>? credentials,
    String? repoUrl,
    String? sourceCode,
    DateTime? installedAt,
  }) {
    return ExtensionManifest(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      version: version ?? this.version,
      lang: lang ?? this.lang,
      author: author ?? this.author,
      iconUrl: iconUrl ?? this.iconUrl,
      bannerUrl: bannerUrl ?? this.bannerUrl,
      baseUrl: baseUrl ?? this.baseUrl,
      sourceCodeUrl: sourceCodeUrl ?? this.sourceCodeUrl,
      sha256: sha256 ?? this.sha256,
      minAppVersion: minAppVersion ?? this.minAppVersion,
      loginType: loginType ?? this.loginType,
      isDevOnly: isDevOnly ?? this.isDevOnly,
      credentials: credentials ?? this.credentials,
      repoUrl: repoUrl ?? this.repoUrl,
      sourceCode: sourceCode ?? this.sourceCode,
      installedAt: installedAt ?? this.installedAt,
    );
  }

  factory ExtensionManifest.fromJson(Map<String, dynamic> json, {String? repoUrl}) {
    final credsRaw = json['credentials'];
    final creds = <ExtensionCredentialField>[];
    if (credsRaw is List) {
      for (final item in credsRaw) {
        if (item is Map) {
          creds.add(ExtensionCredentialField.fromJson(item.cast<String, dynamic>()));
        }
      }
    }

    return ExtensionManifest(
      id: (json['id'] ?? json['guid'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      description: (json['description'] ?? json['notes'] ?? '').toString(),
      version: (json['version'] ?? '1.0.0').toString(),
      lang: (json['lang'] ?? 'pl').toString(),
      author: (json['author'] ?? 'Ogaku').toString(),
      iconUrl: (json['iconUrl'] ?? json['icon'] ?? '').toString(),
      bannerUrl: json['bannerUrl']?.toString(),
      baseUrl: (json['baseUrl'] ?? '').toString(),
      sourceCodeUrl: (json['sourceCodeUrl'] ?? '').toString(),
      sha256: json['sha256']?.toString(),
      minAppVersion: (json['minAppVersion'] ?? json['appMinVerReq'] ?? '1.1.0').toString(),
      loginType: json['loginType'] is int ? json['loginType'] as int : int.tryParse('${json['loginType'] ?? 20}') ?? 20,
      isDevOnly: json['isDevOnly'] == true,
      credentials: creds,
      repoUrl: repoUrl ?? json['repoUrl']?.toString(),
      sourceCode: json['sourceCode']?.toString(),
      installedAt: json['installedAt'] != null ? DateTime.tryParse(json['installedAt'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson({bool includeSourceCode = false}) => {
        'id': id,
        'name': name,
        'description': description,
        'version': version,
        'lang': lang,
        'author': author,
        'iconUrl': iconUrl,
        if (bannerUrl != null) 'bannerUrl': bannerUrl,
        'baseUrl': baseUrl,
        'sourceCodeUrl': sourceCodeUrl,
        if (sha256 != null) 'sha256': sha256,
        'minAppVersion': minAppVersion,
        'loginType': loginType,
        'isDevOnly': isDevOnly,
        'credentials': credentials.map((c) => c.toJson()).toList(),
        if (repoUrl != null) 'repoUrl': repoUrl,
        if (includeSourceCode && sourceCode != null) 'sourceCode': sourceCode,
        if (installedAt != null) 'installedAt': installedAt!.toIso8601String(),
      };

  @override
  String toString() => jsonEncode(toJson());
}

class ExtensionRepo {
  const ExtensionRepo({
    required this.name,
    required this.url,
    this.website,
    this.isOfficial = false,
    this.enabled = true,
  });

  final String name;
  final String url;
  final String? website;
  final bool isOfficial;
  final bool enabled;

  ExtensionRepo copyWith({
    String? name,
    String? url,
    String? website,
    bool? isOfficial,
    bool? enabled,
  }) {
    return ExtensionRepo(
      name: name ?? this.name,
      url: url ?? this.url,
      website: website ?? this.website,
      isOfficial: isOfficial ?? this.isOfficial,
      enabled: enabled ?? this.enabled,
    );
  }

  factory ExtensionRepo.fromJson(Map<String, dynamic> json) => ExtensionRepo(
        name: (json['name'] ?? 'Repository').toString(),
        url: (json['url'] ?? '').toString(),
        website: json['website']?.toString(),
        isOfficial: json['isOfficial'] == true,
        enabled: json['enabled'] != false,
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'url': url,
        if (website != null) 'website': website,
        'isOfficial': isOfficial,
        'enabled': enabled,
      };
}

