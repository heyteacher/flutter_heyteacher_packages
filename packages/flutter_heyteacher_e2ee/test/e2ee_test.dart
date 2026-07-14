import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter_heyteacher_auth/flutter_heyteacher_auth.dart'
    show AuthViewModel;
import 'package:flutter_heyteacher_e2ee/flutter_heyteacher_e2ee.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// End 2 End Encryption tests
///
/// compiler webwrypto library before first run of `flutter test`
/// ```bash
/// flutter pub run webcrypto:setup
/// ```
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  PackageInfoPlusLinuxPlugin.registerWith();
  FlutterSecureStorage.setMockInitialValues({});
  PackageInfoPlusLinuxPlugin.registerWith();

  unawaited(AuthViewModel.instance.localInitialize());
  unawaited(
    E2EEViewModel.instance(AuthViewModel.instance.uid).setAAD('debugPassword'),
  );

  group('secret key', () {
    test('generate secret key ,encrypt an decrypt with master key', () async {
      // Generate a master key
      final masterSecretKey = await E2EEViewModel.instance(
        AuthViewModel.instance.uid,
      ).generateSecretKey(isToStore: false);
      debugPrint(
        '\naad: ${await E2EEViewModel.instance(
          AuthViewModel.instance.uid,
        ).getAAD()}\n',
      );
      debugPrint(
        'masterSecretJwkJson:\n'
        '${jsonEncode(await masterSecretKey.exportJsonWebKey())}\n',
      );
      // generate a secret key
      final secretKey = await E2EEViewModel.instance(
        AuthViewModel.instance.uid,
      ).generateSecretKey(isToStore: false);
      final secretJwkJson = jsonEncode(await secretKey.exportJsonWebKey());
      //const aad = '/&/8678bhnogvd6&/=gB097';
      // encrypt with master key
      final encryptedSecretE2EEValue =
          await E2EEViewModel.instance(
            AuthViewModel.instance.uid,
          ).encrypt(
            secretJwkJson,
            esternalSecretKey: masterSecretKey,
            //externalAAD: aad,
          );
      debugPrint(
        'encryptedSecretE2EEValue:\n'
        '${jsonEncode(encryptedSecretE2EEValue)}\n',
      );
      // decrypt with master key
      final decryptedSecretJwkJson =
          await E2EEViewModel.instance(
            AuthViewModel.instance.uid,
          ).decrypt(
            encryptedSecretE2EEValue,
            esternalSecretKey: masterSecretKey,
            //externalAAD: aad,
          );
      // check if it's the same
      expect(secretJwkJson, decryptedSecretJwkJson);
    });
  });

  group('secretKeyChangedStream', () {
    setUp(() {
      // Reset static state so each test starts clean
      E2EEViewModel.debugSecretKeyJWK = null;
      E2EEViewModel.masterSecretKeyJwk = '';
    });

    test('emits debug:true when debugSecretKeyJWK setter is called', () async {
      final vm = E2EEViewModel.instance(AuthViewModel.instance.uid);

      // Collect the next event from the stream
      final eventFuture = vm.secretKeyChangedStream.first;

      // Trigger the setter
      final jwk = await E2EEViewModel.generateSecretKeyJwk();
      E2EEViewModel.debugSecretKeyJWK = jwk;

      final event = await eventFuture;
      expect(event.debug, isTrue, reason: 'expected debug flag to be true');
      expect(
        event.uid,
        equals(AuthViewModel.instance.uid),
        reason: 'expected uid to match current user',
      );
    });

    test(
      'emits debug:false when generateSecretKey is called with isToStore:true',
      () async {
        final vm = E2EEViewModel.instance(AuthViewModel.instance.uid);

        final eventFuture = vm.secretKeyChangedStream.first;

        await vm.generateSecretKey();

        final event = await eventFuture;
        expect(event.debug, isFalse, reason: 'expected debug flag to be false');
        expect(
          event.uid,
          equals(AuthViewModel.instance.uid),
          reason: 'expected uid to match current user',
        );
      },
    );

    test(
      'does not emit when generateSecretKey is called with isToStore:false',
      () async {
        final vm = E2EEViewModel.instance(AuthViewModel.instance.uid);

        var emitted = false;
        final sub = vm.secretKeyChangedStream.listen((_) => emitted = true);

        await vm.generateSecretKey(isToStore: false);

        // Give the stream a moment to deliver any event
        await Future<void>.delayed(const Duration(milliseconds: 50));
        expect(
          emitted,
          isFalse,
          reason: 'stream should not emit for isToStore:false',
        );

        await sub.cancel();
      },
    );

    test(
      'emits debug:false when importSecretJwkJson imports a valid key',
      () async {
        final vm = E2EEViewModel.instance(AuthViewModel.instance.uid);

        // Set up a master key so importSecretJwkJson can decrypt
        final masterJwk = await E2EEViewModel.generateSecretKeyJwk();
        E2EEViewModel.masterSecretKeyJwk = masterJwk;

        // Export a real secret key encrypted with the master key
        final exportedJson = await vm.exportSecretJwkJson();

        final eventFuture = vm.secretKeyChangedStream.first;

        await vm.importSecretJwkJson(exportedJson);

        final event = await eventFuture;
        expect(event.debug, isFalse, reason: 'expected debug flag to be false');
        expect(
          event.uid,
          equals(AuthViewModel.instance.uid),
          reason: 'expected uid to match current user',
        );
      },
    );
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
