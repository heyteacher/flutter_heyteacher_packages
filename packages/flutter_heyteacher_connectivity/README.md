# Flutter HeyTeacher Connectivity

A Flutter package responsible for managing network connectivity status within the HeyTeacher ecosystem.

This package provides utilities to monitor internet connection status, offering both one-time checks and continuous monitoring via streams.

## Features

- **Connectivity Monitoring**: Real-time detection of network connectivity changes.
- **Status Stream**: Listen to connectivity updates via a `Stream<bool>`.
- **Instant Check**: Verify current connection status using `connected` or `notConnected` futures.
- **Ecosystem Integration**: Designed to work seamlessly with other packages of flutter_heyteacher_packages.

## Usage

Add `flutter_heyteacher_connectivity` as a dependency in your `pubspec.yaml` file.

```yaml
dependencies:
  flutter_heyteacher_connectivity: ^2.0.0
```

Import the package in your Dart code:

```dart
import 'package:flutter_heyteacher_connectivity/flutter_heyteacher_connectivity.dart';
```

### Check Connectivity

You can check if the device is currently connected:

```dart
final connectivity = ConnectivityViewModel();

if (await connectivity.connected) {
  print('Device is connected');
}

if (await connectivity.notConnected) {
  print('Device is offline');
}
```

### Listen to Changes

Subscribe to the stream to receive updates when connectivity status changes:

```dart
connectivity.stream.listen((isConnected) {
  if (isConnected) {
    print('Back online');
  } else {
    print('Lost connection');
  }
});
```

A complete app example can be found in [example app](example)
