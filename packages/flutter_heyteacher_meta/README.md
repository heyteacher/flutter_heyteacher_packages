# Flutter Heyteacher Fastlane

Utilities for configure flutter projects importing common or app `FastLane`.
lanes.

After setup the environment run from root project directory:

* for libraries flutter projects:

  ```bash
  install_common_lanes.sh
  ```

* for android app flutter projects
  
  ```bash
  install_app_lanes.sh
  ```
  
  For utilize firebase backup and app distribution edit
  `./fastlane/Fastfile` uncommenting and setup these environtment variables:

  * `google_storage_backup_bucket` the Google Storage backup bucket name

  * `firebase_app_distribution_service_credentials_file` the Firebase App
     Distribution service credentials file name
  
## environment setup

Instructions for setup environment installing all software needed to develop a
Flutter project.

### installation

* install `nodejs` and `firebase CLI`

   ```bash
   curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
   nvm install 22
   npm install -g firebase-tools
   ```

* install `Visual Studio Code` 1.77 or later with the `Flutter extension for VS Code`
  
* install  `Android Studio`

* setup your `~/.bashrc` with this env variables and alias

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

* setup your `~/.bash_aliases` with this fl alias

  ```bash
  # alias for fastlane inside flutter projects
  alias fl='<PRJ_INSTALLATION_DIR>/flutter_heyteacher_fastlane/scripts/fl.sh'
  ```

### create and configure the flutter project in firebase

Create a `flutter project application` in `vs code`

* login in firebase and install flutterfire

   ```bash
   firebase login
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```

* add firebase core and other packages

  ```bash
  flutter pub add firebase_core
  flutter pub add firebase_auth
  flutter pub add cloud_firestore
  flutterfire configure
  ```

* initialize firestore, and deploy rules and indexes

  ```bash
  firebase init firestore
  firebase deploy --only firestore
  ```

* build and run application created

  ```bash
  flutter run
  ```

### fastlane

* install rbenv, ruby and bundler

  ```bash
  brew install rbenv
  rbenv init
  rbenv install -l
  rbenv install 3.3.6
  rbenv local 3.3.6
  gem install bundler
  ```

* create Genfile in project root containing:

  ```bash
  source "https://rubygems.org"
  gem "fastlane"
  ```

* install fastlane via bundle

  ```bash
  bundle update
  ```

### run

`fl` is an alias of `fl.sh` command:

```bash
if [ -z "$@" ] 
then
    bundle exec fastlane lanes
else
    bundle exec fastlane $@
```

the execution `fl` in root project directory without paramenter show all `lanes` configured and how to use them:

```bash
----- fastlane android test
fl test
        Run tests

----- fastlane android launch
fl launch
        launch on device

----- fastlane android bundle
fl bundle
        clean and build new version flutter artifacts

----- fastlane android appbundle
fl appbundle
        clean and build application `build/app/outputs/bundle/release/app-release.aab`

----- fastlane android integration_test
fl integration_test
        Run integration tests

----- fastlane android testlab
fl testlab
        Run integration test in Firebase Test Lab

----- fastlane android backup
fl backup
        backup [snapshot:YYYY-MM-DDTHH:mm:ss.00Z] firestore

----- fastlane android restore
fl restore backup:<YYYY-MM-DDTHH:mm:ss_mi>
        restore firestore backup

----- fastlane android rm
fl rm backup:<YYYY-MM-DDTHH:mm:ss_mi>
        delete firestore backup

----- fastlane android release
fl release version:mayor|minor|patch [suffix:<nmenonic_tag_suffix>]
        release e version tagging in git

----- fastlane android playstore
fl playstore track:production|beta|alpha|internal
        upload app to Google Play via `supply`

----- fastlane android app_distribution
fl app_distribution
        build the release and publish app in Google Play via `Firebase App Distribution`
```
