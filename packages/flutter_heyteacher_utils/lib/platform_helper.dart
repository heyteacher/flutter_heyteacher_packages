/// Provides utility methods and properties to easily determine the current
/// operating platform (e.g., mobile, web, desktop).
///
/// This helps in writing platform-specific code or adapting UI elements
/// based on the runtime environment.
library;

import 'dart:io';

import 'package:flutter/foundation.dart';

/// A utility class offering static boolean flags to identify the current 
/// platform.
///
/// This class cannot be instantiated and all its members are static.
final class PlatformHelper {

  // static class, avoid costructor
  PlatformHelper._();
  
  /// `true` if the application is running on a mobile platform 
  /// (Android or iOS).
  ///
  /// This excludes web environments.
  static final bool isMobile =
      !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  /// `true` if the application is running on Android.
  ///
  /// This excludes web environments.
  static final bool isAndroid =
      !kIsWeb && Platform.isAndroid;

  /// `true` if the application is running on iOS.
  ///
  /// This excludes web environments.
 static final bool isIOS =
      !kIsWeb && Platform.isIOS;

  /// `true` if the application is running in a web browser, linux or windows.
  /// but not on mobile.
  static final bool isNotMobile =
      kIsWeb || (!Platform.isAndroid && !Platform.isIOS);

  /// `true` if the application is running in a web browser, linux or windows.
  static const bool isWeb = kIsWeb;

  /// `true` if the application is not running in a web browser.
  static bool get isNotWeb => !kIsWeb;
}
