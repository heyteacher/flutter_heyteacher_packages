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
/// ```
/// flutter pub run webcrypto:setup
/// ```
void main() {
  const String userId = 'testuid',
      userEmail = 'test@example.com',
      userDisplayName = 'Test User';

  WidgetsFlutterBinding.ensureInitialized();
  PackageInfoPlusLinuxPlugin.registerWith();
  FlutterSecureStorage.setMockInitialValues({});
  PackageInfoPlusLinuxPlugin.registerWith();
  // mock authentication
  MockFirebaseAuth auth = MockFirebaseAuth(
      mockUser: MockUser(
    isAnonymous: false,
    uid: userId,
    email: userEmail,
    displayName: userDisplayName,
  ));
  // mock sign-in
  auth.signInWithEmailAndPassword(email: userEmail, password: userEmail);

  // initialize Auth with MockFirebaseAuth
  AuthViewModel.instance(mockedFirebaseAuth: auth);
  E2EE.instance.setAAD(aadValue: 'aadValue');

  group('encrypt decryp message:', () {
    test('encrypted decrypted empty message return same', () async {
      final originalMessage = '';
      final encrypted = await E2EE.instance.encrypt(originalMessage);

      expect(encrypted.value.isNotEmpty, true,
          reason: 'encrypted value is empty');
      expect(encrypted.iv.isNotEmpty, true, reason: 'encrypted iv is empty');

      final decryptedMessage = await E2EE.instance.decrypt(encrypted);
      expect(originalMessage, decryptedMessage,
          reason:
              'decrypted message $decryptedMessage differs from original message $originalMessage');
    });

    test('encrypted decrypted message return same', () async {
      final originalMessage = 'this is a message';
      final encrypted = await E2EE.instance.encrypt(originalMessage);

      expect(encrypted.value.isNotEmpty, true,
          reason: 'encrypted value is empty');
      expect(encrypted.iv.isNotEmpty, true, reason: 'encrypted iv is empty');

      final decryptedMessage = await E2EE.instance.decrypt(encrypted);
      expect(originalMessage, decryptedMessage,
          reason:
              'decrypted message $decryptedMessage differs from original message $originalMessage');
    });
  });
}
