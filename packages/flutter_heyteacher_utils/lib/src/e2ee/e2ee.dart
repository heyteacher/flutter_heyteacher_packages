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
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_heyteacher_utils/context_helper.dart';
import 'package:flutter_heyteacher_utils/firebase.dart';
import 'package:flutter_heyteacher_utils/locale.dart';
import 'package:flutter_heyteacher_utils/src/e2ee/e2ee_data.dart';
import 'package:flutter_heyteacher_utils/theme.dart';
import 'package:flutter_heyteacher_utils/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logging/logging.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:webcrypto/webcrypto.dart';

class E2EEPassphraseCard extends StatefulWidget {
  final FocusNode focusNode;
  final VoidCallback setPassphraseCallback;
  const E2EEPassphraseCard({
    super.key,
    required this.focusNode,
    required this.setPassphraseCallback,
  });

  @override
  State<E2EEPassphraseCard> createState() => _E2EEPassphraseCard();
}

class _E2EEPassphraseCard extends State<E2EEPassphraseCard> {
  bool _passphraseVisibility = false;
  bool _warningAlreadyShowed = false;
  @override
  Widget build(BuildContext context) => FutureBuilder(
    future: E2EEViewModel.instance(AuthViewModel.instance().uid).getAAD(),
    builder: (_, aadSnapshot) => Card(
      child: ListTile(
        focusNode: widget.focusNode,
        leading: const Icon(Icons.password),
        title: StreamBuilder<User?>(
          stream: AuthViewModel.instance().stateChangesStream,
          builder: (_, userSnapshot) => TextField(
            enabled: userSnapshot.hasData,
            onChanged: (value) async =>
                await _setPassphrase(value, oldValue: aadSnapshot.data),
            obscureText:
                !_passphraseVisibility &&
                (aadSnapshot.data?.isNotEmpty ?? false),
            decoration: InputDecoration(
              isDense: true,
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: ThemeViewModel.instance.theme.colorScheme.onSurface,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _passphraseVisibility
                      ? Icons.visibility_off
                      : Icons.visibility,
                ),
                onPressed: () => setState(
                  () => _passphraseVisibility = !_passphraseVisibility,
                ),
              ),
              labelText: FlutterHeyteacherUtilsLocalizations.of(
                context,
              )!.encryptionPassphrase,
            ),
            controller: TextEditingController(text: aadSnapshot.data ?? ''),
          ),
        ),
      ),
    ),
  );

  Future<void> _setPassphrase(String value, {String? oldValue}) async {
    // first time, show a warning on change encryption password and
    // lost ability to decrypt data
    if (!_warningAlreadyShowed && (oldValue?.isNotEmpty ?? false)) {
      showConfirmCancelDialog(
        context: context,
        confirmCallback: (_) async {
          await E2EEViewModel.instance(
            AuthViewModel.instance().uid,
          ).setAAD(aadValue: value);
          _warningAlreadyShowed = true;
          widget.setPassphraseCallback();
          return null;
        },
        cancelCallback: (_) async {
          setState(() {});
          return null;
        },
        content: Text(
          FlutterHeyteacherUtilsLocalizations.of(
            context,
          )!.areYouSureToChangeEncryptionPassphrase,
        ),
      );
    } else {
      await E2EEViewModel.instance(
        AuthViewModel.instance().uid,
      ).setAAD(aadValue: value);
      widget.setPassphraseCallback();
    }
  }
}

class E2EESecretKeyCard extends StatefulWidget {
  final FocusNode _encryptionPassphraseFocusNode;
  final VoidCallback _secretKeyImportedCallback;
  const E2EESecretKeyCard({
    required FocusNode encryptionPassphraseFocusNode,
    required void Function() secretKeyImportedCallback,
    super.key,
  }) : _secretKeyImportedCallback = secretKeyImportedCallback,
       _encryptionPassphraseFocusNode = encryptionPassphraseFocusNode;

  @override
  State<E2EESecretKeyCard> createState() => _E2EESecretKeyCardState();
}

class _E2EESecretKeyCardState extends State<E2EESecretKeyCard> {
  @override
  Widget build(BuildContext context) => FutureBuilder<bool>(
    future: E2EEViewModel.instance(
      AuthViewModel.instance().uid,
    ).secretKeyStored,
    builder: (_, secretKeySnapshot) => Card(
      child: ListTile(
        leading: Icon(
          secretKeySnapshot.data ?? false ? Icons.key : Icons.key_off,
          color: secretKeySnapshot.data ?? false
              ? ThemeViewModel.instance.greenColor
              : ThemeViewModel.instance.redColor,
        ),
        title: Padding(
          padding: const EdgeInsets.only(bottom: 15.0),
          child: Text(
            FlutterHeyteacherUtilsLocalizations.of(
              context,
            )!.encryptionSecretKey,
          ),
        ),
        trailing: Wrap(
          children: [
            IconButton(
              onPressed: () => AuthViewModel.instance().autenticated
                  ? _showQrCode()
                  : showConfirmCancelDialog(
                      context: context,
                      content: Text(
                        FlutterHeyteacherUtilsLocalizations.of(
                          context,
                        )!.userNotAuthenticated,
                      ),
                    ),
              icon: const Icon(Icons.qr_code),
            ),
            IconButton(
              onPressed: () => _showQrCodeScanner(),
              icon: const Icon(Icons.qr_code_scanner),
            ),
          ],
        ),
      ),
    ),
  );

  void _showQrCode() async {
    // remove focus on encryption passphrase
    widget._encryptionPassphraseFocusNode.unfocus();
    await showDialog(
      useSafeArea: true,
      context: context,
      builder: (context) {
        return FutureBuilder<String>(
          future: E2EEViewModel.instance(
            AuthViewModel.instance().uid,
          ).exportSecretJwkJson(),
          builder: (_, snapshot) => snapshot.hasData
              ? AlertDialog(
                  title: Text(
                    FlutterHeyteacherUtilsLocalizations.of(
                      context,
                    )!.scanQRCodeWithAnotherDeviceOrStoreInASecurePlaceRememberToUseSamePassphrase,
                  ),
                  content: SizedBox(
                    width: 500,
                    child: QrImageView(
                      data: snapshot.data!,
                      backgroundColor: Colors.white,
                    ),
                  ),
                )
              : snapshot.hasError
              ? AlertDialog(
                  content: Text(snapshot.error.toString()),
                  actions: <Widget>[
                    IconButton(
                      key: const ValueKey('ib_dialog_no'),
                      icon: Icon(
                        Icons.close,
                        color: ThemeViewModel.instance.redColor,
                      ),
                      onPressed: () {
                        Navigator.of(context).pop(false);
                      },
                    ),
                  ],
                )
              : const ProgressIndicatorView(),
        );
      },
    );
    setState(() {});
  }

  void _showQrCodeScanner() async {
    // get localized confirm question message before async invocation
    final confirmQuestionMessage = FlutterHeyteacherUtilsLocalizations.of(
      context,
    )!.areYouSureToImportEncryptionSecretKey;
    widget._encryptionPassphraseFocusNode.unfocus();
    if (AuthViewModel.instance().notAutenticated) {
      showConfirmCancelDialog(
        context: context,
        content: Text(
          FlutterHeyteacherUtilsLocalizations.of(context)!.userNotAuthenticated,
        ),
      );
      return;
    }
    String? secretJwkJson;
    await showDialog<bool>(
      useSafeArea: true,
      context: context,
      builder: (context) => MobileScanner(
        onDetect: (barcodeCapture) {
          if (barcodeCapture.barcodes.firstOrNull?.displayValue?.isNotEmpty ??
              false) {
            secretJwkJson = barcodeCapture.barcodes.first.displayValue!;
            Navigator.of(context).pop(true);
          }
        },
      ),
    );
    if (secretJwkJson != null) {
      showConfirmCancelDialog(
        context: context.mounted ? context : context,
        content: Text(confirmQuestionMessage),
        confirmCallback: (_) async {
          // get localized success message before async invocation
          final successMessage = FlutterHeyteacherUtilsLocalizations.of(
            context,
          )!.encryptionSecretKeyImported;
          await E2EEViewModel.instance(
            AuthViewModel.instance().uid!,
          ).importSecretJwkJson(secretJwkJson!);
          setState(() {});
          widget._secretKeyImportedCallback();
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
class E2EEViewModel {
  final _logger = Logger('E2EEViewModel');

  /// Key used in secure storage for the Additional Authenticated Data (AAD).
  /// Uniquely identifies the AAD for the current authenticated user.
  @visibleForTesting
  String get aadKey => '${_uid}_aad';

  /// Key used in secure storage for the user's secret encryption key (in JWK format).
  /// Uniquely identifies the secret key for the current authenticated user.
  @visibleForTesting
  String get secretKeyKey => '${_uid}_secretKey';

  /// Asynchronously checks if the user's secret key is currently stored.
  Future<bool> get secretKeyStored async =>
      (await _secureStorage).containsKey(key: secretKeyKey);

  // Singleton instance
  static final Map<String?, E2EEViewModel?> _instances = {};

  final String? _uid;

  /// Provides the singleton instance of the [E2EEViewModel] manager.
  static E2EEViewModel instance(String? uid) =>
      _instances[uid] ??= E2EEViewModel._(uid);

  /// Private constructor for the singleton.
  E2EEViewModel._(this._uid);

  FlutterSecureStorage? _secureStorageInstance;

  @visibleForTesting
  set secureStorage(FlutterSecureStorage secureStorage) =>
      _secureStorageInstance = secureStorage;

  /// Lazily initializes and returns the [FlutterSecureStorage] instance.
  /// Configures Android-specific options for encrypted shared preferences.
  Future<FlutterSecureStorage> get _secureStorage async {
    if (_secureStorageInstance != null) return _secureStorageInstance!;
    String appName = 'appName';
    try {
      appName = (await PackageInfo.fromPlatform()).appName;
    } catch (error, stackTrace) {
      _logger.warning(
        'unable to read app name, use \'appName\'',
        error,
        stackTrace,
      );
    }
    _secureStorageInstance = FlutterSecureStorage(
      aOptions: _getAndroidOptions(appName),
    );
    return _secureStorageInstance!;
  }

  /// Returns Android-specific options for `FlutterSecureStorage`.
  ///
  /// Enables encrypted shared preferences, using the [appName] for naming.
  AndroidOptions _getAndroidOptions(String appName) => AndroidOptions(
    encryptedSharedPreferences: true,
    sharedPreferencesName: appName,
    preferencesKeyPrefix: appName,
  );

  /// Encrypts the given [value] string using AES-GCM.
  ///
  /// Requires the user to be authenticated and an AAD (passphrase) to be set.
  /// If [secretKey] is not provided, it generates or retrieves the user's secret key from secure storage.
  /// Returns an [E2EEValue] containing the encrypted data and the Initialization Vector (IV).
  /// Throws [UserNotAuthenticatedException], [AADEmptyException], or [ErrorOnEncryptException] on failure.
  Future<E2EEValue> encrypt(String value, {AesGcmSecretKey? secretKey}) async {
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
    final FlutterSecureStorage secureStorage = await _secureStorage;

    if (secretKey == null) {
      // first use, generate the key if non present in secure storage
      if (!await secureStorage.containsKey(key: secretKeyKey)) {
        secretKey = await generateSecretKey();
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
      final encryptedBytes = await secretKey.encryptBytes(
        decryptedBytes,
        iv,
        additionalData: aadBytes,
      );
      // return string encoded with the initial vector
      return E2EEValue(value: encryptedBytes, iv: iv);
    } catch (error, stackTrace) {
      _logger.severe('(encrypt): error', error, stackTrace);
      throw ErrorOnEncryptException();
    }
  }

  /// Decrypts the given [encrypted] [E2EEValue] using AES-GCM.
  ///
  /// Requires the user to be authenticated and an AAD (passphrase) to be set.
  /// If [secretKey] is not provided, it retrieves the user's secret key from secure storage.
  /// Returns the decrypted string.
  /// Throws [UserNotAuthenticatedException], [AADEmptyException], [MissingEncryptionSecretKeyException], or [ErrorOnDecryptException] on failure.
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
    String aad = await getAAD() ?? '';
    if (aad.isEmpty) {
      _logger.severe('(decrypt): aad is empty');
      throw AADEmptyException();
    }
    FlutterSecureStorage secureStorage = await _secureStorage;

    // raise exception if key not found in secure storage
    if (secretKey == null &&
        !await secureStorage.containsKey(key: secretKeyKey)) {
      _logger.severe('decrypt: missing secret key');
      throw MissingEncryptionSecretKeyException();
    }
    // aad bytes
    final aadBytes = utf8.encode(aad);
    // if param secretKey is null, read the secret key from secure storage
    secretKey ??= await _readSecretKey();
    // decrypt value
    try {
      final decryptedBytes = await secretKey.decryptBytes(
        encrypted.value,
        encrypted.iv,
        additionalData: aadBytes,
      );
      // return string decripted utf8 decoding bytes
      final decrypted = utf8.decode(decryptedBytes);
      return decrypted;
    } catch (error, stackTrace) {
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
    _logger.finest('<setAAD>:');
    // cannot encrypt if not auth
    if (_uid?.isEmpty ?? false) {
      _logger.severe('(setAAD): user not authenticated');
      throw UserNotAuthenticatedException();
    }
    FlutterSecureStorage secureStorage = await _secureStorage;
    secureStorage.write(
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
    FlutterSecureStorage secureStorage = await _secureStorage;
    return secureStorage.read(key: aadKey);
  }

  /// Exports the user's secret key as a JSON string.
  ///
  /// The secret key (in JWK format) is first encrypted using a master secret key
  /// (retrieved from Firebase Remote Config) before being returned as a JSON representation
  /// of an [E2EEValue]. This allows for secure backup or transfer of the key.
  Future<String> exportSecretJwkJson() async {
    _logger.finest('<exportSecretJwkJson>:');
    AesGcmSecretKey secretKey;
    if (!await secretKeyStored) {
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
      secretKey: await _readMasterSecretKey(),
    );
    // return json encode E2EE value
    return jsonEncode(e2eeValue);
  }

  /// Imports a user's secret key from an [e2eeValueJson] string.
  ///
  /// The [e2eeValueJson] is expected to be a JSON representation of an [E2EEValue]
  /// containing the user's secret key (in JWK format) encrypted with the master secret key.
  /// This method decrypts it, validates it, and stores it in secure storage.
  Future<void> importSecretJwkJson(String e2eeValueJson) async {
    _logger.finest('<importSecretJwkJson>:');
    // deserialize E2EEValue from json
    final e2eeValue = E2EEValue.fromJson(jsonDecode(e2eeValueJson));
    // decrypt E2EEValue using Master Secret Key (and passphrase)
    final secretJwkJson = await decrypt(
      e2eeValue,
      secretKey: await _readMasterSecretKey(),
    );
    // try to read secret key
    await _readSecretKeyFromJwkJson(secretJwkJson);
    // write the jwk json into storage
    final FlutterSecureStorage secureStorage = await _secureStorage;
    await secureStorage.write(key: secretKeyKey, value: secretJwkJson);
  }

  String _generateAADValue() {
    _logger.finest('<_generateAADValue>:');
    var r = Random();
    const chars =
        'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    return List.generate(5, (index) => chars[r.nextInt(chars.length)]).join();
  }

  /// Generates a new AES-GCM secret key (256-bit), stores it securely in JWK format,
  /// and returns the [AesGcmSecretKey].
  ///
  /// Requires the user to be authenticated.
  @visibleForTesting
  Future<AesGcmSecretKey> generateSecretKey() async {
    _logger.finest('<_generateSecretKey>:');
    // cannot encrypt if not auth
    if (_uid?.isEmpty ?? false) {
      _logger.severe('(_generateSecretKey): user not authenticated');
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
    secureStorage.write(key: secretKeyKey, value: secretJwkJson);
    _logger.info(
      '(_generateSecretKey): new key generated stored in secureStorage',
    );
    // secret key in secure storage, load it
    return secretKey;
  }

  /// Reads the user's secret key from secure storage and returns it as an [AesGcmSecretKey].
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
    FlutterSecureStorage secureStorage = await _secureStorage;
    // read the json jwk secret key from secure storage
    final String secretJwkJson = (await secureStorage.read(key: secretKeyKey))!;
    // decode the json jwk
    return await _readSecretKeyFromJwkJson(secretJwkJson);
  }

  /// Reads the master secret key from Firebase Remote Config and returns it as an [AesGcmSecretKey].
  ///
  /// The key is expected to be stored in Remote Config as a JWK JSON string
  /// under the key "masterSecretKeyJwk".
  /// Requires the user to be authenticated.
  Future<AesGcmSecretKey> _readMasterSecretKey() async {
    _logger.finest('<_readMasterSecretKey>:');
    // cannot encrypt if not auth
    if (_uid?.isEmpty ?? false) {
      _logger.severe('(_readMasterSecretKey): user not authenticated');
      throw UserNotAuthenticatedException();
    }
    // decode the json jwk
    return await _readSecretKeyFromJwkJson(
      FirebaseRemoteConfig.instance.getString('masterSecretKeyJwk'),
    );
  }

  /// Imports an [AesGcmSecretKey] from its JWK (JSON Web Key) JSON representation.
  Future<AesGcmSecretKey> _readSecretKeyFromJwkJson(
    String secretJwkJson,
  ) async {
    _logger.finest('<_readSecretKeyFromJwkJson>:');
    final secretJwk = jsonDecode(secretJwkJson);
    _logger.finest(
      "(_readSecretKeyFromJwkJson): secret key alg ${secretJwk["alg"]}",
    );
    // import the jwk into secret key
    return await AesGcmSecretKey.importJsonWebKey(secretJwk);
  }

  /// Initializes the secret key by generating one if it's not already stored.
  /// This is typically called during application startup or after user authentication.
  void initSecretKey() async {
    _logger.finest('<initSecretKey>:');
    if (!await secretKeyStored) {
      generateSecretKey();
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
/// Often indicates an issue with the AAD (passphrase), the secret key, or corrupted ciphertext.
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

/// Exception thrown when an attempt is made to encrypt or decrypt without a valid AAD (passphrase) set.
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

/// Exception thrown when decryption is attempted but the required secret key is not found in secure storage.
class MissingEncryptionSecretKeyException implements Exception {
  /// Returns a localized error message prompting the user to import their secret key.
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
