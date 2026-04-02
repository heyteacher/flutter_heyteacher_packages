# Flutter Heyteacher Platform

This package contains platform-specific utilities, UI components, and localization support for the Heyteacher project.

## Features

This package exports the following modules via `platform.dart`:

- **Context Management**: `ContextHelper` provides utility methods for interacting with `BuildContext`.
- **Device Information**:
  - `DevicePackageInfoCard`: A widget to display device and package information.
  - `InfoDevicePackageViewModel`: The view model backing the device info card.
- **Localization**: `FlutterHeyteacherPlatformLocalizations` handles localized strings specific to platform features.
- **Platform Utilities**: `PlatformHelper` offers methods to handle platform-specific behaviors.

The components in this packages are implemented following [`Model-View-ViewModel` (`MVVM`) architecture](https://codeberg.org/heyteacher/flutter_heyteacher_packages#model-view-viewmodel-mvvm-architecture) and [`Singleton` pattern](https://codeberg.org/heyteacher/flutter_heyteacher_packages#singleton-pattern).

## Usage

Import the main library file to access the components:

```dart
import 'package:flutter_heyteacher_platform/flutter_heyteacher_platform.dart';
```

Refer to the individual source files in `lib/src/` for detailed implementation logic.
