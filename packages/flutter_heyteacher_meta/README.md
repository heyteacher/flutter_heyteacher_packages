# Flutter Heyteacher Meta

A Flutter meta project with utilities for Flutter packages and applications.

## Table of Contents

- [Flutter Heyteacher Meta](#flutter-heyteacher-meta)
  - [Table of Contents](#table-of-contents)
  - [Installing](#installing)
  - [Environment Setup](#environment-setup)
    - [Node JS](#node-js)
    - [Firebase CLI](#firebase-cli)
    - [Flutter](#flutter)
    - [Visual Studio Code](#visual-studio-code)
    - [Android Studio](#android-studio)
    - [changelog-from-release](#changelog-from-release)
    - [FastLane](#fastlane)
  - [Create a flutter project](#create-a-flutter-project)
    - [Configure FastLane Lanes](#configure-fastlane-lanes)
  - [`git` utilities](#git-utilities)
    - [checkout](#checkout)
    - [release](#release)
    - [bump](#bump)
    - [`git` conventional commit](#git-conventional-commit)
    - [avoid commit on `main` branch](#avoid-commit-on-main-branch)
    - [example: release a patch](#example-release-a-patch)
  - [Add Firebase to a app flutter project](#add-firebase-to-a-app-flutter-project)
  - [Release app](#release-app)
    - [Sign app](#sign-app)
    - [App Distribution](#app-distribution)
    - [Google Play](#google-play)
  - [Integration Test](#integration-test)
    - [Firebase Test Lab](#firebase-test-lab)
  - [`Firestore` backup, restore and Point-in-time recovery](#firestore-backup-restore-and-point-in-time-recovery)
    - [install gcloud](#install-gcloud)
    - [Restore a Point-in-time Recovery (PITR)](#restore-a-point-in-time-recovery-pitr)
    - [Backup and Restore database](#backup-and-restore-database)
  - [Firebase Hosting](#firebase-hosting)
    - [Deploy default `site`](#deploy-default-site)
    - [Alternative sites](#alternative-sites)
  - [documentation utilities](#documentation-utilities)
  - [Launcher Icon](#launcher-icon)
  - [Splash](#splash)
  - [Dart Builders](#dart-builders)
  - [`webcrypto` setup for tests](#webcrypto-setup-for-tests)
  - [`ffmpeg` utilities](#ffmpeg-utilities)
  - [localization utils](#localization-utils)
  - [command-line utility `version`](#command-line-utility-version)
  
## Installing

- clone the project from github at the same directory of your packages:
  
  ```bash
  git clone https://github.com/heyteacher/flutter_heyteacher_meta.git
  ```

- setup environment following instruction [Environment Setup](#environment-setup)

- configure your projects based on type:
  
  - for packages:
  
    ```bash
    configure_flutter_package.sh
    ```

  - for flutter application

    ```bash
    configure_flutter_app.sh
    ```

- test all works fine, running `fl` will show command avaiable  

## Environment Setup

Instructions for setup environment installing all software needed to develop a
Flutter project.

### Node JS

```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
nvm install 22
```

### Firebase CLI

```bash
npm install -g firebase-tools
```

### Flutter

install flutter manually following instructions <https://docs.flutter.dev/install/quick#install>

- setup your `~/.bashrc` with this env variables

  ```bash
  # flutter
  export PATH=/usr/local/flutter/bin:$PATH

  # dart 
  export PATH="$PATH":"$HOME/.pub-cache/bin"

  # flutter_heyteacher_meta scripts
  export PATH="$PATH":"<INSTALLATION_DIR>flutter_heyteacher_meta/scripts"
  ```

### Visual Studio Code

install `Visual Studio Code` 1.77 or later with the `Flutter extension for VS Code`

### Android Studio

- install  `Android Studio`

- setup your `~/.bashrc` with this env variables and alias

  ```bash
  #android studio
  export ANDROID_HOME="$HOME/Android/Sdk/"
  export PATH="${PATH}:${ANDROID_HOME}tools/:${ANDROID_HOME}platform-tools/"
  export PATH=/usr/local/android-studio/jbr/bin/:$PATH
  ```

### changelog-from-release

- install `go`
  
- install `changelog-from-release`

  ```bash
  go install github.com/rhysd/changelog-from-release/v3@latest
  ```

- set the classpath of go binaries

  ```bash
  export PATH="$PATH":"$HOME/go/bin"  
  ```

- create a github `personal access token` and set on GITHUB_TOKEN env variable

  ```bash
  export GITHUB_TOKEN=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
  ```

- authenticate on `gh` whith the same token

  ```bash
  gh auth login --with-token
  ```

- test the command

  ```bash
  changelog-from-release
  ```

### FastLane

- install rbenv, ruby and bundler

  ```bash
  brew install rbenv
  rbenv init
  rbenv install -l
  rbenv install 3.4.3
  rbenv local 3.4.3
  gem install bundler
  ```

- create Genfile in project root containing:

  ```bash
  source "https://rubygems.org"
  gem "fastlane"
  ```

- install fastlane via bundle

  ```bash
  bundle update
  ```

- setup your `~/.bash_aliases` with this fl alias

  ```bash
  # alias for fastlane inside flutter projects
  alias fl='<PRJ_INSTALLATION_DIR>/flutter_heyteacher_meta/scripts/fl.sh'
  ```

  `fl` is an alias of `fl.sh` command.

```bash
#!/bin/bash
#
# Run FastLane Lanes.
#
# Executed without paramenter show lanes available and documentation 
if [[ -z ${@} ]] 
then
    # show lanes avalilable and documentation
    bundle exec fastlane lanes
else
    # run lane 
    bundle exec fastlane $@
fi  
```

the execution `fl` in root project directory without paramenter show all `lanes` configured and how to use them.

## Create a flutter project

- flutter app project:

  ```bash
  flutter create <app project name>
  ```

- flutter package projects:

  ```bash
  flutter create -t package <app project name>
  ```

### Configure FastLane Lanes

After setup the environment run from root project directory and create the project:

- for flutter packages:

  ```bash
  configure_flutter_package.sh
  ```

- for flutter app
  
  ```bash
  configure_flutter_app.sh
  ```
  
  For utilize firebase backup and app distribution edit
  `./fastlane/Fastfile` uncommenting and setup these environtment variables:

  - `google_storage_backup_bucket` the Google Storage backup bucket name

  - `firebase_app_distribution_service_credentials_file` the Firebase App
     Distribution service credentials file name

## `git` utilities

`checkout` and `release` commands with git `hooks` for `conventional commit` and `avoid commit on main branch` helps you to work properly with versions, git branches, git tags and github releases.

`bump` command commit `pubspec.lock` and `pubspec.yaml`  after a bump version on dependencies without create a new version and without create new release.

### checkout

To checkout the latest remote branch already created remotely (i.e. in `github project` ) run:

```bash
fl checkout
```

This command run a `git fetch` and run a `git chechout` to the latest branch fetched.

### release

After you commit and push your changes into the branch you can release to `main` branch using this command:

```bash
fl release version:major|minor|patch [suffix:<nmenonic_tag_suffix>] [merge:true|false] [github:false|true]
```

- `version`: increments the version into `pubspec.yaml`, for example:
  - `major`: move version from `1.0.0` to `2.0.0`
  - `minor`: move version from `1.0.0` to `1.1.0`
  - `patch`: move version from `1.0.0` to `1.0.1`
- `suffix`: (optional) add a mnemonic suffix to git `tag` greated
- `merge`: (optional, default `true`) make the marge to `main` branch
- `github`: (optional, default `false`) create the github release
and update the `CHANGELOG.md`

These command make several tasks:

- increments the version into `pubspec.yaml`
- create a `github release` and update `CHANGELOG.md` (if `github` param is `true)  
- create a `pull request` and merge changes into `main` branch, checkout the `main` branch and delete the branch merged (if `merge` param is `true)  
- create a git `tag`

There are who checks implemented as `git-hooks`:

- conventional commit
- avoid commit on `main` branch

### bump

```bash
fl bump
```

commits `pubspec.lock` and `pubspec.yaml`  without generate a new version and without create a new release.

### `git` conventional commit

The commit message should follow che [conventional commit](https://www.conventionalcommits.org/en/v1.0.0) specification:

```text
<type>[optional scope]: <description>
```

where `<type>` MUST be one of:

- `build`: Changes that affect the build system or external dependencies (example scopes: gulp, broccoli, npm)
- `chore`: (updating grunt tasks etc; no production code change)
- `ci`: Changes to our CI configuration files and scripts (example scopes: Travis, Circle, BrowserStack, SauceLabs)
- `docs`: Documentation only changes
- `feat`: A new feature
- `fix`: A bug fix
- `perf`: A code change that improves performance
- `refactor`: A code change that neither fixes a bug nor adds a feature
- `style`: Changes that do not affect the meaning of the code (white-space, formatting, missing semi-colons, etc)
- `test`: Adding missing tests or correcting existing tests

### avoid commit on `main` branch

`main` branch is the default branch and user cannot be commit directly on it, but only merge are allowed.

If you try to commit on `main` this message is show

```text
You can't commit directly to main branch
```

### example: release a patch

- if you create an `github issue` and a branch on `github`

  ```bash
  fl checkout
  ```

  otherwise create a branch locally and push it to remote

  ```bash
  git branch hotfix
  git push -u origin hotfix
  ```

- make changes to your code, commit and push changes to branch
  
  ```bash
  git add .
  git commit -m "fix: fix bug ..."
  git push
  ```

- release the patch merging chenges to `main` branch and create a `github release`
  
  ```bash
  fl release version:patch github:true
  ```

## Add Firebase to a app flutter project

- login in firebase and install flutterfire

   ```bash
   firebase login
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```

- add firebase core and other packages

  ```bash
  flutter pub add firebase_core
  flutter pub add firebase_auth
  flutter pub add cloud_firestore
  flutterfire configure
  ```

- initialize firestore, and deploy rules and indexes

  ```bash
  firebase init firestore
  firebase deploy --only firestore
  ```

- build and run application created

  ```bash
  flutter run
  ```

## Release app

### Sign app

- generate upload keystore

  ```bash
  mkdir -p ~/.flutter
  keytool -genkey -v -keystore ~/.flutter/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
  ```

- create `android/key.properties` containing:

  ```properties
  storePassword=<password-from-previous-step>
  keyPassword=<password-from-previous-step>
  keyAlias=upload
  storeFile=<keystore-file-location>
  ```

- configure Gradle following instruction <https://docs.flutter.dev/deployment/android#configure-signing-in-gradle>

- create the ABB file running `flutter build appbundle`. The file created is located here:

  ```properties
  build/app/outputs/bundle/release/app-release.aab
  ```

- extract SHA-1 SHA-256 from keystore

  ```bash
  keytool -list -v -alias upload -keystore ~/.flutter/upload-keystore.jks
  ```

  or directly from `app-release.aab`

  ```bash
  keytool -printcert -jarfile build/app/outputs/bundle/release/app-release.aab 
  ```

- load SHA256 in firebase AppCheck section in (`appcheck/apps`)  (this istructi on doesn't work for <https://firebase.google.com/docs/app-check/android/play-integrity-provider> `Currently, the built-in Play Integrity provider only supports Android apps distributed by Google Play` and <https://stackoverflow.com/a/78698583/1123065>)

- link Google Cloud project to Google Play console follow istructions <https://developer.android.com/google/play/integrity/setup>

### App Distribution
  
- follow istructions <https://firebase.google.com/docs/app-distribution/android/distribute-fastlane?apptype=aab>

- Copy the AppDistribution JSON keys created in google cloud IAM in:
  
  ```bash
  ~/.flutter/<YOUR_PROJECT>-app_distribution.json
  ```

- setup your `~/.bashrc`

  ```bash
  # setup for `Firestore App Distribution` in `~/.flutter/` 
  export GOOGLE_APPLICATION_CREDENTIALS=<path_of_app_distribution_json>
  ```

- run `firebase login:ci` and copy the token generated

- create the file `~/.flutter/firebase_cli_token.json` and paste the token generate in this json:

  ```json
  {
    "firebase_cli_token": "<paste here token generated by 'firebase login:ci'>"
  }
  ```

- run fastlane

  ```bash
  fl.sh distribute
  ```

### Google Play

- create the app and publish for internal test in Google Play following instructions <https://support.google.com/googleplay/android-developer/answer/9859152?hl=en>

- Link Firestore App Distribution to Google Play account following instructions <https://support.google.com/firebase/answer/6392038>

- run fastlane

  ```bash
  ./fl.sh playstore track:production|beta|alpha|internal
  ```

## Integration Test

Follow the instruction <https://github.com/flutter/flutter/tree/main/packages/integration_test>

with this changes:

- `android/gradle/wrapper/gradle-wrapper.properties`

  ```properties
  - distributionUrl=https\://services.gradle.org/distributions/gradle-8.3-all.zip
  + distributionUrl=https\://services.gradle.org/distributions/gradle-8.9-all.zip
  ```

- `android/settings.gradle`

  ```properties
  - id "com.android.application" version "8.1.0" apply false
  + id "com.android.application" version "8.7.0" apply false
  ```

Run locally on device connected:

```bash
flutter test integration_test/main.dart
```

or

```bash
flutter driver --driver=test_driver/main_test.dart --target=integration_test/main.dart 
```

or with `gradlew`

```bash
./gradlew app:connectedAndroidTest -Ptarget=`pwd`/../integration_test/main.dart
```

### Firebase Test Lab

- buid integration test artifacts using scripts `android/firebaseTestLabBuild.sh`, shortcut of:

  ```bash
  ./gradlew app:assembleAndroidTest
  ./gradlew app:assembleDebug -Ptarget=`pwd`/../integration_test/main.dart
  ```

- select device from supported devices:

  ```bash
  gcloud firebase test android models list 
  ```

- you can filter only virtual devices (hight availability, lower cost):

  ```bash
  gcloud firebase test android models list --filter=virtual 
  ```

- start test in Firebase Test Lab on the selected device launching gcloud command. For example, run test in Medium Phone virtual with android 13 (version 33):

  ```bash
  gcloud firebase test android run --type instrumentation --app=../build/app/outputs/apk/debug/app-debug.apk --test=../build/app/outputs/apk/androidTest/debug/app-debug-androidTest.apk --device model=MediumPhone.arm,version=33,locale=en,orientation=portrait
  ```

The lane `fl testlab` run commands above

## `Firestore` backup, restore and Point-in-time recovery

### install gcloud

```bash
sudo apt-get install apt-transport-https ca-certificates gnupg curl
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg
echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
sudo apt-get update && sudo apt-get install google-cloud-cli
```

inizialize configuring your project

```bash
gcloud init
```

create the bucket `<PROJECT_NAME>-backups` which hosts backups here: <https://console.cloud.google.com/storage/browser>

### Restore a Point-in-time Recovery (PITR)

You can restore the database snapshot since last 15 days specifying `snapshot-time` in ISO 8601 format.

```bash
fl backup snapshot:<YYYY-MM-DDTHH:mm:ss.00Z>
# restore the backup <YYYY-MM-DDTHH:mm:ss_mi> already created
fl restore <YYYY-MM-DDTHH:mm:ss_mi>
```

### Backup and Restore database

- create a backup of current firestore database

  ```bash
  fl backup
  ```

- restore a firestore backup

  ```bash
  # list all backups
  fl restore 
  # restore a backup
  fl restore <YYYY-MM-DDTHH:mm:ss_mi>
  ```

- remove a firestore backup

  ```hash
  # list all backups
  fl restore 
  # remove backup
  fl rm <YYYY-MM-DDTHH:mm:ss_mi>
  ```

## Firebase Hosting

Deploy and publish a flutter web app into `Firebase Hosting`.

Default `site`:

- Site Id: `<Firebase Project Id>`
- `Default URL`: `<Firebase Project Id>.web.app` and
  `<Firebase Project Id>.web.firebaseapp.com/`

### Deploy default `site`

- configure `firebase.json` adding hosting configuration
  
  ```json
    "hosting": {
      "public": "build/web",
      "frameworksBackend": {
        "region": "<Firebase Region>"
      }
    }
  ```

- build web and test locally

  ```bash
  fl buildweb [--debug:true]
  ```

- deploy to default `site`

  ```bash
  firebase deploy --only hosting
  ```
  
Default `site` cannot be deleted, you can disable entire hosting:

```bash
firebase hosting:disable
```

### Alternative sites

- define the alternative site
  
  ```bash
  firebase target:apply hosting <Alternative Site Id> <Alternative Site Id>
  ```

- Create the alternative site
  
  ```bash
  firebase hosting:sites:create <Alternative Site Id>
  ```

- configure `firebase.json` adding `target`
  
  ```json
    "hosting": [
      {
        "target": "<Alternative Site Id>",
        "public": "build/web",
        "frameworksBackend": {
          "region": "<Firebase Region>"
        }
      }
    ]
  ```

- deploy to the alternative site

  ```bash
  firebase deploy --only hosting
  ```

To list all sites created:

```bash
firebase hosting:sites:list
```

To delete an alternative site:

```bash
firebase hosting:sites:delete <Alternative Site Id>
```

## documentation utilities

```bash
fl doc
```

Generates dart documentation, run a local web server on `http://localhost:8080` and open a browser on it.

```bash
fl docweb
```

Run a local web server on `http://localhost:8080` and open a browser on project documentation already generatd

## Launcher Icon

- modify 'assets/icon/icon.png' and 'assets/icon/background.png'
- run

  ```bash
  dart run flutter_launcher_icons
  ```

## Splash

- modify 'assets/splash.png'
- run

  ```bash
  flutter_splash.sh
  ```

  an alias of:

  ```bash
  dart run flutter_native_splash:create
  ```

## Dart Builders

The builders like:

- [json_serializable](https://pub.dev/packages/json_serializable)
- [copy_with_extension](https://pub.dev/packages/copy_with_extension)
- [mockito](https://pub.dev/packages/mockito)

can be gererated using script:

```bash
dart_builders.sh
```

## `webcrypto` setup for tests

Flutter tests which use `webcrypto` need to be compiled locally running this command:

```bash
flutter_webcrypto_setup
```

an alias of:

```bash
dart run webcrypto:setup
```

## `ffmpeg` utilities

`ffmpeg_cmd` is a bash script with utilites for `crop`, `cut`, `estract` and `concat`.

```bash
ffmpeg_cmd.sh
```

Usage:

- crop
  
  `ffmpeg_cmd.sh crop <input_video> <output_video> <width_in_px> <height_in_px> <x_in_px> <y_in_px>`

- cut
  
  `ffmpeg_cmd.sh cut  <input_video> <output_video> <start_in_sec> <end_in_sec>`

- extract
  
  `ffmpeg_cmd.sh extract <input_video> <output_video> <start_in_sec> <end_in_sec>`

- concat

  `ffmpeg_cmd.sh concat <input_video_1> <input_video_2> [input_video_3 ...] <output_video> <fade_duration_in_sec>`

## localization utils

- install packages

  ```bash
  flutter pub add flutter_localizations --sdk=flutter
  flutter pub add intl:any
  ```

- modify `pubspec.yaml` setting flutter artifact generation  

  ```yaml
  flutter:
    generate: true
  ```

- in root project creat `l10n.yaml`

  ```yaml
  arb-dir: lib/src/l10n
  template-arb-file: flutter_heyteacher_utils_en.arb
  output-localization-file: flutter_heyteacher_utils.dart
  output-class: FlutterHeyteacherUtilsLocalizations
  output-dir: lib/src/l10n
  untranslated-messages-file: untranslated-messages.txt
  ```

- create the `arb` files of your supported languages

  ```bash
  mkdir lib/l10n
  touch lib/l10n/flutter_heyteacher_utils_en.arb
  touch lib/l10n/flutter_heyteacher_utils_it.arb
  ```

- insert in `flutter_heyteacher_utils_en.arb` the translation

- commit `untranslated-messages.txt` the file containing localized strings to be
  translated, this file should be always empty

  ```bash
  git add untranslated-messages.txt
  git commit -m "chore: localized strings to be translated, this file should be always empty"
  ```

- insert localized string into `flutter_heyteacher_utils_en.arb`

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

- regenerate the artifacts

  ```bash
  flutter pub get
  ```

- create a file `lib/localizations.dart` containing the export

  ```dart
  export 'package:flutter_heyteacher_utils/src/l10n/flutter_heyteacher_utils.dart' show FlutterHeyteacherUtilsLocalizations;
  ```

- add delegate to your app

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

- import and use in your code

  ```dart
  import 'package:flutter_heyteacher_utils/localizations.dart';
  .
  .
  .
  FlutterHeyteacherUtilsLocalizations.of(context)!.userNotAutenticated
  ```

## command-line utility `version`

From the root of your project, run:

```bash
dart run flutter_heyteacher_meta:version major|minor|patch|build|show|show-build [--dry-run]
```

- `major`,`minor`, `patch` increment the version in your `pubsec.yaml`.
  `--dry-run` show how the version will be changed without modify `pubsec.yaml`

- `build` set the build version in your `pubsec.yaml`  to `YYMMddHHm` based on
  the current time.
  
- `dry-run` show how the version will be changed without modify `pubsec.yaml`

- `show` print the version in `pubsec.yaml`

- `show-build` print only the build version from `pubsec.yaml`

You can configure you `vscode` to execute the command with `build` in order to
automatically update build version every run/debug execution of your code:

- create/modify `.vscode/tasks.json` in the root of your project
  
  ```json
  {
        "version": "2.0.0",
        "tasks": [
                {
                        "type": "dart",
                        "command": "dart",
                        "args": [
                                "run",
                                "flutter_heyteacher_meta:version",
                                "build"
                        ],
                        "group": "build",
                        "problemMatcher": [],
                        "label": "dart: run flutter_heyteacher_meta:version build",
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

- add `preLaunchTask` in your launch configurations '.vscode/launch.json'
  
  ```json
  ...
    
    "preLaunchTask": "dart: run flutter_heyteacher_meta:version build"
  ```
