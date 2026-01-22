/// Provides End-to-End Encryption (E2EE) capabilities using AES-GCM.
///
/// This library manages the generation, secure storage, import, and export
/// of cryptographic keys. It leverages `flutter_secure_storage` for key
/// persistence
/// and `webcrypto` for cryptographic operations.
///
/// Key features:
/// - AES-GCM for authenticated encryption.
/// - Secure storage of the user's secret key.
/// - Use of Additional Authenticated Data (AAD), often a user-provided
/// passphrase.
/// - Export/import of the secret key, itself encrypted with a master key (e.g., from Remote Config).
/// - Custom exceptions for specific E2EE-related errors.
library;

import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_heyteacher_utils/context_helper.dart';
import 'package:flutter_heyteacher_utils/firebase.dart';
import 'package:flutter_heyteacher_utils/locale.dart';
import 'package:flutter_heyteacher_utils/platform_helper.dart';
import 'package:flutter_heyteacher_utils/src/e2ee/e2ee_data.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logging/logging.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:webcrypto/webcrypto.dart';

/// Manages End-to-End Encryption (E2EE) operations for the application.
///
/// This class is a singleton, accessible via `E2EE.instance`.
/// It handles AES-GCM encryption/decryption, secret key management (generation,
/// storage in `FlutterSecureStorage`, import/export), and the use of
/// Additional Authenticated Data (AAD).
class E2EEViewModel {
  /// Private constructor for the singleton.
  E2EEViewModel._(this._uid);
  final _logger = Logger('E2EEViewModel');

  /// Key used in secure storage for the Additional Authenticated Data (AAD).
  /// Uniquely identifies the AAD for the current authenticated user.
  @visibleForTesting
  String get aadKey => '${_uid}_aad';

  /// Key used in secure storage for the user's secret encryption key
  /// (in JWK format).
  /// Uniquely identifies the secret key for the current authenticated user.
  @visibleForTesting
  String get secretKeyKey => '${_uid}_secretKey';

  /// Asynchronously checks if the user's secret key is currently stored.
  Future<bool> get secretKeyStored async =>
      _useE2EEWebDebugSecretKey ||
      await (await _secureStorage).containsKey(key: secretKeyKey);

  bool get _useE2EEWebDebugSecretKey =>
      PlatformHelper.isWeb &&
      RemoteConfigViewModel.instance
          .getString(FHURemoteConfigKeys.webDemoE2EESecretKey.name)
          .isNotEmpty;

  /// Asynchronously checks if the user's secret key is not currently stored.
  Future<bool> get secretKeyNotStored async => !await secretKeyStored;

  // Singleton instance
  static final Map<String?, E2EEViewModel?> _instances = {};

  final String? _uid;

  /// Provides the singleton instance of the [E2EEViewModel] manager.
  // ignore: prefer_constructors_over_static_methods
  static E2EEViewModel instance(String? uid) =>
      _instances[uid] ??= E2EEViewModel._(uid);

  /// the secure storage instance
  @visibleForTesting
  FlutterSecureStorage? flutterSecureStorage;

  /// Lazily initializes and returns the [FlutterSecureStorage] instance.
  /// Configures Android-specific options for encrypted shared preferences.
  Future<FlutterSecureStorage> get _secureStorage async {
    if (flutterSecureStorage != null) return flutterSecureStorage!;
    var appName = 'appName';
    try {
      appName = (await PackageInfo.fromPlatform()).appName;
    } on Exception catch (error, stackTrace) {
      _logger.warning(
        "unable to read app name, use 'appName'",
        error,
        stackTrace,
      );
    }
    flutterSecureStorage = FlutterSecureStorage(
      aOptions: _getAndroidOptions(appName),
    );
    return flutterSecureStorage!;
  }

  /// Returns Android-specific options for `FlutterSecureStorage`.
  ///
  /// Enables encrypted shared preferences, using the [appName] for naming.
  AndroidOptions _getAndroidOptions(String appName) => AndroidOptions(
    sharedPreferencesName: appName,
    preferencesKeyPrefix: appName,
  );

  /// Encrypts the given [value] string using AES-GCM.
  ///
  /// Requires the user to be authenticated and an AAD (passphrase) to be set.
  /// If [esternalSecretKey] is not provided, it generates or retrieves
  /// the user's secret key from secure storage.
  /// Returns an [E2EEValue] containing the encrypted data and the
  /// Initialization Vector (IV).
  /// Throws [UserNotAuthenticatedException], [AADEmptyException],
  /// or [ErrorOnEncryptException] on failure.
  Future<E2EEValue> encrypt(
    String value, {
    AesGcmSecretKey? esternalSecretKey,
  }) async {
    _logger.finest('<encrypt>:');
    // cannot encrypt if not auth
    if (_uid?.isEmpty ?? false) {
      _logger.severe('(encrypt): user not authenticated');
      throw UserNotAuthenticatedException();
    }
    final aad = await getAAD();
    if (aad == null || aad.isEmpty) {
      _logger.severe('(encrypt): aad not set');
      throw AADEmptyException();
    }

    var secretKeyToUse = esternalSecretKey;
    secretKeyToUse ??= await secretKeyNotStored
        ? await generateSecretKey()
        : await _readSecretKey();
    // Use a unique IV for each message.
    final iv = Uint8List(16);
    fillRandomBytes(iv);
    // aad bytes
    final aadBytes = utf8.encode(aad);
    // decode value in utf8 byte array
    final decryptedBytes = utf8.encode(value);
    // encrypt the value, with initial vector ad additional data provided
    try {
      final encryptedBytes = await secretKeyToUse.encryptBytes(
        decryptedBytes,
        iv,
        additionalData: aadBytes,
      );
      // return string encoded with the initial vector
      return E2EEValue(value: encryptedBytes, iv: iv);
    } on Exception catch (error, stackTrace) {
      _logger.severe('(encrypt): error', error, stackTrace);
      throw ErrorOnEncryptException();
    }
  }

  /// Decrypts the given [encrypted] [E2EEValue] using AES-GCM.
  ///
  /// Requires the user to be authenticated and an AAD (passphrase) to be set.
  /// If [secretKey] is not provided, it retrieves the user's secret key from
  /// secure storage.
  /// Returns the decrypted string.
  /// Throws [UserNotAuthenticatedException], [AADEmptyException],
  /// [MissingEncryptionSecretKeyException], or [ErrorOnDecryptException]
  /// on failure.
  Future<String> decrypt(
    E2EEValue encrypted, {
    AesGcmSecretKey? secretKey,
  }) async {
    _logger.finest('<decrypt>:');
    // cannot encrypt if not auth
    if (_uid?.isEmpty ?? false) {
      _logger.severe('(decrypt): user not authenticated');
      throw UserNotAuthenticatedException();
    }
    // check and read AAD
    final aad = await getAAD();
    if (aad == null || aad.isEmpty) {
      _logger.severe('(decrypt): aad is empty');
      throw AADEmptyException();
    }
    var secretKeyToUse = secretKey;
    // raise exception if key not found in secure storage
    if (secretKeyToUse == null && await secretKeyStored) {
      // if param secretKey is null, read the secret key from secure storage
      secretKeyToUse = await _readSecretKey();
    }
    // raise exception if key not found in secure storage
    if (secretKeyToUse == null) {
      _logger.severe('decrypt: missing secret key');
      throw MissingEncryptionSecretKeyException();
    }
    try {
      // aad bytes
      final aadBytes = utf8.encode(aad);
      // decrypt bytes
      final decryptedBytes = await secretKeyToUse.decryptBytes(
        encrypted.value,
        encrypted.iv,
        additionalData: aadBytes,
      );
      // return string decripted utf8 decoding bytes
      final decrypted = utf8.decode(decryptedBytes);
      return decrypted;
    } on Exception catch (error, stackTrace) {
      _logger.severe('(decrypt): error', error, stackTrace);
      throw ErrorOnDecryptException();
    }
  }

  /// Sets the Additional Authenticated Data (AAD) for the current user.
  ///
  /// The [aadValue] (typically a user-provided passphrase) is stored securely.
  /// Requires the user to be authenticated.
  ///
  /// If [generate] is true, a random AAD value is generated instead of using
  /// the provided [aadValue].
  Future<void> setAAD({String? aadValue, bool generate = false}) async {
    _logger.finer('<setAAD>:');
    // cannot encrypt if not auth
    if (_uid?.isEmpty ?? false) {
      _logger.severe('(setAAD): user not authenticated');
      throw UserNotAuthenticatedException();
    }
    final secureStorage = await _secureStorage;
    await secureStorage.write(
      key: aadKey,
      value: generate ? _generateAADValue() : aadValue,
    );
  }

  /// Retrieves the Additional Authenticated Data (AAD) for the current user.
  ///
  /// Returns `null` if the user is not authenticated or if no AAD is set.
  Future<String?> getAAD() async {
    _logger.finest('<getAAD>:');
    // cannot encrypt if not auth
    if (_uid?.isEmpty ?? false) {
      _logger.warning('(getAAD): user not authenticated');
      return null;
    }
    if (PlatformHelper.isWeb) {
      // not found, try to read from remote config `e2eeWebDebugPassword`
      final e2eeWebDebugPassword = RemoteConfigViewModel.instance.getString(
        FHURemoteConfigKeys.webDemoPassword.name,
      );
      if (e2eeWebDebugPassword.isNotEmpty) {
        await setAAD(aadValue: e2eeWebDebugPassword);
        return e2eeWebDebugPassword;
      } else {
        _logger.severe('(getAAD): e2eeWebDebugPassword is empty');
        // not found, return null
        return null;
      }
    } else {
      // try to read from secure storage
      final aad = await (await _secureStorage).read(key: aadKey);
      if (aad != null && aad.isNotEmpty) {
        // found, return it
        return aad;
      } else {
        // not found return null
        return null;
      }
    }
  }

  /// Exports the user's secret key as a JSON string.
  ///
  /// The secret key (in JWK format) is first encrypted using a master secret
  /// key (retrieved from Firebase Remote Config) before being returned as a
  /// JSON representation of an [E2EEValue]. This allows for secure backup or
  /// transfer of the key.
  Future<String> exportSecretJwkJson() async {
    _logger.finer('<exportSecretJwkJson>:');
    AesGcmSecretKey secretKey;
    if (await secretKeyNotStored) {
      // if secret key isn't already generated, generate it
      secretKey = await generateSecretKey();
    } else {
      // read the secret key from secure storage
      secretKey = await _readSecretKey();
    }
    // save into storage
    final secretJwk = await secretKey.exportJsonWebKey();
    // encode json the jwk
    final secretJwkJson = jsonEncode(secretJwk);
    // encrypt key with master key
    final e2eeValue = await encrypt(
      secretJwkJson,
      esternalSecretKey: await _readMasterSecretKey(),
    );
    // return json encode E2EE value
    return jsonEncode(e2eeValue);
  }

  /// Imports a user's secret key from an [e2eeValueJson] string and returns
  /// the secret Jwk in JSON format.
  ///
  /// The [e2eeValueJson] is expected to be a JSON representation of an
  /// [E2EEValue] containing the user's secret key (in JWK format) encrypted
  /// with the master secret key. This method decrypts it, validates it, and
  /// stores it in secure storage.
  Future<String> importSecretJwkJson(String e2eeValueJson) async {
    _logger.info('<importSecretJwkJson>:');
    // check if json is empty
    if (e2eeValueJson.isEmpty) {
      _logger.severe('(importSecretJwkJson): e2eeValueJson is empty');
      throw MissingEncryptionSecretKeyException();
    }
    // deserialize E2EEValue from json
    final e2eeValue = E2EEValue.fromJson(
      jsonDecode(e2eeValueJson) as Map<String, dynamic>,
    );
    // decrypt E2EEValue using Master Secret Key (and passphrase)
    final secretJwkJson = await decrypt(
      e2eeValue,
      secretKey: await _readMasterSecretKey(),
    );
    // try to read secret key
    await _readSecretKeyFromJwkJson(secretJwkJson);
    _logger.info('(importSecretJwkJson): secret key is valid');
    // write the jwk json into storage
    await (await _secureStorage).write(key: secretKeyKey, value: secretJwkJson);
    _logger.info('(importSecretJwkJson): secret key imported');
    return secretJwkJson;
  }

  String _generateAADValue() {
    _logger.info('<_generateAADValue>:');
    final r = Random();
    const chars =
        'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    _logger.info('(_generateAADValue): AAD generated');
    return List.generate(5, (index) => chars[r.nextInt(chars.length)]).join();
  }

  /// Generates a new AES-GCM secret key (256-bit), stores it securely in
  /// JWK format, and returns the [AesGcmSecretKey].
  ///
  /// Requires the user to be authenticated.
  @visibleForTesting
  Future<AesGcmSecretKey> generateSecretKey() async {
    _logger.info('<generateSecretKey>:');
    // cannot encrypt if not auth
    if (_uid?.isEmpty ?? false) {
      _logger.severe('(generateSecretKey): user not authenticated');
      throw UserNotAuthenticatedException();
    }
    final secureStorage = await _secureStorage;
    // Generate a new random AES-GCM secret key for AES-256.
    final secretKey = await AesGcmSecretKey.generateKey(256);
    // save into storage
    final secretJwk = await secretKey.exportJsonWebKey();
    // encode json the jwk
    final secretJwkJson = jsonEncode(secretJwk);
    // write the jwk json into storage
    await secureStorage.write(key: secretKeyKey, value: secretJwkJson);
    _logger.info(
      '(generateSecretKey): new key generated stored in secureStorage',
    );
    // if (kDebugMode) {
    //   final e2eeValue = await encrypt(
    //     secretJwkJson,
    //     esternalSecretKey: await _readMasterSecretKey(),
    //   );
    //   debugPrint(
    //     '(generateSecretKey):  secretJwkJson '
    //     '${jsonEncode(e2eeValue)}',
    //   );
    // }
    // secret key in secure storage, load it
    return secretKey;
  }

  /// Reads the user's secret key from secure storage and returns it as an
  ///  [AesGcmSecretKey].
  ///
  /// The key is expected to be stored in JWK JSON format.
  /// Requires the user to be authenticated.
  Future<AesGcmSecretKey> _readSecretKey() async {
    _logger.finest('<_readSecretKey>:');
    // cannot encrypt if not auth
    if (_uid?.isEmpty ?? false) {
      _logger.severe('(_readSecretKey): user not authenticated');
      throw UserNotAuthenticatedException();
    }
    final secureStorage = await _secureStorage;
    if (await secretKeyStored) {
      // try to read secret key from secure storage
      var secretJwkJson = await secureStorage.read(key: secretKeyKey);
      // if not found, try to read from remote config `e2eeWebDebugSecretKey`
      if (secretJwkJson == null && _useE2EEWebDebugSecretKey) {
        _logger.info(
          '(_readSecretKey): secretJwkJson null and '
          '_useE2EEWebDebugSecretKey true, read secret key from remote config',
        );
        secretJwkJson = await importSecretJwkJson(
          RemoteConfigViewModel.instance.getString(
            FHURemoteConfigKeys.webDemoE2EESecretKey.name,
          ),
        );
      }
      if (secretJwkJson != null) {
        // found, decode the json jwk
        return _readSecretKeyFromJwkJson(secretJwkJson);
      }
    }
    // not found, throw exception
    throw MissingEncryptionSecretKeyException();
  }

  /// Reads the master secret key from Firebase Remote Config and returns it as
  ///  an [AesGcmSecretKey].
  ///
  /// The key is expected to be stored in Remote Config as a JWK JSON string
  /// under the key "masterSecretKeyJwk".
  /// Requires the user to be authenticated.
  Future<AesGcmSecretKey> _readMasterSecretKey() async {
    _logger.finer('<_readMasterSecretKey>:');
    // cannot encrypt if not auth
    if (_uid?.isEmpty ?? false) {
      _logger.severe('(_readMasterSecretKey): user not authenticated');
      throw UserNotAuthenticatedException();
    }
    // decode the json jwk
    return _readSecretKeyFromJwkJson(
      FirebaseRemoteConfig.instance.getString('masterSecretKeyJwk'),
    );
  }

  /// Imports an [AesGcmSecretKey] from its JWK (JSON Web Key) JSON
  /// representation.
  Future<AesGcmSecretKey> _readSecretKeyFromJwkJson(
    String secretJwkJson,
  ) async {
    _logger.finest('<_readSecretKeyFromJwkJson>:');
    final secretJwk = jsonDecode(secretJwkJson) as Map<String, dynamic>;
    _logger.finest(
      '(_readSecretKeyFromJwkJson): secret key alg ${secretJwk["alg"]} '
      'secretJwkJson $secretJwkJson',
    );
    // import the jwk into secret key
    return AesGcmSecretKey.importJsonWebKey(secretJwk);
  }

  /// Initializes the secret key by generating one if it's not already stored.
  /// This is typically called during application startup or after user
  /// authentication.
  Future<void> initSecretKey() async {
    _logger.finer('<initSecretKey>:');
    if (await secretKeyNotStored) {
      await generateSecretKey();
    }
  }
}

/// Exception thrown when an error occurs during the encryption process.
/// Often indicates an issue with the AAD (passphrase) or the secret key.
class ErrorOnEncryptException implements Exception {
  /// Returns a localized error message.
  @override
  String toString() {
    if (ContextHelper.context != null) {
      return FlutterHeyteacherUtilsLocalizations.of(
        ContextHelper.context!,
      )!.errorOnEncryptionCheckPassphrase;
    } else {
      return 'Error on encryption, check passphrase';
    }
  }
}

/// Exception thrown when an error occurs during the decryption process.
/// Often indicates an issue with the AAD (passphrase), the secret key, or
/// corrupted ciphertext.
class ErrorOnDecryptException implements Exception {
  /// Returns a localized error message.
  @override
  String toString() {
    if (ContextHelper.context != null) {
      return FlutterHeyteacherUtilsLocalizations.of(
        ContextHelper.context!,
      )!.errorOnDecryptionCheckPassphrase;
    } else {
      return 'Error on decryption, check passphrase';
    }
  }
}

/// Exception thrown when an attempt is made to encrypt or decrypt without a
/// valid AAD (passphrase) set.
class AADEmptyException implements Exception {
  /// Returns a localized error message prompting the user to set a passphrase.
  @override
  String toString() {
    if (ContextHelper.context != null) {
      return FlutterHeyteacherUtilsLocalizations.of(
        ContextHelper.context!,
      )!.encryptionPassphraseIsEmptySetIt;
    } else {
      return 'Encryption Passphrase is empty, set it';
    }
  }
}

/// Exception thrown when decryption is attempted but the required secret key
/// is not found in secure storage.
class MissingEncryptionSecretKeyException implements Exception {
  /// Returns a localized error message prompting the user to import their
  /// secret key.
  @override
  String toString() {
    if (ContextHelper.context != null) {
      return FlutterHeyteacherUtilsLocalizations.of(
        ContextHelper.context!,
      )!.missingEncryptionSecretKeyImportIt;
    } else {
      return 'Missing Encryption Secret Key, import it';
    }
  }
}
