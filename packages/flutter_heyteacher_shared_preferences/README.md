# flutter_heyteacher_shared_preferences

A Flutter package providing shared preferences utilities with asynchronous operations and reactive stream updates, designed for the [Flutter HeyTeacher ecosystem](https://codeberg.org/heyteacher/flutter_heyteacher_packages).

The components in this package are implemented following [`Model-View-ViewModel` (`MVVM`) architecture](https://codeberg.org/heyteacher/flutter_heyteacher_packages#model-view-viewmodel-mvvm-architecture) and [`Singleton` pattern](https://codeberg.org/heyteacher/flutter_heyteacher_packages#singleton-pattern).

## Features

- **Asynchronous Storage**: Built on `SharedPreferencesAsync` for non-blocking read and write operations across platforms.
- **Reactive Stream Updates**: Subscribe to value updates for specific keys with `stream<T>(key: ...)` for fine-grained UI rebuilds.
- **Strongly Typed Getters & Setters**: Dedicated methods for `String`, `int`, `double`, `bool`, and `List<String>`.
- **Dynamic Type Dispatch**: Set values dynamically using `setValue(key: ..., value: ...)`.
- **Redundant Write Prevention**: Checks the existing value before persisting to prevent redundant disk I/O and duplicate stream notifications.
- **`SharedPreferencesListTile` Widget**: Pre-built settings list tile with dropdown selection that automatically loads and persists preferences for `String`, `int`, `double`, and `bool` values.

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
final username = await SharedPreferencesViewModel.instance.getString('username');
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

### SharedPreferencesListTile Widget

`SharedPreferencesListTile<T>` is a pre-built settings list tile (built on `PropertyEditorListTile` from [`flutter_heyteacher_views`](https://codeberg.org/heyteacher/flutter_heyteacher_packages/src/branch/main/packages/flutter_heyteacher_views)) that binds directly to a key in `SharedPreferences`.

It displays a dropdown menu for selecting among predefined options, asynchronously loads the stored preference (falling back to `defaultValue` if unset), and automatically persists changes to storage when a selection is made.

Supported types for `T`: `String`, `int`, `double`, and `bool`.

```dart
ListView(
  children: const [
    // Boolean preference
    SharedPreferencesListTile<bool>(
      sharedPreferencesKey: 'notifications_enabled',
      label: 'Notifications',
      icon: Icon(Icons.notifications),
      values: [true, false],
      defaultValue: true,
      labels: ['Enabled', 'Disabled'],
    ),
    Divider(height: 1),

    // Integer preference with custom labels
    SharedPreferencesListTile<int>(
      sharedPreferencesKey: 'refresh_interval',
      label: 'Refresh Interval',
      icon: Icon(Icons.timer),
      values: [1, 2, 5],
      defaultValue: 2,
      labels: ['1 second', '2 seconds', '5 seconds'],
      width: 140,
    ),
    Divider(height: 1),

    // String preference
    SharedPreferencesListTile<String>(
      sharedPreferencesKey: 'theme_mode',
      label: 'Theme Mode',
      icon: Icon(Icons.palette),
      values: ['light', 'dark', 'system'],
      defaultValue: 'system',
    ),
    Divider(height: 1),

    // Double preference
    SharedPreferencesListTile<double>(
      sharedPreferencesKey: 'playback_speed',
      label: 'Playback Speed',
      icon: Icon(Icons.speed),
      values: [0.5, 1.0, 1.5, 2.0],
      defaultValue: 1.0,
      labels: ['0.5x', '1.0x', '1.5x', '2.0x'],
    ),
  ],
)
```

#### Parameters

| Parameter | Type | Description |
| --- | --- | --- |
| `label` | `String` | The display label for the property/setting. |
| `sharedPreferencesKey` | `String` | The key used to store and retrieve the property's value in shared preferences. |
| `values` | `List<T>` | The list of selectable values (`String`, `int`, `double`, or `bool`). |
| `labels` | `List<String>?` | Optional list of display labels corresponding to `values`. |
| `defaultValue` | `T?` | Optional default value used if no value is currently stored. |
| `icon` | `Icon?` | Optional icon widget displayed for the property. |
| `width` | `double` | Width of the dropdown menu (defaults to `120`). |

### Example App

See the [example](./example/) directory for a complete runnable demonstration.
