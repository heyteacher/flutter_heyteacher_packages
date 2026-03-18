# flutter_heyteacher_connectivity

A Flutter package for managing and displaying connectivity status.

## Features

* **ConnectivityViewModel**: Manages the connectivity state and logic.
* **ConnectivityCard**: A reusable widget to display connectivity status.
* **Localization**: Includes `FlutterHeyteacherConnectivityLocalizations` for internationalization support.

## Installation

Add the dependency to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_heyteacher_connectivity:
    path: ../flutter_heyteacher_connectivity # If using local path in monorepo
    # or git dependency
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
