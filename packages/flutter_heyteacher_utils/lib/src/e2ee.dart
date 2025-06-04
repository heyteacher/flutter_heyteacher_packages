/// Provides End-to-End Encryption (E2EE) capabilities using AES-GCM.
///
/// This library manages the generation, secure storage, import, and export
/// of cryptographic keys. It leverages `flutter_secure_storage` for key persistence
/// and `webcrypto` for cryptographic operations.
///
/// Key features:
/// - AES-GCM for authenticated encryption.
/// - Secure storage of the user's secret key.
/// - Use of Additional Authenticated Data (AAD), often a user-provided passphrase.
/// - Export/import of the secret key, itself encrypted with a master key (e.g., from Remote Config).
/// - Custom exceptions for specific E2EE-related errors.
library;

import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_heyteacher_utils/context_helper.dart';
import 'package:flutter_heyteacher_utils/firebase.dart';
import 'package:flutter_heyteacher_utils/locale.dart';
import 'package:flutter_heyteacher_utils/platform_helper.dart';
import 'package:flutter_heyteacher_utils/theme.dart';
import 'package:flutter_heyteacher_utils/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logging/logging.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:webcrypto/webcrypto.dart';

class E2EEPassphraseCard extends StatefulWidget {
  final FocusNode encryptionPassphraseFocusNode;
  const E2EEPassphraseCard(this.encryptionPassphraseFocusNode, {super.key});

  @override
  State<E2EEPassphraseCard> createState() => _E2EEPassphraseCard();
}

class _E2EEPassphraseCard extends State<E2EEPassphraseCard> {
  bool _passphraseVisibility = false;
  bool _warningAlreadyShowed = false;
  @override
  Widget build(BuildContext context) => FutureBuilder(
      future: E2EE.instance.getAAD(),
      builder: (_, aadSnapshot) => Card(
            child: ListTile(
              focusNode: widget.encryptionPassphraseFocusNode,
              leading: const Icon(Icons.password),
              title: StreamBuilder<User?>(
                  stream: AuthModel.instance().stateChangesStream,
                  builder: (_, userSnapshot) => TextField(
                      enabled: userSnapshot.hasData,
                      onChanged: (value) async => await _setPassphrase(value,
                          oldValue: aadSnapshot.data),
                      obscureText: !_passphraseVisibility &&
                          (aadSnapshot.data?.isNotEmpty ?? false),
                      decoration: InputDecoration(
                          isDense: true,
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.onSurface),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(_passphraseVisibility
                                ? Icons.visibility_off
                                : Icons.visibility),
                            onPressed: () => setState(() =>
                                _passphraseVisibility = !_passphraseVisibility),
                          ),
                          labelText:
                              FlutterHeyteacherUtilsLocalizations.of(context)!
                                  .encryptionPassphrase),
                      controller:
                          TextEditingController(text: aadSnapshot.data ?? ''))),
            ),
          ));

  Future<void> _setPassphrase(String value, {String? oldValue}) async {
    // first time, show a warning on change encryption password and
    // lost ability to decrypt data
    if (!_warningAlreadyShowed && (oldValue?.isNotEmpty ?? false)) {
      showConfirmCancelDialog(
          context: context,
          confirmCallback: (_) async {
            await E2EE.instance.setAAD(aadValue: value);
            _warningAlreadyShowed = true;
            return null;
          },
          cancelCallback: (_) async {
            setState(() {});
            return null;
          },
          content: FlutterHeyteacherUtilsLocalizations.of(context)!
              .areYouSureToChangeEncryptionPassphrase);
    } else {
      await E2EE.instance.setAAD(aadValue: value);
    }
  }
}

class E2EESecretKeyCard extends StatefulWidget {
  final FocusNode encryptionPassphraseFocusNode;
  const E2EESecretKeyCard(this.encryptionPassphraseFocusNode, {super.key});

  @override
  State<E2EESecretKeyCard> createState() => _E2EESecretKeyCardState();
}

class _E2EESecretKeyCardState extends State<E2EESecretKeyCard> {
  @override
  Widget build(BuildContext context) => FutureBuilder<bool>(
        future: E2EE.instance.secretKeyStored,
        builder: (_, secretKeySnapshot) => Card(
          child: ListTile(
            leading: Icon(
              secretKeySnapshot.data ?? false ? Icons.key : Icons.key_off,
              color: secretKeySnapshot.data ?? false
                  ? ThemeModel.instance().greenColor
                  : Theme.of(context).colorScheme.onError,
            ),
            title: Padding(
              padding: const EdgeInsets.only(bottom: 15.0),
              child: Text(FlutterHeyteacherUtilsLocalizations.of(context)!
                  .encryptionSecretKey),
            ),
            trailing: Wrap(children: [
              IconButton(
                  onPressed: () => AuthModel.instance().autenticated
                      ? _showQrCode()
                      : showConfirmCancelDialog(
                          context: context,
                          content:
                              FlutterHeyteacherUtilsLocalizations.of(context)!
                                  .userNotAutenticated),
                  icon: const Icon(Icons.qr_code)),
              IconButton(
                  onPressed: () => _showQrCodeScanner(),
                  icon: const Icon(Icons.qr_code_scanner)),
            ]),
          ),
        ),
      );

  void _showQrCode() async {
    // remove focus on encryption passphrase
    widget.encryptionPassphraseFocusNode.unfocus();
    await showDialog(
        useSafeArea: true,
        context: context,
        builder: (context) {
          return FutureBuilder<String>(
            future: E2EE.instance.exportSecretJwkJson(),
            builder: (_, snapshot) => snapshot.hasData
                ? AlertDialog(
                    title: Text(FlutterHeyteacherUtilsLocalizations.of(context)!
                        .scanQRCodeWithAnotherDeviceOrStoreInASecurePlaceRememberToUseSamePassphrase),
                    content: SizedBox(
                        width: 500,
                        child: QrImageView(
                            data: snapshot.data!,
                            backgroundColor: Colors.white)))
                : snapshot.hasError
                    ? AlertDialog(
                        content: Text(
                          snapshot.error.toString(),
                        ),
                        actions: <Widget>[
                          IconButton(
                            key: const ValueKey('ib_dialog_no'),
                            icon: Icon(Icons.close,
                                color: Theme.of(context).colorScheme.onError),
                            onPressed: () {
                              Navigator.of(context).pop(false);
                            },
                          )
                        ],
                      )
                    : const ProgressIndicatorView(),
          );
        });
    setState(() {});
  }

  void _showQrCodeScanner() async {
    // get localized confirm question message before async invocation
    final confirmQuestionMessage =
        FlutterHeyteacherUtilsLocalizations.of(context)!
            .areYouSureToImportEncryptionSecretKey;
    widget.encryptionPassphraseFocusNode.unfocus();
    if (AuthModel.instance().notAutenticated) {
      showConfirmCancelDialog(
          context: context,
          content: FlutterHeyteacherUtilsLocalizations.of(context)!
              .userNotAutenticated);
      return;
    }
    String? secretJwkJson;
    await showDialog<bool>(
        useSafeArea: true,
        context: context,
        builder: (context) => MobileScanner(onDetect: (barcodeCapture) {
              if (barcodeCapture
                      .barcodes.firstOrNull?.displayValue?.isNotEmpty ??
                  false) {
                secretJwkJson = barcodeCapture.barcodes.first.displayValue!;
                Navigator.of(context).pop(true);
              }
            }));
    if (secretJwkJson != null) {
      showConfirmCancelDialog(
        context: context.mounted ? context : context,
        content: confirmQuestionMessage,
        confirmCallback: (_) async {
          // get localized success message before async invocation
          final successMessage =
              FlutterHeyteacherUtilsLocalizations.of(context)!
                  .encryptionSecretKeyImported;
          await E2EE.instance.importSecretJwkJson(secretJwkJson!);
          setState(() {});
          return successMessage;
        },
      );
    }
  }
}

/// Manages End-to-End Encryption (E2EE) operations for the application.
///
/// This class is a singleton, accessible via `E2EE.instance`.
/// It handles AES-GCM encryption/decryption, secret key management (generation,
/// storage in `FlutterSecureStorage`, import/export), and the use of
/// Additional Authenticated Data (AAD).
class E2EE {
  final _log = Logger('E2EE');

  /// Key used in secure storage for the Additional Authenticated Data (AAD).
  /// Uniquely identifies the AAD for the current authenticated user.
  String get _aadKey => '${AuthModel.instance().uid!}_aad';

  /// Key used in secure storage for the user's secret encryption key (in JWK format).
  /// Uniquely identifies the secret key for the current authenticated user.
  String get _secretKeyKey => '${AuthModel.instance().uid!}_secretKey';

  /// Asynchronously checks if the user's secret key is currently stored.
  Future<bool> get secretKeyStored async =>
      (await _secureStorage).containsKey(key: _secretKeyKey);

  // Singleton instance
  static E2EE? _instance;

  /// Provides the singleton instance of the [E2EE] manager.
  static E2EE get instance => _instance ??= E2EE._();

  /// Private constructor for the singleton.
  E2EE._();

  FlutterSecureStorage? _secureStorageInstance;

  /// Lazily initializes and returns the [FlutterSecureStorage] instance.
  /// Configures Android-specific options for encrypted shared preferences.
  Future<FlutterSecureStorage> get _secureStorage async {
    if (_secureStorageInstance != null) return _secureStorageInstance!;
    String appName = 'appName';
    if (PlatformHelper.isMobile) {
      appName = (await PackageInfo.fromPlatform()).appName;
    }
    _secureStorageInstance =
        FlutterSecureStorage(aOptions: _getAndroidOptions(appName));
    return _secureStorageInstance!;
  }

  /// Returns Android-specific options for `FlutterSecureStorage`.
  ///
  /// Enables encrypted shared preferences, using the [appName] for naming.
  AndroidOptions _getAndroidOptions(String appName) => AndroidOptions(
      encryptedSharedPreferences: true,
      sharedPreferencesName: appName,
      preferencesKeyPrefix: appName);

  /// Encrypts the given [value] string using AES-GCM.
  ///
  /// Requires the user to be authenticated and an AAD (passphrase) to be set.
  /// If [secretKey] is not provided, it generates or retrieves the user's secret key from secure storage.
  /// Returns an [E2EEValue] containing the encrypted data and the Initialization Vector (IV).
  /// Throws [UserNotAuthenticatedException], [AADEmptyException], or [ErrorOnEncryptException] on failure.
  Future<E2EEValue> encrypt(String value, {AesGcmSecretKey? secretKey}) async {
    // cannot encrypt if not auth
    if (AuthModel.instance().notAutenticated) {
      _log.severe('encrypt: user not authenticated');
      throw UserNotAuthenticatedException();
    }
    String aad = await getAAD() ?? '';
    if (aad.isEmpty) {
      _log.severe('encrypt: aad is empty');
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
      _log.severe('encrypt: error', e, s);
      throw ErrorOnEncryptException();
    }
  }

  /// Decrypts the given [encrypted] [E2EEValue] using AES-GCM.
  ///
  /// Requires the user to be authenticated and an AAD (passphrase) to be set.
  /// If [secretKey] is not provided, it retrieves the user's secret key from secure storage.
  /// Returns the decrypted string.
  /// Throws [UserNotAuthenticatedException], [AADEmptyException], [MissingEncryptionSecretKeyException], or [ErrorOnDecryptException] on failure.
  Future<String> decrypt(E2EEValue encrypted,
      {AesGcmSecretKey? secretKey}) async {
    // cannot encrypt if not auth
    if (AuthModel.instance().notAutenticated) {
      _log.severe('decrypt: user not authenticated');
      throw UserNotAuthenticatedException();
    }
    String aad = await getAAD() ?? '';
    if (aad.isEmpty) {
      _log.severe('decrypt: aad is empty');
      throw AADEmptyException();
    }
    FlutterSecureStorage secureStorage = await _secureStorage;

    // raise exception if key not found in secure storage
    if (secretKey == null &&
        !await secureStorage.containsKey(key: _secretKeyKey)) {
      _log.severe('decrypt: missing secret key');
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
      _log.severe('decrypt: error', e, s);
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
    // cannot encrypt if not auth
    if (AuthModel.instance().notAutenticated) {
      _log.severe('setAAD: user not authenticated');
      throw UserNotAuthenticatedException();
    }
    FlutterSecureStorage secureStorage = await _secureStorage;
    secureStorage.write(
        key: _aadKey, value: generate ? _generateAADValue() : aadValue);
  }

  /// Retrieves the Additional Authenticated Data (AAD) for the current user.
  ///
  /// Returns `null` if the user is not authenticated or if no AAD is set.
  Future<String?> getAAD() async {
    // cannot encrypt if not auth
    if (AuthModel.instance().notAutenticated) {
      return null;
    }
    FlutterSecureStorage secureStorage = await _secureStorage;
    return secureStorage.read(key: _aadKey);
  }

  /// Exports the user's secret key as a JSON string.
  ///
  /// The secret key (in JWK format) is first encrypted using a master secret key
  /// (retrieved from Firebase Remote Config) before being returned as a JSON representation
  /// of an [E2EEValue]. This allows for secure backup or transfer of the key.
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

  /// Imports a user's secret key from an [e2eeValueJson] string.
  ///
  /// The [e2eeValueJson] is expected to be a JSON representation of an [E2EEValue]
  /// containing the user's secret key (in JWK format) encrypted with the master secret key.
  /// This method decrypts it, validates it, and stores it in secure storage.
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

  String _generateAADValue() {
    var r = Random();
    const chars =
        'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    return List.generate(5, (index) => chars[r.nextInt(chars.length)]).join();
  }

  /// Generates a new AES-GCM secret key (256-bit), stores it securely in JWK format,
  /// and returns the [AesGcmSecretKey].
  ///
  /// Requires the user to be authenticated.
  Future<AesGcmSecretKey> _generateSecretKey() async {
    // cannot encrypt if not auth
    if (AuthModel.instance().notAutenticated) {
      _log.severe('_generateSecretKey: user not authenticated');
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
    _log.fine('_generateSecretKey: new key generated stored in secureStorage');
    // secret key in secure storage, load it
    return secretKey;
  }

  /// Reads the user's secret key from secure storage and returns it as an [AesGcmSecretKey].
  ///
  /// The key is expected to be stored in JWK JSON format.
  /// Requires the user to be authenticated.
  Future<AesGcmSecretKey> _readSecretKey() async {
    // cannot encrypt if not auth
    if (AuthModel.instance().notAutenticated) {
      _log.severe('_readSecretKey: user not authenticated');
      throw UserNotAuthenticatedException();
    }
    FlutterSecureStorage secureStorage = await _secureStorage;
    // read the json jwk secret key from secure storage
    final String secretJwkJson =
        (await secureStorage.read(key: _secretKeyKey))!;
    // decode the json jwk
    return await _readSecretKeyFromJwkJson(secretJwkJson);
  }

  /// Reads the master secret key from Firebase Remote Config and returns it as an [AesGcmSecretKey].
  ///
  /// The key is expected to be stored in Remote Config as a JWK JSON string
  /// under the key "masterSecretKeyJwk".
  /// Requires the user to be authenticated.
  Future<AesGcmSecretKey> _readMasterSecretKey() async {
    // cannot encrypt if not auth
    if (AuthModel.instance().notAutenticated) {
      _log.severe('_readMasterSecretKey: user not authenticated');
      throw UserNotAuthenticatedException();
    }
    // decode the json jwk
    return await _readSecretKeyFromJwkJson(
        FirebaseRemoteConfig.instance.getString('masterSecretKeyJwk'));
  }

  /// Imports an [AesGcmSecretKey] from its JWK (JSON Web Key) JSON representation.
  Future<AesGcmSecretKey> _readSecretKeyFromJwkJson(
      String secretJwkJson) async {
    final secretJwk = jsonDecode(secretJwkJson);
    _log.fine("_readSecretKeyFromJwkJson: secret key alg ${secretJwk["alg"]}");
    // import the jwk into secret key
    return await AesGcmSecretKey.importJsonWebKey(secretJwk);
  }

  /// Initializes the secret key by generating one if it's not already stored.
  /// This is typically called during application startup or after user authentication.
  void initSecretKey() async {
    if (!await secretKeyStored) {
      _generateSecretKey();
    }
  }
}

/// Represents an encrypted value along with its Initialization Vector (IV).
///
/// Used to package the ciphertext and IV together, as both are needed for decryption.
/// Provides methods for JSON serialization/deserialization, including GZip compression
/// and Base64 encoding for efficient storage or transmission.
class E2EEValue {
  /// The encrypted data (ciphertext).
  Uint8List value;

  /// The Initialization Vector used during encryption.
  Uint8List iv;

  /// Creates an [E2EEValue].
  E2EEValue({required this.value, required this.iv});

  /// Creates an [E2EEValue] from a map (typically from JSON deserialization).
  ///
  /// Assumes the 'value' and 'iv' fields in the map are Base64 encoded and GZipped.
  E2EEValue.fromMap(Map<String, dynamic> map)
      : value = Uint8List.fromList(_unzip(map['value'])?.cast<int>() ?? []),
        iv = Uint8List.fromList(_unzip(map['iv'])?.cast<int>() ?? []);

  /// Converts the [E2EEValue] to a JSON-compatible map.
  ///
  /// The 'value' and 'iv' are GZipped and Base64 encoded.
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

/// Exception thrown when an error occurs during the encryption process.
/// Often indicates an issue with the AAD (passphrase) or the secret key.
class ErrorOnEncryptException implements Exception {
  /// Returns a localized error message.
  @override
  String toString() {
    if (ContextHelper.context != null) {
      return FlutterHeyteacherUtilsLocalizations.of(ContextHelper.context!)!
          .errorOnEncryptionCheckPassphrase;
    } else {
      return 'Error on encryption, check passphrase';
    }
  }
}

/// Exception thrown when an error occurs during the decryption process.
/// Often indicates an issue with the AAD (passphrase), the secret key, or corrupted ciphertext.
class ErrorOnDecryptException implements Exception {
  /// Returns a localized error message.
  @override
  String toString() {
    if (ContextHelper.context != null) {
      return FlutterHeyteacherUtilsLocalizations.of(ContextHelper.context!)!
          .errorOnDecryptionCheckPassphrase;
    } else {
      return 'Error on decryption, check passphrase';
    }
  }
}

/// Exception thrown when an attempt is made to encrypt or decrypt without a valid AAD (passphrase) set.
class AADEmptyException implements Exception {
  /// Returns a localized error message prompting the user to set a passphrase.
  @override
  String toString() {
    if (ContextHelper.context != null) {
      return FlutterHeyteacherUtilsLocalizations.of(ContextHelper.context!)!
          .encryptionPassphraseIsEmptySetIt;
    } else {
      return 'Encryption Passphrase is empty, set it';
    }
  }
}

/// Exception thrown when decryption is attempted but the required secret key is not found in secure storage.
class MissingEncryptionSecretKeyException implements Exception {
  /// Returns a localized error message prompting the user to import their secret key.
  @override
  String toString() {
    if (ContextHelper.context != null) {
      return FlutterHeyteacherUtilsLocalizations.of(ContextHelper.context!)!
          .missingEncryptionSecretKeyImportIt;
    } else {
      return 'Missing Encryption Secret Key, import it';
    }
  }
}
