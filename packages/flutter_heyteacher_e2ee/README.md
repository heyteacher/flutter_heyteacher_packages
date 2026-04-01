# flutter_heyteacher_e2ee

A Flutter package for managing End-to-End Encryption (E2EE) workflows, specifically designed for the [Flutter HeyTeacher ecosystem](../../). This package handles the generation, storage, and management of cryptographic keys and Additional Authenticated Data (AAD).

## Features

- **Key Generation**: Generate cryptographically secure secret keys using `AES-GCM` encryption.
- **JWK Support**: Export and import keys using the `JSON Web Key` (`JWK`) standard.
- **Secure Storage**: Integrated support for persisting keys using `flutter_secure_storage`.
- **AAD Management**: Specific handling for Additional Authenticated Data to ensure integrity.
- **QR Code Utilities**: Helpers for managing key exchange or backup via QR codes.

The components in this packages are implemented following [`Model-View-ViewModel` (`MVVM`) architecture](https://codeberg.or/heyteacher/flutter_heyteacher_packages#model-view-viewmodel-mvvm-architecture) and [`Singleton` pattern](https://codeberg.org/heyteacher/flutter_heyteacher_packages#singleton-pattern).

## Getting started

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_heyteacher_e2ee: 
```

`flutter_heyteacher_e2ee` use `flutter_heyteacher_auth`, so read [flutter_heyteacher_auth](../flutter_heyteacher_auth/) in order to configure authentication.

## Usage

Here is a basic example of how to initialize the view model and generate a key.

```dart
import 'package:flutter_heyteacher_e2ee/e2ee.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

void main() async {

  try {
    // generate Master Secret Key
    E2EEViewModel.masterSecretKeyJwk = await E2EEViewModel.generateSecretKeyJwk();

    // set AAD (aka Password)
    await E2EEViewModel.instance(AuthViewModel.instance.uid).setAAD('jd&76h%d');

    // encrypt text in JSON format
    final e2eeValue = await E2EEViewModel.instance(
        _AuthViewModel.instance.uid,
      ).encrypt('Lorem ipsum dolor sit amet, consectetur adipiscing elit.');

    print('Encrypted Text: ${jsonEncode(e2eeValue.toJson())}}');

    // decrypt text
    final decryptedText = await E2EEViewModel.instance(
        _AuthViewModel.instance.uid,
      ).decrypt(e2eeValue);

    print('Encrypted Text: ${decryptedText}');

  } catch (e) {
    print('Error managing keys: $e');
  }
}
```

A complete app example can be found in [example](example)
