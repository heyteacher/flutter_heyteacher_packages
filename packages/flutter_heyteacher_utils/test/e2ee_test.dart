import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_heyteacher_utils/e2ee.dart';
import 'package:flutter_heyteacher_utils/firebase/auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// End 2 End Encryption tests
///
/// compiler webwrypto library before first run of `flutter test`
/// ```
/// flutter pub run webcrypto:setup
/// ```
void main() {
  final e2ee = E2EE.instance;
  const String userId = 'testuid',
      userEmail = 'test@example.com',
      userDisplayName = 'Test User';

  WidgetsFlutterBinding.ensureInitialized();
  FlutterSecureStorage.setMockInitialValues({});
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
  Auth.instance(firebaseAuth: auth);

  group('encrypt decryp message:', () {
    test('encrypted decrypted empty message return same', () async {
      final originalMessage = "";
      final encrypted = await e2ee.encrypt(originalMessage);

      expect(encrypted.value.isNotEmpty, true,
          reason: "encrypted value is empty");
      expect(encrypted.iv.isNotEmpty, true, reason: "encrypted iv is empty");

      final decryptedMessage = await e2ee.decrypt(encrypted);
      expect(originalMessage, decryptedMessage,
          reason:
              "decrypted message $decryptedMessage differs from original message $originalMessage");
    });

    test('encrypted decrypted message return same', () async {
      final originalMessage = "this is a message";
      final encrypted = await e2ee.encrypt(originalMessage);

      expect(encrypted.value.isNotEmpty, true,
          reason: "encrypted value is empty");
      expect(encrypted.iv.isNotEmpty, true, reason: "encrypted iv is empty");

      final decryptedMessage = await e2ee.decrypt(encrypted);
      expect(originalMessage, decryptedMessage,
          reason:
              "decrypted message $decryptedMessage differs from original message $originalMessage");
    });
  });
}
