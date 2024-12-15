import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:logging/logging.dart';
import 'package:flutter/foundation.dart';

Future<void> configureAppCheck() async {
  final log = Logger("configureAppCheck");
  AndroidProvider androidProvider = kDebugMode ? AndroidProvider.debug: AndroidProvider.playIntegrity;
  
  // in debug mode, uncomment for test permission denied error in firesotre forcing playIntegrity
  //AndroidProvider androidProvider = AndroidProvider.playIntegrity;
  
  log.fine("androidProvider $androidProvider");

  await FirebaseAppCheck.instance.activate(
    // You can also use 6a `ReCaptchaEnterpriseProvider` provider instance as an
    // argument for `webProvider`
    webProvider: ReCaptchaV3Provider(
        FirebaseRemoteConfig.instance.getString("appCheckReCaptchaV3SiteKey")),
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
