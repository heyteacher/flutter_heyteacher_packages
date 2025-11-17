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

## Usage

### command-line utility `version`

From the root of your project, run:

```bash
dart run flutter_heyteacher_fastlane:version mayor|minor|patch|build|show|show-build [--dry-run]
```

* `mayor`,`minor`, `patch` increment the version in your `pubsec.yaml`.
  `--dry-run` show how the version will be changed without modify `pubsec.yaml`

* `build` set the build version in your `pubsec.yaml`  to `YYMMddHHm` based on
  the current time.
  
* `dry-run` show how the version will be changed without modify `pubsec.yaml`

* `show` print the version in `pubsec.yaml`

* `show-build` print only the build version from `pubsec.yaml`

You can configure you `vscode` to execute the command with `build` in order to
automatically update build version every run/debug execution of your code:

* create/modify `.vscode/tasks.json` in the root of your project
  
  ```json
  {
        "version": "2.0.0",
        "tasks": [
                {
                        "type": "dart",
                        "command": "dart",
                        "args": [
                                "run",
                                "flutter_heyteacher_fastlane:version",
                                "build"
                        ],
                        "group": "build",
                        "problemMatcher": [],
                        "label": "dart: run flutter_heyteacher_fastlane:version build",
                        "detail": "increment version build number",
                        "presentation": {
                                "close": true,
                                "echo": false,
                                "reveal": "silent",
                                "focus": false,
                                "panel": "shared",
                                "showReuseMessage": false,
                                "clear": false
                        }
                }
        ]
  }
  ```

* add `preLaunchTask` in your launch configurations '.vscode/launch.json'
  
  ```json
  ...
    
    "preLaunchTask": "dart: run flutter_heyteacher_fastlane:version build"
  ```

## localization utils

* install packages

  ```bash
  flutter pub add flutter_localizations --sdk=flutter
  flutter pub add intl:any
  ```

* modify `pubspec.yaml` setting flutter artifact generation  

  ```yaml
  flutter:
    generate: true
  ```

* in root project creat `l10n.yaml`

  ```yaml
  arb-dir: lib/src/l10n
  template-arb-file: flutter_heyteacher_utils_en.arb
  output-localization-file: flutter_heyteacher_utils.dart
  output-class: FlutterHeyteacherUtilsLocalizations
  output-dir: lib/src/l10n
  untranslated-messages-file: untranslated-messages.txt
  ```

* create the `arb` files of your supported languages

  ```bash
  mkdir lib/l10n
  touch lib/l10n/flutter_heyteacher_utils_en.arb
  touch lib/l10n/flutter_heyteacher_utils_it.arb
  ```

* insert in `flutter_heyteacher_utils_en.arb` the translation

* commit `untranslated-messages.txt` the file containing localized strings to be
  translated, this file should be always empty

  ```bash
  git add untranslated-messages.txt
  git commit -m "localized strings to be translated, this file should be always empty"
  ```

* insert localized string into `flutter_heyteacher_utils_en.arb`

  ```json
  {
    "@@locale": "en",
    "userNotAutenticated": "User not autenticated",
    "@userNotAutenticated": {},
    "notAuthenticated": "Not Authenticated",
    "@notAuthenticated": {},
    "errorOnRetrieveData": "Error on retrieve Data",
    "@errorOnRetrieveData": {},
    "timeoutOnRetrieveData": "Timeout on retieve data",
    "@timeoutOnRetrieveData": {}
  }
  ```

* regenerate the artifacts

  ```bash
  flutter pub get
  ```

* create a file `lib/localizations.dart` containing the export

  ```dart
  export 'package:flutter_heyteacher_utils/src/l10n/flutter_heyteacher_utils.dart' show FlutterHeyteacherUtilsLocalizations;
  ```

* add delegate to your app

  ```dart
  MaterialApp.router(
    localizationsDelegates: [
      .
      .
      .
      FlutterHeyteacherUtilsLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],

  )
  ```

* import and use in your code

  ```dart
  import 'package:flutter_heyteacher_utils/localizations.dart';
  .
  .
  .
  FlutterHeyteacherUtilsLocalizations.of(context)!.userNotAutenticated
  ```
  
## End 2 End Encryption (E2EE)

compiler webwrypto library before first run of `flutter test`

```bash
flutter pub run webcrypto:setup
```
