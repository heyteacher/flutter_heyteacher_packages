/// A convenience library that exports common Firebase-related utilities.
///
/// This allows for a single import to access various Firebase functionalities
/// configured for the application, such as:
/// - App Check configuration ([configureAppCheck])
/// - Authentication services ([Auth], [UserNotAuthenticatedException])
/// - Crashlytics configuration ([configureCrashlytics])
/// - Remote Config configuration ([configureRemoteConfig])
library;

export 'src/firebase/app_check.dart' show AppCheckModel;
export 'src/firebase/auth.dart' show AuthModel, UserNotAuthenticatedException;
export 'src/firebase/crashlytics.dart' show CrashlyticsModel;
export 'src/firebase/remote_config.dart' show  RemoteConfigModel;