# flutter_heyteacher_shared_preferences

A Flutter package providing shared preferences utilities with asynchronous operations and reactive stream updates, designed for the [Flutter HeyTeacher ecosystem](https://codeberg.org/heyteacher/flutter_heyteacher_packages).

The components in this package are implemented following [`Model-View-ViewModel` (`MVVM`) architecture](https://codeberg.org/heyteacher/flutter_heyteacher_packages#model-view-viewmodel-mvvm-architecture) and [`Singleton` pattern](https://codeberg.org/heyteacher/flutter_heyteacher_packages#singleton-pattern).

## Features

- **Asynchronous Storage**: Built on `SharedPreferencesAsync` for non-blocking read and write operations across platforms.
- **Reactive Stream Updates**: Subscribe to value updates for specific keys with `stream<T>(key: ...)` for fine-grained UI rebuilds.
- **Strongly Typed Getters & Setters**: Dedicated methods for `String`, `int`, `double`, `bool`, and `List<String>`.
- **Dynamic Type Dispatch**: Set values dynamically using `setValue(key: ..., value: ...)`.
- **Redundant Write Prevention**: Checks the existing value before persisting to prevent redundant disk I/O and duplicate stream notifications.

## Getting started

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_heyteacher_shared_preferences:
```

Then, run `flutter pub get`.

## Usage

### Accessing the Singleton

Access `SharedPreferencesViewModel` through its singleton instance:

```dart
import 'package:flutter_heyteacher_shared_preferences/flutter_heyteacher_shared_preferences.dart';
```

### Reading and Writing Values

```dart
// Writing values
await SharedPreferencesViewModel.instance.setString('username', 'Alice');
await SharedPreferencesViewModel.instance.setInt('counter', 10);
await SharedPreferencesViewModel.instance.setDouble('volume', 0.75);
await SharedPreferencesViewModel.instance.setBool('isDarkMode', true);
await SharedPreferencesViewModel.instance.setStringList('tags', ['flutter', 'dart']);

// Setting a value dynamically by type
await SharedPreferencesViewModel.instance.setValue(key: 'enabled', value: true);

// Reading values
final username = await SharedPreferencesViewModel.instance.instanceredPreferences.getString('username');
final counter = await SharedPreferencesViewModel.instance.getInt('counter');
final isDarkMode = await SharedPreferencesViewModel.instance.getBool('isDarkMode');
final tags = await SharedPreferencesViewModel.instance.getStringList('tags');

// Removing a value (or pass null to the setter)
await SharedPreferencesViewModel.instance.setString('username', null);
await SharedPreferencesViewModel.instance.remove('counter');

// Checking key existence
final exists = await SharedPreferencesViewModel.instance.containsKey('isDarkMode');

// Clearing all stored preferences
await SharedPreferencesViewModel.instance.clear();
```

### Reactive Stream Subscription

Listen to changes for a specific key using `stream<T>(key: ...)`:

```dart
final subscription = SharedPreferencesViewModel.instance
    .stream<bool>(key: 'isDarkMode')
    .listen((event) {
      print('Key ${event.key} updated to: ${event.value}');
    });

// Cancel subscription when no longer needed
await subscription.cancel();
```
