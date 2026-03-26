# flutter_heyteacher_firebase

A Flutter package for integrating Firebase services into HeyTeacher applications. It provides a set of convenience wrappers (ViewModels) for common Firebase functionalities.

This package is part of the `flutter_heyteacher_packages` monorepo.

## Features

This package provides singleton `ViewModel` classes to simplify integration with various Firebase services:

- `AppCheckViewModel`: Integrates Firebase App Check to protect your backend resources.
- `CrashlyticsViewModel`: Sets up Firebase Crashlytics for automatic crash reporting.
- `RemoteConfigViewModel`: Fetches and manages parameters from Firebase Remote Config.
- `StorageViewModel`: Provides utilities for uploading files to Firebase Storage.
- `FirebaseCloudMessagingViewModel`: Handles setup and interaction with Firebase Cloud Messaging (FCM) for push notifications.
- `GoogleAnalitycsViewModel`: A wrapper for logging events and user properties to Google Analytics for Firebase.

## Getting started

### Prerequisites

Before using this package, you need to have:

1. A Flutter project.
2. A Firebase project set up on the Firebase Console.
3. The Firebase CLI and FlutterFire CLI installed.

### Installation

Add `flutter_heyteacher_firebase` to your `pubspec.yaml` dependencies:

```yaml
dependencies:
  flutter_heyteacher_firebase: 
```

Then, run `flutter pub get` to install the package.

### Configuration

1. **Configure Firebase:** Connect your Flutter application with your Firebase project using the FlutterFire CLI. This will generate the necessary `lib/firebase_options.dart` file.

    ```bash
    flutterfire configure
    ```

2. **Initialize Firebase:** In your application's entry point (`lib/main.dart`), initialize Firebase before running your app. You can also initialize the ViewModels you need at startup.

    ```dart
    import 'package:flutter/material.dart';
    import 'package:firebase_core/firebase_core.dart';
    import 'package:flutter_heyteacher_firebase/firebase.dart'; // Import the package
    import 'firebase_options.dart';

    void main() async {
      WidgetsFlutterBinding.ensureInitialized();
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      
      // Optionally, initialize the ViewModels you need right away
      await RemoteConfigViewModel.instance.initialize();
      CrashlyticsViewModel.instance.initialize();
      await AppCheckViewModel.instance.initialize();
      
      runApp(const MyApp()); // Your app widget
    }
    ```

## Usage

After initialization, you can access the singleton instance of each ViewModel anywhere in your app to use its functionality.

Here is an example of using `RemoteConfigViewModel` to fetch a value and `GoogleAnalitycsViewModel` to log an event.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_heyteacher_firebase/firebase.dart';

class MyFeatureWidget extends StatefulWidget {
  const MyFeatureWidget({super.key});

  @override
  State<MyFeatureWidget> createState() => _MyFeatureWidgetState();
}

class _MyFeatureWidgetState extends State<MyFeatureWidget> {
  String _welcomeMessage = 'Loading...';

  @override
  void initState() {
    super.initState();
    _fetchWelcomeMessage();
  }

  Future<void> _fetchWelcomeMessage() async {
    // Log an analytics event
    GoogleAnalitycsViewModel.instance.logEvent(name: 'fetch_welcome_message');

    // Get a value from Remote Config
    final message = RemoteConfigViewModel.instance.getString('welcome_message');
    if (mounted) {
      setState(() {
        _welcomeMessage = message.isNotEmpty ? message : 'Welcome!';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Text(_welcomeMessage);
  }
}
```
