/// A convenience library that exports common Firebase-related utilities.
///
/// This allows for a single import to access various Firebase functionalities
/// configured for the application, such as:
/// - App Check configuration ([AppCheckModel])
/// - Authentication services ([AuthModel], [UserNotAuthenticatedException], 
///   [AccountCard])
/// - Crashlytics configuration ([CrashlyticsModel])
/// - Remote Config configuration ([RemoteConfigModel])
library;

export 'src/firebase/app_check.dart' show AppCheckModelView;
export 'src/firebase/auth.dart'
    show AuthModelView, UserNotAuthenticatedException, AccountCard;
export 'src/firebase/crashlytics.dart' show CrashlyticsModelView;
export 'src/firebase/remote_config.dart' show RemoteConfigModel;
