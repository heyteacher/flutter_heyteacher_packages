# Flutter Heyteacher Meta

A Flutter meta project implementing utilities and best practices for Flutter `package` and `app` project avoiding `Copy & Paste` pattern.

- environment setup instructions for `app` and `package` projects and `Firebase` setup `app` projects
- `git` utilities for manage versions and releases
- release app in `Google Play` and `Firebase App Distribution`
- integration test and `Firebase Test Lab` utilities
- backup and restore `Firestore` utilities
- `localization` setup instructions
- documentation utilities
- `Launcher Icon`, `Splash`, `dart builder`, `ffmpeg`, `webcrypto` utilities

## Table of Contents

- [Flutter Heyteacher Meta](#flutter-heyteacher-meta)
  - [Table of Contents](#table-of-contents)
  - [Installing](#installing)
  - [Credits](#credits)
  - [Requirements](#requirements)
  - [Environment Setup](#environment-setup)
    - [Flutter](#flutter)
    - [Visual Studio Code](#visual-studio-code)
    - [Android Studio](#android-studio)
    - [`git-cliff`](#git-cliff)
    - [`FastLane`](#fastlane)
    - [`nodeJs`](#nodejs)
    - [Firebase CLI](#firebase-cli)
  - [Create a flutter project](#create-a-flutter-project)
    - [Configure `FastLane`](#configure-fastlane)
  - [`Fastlane` lines for `app` and `package` projects](#fastlane-lines-for-app-and-package-projects)
    - [doc](#doc)
    - [docweb](#docweb)
    - [test](#test)
    - [checkout](#checkout)
    - [release](#release)
    - [github\_release](#github_release)
    - [bump](#bump)
  - [`Fastlane` lines for `app` projects](#fastlane-lines-for-app-projects)
    - [appbundle](#appbundle)
    - [integration\_test](#integration_test)
    - [testlab](#testlab)
    - [firestore\_backup](#firestore_backup)
    - [firestore\_restore](#firestore_restore)
    - [firestore\_remove\_backup](#firestore_remove_backup)
    - [app\_distribution](#app_distribution)
    - [playstore](#playstore)
    - [playstore\_promote](#playstore_promote)
    - [buildweb](#buildweb)
    - [deployweb](#deployweb)
  - [`git` utilities](#git-utilities)
    - [`git` conventional commit](#git-conventional-commit)
    - [avoid commit on `main` branch](#avoid-commit-on-main-branch)
    - [example: release a patch](#example-release-a-patch)
  - [`Firebase` setup for `app` flutter project](#firebase-setup-for-app-flutter-project)
  - [Release app](#release-app)
    - [Sign app](#sign-app)
    - [Firebase App Distribution](#firebase-app-distribution)
    - [Google Play](#google-play)
  - [Integration Test](#integration-test)
    - [Firebase Test Lab](#firebase-test-lab)
  - [`Firestore` backup, restore and Point-in-time recovery](#firestore-backup-restore-and-point-in-time-recovery)
    - [install `gcloud`](#install-gcloud)
    - [Restore a Point-in-time Recovery (PITR)](#restore-a-point-in-time-recovery-pitr)
    - [Backup and Restore database](#backup-and-restore-database)
  - [Firebase Hosting](#firebase-hosting)
    - [Deploy default `site`](#deploy-default-site)
    - [Alternative sites](#alternative-sites)
  - [`localization` setup](#localization-setup)
  - [documentation utilities](#documentation-utilities)
  - [Launcher Icon](#launcher-icon)
  - [Splash](#splash)
  - [Dart Builders](#dart-builders)
  - [`ffmpeg` utilities](#ffmpeg-utilities)
  - [command-line utility `version`](#command-line-utility-version)
  - [`webcrypto` setup for tests](#webcrypto-setup-for-tests)
  
## Installing

- setup environment following instruction [Environment Setup](#environment-setup)

- install `flutter_heyteacher_meta` as dev package into your `app` or `package` project:
  
  ```bash
  flutter pub add dev:flutter_heyteacher_meta
  ```

  or add to your `pubspec.yaml`

  ```yaml
  dev_dependencies:
    flutter_heyteacher_meta: 
  ```

- follow instuctions in [Configure `FastLane`](#configure-fastlane) in order to configure a `app` or `package` project.

- test all works fine, running `fl` will show command avaiable

## Credits

- [yaml_edit](https://pub.dev/packages/yaml_edit): A library for YAML manipulation while preserving comments

- [very_good_analysis](https://pub.dev/packages/very_good_analysis): This package provides lint rules for Dart and Flutter which are used at `Very Good Ventures`

- [git-cliff](https://git-cliff.org/): Command line tool for generating a changelog from git tags and commit history

- [vscode-markdownlint](https://github.com/DavidAnson/vscode-markdownlint): Markdown/CommonMark linting and style checking for Visual Studio Code

- [vscode-markdown](https://github.com/yzhang-gh/vscode-markdown): All you need for Markdown (keyboard shortcuts, table of contents, auto preview and more).

## Requirements

- a shell terminal on `Linux`, `MacOS` or [WSL](https://learn.microsoft.com/en-us/windows/wsl/install) on `Windows`

- `git` 1.7.2 or later

- a `GitHub` account

- `gh` 2.46.0 or later (GitHub CLI)

- other software and utilities as described in [Environment Setup](#environment-setup)

## Environment Setup

Instructions for setup environment installing all software needed to develop a `Flutter` project.

### Flutter

install flutter manually following instructions <https://docs.flutter.dev/install/quick#install>

- setup your `~/.bashrc` with this env variables

  ```bash
  # flutter
  export PATH=/usr/local/flutter/bin:$PATH

  # dart 
  export PATH="$HOME/.pub-cache/bin":$PATH

  # flutter_heyteacher_meta tool
  latest_meta_version=`ls $HOME/.pub-cache/hosted/pub.dev | grep flutter_heyteacher_meta |  tail -n 1`
  project_meta_root="$HOME/.pub-cache/hosted/pub.dev/$latest_meta_version"
  export PATH="$project_meta_root/tool":$PATH
  ```

### Visual Studio Code

install `Visual Studio Code` 1.77 or later with the `Flutter extension for VS Code`

You can configure you `vscode` to execute the [command-line utility `version`](#command-line-utility-version) in order to automatically update build version every run/debug execution of your code:

- install `flutter_heyteacher_meta` package as dev dependency ad described in [Installing](#installing)

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
                                "dartsemver",
                                "build"
                        ],
                        "group": "build",
                        "problemMatcher": [],
                        "label": "dart: run dartsemver build",
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
    
    "preLaunchTask": "dart: run flutter_heyteacher_meta:dartsemver build"
  ```

### Android Studio

- install  `Android Studio`

- setup your `~/.bashrc` with this env variables and alias

  ```bash
  #android studio
  export ANDROID_HOME="$HOME/Android/Sdk/"
  export PATH="${PATH}:${ANDROID_HOME}tools/:${ANDROID_HOME}platform-tools/"
  export PATH=/usr/local/android-studio/jbr/bin/:$PATH
  ```

### `git-cliff`

[git-cliff](https://git-cliff.org/) is an utility which generate `CHANGELOG.md` automatically based
on git `commits` and `tags`.

- install `npm` as described in [`nodeJs`](#nodejs)

- install `git-cliff`

  ```bash
  npm install -g git-cliff
  ```

- test the command

  ```bash
  git-cliff --help
  ```

### `FastLane`

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
  alias fl='fl.sh'
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

### `nodeJs`

- install `nodeJs`
  
  ```bash
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
  nvm install 22
  ```

### Firebase CLI

- install `firebase-tools`

  ```bash
  npm install -g firebase-tools
  ```

## Create a flutter project

- flutter app project:

  ```bash
  flutter create <app project name>
  ```

- flutter package projects:

  ```bash
  flutter create -t package <app project name>
  ```

### Configure `FastLane`

After setup the environment run from root project directory and create the project:

- for flutter packages:

  ```bash
  configure_flutter_package.sh
  ```

- for flutter app
  
  ```bash
  configure_flutter_app.sh
  ```
  
  This scripts create a skeleton of `fastlane/metadata` mandatory for release
  application in `Google Play`. So, before release the application you need to:
  
  - edit `fastlane/metadata/android/en-US/title.txt`
  
  - edit `fastlane/metadata/android/en-US/short_description.txt`
  
  - edit `fastlane/metadata/android/en-US/full_description.txt`
  
  - edit `fastlane/metadata/android/en-US/video.txt`
  
  - edit `fastlane/metadata/android/en-US/changelogs/default.txt`
  
  - edit `fastlane/metadata/android/en-US/images/icon.png`
  
  - edit `fastlane/metadata/android/en-US/images/featureGraphic.png`
  
  - add screenshots to `fastlane/metadata/android/en-US/images/phoneScreenshots`

  For utilize `Firebase Firestore` backup and restore utilities, edit
  `./fastlane/Fastfile` uncommenting and setup these environment variable:

  - `google_storage_backup_bucket` the Google Storage backup bucket name

  For utilize `Firebase App Distribution`, edit
  `./fastlane/Fastfile` uncommenting and setup these environment variable:

  - `firebase_app_distribution_service_credentials_file` the `Firebase App Distribution` service credentials file name

## `Fastlane` lines for `app` and `package` projects

Common `Fastlane` lines are provided to `app` and `package` projects. In details:

- generate dart documentation
- checkout and release on `github`
- run unit test

### doc

```bash
fl doc
```

Generate the `dart` documentation and run webserver on `http://localhost:8080`

### docweb

```bash
fl docweb
```

Runs local webserver on `http://localhost:8080`  with `dart` documentation

### test

```bash
fl test
```

Run unit tests of the project.

### checkout

```bash
fl checkout
```

Checkout the latest remote branch already created remotely (i.e. in `github project` ).

Runs `git fetch` and `git checkout` to the latest branch fetched.

### release

```bash
fl release semver:major|minor|patch [suffix:<nmenonic_tag_suffix>] [merge:true|false] [github:false|true]
```

Release to `main` branch after you commit and push your changes into your branch.

- `semver`: increments the version into `pubspec.yaml` following [Semantic Versioning](https://semver.org/), for example:
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
- create a `pull request` and merge changes into `main` branch
- checkout the `main` branch
- delete the branch merged (if `merge` param is `true)  
- create a git `tag` named `{package-name}-{version}`

### github_release

```bash
fl github_release
```

Create a `github release` and update `CHANGELOG.md`

### bump

```bash
fl bump
```

Commits `pubspec.lock` and `pubspec.yaml`  without generate a new version and without create a new release.

Creates a `github` release and update `CHANGELOG.md`

## `Fastlane` lines for `app` projects

Specific `Fastlane` lines are provided for `app`  projects. In details:

- build `AAB`
- run integration test locally or on `Firebase Test Lab`
- backup and restore `Firestore` dababase
- release application in `Google Play` and `Firebase App Distribution`
- build and release web application in `Firebase Hosting`

### appbundle

```bash
fl appbundle
```

Clean and build the application.

When completed, the `AAB` is generate into `build/app/outputs/bundle/release/app-release.aab`.

### integration_test

```bash
fl integration_test
```

Run integration tests of app project.

### testlab

```bash
fl testlab
```

Run integration test of app project in `Firebase Test Lab`

### firestore_backup

```bash
fl firestore_backup [snapshot:YYYY-MM-DDTHH:mm:ss.00Z] [database:<database>]
```

Backup `Firestore` dababase. if `snapshot` is set, create backup at time specified. If `database` isn't set use `(default)`. For details [`Firestore` backup, restore and Point-in-time recovery](#firestore-backup-restore-and-point-in-time-recovery).

### firestore_restore

```bash
fl firestore_restore backup:<YYYY-MM-DDTHH:mm:ss_mi> [database:<database>]
 ```

Restore `Firestore` dababase to specified `backup`. If `database` isn't set use `(default)`.
For details [`Firestore` backup, restore and Point-in-time recovery](#firestore-backup-restore-and-point-in-time-recovery).

### firestore_remove_backup

```bash
fl firestore_remove_backup backup:<YYYY-MM-DDTHH:mm:ss_mi>
```

Remove `Firestore` dababase `backup` specified.
For details [`Firestore` backup, restore and Point-in-time recovery](#firestore-backup-restore-and-point-in-time-recovery).

### app_distribution

```bash
fl app_distribution
```

Build the release and publish app in `Google Play` via `Firebase App Distribution`

### playstore

```bash
fl playstore track:production|beta|alpha|internal [upload_only:true|false]
```

Upload app in `Google Play` via `supply` on `track`. if `upload_only` is `true` upload app without build. (default `false`)

### playstore_promote

```bash
fl playstore_promote from_track:beta|alpha|internal to_track:production|beta|alpha|internal
```

Promote a release in Google Play via `supply` from `from_track` to `to_track`.

### buildweb

```bash
fl buildweb [version:profile|debug]
```

Build web and run local webserver on `http://localhost:8080`

### deployweb

```bash
fl deployweb [release_type:release|profile|debug]
```

Deploy web in `Firabase Hosting` with release type `release_type` (default `release`)

## `git` utilities

[checkout](#checkout) and [release](#release) commands with git `hooks` for [`git` conventional commit](#git-conventional-commit) and [avoid commit on `main` branch](#avoid-commit-on-main-branch) helps you to work properly with versions, git branches, git tags and github releases.

[bump](#bump) command commit `pubspec.lock` and `pubspec.yaml`  after a bump version on dependencies without create a new version and without create new release.

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

## `Firebase` setup for `app` flutter project

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

- load SHA256 in firebase AppCheck section in (`appcheck/apps`)  (this istruction doesn't work for <https://firebase.google.com/docs/app-check/android/play-integrity-provider> `Currently, the built-in Play Integrity provider only supports Android apps distributed by Google Play` and <https://stackoverflow.com/a/78698583/1123065>)

- link Google Cloud project to Google Play console follow istructions <https://developer.android.com/google/play/integrity/setup>

### Firebase App Distribution
  
- follow istructions <https://firebase.google.com/docs/app-distribution/android/distribute-fastlane?apptype=aab>

- Copy the AppDistribution JSON keys created in google cloud IAM in:
  
  ```bash
  ~/.flutter/<YOUR_PROJECT>-app_distribution.json
  ```

- setup your `~/.bashrc`

  ```bash
  # setup for `Firebase App Distribution` in `~/.flutter/` 
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

- Link Firebase App Distribution to Google Play account following instructions <https://support.google.com/firebase/answer/6392038>

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

### install `gcloud`

With `Google Cloud CLI` you can manage command line `Gogle Cloud` services.

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
fl firestore_backup snapshot:<YYYY-MM-DDTHH:mm:ss.00Z>
# restore the backup <YYYY-MM-DDTHH:mm:ss_mi> already created
fl firestore_restore <YYYY-MM-DDTHH:mm:ss_mi>
```

### Backup and Restore database

- create a backup of current firestore database

  ```bash
  fl firestore_backup
  ```

- restore a firestore backup

  ```bash
  # list all backups
  fl firestore_restore 
  # restore a backup
  fl firestore_restore <YYYY-MM-DDTHH:mm:ss_mi>
  ```

- remove a firestore backup

  ```hash
  # list all backups
  fl firestore_restore 
  # remove backup
  fl firestore_remove_backup <YYYY-MM-DDTHH:mm:ss_mi>
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

## `localization` setup

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
  template-arb-file: flutter_heyteacher_locale_en.arb
  output-localization-file: flutter_heyteacher_locale.dart
  output-class: FlutterHeyteacherLocaleLocalizations
  output-dir: lib/src/l10n
  untranslated-messages-file: untranslated-messages.txt
  ```

- create the `arb` files of your supported languages

  ```bash
  mkdir lib/l10n
  touch lib/l10n/flutter_heyteacher_locale_en.arb
  touch lib/l10n/flutter_heyteacher_locale_it.arb
  ```

- insert in `flutter_heyteacher_locale_en.arb` the translation

- commit `untranslated-messages.txt` the file containing localized strings to be
  translated, this file should be always empty

  ```bash
  git add untranslated-messages.txt
  git commit -m "chore: localized strings to be translated, this file should be always empty"
  ```

- insert localized string into `flutter_heyteacher_locale_en.arb`

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
  export 'package:flutter_heyteacher_locale/src/l10n/flutter_heyteacher_locale.dart' show FlutterHeyteacherLocaleLocalizations;
  ```

- add delegate to your app

  ```dart
  MaterialApp.router(
    localizationsDelegates: [
      .
      .
      .
      FlutterHeyteacherLocaleLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],

  )
  ```

- import and use in your code

  ```dart
  import 'package:flutter_heyteacher_locale/localizations.dart';
  .
  .
  .
  FlutterHeyteacherLocaleLocalizations.of(context)!.userNotAutenticated
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

- install [flutter_launcher_icons](https://pub.dev/packages/flutter_launcher_icons)
  
  ```bash
  flutter pub add flutter_launcher_icons
  ```
  
- create or modify 'assets/icon/icon.png' and 'assets/icon/background.png'

- add configuration to `pubspec.yaml`

```yaml
flutter_launcher_icons:
  android: "launcher_icon"
  ios: false
  remove_alpha_ios: true
  image_path: "assets/icon/icon.png"
  min_sdk_android: 21 # android min sdk min:16, default 21
  adaptive_icon_background: "assets/icon/background.png"
  adaptive_icon_foreground: "assets/icon/icon.png"
  web:
    generate: true
    image_path: "assets/icon/icon.png"
    background_color: "#000000"
    theme_color: "#000000"
  windows:
    generate: true
    image_path: "assets/icon/icon.png"
    icon_size: 48 # min:48, max:256, default: 48
  macos:
    generate: true 
    image_path: "assets/icon/icon.png"
```

- run

  ```bash
  dart run flutter_launcher_icons
  ```

## Splash

- install [flutter_native_splash)](https://pub.dev/packages/flutter_native_splash)
  
  ```bash
  flutter pub add flutter_native_splash
  ```

- create or modify 'assets/splash.png'

 add configuration to `pubspec.yaml`

  ```yaml
  flutter_native_splash:
  color: "#000000"
  image: assets/splash.png
  android_12:
    image: assets/splash.png
    color: "#000000"  
  ```

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

## command-line utility `version`

From the root of your project, run:

```bash
dart run flutter_heyteacher_meta:dartsemver major|minor|patch|build|show|show-build [--dry-run]
```

- `major`,`minor`, `patch` increment the version in your `pubsec.yaml`.
  `--dry-run` show how the version will be changed without modify `pubsec.yaml`

- `build` set the build version in your `pubsec.yaml`  to `YYMMddHHm` based on
  the current time.
  
- `dry-run` show how the version will be changed without modify `pubsec.yaml`

- `show` print the version in `pubsec.yaml`

- `show-build` print only the build version from `pubsec.yaml`

## `webcrypto` setup for tests

Flutter tests which use `webcrypto` need to be compiled locally running this command:

```bash
flutter_webcrypto_setup
```

an alias of:

```bash
dart run webcrypto:setup
```
