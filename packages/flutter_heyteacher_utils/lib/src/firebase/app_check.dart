/// Configures and activates Firebase App Check for the application.
///
/// Firebase App Check helps protect backend resources from abuse, such as billing
/// fraud or phishing, by ensuring that incoming requests originate from authentic
/// app instances. This library sets up App Check with appropriate providers
/// for web, Android, and Apple platforms.
library;

import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:logging/logging.dart';
import 'package:flutter/foundation.dart';

class AppCheckModel {
  final log = Logger("AppCheckModel");

  static AppCheckModel? _instance;
  AppCheckModel._();

  /// Provides the singleton instance of [AppCheckModel].
  static AppCheckModel get instance => _instance ??= AppCheckModel._();

  /// Initializes and activates Firebase App Check with platform-specific providers.
  ///
  /// - For web, it uses `ReCaptchaV3Provider` with a site key fetched from Firebase Remote Config.
  /// - For Android, it uses `AndroidProvider.playIntegrity` in release mode and `AndroidProvider.debug` in debug mode.
  /// - For Apple platforms (iOS/macOS), it uses `AppleProvider.appAttest`.
  Future<void> initialize() async {
    AndroidProvider androidProvider =
        kDebugMode ? AndroidProvider.debug : AndroidProvider.playIntegrity;

    // in debug mode, uncomment for test permission denied error in firesotre forcing playIntegrity
    //AndroidProvider androidProvider = AndroidProvider.playIntegrity;

    log.info("androidProvider $androidProvider");

    await FirebaseAppCheck.instance.activate(
      // You can also use 6a `ReCaptchaEnterpriseProvider` provider instance as an
      // argument for `webProvider`
      webProvider: ReCaptchaV3Provider(FirebaseRemoteConfig.instance
          .getString("appCheckReCaptchaV3SiteKey")),
      // Default provider for Android is the Play Integrity provider. You can use the "AndroidProvider" enum to choose
      // your preferred provider. Choose from:
      // 1. Debug provider
      // 2. Safety Net provider
      // 3. Play Integrity provider
      androidProvider: androidProvider,
      // Default provider for iOS/macOS is the Device Check provider. You can use the "AppleProvider" enum to choose
      // your preferred provider. Choose from:
      // 1. Debug provider
      // 2. Device Check provider
      // 3. App Attest provider
      // 4. App Attest provider with fallback to Device Check provider (App Attest provider is only available on iOS 14.0+, macOS 14.0+)
      appleProvider: AppleProvider.appAttest,
    );
  }
}
