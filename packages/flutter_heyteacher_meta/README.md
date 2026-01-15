# Flutter Heyteacher Fastlane

Utilities for configure environment for flutter projects and importing common and app `FastLane` lanes.

## Table of Contents

- [Flutter Heyteacher Fastlane](#flutter-heyteacher-fastlane)
  - [Table of Contents](#table-of-contents)
  - [Environment Setup](#environment-setup)
    - [`Node JS`](#node-js)
    - [`firebase CLI`](#firebase-cli)
    - [`Flutter`](#flutter)
    - [`Visual Studio Code`](#visual-studio-code)
    - [`Android Studio`](#android-studio)
    - [FastLane](#fastlane)
  - [Create a flutter project](#create-a-flutter-project)
    - [Configure FastLane Lanes](#configure-fastlane-lanes)
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
  - [Launcher Icon](#launcher-icon)
  - [Splash](#splash)
  - [Dart Builders](#dart-builders)
  
## Environment Setup

Instructions for setup environment installing all software needed to develop a
Flutter project.

### `Node JS`

```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
nvm install 22
```

### `firebase CLI`

```bash
npm install -g firebase-tools
```

### `Flutter`

install flutter manually following instructions <https://docs.flutter.dev/install/quick#install>

- setup your `~/.bashrc` with this env variables

  ```bash
  # flutter
  export PATH=/usr/local/flutter/bin:$PATH

  #dart 
  export PATH="$PATH":"$HOME/.pub-cache/bin"

  #flutter_heyteacher_fastlane scripts
  export PATH="$PATH":"<INSTALLATION_DIR>flutter_heyteacher_fastlane/scripts"

  # flutter mapbox token for maven compiler created here https://console.mapbox.com/account/access-tokens/
  export SDK_REGISTRY_TOKEN=<public_token>

  # setup for `Firestore App Distribution` in `~/.flutter/` 
  export GOOGLE_APPLICATION_CREDENTIALS=<path_of_app_distribution_json>
  ```

### `Visual Studio Code`

install `Visual Studio Code` 1.77 or later with the `Flutter extension for VS Code`

### `Android Studio`

- install  `Android Studio`

- setup your `~/.bashrc` with this env variables and alias

  ```bash
  #android studio
  export ANDROID_HOME="$HOME/Android/Sdk/"
  export PATH="${PATH}:${ANDROID_HOME}tools/:${ANDROID_HOME}platform-tools/"
  export PATH=/usr/local/android-studio/jbr/bin/:$PATH
  ```

### FastLane

- install rbenv, ruby and bundler

  ```bash
  brew install rbenv
  rbenv init
  rbenv install -l
  rbenv install 3.3.6
  rbenv local 3.3.6
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
  alias fl='<PRJ_INSTALLATION_DIR>/flutter_heyteacher_fastlane/scripts/fl.sh'
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

- for libraries flutter projects:

  ```bash
  install_common_lanes.sh
  ```

- for android app flutter projects
  
  ```bash
  install_app_lanes.sh
  ```
  
  For utilize firebase backup and app distribution edit
  `./fastlane/Fastfile` uncommenting and setup these environtment variables:

  - `google_storage_backup_bucket` the Google Storage backup bucket name

  - `firebase_app_distribution_service_credentials_file` the Firebase App
     Distribution service credentials file name

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
