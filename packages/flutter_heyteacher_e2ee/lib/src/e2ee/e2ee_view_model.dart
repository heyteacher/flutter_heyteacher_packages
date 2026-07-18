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
/// - Export/import of the secret key, itself encrypted with a master key.
/// - Custom exceptions for specific E2EE-related errors.
library;

import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_heyteacher_auth/flutter_heyteacher_auth.dart';
import 'package:flutter_heyteacher_e2ee/src/e2ee/e2ee_data.dart';
import 'package:flutter_heyteacher_e2ee/src/l10n/flutter_heyteacher_e2ee.dart';
import 'package:flutter_heyteacher_platform/flutter_heyteacher_platform.dart';
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

  /// the uid of the current user
  final String? _uid;

  /// secret key changed notifier
  final StreamController<String?> _secretKeyChangedStreamController =
      StreamController<String?>.broadcast();

  /// the secure storage instance
  @visibleForTesting
  FlutterSecureStorage? flutterSecureStorage;

  // Singleton instance
  static final Map<String?, E2EEViewModel?> _instances = {};

  /// Provides the singleton instance of the [E2EEViewModel] manager.
  // ignore: prefer_constructors_over_static_methods
  static E2EEViewModel instance(String? uid) =>
      _instances[uid] ??= E2EEViewModel._(uid);

  /// master Secret Key JWK
  static String? _masterSecretKeyJwk;

  /// Set master secret key JWK
  static void setMasterSecretKeyJwk(String masterSecretKeyJwk) {
    if (debugMode) {
      instance(
        AuthViewModel.instance.uid,
      )._logger.severe(
        '(masterSecretKeyJwk): cannot set master secret key in debug mode',
      );
      throw DebugModeException();
    }
    _masterSecretKeyJwk = masterSecretKeyJwk;
  }

  /// The debug AAD
  static const String _debugAAD = '/&/8678bhnogvd6&/=gB097';

  /// The debug Secret Key JWK
  static const String _debugSecretKeyJWK =
      '{'
      '  "kty": "oct", '
      '  "use": "enc", '
      '  "alg": "A256GCM", '
      '  "k": "PchiB6gMbbKd6PZLyQDGyY_T6E5OS9GjjoQiEy9jfuE" '
      '}';

  /// The debug Master Secret Key JWK
  static const String _debugMasterSecretKeyJWK =
      '{'
      '  "kty": "oct", '
      '  "use": "enc", '
      '  "alg": "A256GCM", '
      '  "k": "GzZgFMxgx1sTCGd5cXMt9YAv7dfrSyC-6R7AYtKlYbU" '
      '}';

  static bool _debugMode = false;

  /// Get debug mode
  static bool get debugMode => _debugMode;

  /// Set debug mode
  static set debugMode(bool debugMode) {
    _debugMode = debugMode;
    instance(
      AuthViewModel.instance.uid,
    )._logger.info('(debugMode): changed to $debugMode');
  }

  /// Generate a Secret Key anr returns the JWK in JSON format.
  static Future<String> generateSecretKeyJwk() async {
    if (debugMode) {
      instance(
        AuthViewModel.instance.uid,
      )._logger.severe(
        '(generateSecretKeyJwk): cannot generate secret key in debug mode',
      );
      throw DebugModeException();
    }
    return jsonEncode(
      await (await AesGcmSecretKey.generateKey(256)).exportJsonWebKey(),
    );
  }

  /// the secret key changed stream
  Stream<String?> get secretKeyChangedStream =>
      _secretKeyChangedStreamController.stream;

  /// Asynchronously checks if the user's secret key is currently stored.
  Future<bool> get secretKeyStored async =>
      _debugMode || await (await _secureStorage).containsKey(key: secretKeyKey);

  /// Asynchronously checks if the user's secret key is not currently stored.
  Future<bool> get secretKeyNotStored async => !await secretKeyStored;

  /// Initializes the secret key by generating one if it's not already stored.
  /// This is typically called during application startup or after user
  /// authentication.
  Future<void> initSecretKey() async {
    _logger.finer('<initSecretKey>:');
    if (await secretKeyNotStored) {
      await generateSecretKey();
    }
  }

  /// Encrypts the given [value] string using AES-GCM.
  ///
  /// Requires the user to be authenticated and an AAD (passphrase) to be set.
  /// Generates or retrieves the user's secret key from secure storage and use
  /// the AAD supplied by [getAAD].
  ///
  /// If [esternalSecretKey] is provided, use it for encryption insteaf of
  /// the user's secret key.
  ///
  /// if [externalAAD] is provided, use it for encryption insteaf of
  /// the AAD supplied by [getAAD].
  ///
  /// Returns an [E2EEValue] containing the encrypted data and the
  /// Initialization Vector (IV).
  ///
  /// Throws [UserNotAuthenticatedException], [AADEmptyException],
  /// or [ErrorOnEncryptException] on failure.
  Future<E2EEValue> encrypt(
    String value, {
    AesGcmSecretKey? esternalSecretKey,
    String? externalAAD,
  }) async {
    _logger.finest('<encrypt>:');
    // cannot encrypt if not auth
    if (_uid?.isEmpty ?? false) {
      _logger.severe('(encrypt): user not authenticated');
      throw UserNotAuthenticatedException();
    }
    final aad = externalAAD ?? await getAAD();
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
  ///
  /// If [esternalSecretKey] is provided, use it for encryption insteaf of
  /// the user's secret key.
  ///
  /// if [externalAAD] is provided, use it for encryption insteaf of
  /// the AAD supplied by [getAAD].
  ///
  /// Returns the decrypted string.
  ///
  /// Throws [UserNotAuthenticatedException], [AADEmptyException],
  /// [MissingEncryptionSecretKeyException], or [ErrorOnDecryptException]
  /// on failure.
  Future<String> decrypt(
    E2EEValue encrypted, {
    AesGcmSecretKey? esternalSecretKey,
    String? externalAAD,
  }) async {
    _logger.finest('<decrypt>:');
    // cannot encrypt if not auth
    if (_uid?.isEmpty ?? false) {
      _logger.severe('(decrypt): user not authenticated');
      throw UserNotAuthenticatedException();
    }
    // check and read AAD
    final aad = externalAAD ?? await getAAD();
    if (aad == null || aad.isEmpty) {
      _logger.severe('(decrypt): aad is empty');
      throw AADEmptyException();
    }
    var secretKeyToUse = esternalSecretKey;
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
  /// If [aadValue] is null, generate a ramdom string and set it
  /// the provided [aadValue].
  Future<void> setAAD([String? aadValue]) async {
    _logger.finer('<setAAD>:');
    // skip in debug mode
    if (_debugMode) {
      _logger.warning('(setAAD): debug mode enabled, skip setting AAD');
      return;
    }
    // cannot encrypt if not auth
    if (_uid?.isEmpty ?? false) {
      _logger.severe('(setAAD): user not authenticated');
      throw UserNotAuthenticatedException();
    }
    final secureStorage = await _secureStorage;
    await secureStorage.write(
      key: aadKey,
      value: aadValue ?? _generateAADValue(),
    );
  }

  /// Retrieves the Additional Authenticated Data (AAD) for the current user.
  ///
  /// Returns `null` if the user is not authenticated or if no AAD is set.
  Future<String?> getAAD() async {
    _logger.finest('<getAAD>:');
    if (_debugMode) {
      // if debug returns debugAAD
      return _debugAAD;
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
  /// key before being returned as a
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
      esternalSecretKey: await _readMasterSecretKey(),
    );
    // try to read secret key
    await _readSecretKeyFromJwkJson(secretJwkJson);
    _logger.info('(importSecretJwkJson): secret key is valid');
    // write the jwk json into storage
    await (await _secureStorage).write(key: secretKeyKey, value: secretJwkJson);
    _logger.info(
      '(importSecretJwkJson): secret key imported, notify secret key changed',
    );
    _secretKeyChangedStreamController.add(_uid);
    return secretJwkJson;
  }

  /// Key used in secure storage for the Additional Authenticated Data (AAD).
  /// Uniquely identifies the AAD for the current authenticated user.
  @visibleForTesting
  String get aadKey => '${_uid}_aad';

  /// Key used in secure storage for the user's secret encryption key
  /// (in JWK format).
  /// Uniquely identifies the secret key for the current authenticated user.
  @visibleForTesting
  String get secretKeyKey => '${_uid}_secretKey';

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
    storageNamespace: appName,
    preferencesKeyPrefix: appName,
  );

  String _generateAADValue() {
    _logger.info('<_generateAADValue>:');
    final r = Random();
    const chars = 'AaBbCcDdEeFfGgHhiJjKkLMmNnoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    _logger.info('(_generateAADValue): AAD generated');
    return List.generate(5, (index) => chars[r.nextInt(chars.length)]).join();
  }

  /// Generates a new AES-GCM secret key (256-bit), stores it securely in
  /// JWK format, and returns the [AesGcmSecretKey].
  ///
  /// Stores into user's secure storage if [isToStore] is true (the default).
  ///
  /// Requires the user to be authenticated.
  @visibleForTesting
  Future<AesGcmSecretKey> generateSecretKey({bool isToStore = true}) async {
    _logger.info('<generateSecretKey>:');
    if (debugMode) {
      _logger.severe(
        '(generateSecretKey): cannot generate secret key in debug mode',
      );
      throw DebugModeException();
    }
    // cannot encrypt if not auth
    if (_uid?.isEmpty ?? false) {
      _logger.severe('(generateSecretKey): user not authenticated');
      throw UserNotAuthenticatedException();
    }
    // Generate a new random AES-GCM secret key for AES-256.
    final secretKey = await AesGcmSecretKey.generateKey(256);
    // encode json the jwk
    final secretJwkJson = jsonEncode(await secretKey.exportJsonWebKey());
    if (isToStore) {
      final secureStorage = await _secureStorage;
      // write the jwk json into storage
      await secureStorage.write(key: secretKeyKey, value: secretJwkJson);
      _logger.info(
        '(generateSecretKey): new key generated stored in secureStorage '
        'and notify secret key changed',
      );
      _secretKeyChangedStreamController.add(_uid);
    }
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
    if (await secretKeyStored) {
      // try to read secret key from secure storage
      String? secretJwkJson;
      // if not found, try to read from remote config `e2eeWebDebugSecretKey`
      if (_debugMode) {
        _logger.info('(_readSecretKey): debug mode, using debug secret key');
        secretJwkJson = _debugSecretKeyJWK;
      } else {
        final secureStorage = await _secureStorage;
        secretJwkJson = await secureStorage.read(key: secretKeyKey);
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
    if (debugMode) {
      _logger.info('(_readMasterSecretKey): debug mode');
      return _readSecretKeyFromJwkJson(_debugMasterSecretKeyJWK);
    }
    if (_masterSecretKeyJwk == null || _masterSecretKeyJwk!.isEmpty) {
      _logger.severe(
        '(_readMasterSecretKey): E2EE not initialized, '
        'master secret key jw not found',
      );
      throw MissingMasterSecretKeyJwkException();
    }
    // decode the json jwk
    return _readSecretKeyFromJwkJson(_masterSecretKeyJwk!);
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
}

/// Exception thrown when an error occurs during the encryption process.
/// Often indicates an issue with the AAD (passphrase) or the secret key.
class ErrorOnEncryptException implements Exception {
  /// Returns a localized error message.
  @override
  String toString() {
    if (ContextHelper.context != null) {
      return FlutterHeyteacherE2EELocalizations.of(
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
      return FlutterHeyteacherE2EELocalizations.of(
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
      return FlutterHeyteacherE2EELocalizations.of(
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
      return FlutterHeyteacherE2EELocalizations.of(
        ContextHelper.context!,
      )!.missingEncryptionSecretKeyImportIt;
    } else {
      return 'Missing Encryption Secret Key, import it';
    }
  }
}

/// Exception thrown when decryption is attempted but the required secret key
/// is not found in secure storage.
class MissingMasterSecretKeyJwkException implements Exception {
  /// Returns a localized error message prompting the user to import their
  /// secret key.
  @override
  String toString() {
    if (ContextHelper.context != null) {
      return FlutterHeyteacherE2EELocalizations.of(
        ContextHelper.context!,
      )!.missingMasterSecretKeyJwk;
    } else {
      return 'Missing Master Secret Key JWK';
    }
  }
}

/// Exception thrown when action not permitter in debug mode.
class DebugModeException implements Exception {
  @override
  String toString() {
    // if (ContextHelper.context != null) {
    //   return FlutterHeyteacherE2EELocalizations.of(
    //     ContextHelper.context!,
    //   )!.actionNotPermittedInDebugMode;
    // } else {
    return 'Action not permitter in debug mode';
    //}
  }
}
