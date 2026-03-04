# flutter_heyteacher_utils

A collection of common utilities (classes, helpers widgets, functions, etc..)
that are used in [flutter] `heyteacher` apps, in order to mantain a unique
and autoritative version of implementation avoiding the `copy-and-paste`
pattern, and decoupling dependencies like firebase.

## Features

* [firebase] library which exports common Firebase-related utiliti
  formats utils
* [e2ee] provides End-to-End Encryption (E2EE) capabilities using AES-GCM.
* [info_device_package] provides utilities for retrieving device and application
  package information, and a widget to display this information along with a
  support request option.
* [logging] configures and initializes the application's logging system.
* [routing] provides routing utilities for Flutter applications using
* `go_router`.
* [localization]
* [theme] manages application-wide theming, including theme selection UI,
  theme persistence, and dynamic theme updates
* [firebase_cloud_messaging.dart] provides utilities for managing background tasks
  using `Firebase Cloud Messaging`.
* [widgets] a collection of reusable Flutter widgets and utility functions
* [formats] provides a collection of pre-configured formatters for dates, times,
  numbers, and durations
* [date_helpers] provides extension methods on [DateTime] to determine its
  relation to the current day (e.g., today, yesterday, tomorrow)..
* [platform_helper] provides utility methods and properties to easily determine
  the current operating platform (e.g., mobile, web, desktop).
* [context_helper] provides a global way to access a [BuildContext] from
  anywhere in the application.
* [version] a command-line utility to manage the version string in `pubspec.yaml`
* [color_to_int32_extension] provides an extension on [Color] to convert it to a
  32-bit integer representation

## Getting started

```bash
dart pub add flutter_heyteacher_utils
```

or

```bash
flutter pub add flutter_heyatecher_utils
```
  
## End 2 End Encryption (E2EE)

compiler webwrypto library before first run of `flutter test`

```bash
flutter pub run webcrypto:setup
```

or

```bash
flutter_webcrypto_setup.sh 
```
