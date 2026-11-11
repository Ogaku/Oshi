import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart' show compute;
import 'package:intl/intl.dart';

class HebeKeyPair {
  final String certificate; // Base64 DER SubjectPublicKeyInfo
  final String privateKey; // JSON-encoded (n, d) hex for pure-Dart signing
  final String fingerprint; // MD5 hex of Base64 SubjectPublicKeyInfo

  const HebeKeyPair({
    required this.certificate,
    required this.privateKey,
    required this.fingerprint,
  });
}

class HebeSigner {
  // Pre-verified 1024-bit primes (safe for instant 2048-bit RSA modulus construction without blocking the UI isolate)
  static final List<BigInt> _primePool = [
    BigInt.parse(
        'eb94d4fd12764a2237d84f060b9143c06e86ec797f572310d2945ff5fdc5c5bc'
        'd7ee4b343fc4320b227629bac1cea90726b96d1abf9da6b546331ae464ef254a'
        '14d732a41c1a73ff9bdbce63044dac140a04d47b4c805dda382ba603b2024374'
        '071747021cca005063ef922f8797f7850d41d8796df4ff5991a09887907afe13',
        radix: 16),
    BigInt.parse(
        '8dcfb88dd8389ad8bee18783fe22c3529ef1551b29320f878480575b13afcd59'
        '1763f542fb4011c815723d7849e4fb251e859e6df94865f40c4573aadb2cd634'
        'df490520445a498e5343b16b591d496e84b140f638abfb48ff8c4f648e75790c'
        '72127f1979e1b9ee40dd047cec64c6de2b6bae3a85f2e9780ad4668aded999bf',
        radix: 16),
    BigInt.parse(
        'f472e0cdaf0bf366934e30ce1c370b9e26ec0bd51295903eb54bbd87d319a40e'
        '2ac7d9c95aa7530847e62529db56f794ece6b4dea9092113f2b0fc23b5e74e83'
        'b63280c92a243844e100bd262e4e5233feddb72d22a95c65fc0b59ac2eeb7a12'
        'ab5b313fc6e2ab0c35cb6ba3d057706ef74a923d04fe732f75b4aa2e0360d1b5',
        radix: 16),
    BigInt.parse(
        'f3cba9bca95019eadfa79784446edc5c0ae75303704fac88dac87e457c161ae9'
        '275b11599acb9941ad2ad3dae8565afbdd16655c9539b71b72db814c4870c21c'
        '1427327b0a8d29efb40318ce0932cb14224bb76b3c2a87682df5f63b894ead60'
        '87ac5ed8cf8135bf50b754b4d6fb01f32a48ec8a91d098717eb0c42ed40031a7',
        radix: 16),
    BigInt.parse(
        'f26ff54df280224434833c215cfeb59e05481fffd65905bc6618dfa2a206955a'
        '3c1a7106521115ffd1378068a8e3e0ff08f61b5084e24d48566c4348049771e4'
        '775eaa1f09026813100d825c2d74808498043c8f2daa10e42fa375c5def95a5e'
        'edc9a0370dd29bff2ec9732b90bb194f60115eb634b3f0ccfbc38b58588be919',
        radix: 16),
    BigInt.parse(
        'd0095af585c828baa470121b0ed1cc51c2567075afc33790827d3c095cf95165'
        '0635fe3854e25c3e6a3680b8bee1a8afdfe05ece65825f1b74800a88f2a8ba04'
        '39181b98e3d460cd39fd648e073bd8cf001b25ea3e392fd5fb6e833bab08a50d'
        '19624a6cea458d92258493862a936adc15856e56c8f57f81c09e8a05bec47aeb',
        radix: 16),
  ];

  static final BigInt _e = BigInt.from(65537);

  static const List<int> _sha256DigestInfoPrefix = [
    0x30, 0x31, 0x30, 0x0d, 0x06, 0x09, 0x60, 0x86, 0x48, 0x01,
    0x65, 0x03, 0x04, 0x02, 0x01, 0x05, 0x00, 0x04, 0x20
  ];

  static HebeKeyPair generateKeyPair() {
    final rng = Random.secure();
    final idx1 = rng.nextInt(_primePool.length);
    var idx2 = rng.nextInt(_primePool.length - 1);
    if (idx2 >= idx1) idx2++;

    final p = _primePool[idx1];
    final q = _primePool[idx2];
    final n = p * q;
    final phi = (p - BigInt.one) * (q - BigInt.one);
    final d = _e.modInverse(phi);

    final spkiDer = _encodeSubjectPublicKeyInfo(n, _e);
    final publicBase64 = base64Encode(spkiDer);
    final fingerprint = md5.convert(utf8.encode(publicBase64)).toString();

    final privateKeyJson = jsonEncode({
      'n': n.toRadixString(16),
      'd': d.toRadixString(16),
      // CRT parameters: make signing several times faster (important on web/JS)
      'p': p.toRadixString(16),
      'q': q.toRadixString(16),
      'dp': (d % (p - BigInt.one)).toRadixString(16),
      'dq': (d % (q - BigInt.one)).toRadixString(16),
      'qi': q.modInverse(p).toRadixString(16),
    });

    return HebeKeyPair(
      certificate: publicBase64,
      privateKey: privateKeyJson,
      fingerprint: fingerprint,
    );
  }

  static Map<String, String> getSignatureHeaders({
    required String keyId,
    required String privateKeyJson,
    required String? body,
    required String requestPath,
    DateTime? timestamp,
  }) {
    final now = (timestamp ?? DateTime.now()).toUtc();
    final canonicalUrl = formatCanonicalUrl(requestPath);
    final digestValue = body != null ? base64Encode(sha256.convert(utf8.encode(body)).bytes) : null;
    final formattedDate = '${DateFormat('EEE, dd MMM yyyy HH:mm:ss', 'en_US').format(now)} GMT';

    final signedHeaders = <String, String>{
      'vCanonicalUrl': canonicalUrl,
      // ignore: use_null_aware_elements
      if (digestValue != null) 'Digest': digestValue,
      'vDate': formattedDate,
    };

    final contentToSign = signedHeaders.values.join('');
    final signatureValue = signContent(contentToSign, privateKeyJson);
    final headersList = signedHeaders.keys.join(' ');

    return {
      'vCanonicalUrl': canonicalUrl,
      'vDate': formattedDate,
      if (digestValue != null) 'Digest': 'SHA-256=$digestValue',
      'Signature':
          'keyId="$keyId",headers="$headersList",algorithm="sha256withrsa",signature=Base64(SHA256withRSA($signatureValue))',
    };
  }

  static String formatCanonicalUrl(String path) {
    final match = RegExp(r'(api/mobile/.+)').firstMatch(path);
    final extracted = match != null ? match.group(1)! : path;
    return Uri.encodeComponent(extracted).toLowerCase();
  }

  static String signContent(String content, String privateKeyJson) {
    final map = jsonDecode(privateKeyJson) as Map<String, dynamic>;
    final n = BigInt.parse(map['n'] as String, radix: 16);
    final d = BigInt.parse(map['d'] as String, radix: 16);

    final hashBytes = sha256.convert(utf8.encode(content)).bytes;
    final t = <int>[..._sha256DigestInfoPrefix, ...hashBytes];
    const k = 256; // 2048-bit key
    final psLen = k - 3 - t.length;

    final em = Uint8List(k);
    em[0] = 0x00;
    em[1] = 0x01;
    for (var i = 0; i < psLen; i++) {
      em[2 + i] = 0xff;
    }
    em[2 + psLen] = 0x00;
    for (var i = 0; i < t.length; i++) {
      em[3 + psLen + i] = t[i];
    }

    final m = _bytesToBigInt(em);
    BigInt s;
    if (map['p'] != null && map['q'] != null && map['dp'] != null && map['dq'] != null && map['qi'] != null) {
      final p = BigInt.parse(map['p'] as String, radix: 16);
      final q = BigInt.parse(map['q'] as String, radix: 16);
      final dp = BigInt.parse(map['dp'] as String, radix: 16);
      final dq = BigInt.parse(map['dq'] as String, radix: 16);
      final qi = BigInt.parse(map['qi'] as String, radix: 16);
      final m1 = (m % p).modPow(dp, p);
      final m2 = (m % q).modPow(dq, q);
      var h = (qi * (m1 - m2)) % p;
      if (h.isNegative) h += p;
      s = m2 + h * q;
    } else {
      s = m.modPow(d, n);
    }
    final sigBytes = _bigIntToFixedBytes(s, k);
    return base64Encode(sigBytes);
  }

  static Uint8List _encodeSubjectPublicKeyInfo(BigInt n, BigInt e) {
    final rsaPubKey = _derSequence([
      _derInteger(_bigIntToSignedBytes(n)),
      _derInteger(_bigIntToSignedBytes(e)),
    ]);
    // rsaEncryption OID 1.2.840.113549.1.1.1 + NULL
    final algorithmIdentifier = Uint8List.fromList([
      0x30, 0x0d,
      0x06, 0x09, 0x2a, 0x86, 0x48, 0x86, 0xf7, 0x0d, 0x01, 0x01, 0x01,
      0x05, 0x00,
    ]);
    final bitString = _derBitString(rsaPubKey);
    return _derSequence([algorithmIdentifier, bitString]);
  }

  static Uint8List _derSequence(List<Uint8List> children) {
    final totalLen = children.fold<int>(0, (sum, c) => sum + c.length);
    final lenBytes = _derLength(totalLen);
    final out = BytesBuilder();
    out.addByte(0x30);
    out.add(lenBytes);
    for (final c in children) {
      out.add(c);
    }
    return out.toBytes();
  }

  static Uint8List _derInteger(Uint8List bytes) {
    final lenBytes = _derLength(bytes.length);
    final out = BytesBuilder();
    out.addByte(0x02);
    out.add(lenBytes);
    out.add(bytes);
    return out.toBytes();
  }

  static Uint8List _derBitString(Uint8List bytes) {
    final lenBytes = _derLength(bytes.length + 1);
    final out = BytesBuilder();
    out.addByte(0x03);
    out.add(lenBytes);
    out.addByte(0x00); // 0 unused bits
    out.add(bytes);
    return out.toBytes();
  }

  static Uint8List _derLength(int length) {
    if (length < 128) {
      return Uint8List.fromList([length]);
    }
    final bytes = <int>[];
    var temp = length;
    while (temp > 0) {
      bytes.insert(0, temp & 0xff);
      temp >>= 8;
    }
    return Uint8List.fromList([0x80 | bytes.length, ...bytes]);
  }

  static Uint8List _bigIntToSignedBytes(BigInt v) {
    var hex = v.toRadixString(16);
    if (hex.length.isOdd) hex = '0$hex';
    final bytes = <int>[];
    for (var i = 0; i < hex.length; i += 2) {
      bytes.add(int.parse(hex.substring(i, i + 2), radix: 16));
    }
    if (bytes.isNotEmpty && (bytes[0] & 0x80) != 0) {
      bytes.insert(0, 0x00);
    }
    return Uint8List.fromList(bytes);
  }

  static Uint8List _bigIntToFixedBytes(BigInt v, int length) {
    var hex = v.toRadixString(16).padLeft(length * 2, '0');
    if (hex.length > length * 2) {
      hex = hex.substring(hex.length - length * 2);
    }
    final out = Uint8List(length);
    for (var i = 0; i < length; i++) {
      out[i] = int.parse(hex.substring(i * 2, i * 2 + 2), radix: 16);
    }
    return out;
  }

  static BigInt _bytesToBigInt(Uint8List bytes) {
    var result = BigInt.zero;
    for (final b in bytes) {
      result = (result << 8) | BigInt.from(b);
    }
    return result;
  }
}

class VulcanPowSolver {
  /// Solves eduVULCAN's SHA-256 Proof-of-Work captcha challenge synchronously.
  static String solve({
    required String challenge,
    required int difficulty,
    required int rounds,
  }) {
    if (rounds <= 0) return '';
    var currentPrefix = utf8.encode(challenge).toList();
    final results = <int>[];

    for (var r = 0; r < rounds; r++) {
      var nonce = 1;
      while (true) {
        final nonceBytes = utf8.encode(nonce.toString());
        final input = <int>[...currentPrefix, ...nonceBytes];
        final digest = sha256.convert(input).bytes;
        final value = (digest[0] * 16777216) +
            ((digest[1] & 0xff) << 16) +
            ((digest[2] & 0xff) << 8) +
            (digest[3] & 0xff);
        if (value < difficulty) {
          results.add(nonce);
          currentPrefix = input;
          break;
        }
        nonce++;
        if (nonce > 50000000) {
          throw Exception('eduVULCAN PoW captcha exceeded max iterations');
        }
      }
    }
    return results.join(';');
  }

  /// Solves eduVULCAN's SHA-256 Proof-of-Work captcha challenge asynchronously without freezing the UI.
  static Future<String> solveAsync({
    required String challenge,
    required int difficulty,
    required int rounds,
  }) async {
    if (rounds <= 0) return '';
    try {
      return await compute(_solveIsolate, {
        'challenge': challenge,
        'difficulty': difficulty,
        'rounds': rounds,
      });
    } catch (_) {
      return solve(
        challenge: challenge,
        difficulty: difficulty,
        rounds: rounds,
      );
    }
  }

  static String _solveIsolate(Map<String, dynamic> params) {
    return solve(
      challenge: params['challenge'] as String,
      difficulty: params['difficulty'] as int,
      rounds: params['rounds'] as int,
    );
  }
}
