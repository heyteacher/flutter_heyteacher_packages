/// Configures Firebase Crashlytics for handling and reporting application errors.
///
/// This library provides a setup function to integrate Crashlytics with
/// Flutter's error handling mechanisms, ensuring that both framework-caught
/// and uncaught asynchronous errors are reported.
library;

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

class CrashlyticsModel {

  static CrashlyticsModel? _instance;
  CrashlyticsModel._();
  /// Provides the singleton instance of [CrashlyticsModel].
  static CrashlyticsModel get instance => _instance ??= CrashlyticsModel._();

  /// Configures Firebase Crashlytics to automatically record and report errors.
  ///
  /// This function sets up handlers for:
  /// - Fatal Flutter framework errors via `FlutterError.onError`.
  /// - Uncaught asynchronous errors via `PlatformDispatcher.instance.onError`.
  ///
  /// Crashlytics reporting is disabled in debug mode (`kDebugMode` is true).
  void initialize() {
    // in debug mode, don't configuree Crashlytics
    if (kDebugMode) return;

    FlutterError.onError = (errorDetails) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
    };
    // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  }
}