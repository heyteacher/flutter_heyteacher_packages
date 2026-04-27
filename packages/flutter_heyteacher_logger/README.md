# flutter_heyteacher_logger

A Flutter package based on [logging](https://pub.dev/packages/logging) that provides UI components and a model for viewing and managing application logs. This package is specifically designed for the [Flutter HeyTeacher ecosystem](../../).

## Features

- **Log Viewing & Filtering**: A dedicated `LoggerScreen` to display, filter, and search through log messages.
- **Easy Access**: A convenient `LoggerCard` widget for easy navigation to the logger screen.
- **Centralized Log Management**: The `LoggerViewModel` captures, configures, and stores logs in-memory.
- **Firebase Integration**: Dynamically set log levels using Firebase Remote Config and forward structured logs to Firebase Analytics.
- **UI Components**: Includes widgets like `EnableLogsStorageChoiceCard` and `LoggingLevelDropDownMenuCard` for user interaction.
- **Routing**: Pre-configured routing for the logger UI with `LoggingRouter`.
- **Localization**: Support for localizations via `FlutterHeyteacherLoggerLocalizations`.

The components in this packages are implemented following [`Model-View-ViewModel` (`MVVM`) architecture](https://codeberg.org/heyteacher/flutter_heyteacher_packages#model-view-viewmodel-mvvm-architecture) and [`Singleton` pattern](https://codeberg.org/heyteacher/flutter_heyteacher_packages#singleton-pattern).

## Getting started

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_heyteacher_logger:
```

This package relies on Firebase for remote configuration of log levels and for analytics. Ensure your Flutter project is correctly configured with Firebase.

## Usage

Here is a basic example of how to use the logger UI components.

### Initialization

First, initialize the `LoggerViewModel`. This is typically done at the start of your application.

```dart
import 'package:flutter_heyteacher_logger/flutter_heyteacher_logger.dart';

void main() async {
  // ... other initializations

  // Initialize LoggerViewModel
  // It will start capturing logs based on the configuration.
  await LoggerViewModel.instance.initialize();

  runApp(MyApp());
}

/// This Widget is the main application widget.
class MyApp extends StatelessWidget {
  .
  .
  .
  @override
  Widget build(BuildContext context) => MaterialApp.router(
    .
    .
    .
    localizationsDelegates: const [
      FlutterHeyteacherLoggerLocalizations.delegate,
    ],
    routerConfig: GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const _MyHomePage(),
          routes: [
            LoggingRouter.builder(),
          ],
        ),
      ],
    ),
  );
}
```

### UI Components

To allow users to view logs, you can use the `LoggerCard` which navigates to the `LoggerScreen` on tap.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_heyteacher_logger/flutter_heyteacher_logger.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: ListView(
        children: [
          // ... other settings
          LoggerCard(''),
        ],
      ),
    );
  }
}
```

### Logging Messages

To log messages from anywhere in your application, use the `Logger` instance from the `LoggerViewModel`.

```dart
import 'package:flutter_heyteacher_logger/flutter_heyteacher_logger.dart';

void doSomething() {
  final logger = Logger('doSomething');

  logger.info('This is an informational message.');
  logger.warning('This is a warning message.');
  try {
    throw Exception('Something went wrong!');
  } catch (e, s) {
    logger.severe('An error occurred', e, s);
  }
}
```
