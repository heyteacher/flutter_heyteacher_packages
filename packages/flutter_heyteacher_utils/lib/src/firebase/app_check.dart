/// Configures and activates Firebase App Check for the application.
///
/// Firebase App Check helps protect backend resources from abuse, such as 
/// billing fraud or phishing, by ensuring that incoming requests originate 
/// from authentic app instances. This library sets up App Check with
///  appropriate providers
/// for web, Android, and Apple platforms.
library;

import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

/// A view model for managing Firebase App Check initialization.
///
/// This singleton class provides a central point to set up App Check for the
/// application, helping to protect backend resources from abuse.
class AppCheckViewModel {
  /// Private constructor for the singleton pattern.
  AppCheckViewModel._();
  final _logger = Logger('AppCheckModel');

  static AppCheckViewModel? _instance;

  /// Provides the singleton instance of [AppCheckViewModel].
  // ignore: prefer_constructors_over_static_methods
  static AppCheckViewModel get instance => _instance ??= AppCheckViewModel._();

  /// Initializes and activates Firebase App Check with platform-specific
  /// providers.
  ///
  /// - For web, it uses `ReCaptchaV3Provider` with a site key fetched from
  ///   Firebase Remote Config.
  /// - For Android, it uses `AndroidProvider.playIntegrity` in release mode
  ///   and `AndroidProvider.debug` in debug mode.
  /// - For Apple platforms (iOS/macOS), it uses `AppleProvider.appAttest`.
  Future<void> initialize() async {
    const androidAppCheckProvider = kDebugMode
        ? AndroidDebugProvider()
        : AndroidPlayIntegrityProvider();

    // in debug mode, uncomment for test permission denied error in firesotre 
    //forcing playIntegrity
    //AndroidProvider androidProvider = AndroidProvider.playIntegrity;

    _logger.info('androidAppCheckProvider $androidAppCheckProvider');

    await FirebaseAppCheck.instance.activate(
      // You can also use 6a `ReCaptchaEnterpriseProvider` provider instance as 
      // an argument for `webProvider`
      providerWeb: ReCaptchaEnterpriseProvider(
        FirebaseRemoteConfig.instance.getString('appCheckReCaptchaV3SiteKey'),
      ),
      // Default provider for Android is the Play Integrity provider. You can 
      // use the "AndroidProvider" enum to choose
      // your preferred provider. Choose from:
      // 1. Debug provider
      // 2. Safety Net provider
      // 3. Play Integrity provider
      providerAndroid: androidAppCheckProvider,
    );
  }
}
