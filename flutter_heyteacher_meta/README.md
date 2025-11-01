# Flutter Heyteacher Fastlane

Utilities for configure environment for flutter projects and importing common and app `FastLane` lanes.

## Table of Contents

- [Flutter Heyteacher Fastlane](#flutter-heyteacher-fastlane)
  - [Table of Contents](#table-of-contents)
  - [FastLane lanes](#fastlane-lanes)
  - [Environment Setup](#environment-setup)
    - [`Visual Studio Code`, `Android Studio` and `Node JS` Installation](#visual-studio-code-android-studio-and-node-js-installation)
    - [Firebase](#firebase)
    - [FastLane](#fastlane)
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
  - [Launcher Icon](#launcher-icon)
  - [Splash](#splash)
  - [JSON serializable](#json-serializable)

## FastLane lanes

After setup the environment run from root project directory:

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
  
## Environment Setup

Instructions for setup environment installing all software needed to develop a
Flutter project.

### `Visual Studio Code`, `Android Studio` and `Node JS` Installation

- install `nodejs` and `firebase CLI`

   ```bash
   curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
   nvm install 22
   npm install -g firebase-tools
   ```

- install `Visual Studio Code` 1.77 or later with the `Flutter extension for VS Code`
  
- install  `Android Studio`

- setup your `~/.bashrc` with this env variables and alias

  ```bash
  #android studio
  export ANDROID_HOME="$HOME/Android/Sdk/"
  export PATH="${PATH}:${ANDROID_HOME}tools/:${ANDROID_HOME}platform-tools/"
  export PATH=/usr/local/android-studio/jbr/bin/:$PATH

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

- setup your `~/.bash_aliases` with this fl alias

  ```bash
  # alias for fastlane inside flutter projects
  alias fl='<PRJ_INSTALLATION_DIR>/flutter_heyteacher_fastlane/scripts/fl.sh'
  ```

### Firebase

Create a `flutter project application` in `vs code`

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

`fl` is an alias of `fl.sh` command:

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

## JSON serializable

- <https://pub.dev/packages/json_serializable>

- command to generate artifacts

  ```bash
  dart run build_runner build
  ```
