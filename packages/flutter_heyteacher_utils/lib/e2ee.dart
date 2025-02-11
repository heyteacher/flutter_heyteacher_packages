import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_heyteacher_utils/firebase/auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:webcrypto/webcrypto.dart';

class E2EEValue {
  Uint8List value;
  Uint8List iv;
  E2EEValue({required this.value, required this.iv});

  E2EEValue.fromJson(Map<String, dynamic> json)
      : value = Uint8List.fromList( json['value']?.cast<int>() ?? []) ,
        iv = Uint8List.fromList(json['iv']?.cast<int>() ?? []);

  Map<String, dynamic> toJson() => {
        'value': value,
        'iv': iv,
      };
}

class E2EE {
  late FlutterSecureStorage _secureStorage;

  AndroidOptions _getAndroidOptions(String appName) => AndroidOptions(
      encryptedSharedPreferences: true,
      sharedPreferencesName: appName,
      preferencesKeyPrefix: appName);

  // singleton
  static E2EE? _instance;
  static E2EE instance({required String appName}) =>
      _instance ??= E2EE._(appName);
  E2EE._(String appName) {
    _secureStorage =
        FlutterSecureStorage(aOptions: _getAndroidOptions(appName));
  }

  Future<E2EEValue> encrypt(String value) async {
    // cannot encrypt if not auth
    if (Auth.instance().notAutenticated) {
      throw UserNotAuthenticatedException();
    }
    final AesGcmSecretKey secretKey;
    // first use, generate the key if non present in secure storage
    if (!await _secureStorage.containsKey(key: Auth.instance().uid!)) {
      // Generate a new random AES-GCM secret key for AES-256.
      secretKey = await AesGcmSecretKey.generateKey(256);
      // save into storage
      final secretJwk = await secretKey.exportJsonWebKey();
      // encode json the jwk
      final secretJwkJson = jsonEncode(secretJwk);
      // write the jwk json into storage
      _secureStorage.write(key: Auth.instance().uid!, value: secretJwkJson);
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
    // raise exception if key not found in secure storage
    if (!await _secureStorage.containsKey(key: Auth.instance().uid!)) {
      throw MissingSecretKeyInSecureStorage();
    }
    // read the secret key from secure storage
    final secretKey = await _readSecretKey();
    // decrypt value
    final decryptedBytes =
        await secretKey.decryptBytes(encrypted.value, encrypted.iv);
    // return string decripted utf8 decoding bytes
    return utf8.decode(decryptedBytes);
  }

  Future<AesGcmSecretKey> _readSecretKey() async {
    // read the json jwk secret key from secure storage
    final String secretJwkJson =
        (await _secureStorage.read(key: Auth.instance().uid!))!;
    // decode the json jwk
    final secretJwk = jsonDecode(secretJwkJson);
    // import the jwk into secret key
    return await AesGcmSecretKey.importJsonWebKey(secretJwk);
  }
}

class MissingSecretKeyInSecureStorage implements Exception {}


/*
// Generate a new random AES-GCM secret key for AES-256.
final k = await AesGcmSecretKey.generate(256);

// Use a unique IV for each message.
final iv = Uint8List(16);
fillRandomBytes(iv);

// Specify optional additionalData
final ad = utf8.encode('my-test-message');

// Encrypt a message
final c = await k.encryptBytes(
  utf8.encode('hello world'),
  iv,
  additionalData: ad,
);

// Decrypt message (requires the same iv)
print(utf8.decode(await k.decryptBytes(
  c,
  iv,
  additionalData: ad,
))); //

*/