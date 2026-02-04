import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_heyteacher_utils/e2ee.dart';
import 'package:flutter_heyteacher_utils/firebase.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// End 2 End Encryption tests
///
/// compiler webwrypto library before first run of `flutter test`
/// ```bash
/// flutter pub run webcrypto:setup
/// ```
void main() {
  const userId = 'testuid';
  const userEmail = 'test@example.com';
  const userDisplayName = 'Test User';

  WidgetsFlutterBinding.ensureInitialized();
  PackageInfoPlusLinuxPlugin.registerWith();
  FlutterSecureStorage.setMockInitialValues({});
  PackageInfoPlusLinuxPlugin.registerWith();
  // mock authentication
  final auth = MockFirebaseAuth(
    mockUser: MockUser(
      uid: userId,
      email: userEmail,
      displayName: userDisplayName,
    ),
  );
  // mock sign-in
  unawaited(
    auth.signInWithEmailAndPassword(email: userEmail, password: userEmail),
  );

  // initialize Auth with MockFirebaseAuth
  AuthViewModel.instance = AuthViewModel(mockedFirebaseAuth: auth);
  unawaited(
    E2EEViewModel.instance(
      AuthViewModel.instance.uid,
    ).setAAD(aadValue: 'aadValue'),
  );

  group('secret key', () {
    test('generate secret key ,encrypt an decrypt with master key', () async {
      // Generate a master key
      final masterSecretKey = await E2EEViewModel.instance(
        AuthViewModel.instance.uid,
      ).generateSecretKey(isToStore: false);
      debugPrint(
        'masterSecretJwkJson:\n\n'
        '${jsonEncode(await masterSecretKey.exportJsonWebKey())}',
      );
      // generate a secret key
      final secretKey = await E2EEViewModel.instance(
        AuthViewModel.instance.uid,
      ).generateSecretKey(isToStore: false);
      final secretJwkJson = jsonEncode(await secretKey.exportJsonWebKey());
      const aad = '/&/8678bhnogvd6&/=gB097';
      // encrypt with master key
      final encryptedSecretE2EEValue =
          await E2EEViewModel.instance(
            AuthViewModel.instance.uid,
          ).encrypt(
            secretJwkJson,
            esternalSecretKey: masterSecretKey,
            externalAAD: aad,
          );
      debugPrint(
        'encryptedSecretE2EEValue:\n'
        '\n${jsonEncode(encryptedSecretE2EEValue)}',
      );
      // decrypt with master key
      final decryptedSecretJwkJson =
          await E2EEViewModel.instance(
            AuthViewModel.instance.uid,
          ).decrypt(
            encryptedSecretE2EEValue,
            esternalSecretKey: masterSecretKey,
            externalAAD: aad,
          );
      // check if it's the same
      expect(secretJwkJson, decryptedSecretJwkJson);
    });
  });

  group('encrypt decryp message:', () {
    test('encrypted decrypted empty message return same', () async {
      const originalMessage = '';
      final encrypted = await E2EEViewModel.instance(
        AuthViewModel.instance.uid,
      ).encrypt(originalMessage);

      expect(
        encrypted.value.isNotEmpty,
        true,
        reason: 'encrypted value is empty',
      );
      expect(encrypted.iv.isNotEmpty, true, reason: 'encrypted iv is empty');

      final decryptedMessage = await E2EEViewModel.instance(
        AuthViewModel.instance.uid,
      ).decrypt(encrypted);
      expect(
        originalMessage,
        decryptedMessage,
        reason:
            'decrypted message $decryptedMessage differs from original '
            'message $originalMessage',
      );
    });

    test('encrypted decrypted message return same', () async {
      const originalMessage = 'this is a message';
      final encrypted = await E2EEViewModel.instance(
        AuthViewModel.instance.uid,
      ).encrypt(originalMessage);

      expect(
        encrypted.value.isNotEmpty,
        true,
        reason: 'encrypted value is empty',
      );
      expect(encrypted.iv.isNotEmpty, true, reason: 'encrypted iv is empty');

      final decryptedMessage = await E2EEViewModel.instance(
        AuthViewModel.instance.uid,
      ).decrypt(encrypted);
      expect(
        originalMessage,
        decryptedMessage,
        reason:
            'decrypted message $decryptedMessage differs from original '
            'message $originalMessage',
      );
    });
  });
}
