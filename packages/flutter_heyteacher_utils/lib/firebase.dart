/// A convenience library that exports common Firebase-related utilities.
///
/// This allows for a single import to access various Firebase functionalities
/// configured for the application, such as:
/// - App Check configuration ([AppCheckViewModel])
/// - Authentication services ([AuthViewModel], [UserNotAuthenticatedException],
///   [AccountCard])
/// - Crashlytics configuration ([CrashlyticsViewModel])
/// - Remote Config configuration ([RemoteConfigViewModel])
/// - Firebase Storage upload utilities ([StorageViewModel])
/// - Firebase Cloud Messaging utilies ([FirebaseCloudMessagingViewModel])
library;

import 'package:flutter_heyteacher_utils/src/firebase/app_check.dart';
import 'package:flutter_heyteacher_utils/src/firebase/auth.dart';
import 'package:flutter_heyteacher_utils/src/firebase/cloud_messaging.dart';
import 'package:flutter_heyteacher_utils/src/firebase/crashlytics.dart';
import 'package:flutter_heyteacher_utils/src/firebase/remote_config.dart';
import 'package:flutter_heyteacher_utils/src/firebase/storage.dart';

export 'src/firebase/app_check.dart' show AppCheckViewModel;
export 'src/firebase/auth.dart'
    show AccountCard, AuthViewModel, UserNotAuthenticatedException;
export 'src/firebase/cloud_messaging.dart' show FirebaseCloudMessagingViewModel;
export 'src/firebase/crashlytics.dart' show CrashlyticsViewModel;
export 'src/firebase/google_analytics.dart' show GoogleAnalitycsViewModel;
export 'src/firebase/remote_config.dart'
    show FHURemoteConfigKeys, RemoteConfigViewModel;
export 'src/firebase/storage.dart' show StorageViewModel;
