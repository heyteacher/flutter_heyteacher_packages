# Flutter HeyTeacher Auth

A Flutter package responsible for managing authentication within the [Flutter HeyTeacher ecosystem](https://codeberg.org/heyteacher/flutter_heyteacher_packages).

This package provides the necessary utilities and repositories to handle user sessions, including Google Sign-In and a demo authentication mode.

## Features

- **Authentication Management**: Handle user sign-in and sign-out flows using [Firebase Authentication](https://firebase.google.com/docs/auth).
- **Google Sign-In**: Integrated support for authenticating users via Google.
- **User Management**: Utilities for managing user profiles and scheduling account deletion.
- **Demo Mode**: `Fake` authentication support for demonstration and testing purposes without requiring real credentials with [firebase_auth_mocks](https://pub.dev/packages/firebase_auth_mocks).
- **Ecosystem Integration**: Designed to work seamlessly with other packages of [flutter_heyteacher_packages](https://github.com/heyteacher/flutter_heyteacher_packages)

The components in this packages are implemented following [`Model-View-ViewModel` (`MVVM`) architecture](https://codeberg.org/heyteacher/flutter_heyteacher_packages#model-view-viewmodel-mvvm-architecture) and [`Singleton` pattern](https://codeberg.org/heyteacher/flutter_heyteacher_packages#singleton-pattern).

## Usage

Configure [Firebase Authentication](https://firebase.google.com/docs/auth) and link to your app following documentation [firebase setup for app flutter project](https://pub.dev/packages/flutter_heyteacher_meta#firebase-setup-for-app-flutter-project).

Add `flutter_heyteacher_auth` as a dependency in your `pubspec.yaml` file.

```yaml
dependencies:
  flutter_heyteacher_auth: 
```

Import the package in your Dart code:

```dart
import 'package:flutter_heyteacher_auth/flutter_heyteacher_auth.dart';
```

In your main function, initialize auth

```dart
Future<void> main() async {
  // ensureInitialized
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}
```

in your App widget, instanziate `MaterialApp.router` configuring router config
with `GoRoute`

```dart
  Widget build(BuildContext context) => MaterialApp.router(
    .
    .
    ,
    localizationsDelegates: const [
      FlutterHeyteacherAuthLocalizations.delegate,
    ],
    routerConfig: GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const _MyHomePage(
            title: 'Your home page',
          ),
          routes: [
            GoAuthRoute.builder(
              landingRoutePath: '/'
            ),
          ],
        ),
      ],
    ),
  );
```

A complete app example can be found in [example](example)

## Delete User Data

User Data deletion is delegate to the application which uses `flutter_heyteacher_auth`.

In order to use `Delete User Data` feature you need:

- in `initialize` enable delete user data:

  ```dart
  AuthViewModel.initialize(enableDeleteUserData: true);
  ```

- in `AccountCard` set `deleteAccountCallback` and `deleteAccountConfirmMessage`

  ```dart
  AccountListTile(
    deleteAccountConfirmMessage: 'Are you sure to delete your user data?',
    deleteAccountCallback: () async {
      // insert here your logic to delete user data
      showSnackBar(context: context, message: 'content');
    },
  ),
  ```

### Mock Firestore Authentication

In unit tests and example applications you can mock [Firebase Authentication](https://firebase.google.com/docs/auth) with [firebase_auth_mocks](https://pub.dev/packages/firebase_auth_mocks) via `AuthViewModel.instance.localInitialize()`:

```dart
  // Local initializzation with Mock Firebase Authentication
  await AuthViewModel.instance.localInitialize();
```
