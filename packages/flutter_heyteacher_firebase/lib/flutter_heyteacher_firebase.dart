/// A convenience library that exports common Firebase-related utilities.
///
/// This allows for a single import to access various Firebase functionalities
/// configured for the application, such as:
/// - App Check configuration ([AppCheckViewModel])
/// - Crashlytics configuration ([CrashlyticsViewModel])
/// - Remote Config configuration ([RemoteConfigViewModel])
/// - Firebase Storage upload utilities ([StorageViewModel])
/// - Firebase Cloud Messaging utilies ([FirebaseCloudMessagingViewModel])
library;

import 'package:flutter_heyteacher_firebase/src/firebase/app_check.dart';
import 'package:flutter_heyteacher_firebase/src/firebase/cloud_messaging.dart';
import 'package:flutter_heyteacher_firebase/src/firebase/crashlytics.dart';
import 'package:flutter_heyteacher_firebase/src/firebase/remote_config.dart';
import 'package:flutter_heyteacher_firebase/src/firebase/storage.dart';

export 'src/firebase/app_check.dart' show AppCheckViewModel;
export 'src/firebase/cloud_messaging.dart' show FirebaseCloudMessagingViewModel;
export 'src/firebase/crashlytics.dart' show CrashlyticsViewModel;
export 'src/firebase/google_analytics.dart' show GoogleAnalitycsViewModel;
export 'src/firebase/remote_config.dart'
    show
        RemoteConfigViewModel;
export 'src/firebase/storage.dart' show StorageViewModel;
