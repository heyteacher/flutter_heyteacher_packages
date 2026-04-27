# flutter_heyteacher_connectivity

A Flutter package based [connectivity_plus](https://pub.dev/packages/connectivity_plus) for managing and displaying connectivity status  specifically designed for the [Flutter HeyTeacher ecosystem](../../).

## Features

* **ConnectivityViewModel**: Manages the connectivity state and logic.
* **ConnectivityCard**: A reusable widget to display connectivity status.
* **Localization**: Includes `FlutterHeyteacherConnectivityLocalizations` for internationalization support.

The components in this packages are implemented following [`Model-View-ViewModel` (`MVVM`) architecture](https://codeberg.org/heyteacher/flutter_heyteacher_packages#model-view-viewmodel-mvvm-architecture) and [`Singleton` pattern](https://codeberg.org/heyteacher/flutter_heyteacher_packages#singleton-pattern).

## Installation

Add the dependency to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_heyteacher_connectivity:
```

## Usage

Import the package and use the provided components:

```dart
import 'package:flutter_heyteacher_connectivity/connectivity.dart';

/// initialize `localizationsDelegates` with 
/// `FlutterHeyteacherConnectivityLocalizations.delegate`
MaterialApp(
      .
      .
      .
      .
      localizationsDelegates: const [
        FlutterHeyteacherConnectivityLocalizations.delegate,
      ]
);

// Use the connectivity card in your widget tree
const ConnectivityCard();
```
