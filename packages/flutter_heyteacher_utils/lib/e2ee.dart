import 'dart:convert';
import 'dart:io';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_heyteacher_utils/context_helper.dart';
import 'package:flutter_heyteacher_utils/firebase/auth.dart';
import 'package:flutter_heyteacher_utils/localizations.dart';
import 'package:flutter_heyteacher_utils/platform_helper.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logging/logging.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:webcrypto/webcrypto.dart';

class E2EE {
  final _log = Logger("E2EE");

  String get _aadKey => "${Auth.instance().uid!}_aad";

  String get _secretKeyKey => "${Auth.instance().uid!}_secretKey";

  Future<bool> get secretKeyStored async =>
      (await _secureStorage).containsKey(key: _secretKeyKey);

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

  AndroidOptions _getAndroidOptions(String appName) => AndroidOptions(
      encryptedSharedPreferences: true,
      sharedPreferencesName: appName,
      preferencesKeyPrefix: appName);

  Future<E2EEValue> encrypt(String value, {AesGcmSecretKey? secretKey}) async {
    // cannot encrypt if not auth
    if (Auth.instance().notAutenticated) {
      _log.severe("encrypt: user not authenticated");
      throw UserNotAuthenticatedException();
    }
    String aad = await getAAD() ?? "";
    if (aad.isEmpty) {
      _log.severe("encrypt: aad is empty");
      throw AADEmptyException();
    }
    final FlutterSecureStorage secureStorage = await _secureStorage;

    if (secretKey == null) {
      // first use, generate the key if non present in secure storage
      if (!await secureStorage.containsKey(key: _secretKeyKey)) {
        secretKey = await _generateSecretKey();
      } else {
        // read the json jwk secret key from secure storage
        secretKey = await _readSecretKey();
      }
    }
    // Use a unique IV for each message.
    final iv = Uint8List(16);
    fillRandomBytes(iv);
    // aad bytes
    final aadBytes = utf8.encode(aad);
    // decode value in utf8 byte array
    final decryptedBytes = utf8.encode(value);
    // encrypt the value, with initial vector ad additional data provided
    try {
      final encryptedBytes = await secretKey.encryptBytes(decryptedBytes, iv,
          additionalData: aadBytes);
      // return string encoded with the initial vector
      return E2EEValue(value: encryptedBytes, iv: iv);
    } catch (e, s) {
      _log.severe("encrypt: error", e, s);
      throw ErrorOnEncryptException();
    }
  }

  Future<String> decrypt(E2EEValue encrypted,
      {AesGcmSecretKey? secretKey}) async {
    // cannot encrypt if not auth
    if (Auth.instance().notAutenticated) {
      _log.severe("decrypt: user not authenticated");
      throw UserNotAuthenticatedException();
    }
    String aad = await getAAD() ?? "";
    if (aad.isEmpty) {
      _log.severe("decrypt: aad is empty");
      throw AADEmptyException();
    }
    FlutterSecureStorage secureStorage = await _secureStorage;

    // raise exception if key not found in secure storage
    if (secretKey == null &&
        !await secureStorage.containsKey(key: _secretKeyKey)) {
      _log.severe("decrypt: missing secret key");
      throw MissingEncryptionSecretKeyException();
    }
    // aad bytes
    final aadBytes = utf8.encode(aad);
    // if param secretKey is null, read the secret key from secure storage
    secretKey ??= await _readSecretKey();
    // decrypt value
    try {
      final decryptedBytes = await secretKey.decryptBytes(
          encrypted.value, encrypted.iv,
          additionalData: aadBytes);
      // return string decripted utf8 decoding bytes
      final decrypted = utf8.decode(decryptedBytes);
      return decrypted;
    } catch (e, s) {
      _log.severe("decrypt: error", e, s);
      throw ErrorOnDecryptException();
    }
  }

  Future<void> setAAD(String aadValue) async {
    // cannot encrypt if not auth
    if (Auth.instance().notAutenticated) {
      _log.severe("setAAD: user not authenticated");
      throw UserNotAuthenticatedException();
    }
    FlutterSecureStorage secureStorage = await _secureStorage;
    secureStorage.write(key: _aadKey, value: aadValue);
  }

  Future<String?> getAAD() async {
    // cannot encrypt if not auth
    if (Auth.instance().notAutenticated) {
      return null;
    }
    FlutterSecureStorage secureStorage = await _secureStorage;
    return secureStorage.read(key: _aadKey);
  }

  Future<String> exportSecretJwkJson() async {
    AesGcmSecretKey secretKey;
    if (!await secretKeyStored) {
      // if secret key isn't already generated, generate it
      secretKey = await _generateSecretKey();
    } else {
      // read the secret key from secure storage
      secretKey = await _readSecretKey();
    }
    // save into storage
    final secretJwk = await secretKey.exportJsonWebKey();
    // encode json the jwk
    final secretJwkJson = jsonEncode(secretJwk);
    // encrypt key with master key
    final e2eeValue =
        await encrypt(secretJwkJson, secretKey: await _readMasterSecretKey());
    // return json encode E2EE value
    return jsonEncode(e2eeValue);
  }

  Future<void> importSecretJwkJson(String e2eeValueJson) async {
    // deserialize E2EEValue from json
    final e2eeValue = E2EEValue.fromMap(jsonDecode(e2eeValueJson));
    // decrypt E2EEValue using Master Secret Key (and passphrase)
    final secretJwkJson =
        await decrypt(e2eeValue, secretKey: await _readMasterSecretKey());
    // try to read secret key
    await _readSecretKeyFromJwkJson(secretJwkJson);
    // write the jwk json into storage
    final FlutterSecureStorage secureStorage = await _secureStorage;
    await secureStorage.write(key: _secretKeyKey, value: secretJwkJson);
  }

  Future<AesGcmSecretKey> _generateSecretKey() async {
    // cannot encrypt if not auth
    if (Auth.instance().notAutenticated) {
      _log.severe("_generateSecretKey: user not authenticated");
      throw UserNotAuthenticatedException();
    }
    final FlutterSecureStorage secureStorage = await _secureStorage;
    // Generate a new random AES-GCM secret key for AES-256.
    final secretKey = await AesGcmSecretKey.generateKey(256);
    // save into storage
    final secretJwk = await secretKey.exportJsonWebKey();
    // encode json the jwk
    final secretJwkJson = jsonEncode(secretJwk);
    // write the jwk json into storage
    secureStorage.write(key: _secretKeyKey, value: secretJwkJson);
    // secret key in secure storage, load it
    return secretKey;
  }

  Future<AesGcmSecretKey> _readSecretKey() async {
    // cannot encrypt if not auth
    if (Auth.instance().notAutenticated) {
      _log.severe("_readSecretKey: user not authenticated");
      throw UserNotAuthenticatedException();
    }
    FlutterSecureStorage secureStorage = await _secureStorage;
    // read the json jwk secret key from secure storage
    final String secretJwkJson =
        (await secureStorage.read(key: _secretKeyKey))!;
    // decode the json jwk
    return await _readSecretKeyFromJwkJson(secretJwkJson);
  }

  Future<AesGcmSecretKey> _readMasterSecretKey() async {
    // cannot encrypt if not auth
    if (Auth.instance().notAutenticated) {
      _log.severe("_readMasterSecretKey: user not authenticated");
      throw UserNotAuthenticatedException();
    }
    // decode the json jwk
    return await _readSecretKeyFromJwkJson(
        FirebaseRemoteConfig.instance.getString("masterSecretKeyJwk"));
  }

  Future<AesGcmSecretKey> _readSecretKeyFromJwkJson(
      String secretJwkJson) async {
    final secretJwk = jsonDecode(secretJwkJson);
    _log.fine("_readSecretKeyFromJwkJson: secret key alg ${secretJwk["alg"]}");
    // import the jwk into secret key
    return await AesGcmSecretKey.importJsonWebKey(secretJwk);
  }
}

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

class ErrorOnEncryptException {
  @override
  String toString() {
    if (ContextHelper.context != null) {
      return FlutterHeyteacherUtilsLocalizations.of(ContextHelper.context!)!
          .errorOnEncryptionCheckPassphrase;
    } else {
      return "Error on encryption, check passphrase";
    }
  }
}

class ErrorOnDecryptException {
  @override
  String toString() {
    if (ContextHelper.context != null) {
      return FlutterHeyteacherUtilsLocalizations.of(ContextHelper.context!)!
          .errorOnDecryptionCheckPassphrase;
    } else {
      return "Error on decryption, check passphrase";
    }
  }
}

class AADEmptyException implements Exception {
  @override
  String toString() {
    if (ContextHelper.context != null) {
      return FlutterHeyteacherUtilsLocalizations.of(ContextHelper.context!)!
          .encryptionPassphraseIsEmptySetIt;
    } else {
      return "Encryption Passphrase is empty, set it";
    }
  }
}

class MissingEncryptionSecretKeyException implements Exception {
  @override
  String toString() {
    if (ContextHelper.context != null) {
      return FlutterHeyteacherUtilsLocalizations.of(ContextHelper.context!)!
          .missingEncryptionSecretKeyImportIt;
    } else {
      return "Missing Encryption Secret Key, import it";
    }
  }
}
