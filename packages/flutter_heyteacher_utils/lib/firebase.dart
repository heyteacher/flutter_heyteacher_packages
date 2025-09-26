/// A convenience library that exports common Firebase-related utilities.
///
/// This allows for a single import to access various Firebase functionalities
/// configured for the application, such as:
/// - App Check configuration ([AppCheckModel])
/// - Authentication services ([AuthModel], [UserNotAuthenticatedException], 
///   [AccountCard])
/// - Crashlytics configuration ([CrashlyticsModel])
/// - Remote Config configuration ([RemoteConfigModel])
/// - Firebase Storage upload utilities ([StorageViewModel])
/// - Firebase Cloud Messaging utilies ([FirebaseCloudMessagingViewModel])
library;

export 'src/firebase/app_check.dart' show AppCheckViewModel;
export 'src/firebase/auth.dart'
    show AuthViewModel, UserNotAuthenticatedException, AccountCard;
export 'src/firebase/crashlytics.dart' show CrashlyticsViewModel;
export 'src/firebase/remote_config.dart' show RemoteConfigViewModel;
export 'src/firebase/storage.dart' show StorageViewModel;
export 'src/firebase/cloud_messaging.dart'
    show
        FirebaseCloudMessagingViewModel,
        FCMSharedPreferencesKeys,
        FCMRemoteConfigKeys;
