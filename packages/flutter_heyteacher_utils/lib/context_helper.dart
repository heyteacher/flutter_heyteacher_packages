// somewhere else in your project
import 'package:flutter/material.dart';

/// Context helper for get [BuildContext] outside widget, for example getting
/// localization in business logic.
/// 
/// To use it, need to be set [scaffoldMessengerKey] in your app 
/// ```
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
  static final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  /// get the context
  static BuildContext? get context =>
      scaffoldMessengerKey.currentContext;

  ContextHelper._();
}
