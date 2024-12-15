<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/tools/pub/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/to/develop-packages).
-->

TODO: Put a short description of the package here that helps potential users
know whether this package might be useful for them.

This package collects common commands, classes, widgets used in my projects, 
in order to mantain a unique and autoritative version of implementation 
avoiding the `copy-and-paste` pattern.

## Features

TODO: List what your package can do. Maybe include images, gifs, or videos.

* firebase package configuration
* command line `version` for upgrade `pubsec.yaml` package version using semver notation (`mayor`, `minor`, `patch` and `build`)
* formats utils
* platform, date and shared preferenses helpers
* routing utils to bild app routes
* ble utils
* chart utils build on `FlChart` library
* localization utils
* TTS utils

## Getting started

TODO: List prerequisites and provide or point to information on how to
start using the package.

```
dart pub add flutter_heytecher_utils
```
or 
```
flutter pub add flutter_heytecher_utils
```

## Usage

### version command

From the root of your project, run:

```
dart run flutter_heyteacher_utils:version --mayor|--minor|--patch|--build|--show|--show-build [--dry-run]
```

* `--mayor`,`--minor`, `--patch` increment the version in your `pubsec.yaml`. `--dry-run` show how the version will be changed without modify `pubsec.yaml`

* `--build` set the build version in your `pubsec.yaml`  to `YYMMddHHm` based on the current time. 
  
* `--dry-run` show how the version will be changed without modify `pubsec.yaml`

* `--show` print the version in `pubsec.yaml`

* `--show-build` print only the build version from `pubsec.yaml`

You can configure you `vscode` to execute the command with `--build` in order to automatically update build version every run/debug execution of your code:

* create/modify `vscode/tasks.json` in the root of your project 
  
  ```json
  {
        "version": "2.0.0",
        "tasks": [
                {
                        "type": "dart",
                        "command": "dart",
                        "args": [
                                "run",
                                "flutter_heyteacher_utils:version",
                                "--build"
                        ],
                        "group": "build",
                        "problemMatcher": [],
                        "label": "dart: run flutter_heyteacher_utils:version --build",
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
    
    "preLaunchTask": "dart: run flutter_heyteacher_utils:version --build"
  ```

## Additional information

TODO: Tell users more about the package: where to find more information, how to
contribute to the package, how to file issues, what response they can expect
from the package authors, and more.
