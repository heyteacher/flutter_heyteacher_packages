/// Configures Firebase Crashlytics for handling and reporting application
/// errors.
///
/// This library provides a setup function to integrate Crashlytics with
/// Flutter's error handling mechanisms, ensuring that both framework-caught
/// and uncaught asynchronous errors are reported.
library;

import 'dart:async';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

/// A view model for managing Firebase Crashlytics initialization and
/// configuration.
///
/// This singleton class provides a central point to set up Crashlytics error
/// reporting for the application.
class CrashlyticsViewModel {
  /// Private constructor for the singleton pattern.
  CrashlyticsViewModel._();
  static CrashlyticsViewModel? _instance;

  /// Provides the singleton instance of [CrashlyticsViewModel].
  // ignore: prefer_constructors_over_static_methods
  static CrashlyticsViewModel get instance =>
      _instance ??= CrashlyticsViewModel._();

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
      unawaited(
        FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails),
      );
    };
    // Pass all uncaught asynchronous errors that aren't handled by the Flutter
    //framework to Crashlytics
    PlatformDispatcher.instance.onError = (error, stack) {
      unawaited(
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true),
      );
      return true;
    };
  }
}
