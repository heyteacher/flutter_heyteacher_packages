/// Provides a global way to access a [BuildContext] from anywhere in the 
/// application.
///
/// This is primarily useful for accessing services that typically require a 
/// context, such as localization or `ScaffoldMessenger`, from non-widget parts 
/// of the codebase (e.g., business logic classes).
library;

import 'package:flutter/material.dart';

/// Context helper for get [BuildContext] outside widget, for example getting
/// localization in business logic.
/// 
/// To use it, need to be set [scaffoldMessengerKey] in your app 
/// ```dart
/// class MyApp extends StatelessWidget {
///   
///   @override
///   Widget build(BuildContext context) {
///     return MaterialApp.router(
///       scaffoldMessengerKey: ContextHelper.scaffoldMessengerKey,
///       ...
///       ...
///       ...
/// ```
class ContextHelper {

  ContextHelper._();

  /// The global scaffold messenger key
  static final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  /// get the context
  static BuildContext? get context =>
      scaffoldMessengerKey.currentContext;
}
