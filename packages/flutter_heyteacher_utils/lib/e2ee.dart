import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_heyteacher_utils/firebase/auth.dart';
import 'package:flutter_heyteacher_utils/platform_helper.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:webcrypto/webcrypto.dart';

class E2EEValue {
  Uint8List value;
  Uint8List iv;
  E2EEValue({required this.value, required this.iv});


  E2EEValue.fromMap(Map<String, dynamic> map)
      : value = Uint8List.fromList(_unzip(map['value'])?.cast<int>() ?? []),
        iv = Uint8List.fromList(_unzip(map['iv'])?.cast<int>() ?? []);

  Map<String, dynamic> toJson() => {
        'value': _zip(value),
        'iv': _zip(iv),
      };

  static String? _zip(dynamic object) {
    if (object == null) return null;
    final jsonEncodeValue = jsonEncode(object);
    final utf8Encoded = utf8.encode(jsonEncodeValue);
    final gzipEncoded = gzip.encode(utf8Encoded);
    final base64Encoded = base64.encode(gzipEncoded);
    return base64Encoded;
  }

  static dynamic _unzip(String? base64Encoded) {
    if (base64Encoded == null) return null;
    final base64Decoded = base64.decode(base64Encoded);
    final gzipDecoded = gzip.decode(base64Decoded);
    final uft8Decoded = utf8.decode(gzipDecoded);
    return jsonDecode(uft8Decoded);
  }
}

class E2EE {
  AndroidOptions _getAndroidOptions(String appName) => AndroidOptions(
      encryptedSharedPreferences: true,
      sharedPreferencesName: appName,
      preferencesKeyPrefix: appName);

  // singleton
  static E2EE? _instance;
  static E2EE get instance => _instance ??= E2EE._();
  E2EE._();

  FlutterSecureStorage? _secureStorageInstance;
  Future<FlutterSecureStorage> get _secureStorage async {
    if (_secureStorageInstance != null) return _secureStorageInstance!;
    String appName = "appName";
    if (PlatformHelper.isMobile) {
      appName = (await PackageInfo.fromPlatform()).appName;
    }
    _secureStorageInstance =
        FlutterSecureStorage(aOptions: _getAndroidOptions(appName));
    return _secureStorageInstance!;
  }

  Future<E2EEValue> encrypt(String value) async {
    // cannot encrypt if not auth
    if (Auth.instance().notAutenticated) {
      throw UserNotAuthenticatedException();
    }

    FlutterSecureStorage secureStorage = await _secureStorage;

    final AesGcmSecretKey secretKey;
    // first use, generate the key if non present in secure storage
    if (!await secureStorage.containsKey(key: Auth.instance().uid!)) {
      // Generate a new random AES-GCM secret key for AES-256.
      secretKey = await AesGcmSecretKey.generateKey(256);
      // save into storage
      final secretJwk = await secretKey.exportJsonWebKey();
      // encode json the jwk
      final secretJwkJson = jsonEncode(secretJwk);
      // write the jwk json into storage
      secureStorage.write(key: Auth.instance().uid!, value: secretJwkJson);
      // secret key in secure storage, load it
    } else {
      // read the json jwk secret key from secure storage
      secretKey = await _readSecretKey();
    }
    // Use a unique IV for each message.
    final iv = Uint8List(16);
    fillRandomBytes(iv);
    // decode value in utf8 byte array
    final decryptedBytes = utf8.encode(value);
    // encrypt the value
    final encryptedBytes = await secretKey.encryptBytes(decryptedBytes, iv);
    // return string decoded of encrypted bytes
    return E2EEValue(value: encryptedBytes, iv: iv);
  }

  Future<String> decrypt(E2EEValue encrypted) async {
    // cannot encrypt if not auth
    if (Auth.instance().notAutenticated) {
      throw UserNotAuthenticatedException();
    }
    FlutterSecureStorage secureStorage = await _secureStorage;

    // raise exception if key not found in secure storage
    if (!await secureStorage.containsKey(key: Auth.instance().uid!)) {
      throw MissingSecretKeyInSecureStorage();
    }
    // read the secret key from secure storage
    final secretKey = await _readSecretKey();
    // decrypt value
    final decryptedBytes =
        await secretKey.decryptBytes(encrypted.value, encrypted.iv);
    // return string decripted utf8 decoding bytes
    final decrypted = utf8.decode(decryptedBytes);
    return decrypted;
  }

  Future<AesGcmSecretKey> _readSecretKey() async {
    FlutterSecureStorage secureStorage = await _secureStorage;
    // read the json jwk secret key from secure storage
    final String secretJwkJson =
        (await secureStorage.read(key: Auth.instance().uid!))!;
    // decode the json jwk
    final secretJwk = jsonDecode(secretJwkJson);
    // import the jwk into secret key
    return await AesGcmSecretKey.importJsonWebKey(secretJwk);
  }
}

class MissingSecretKeyInSecureStorage implements Exception {}
