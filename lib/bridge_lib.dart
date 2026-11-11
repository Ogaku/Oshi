library;

import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:oshi/providers/vulcan/hebe_signer.dart';
import 'package:oshi/share/translator.dart';
import 'package:uuid/uuid.dart';

export 'package:oshi/extensions/bridge/oshi_bridge.dart'
    show OSource, OProvider, OHttpClient, OHttpResponse, OProtocolDriver;

/// Reports progress to the host Oshi UI during `login` or `refresh` inside a `.dart` extension.
void reportProgress(double? progress, String? message) {}

/// Publishes serialized `ProviderData` JSON back to the host Oshi session from a `.dart` extension.
void setRegisterDataJson(Map<String, dynamic> data) {}

/// Translates a localization key using Oshi's active `Translator`.
String localized(String key) => key.localized;

/// Generates a fresh RSA-2048 keypair and SHA-1 fingerprint for the eduVULCAN Hebe API.
Map<String, String> generateHebeKeyPair() {
  final kp = HebeSigner.generateKeyPair();
  return {
    'certificate': kp.certificate,
    'privateKey': kp.privateKey,
    'fingerprint': kp.fingerprint,
  };
}

/// Computes HTTP signature headers (`Digest`, `Signature`, `Date`) for an eduVULCAN Hebe API request.
Map<String, String> getHebeSignatureHeaders({
  required String keyId,
  required String privateKeyJson,
  String? body,
  required String requestPath,
}) {
  return HebeSigner.getSignatureHeaders(
    keyId: keyId,
    privateKeyJson: privateKeyJson,
    body: body,
    requestPath: requestPath,
  );
}

/// Generates a random RFC-4122 UUID v4 string.
String uuidV4() => const Uuid().v4();

/// Computes the lowercase hexadecimal SHA-256 digest of [input].
String sha256Hex(String input) => sha256.convert(utf8.encode(input)).toString();

/// Computes the lowercase hexadecimal MD5 digest of [input].
String md5Hex(String input) => md5.convert(utf8.encode(input)).toString();
