

import 'package:flutter/material.dart';
import 'package:flutter_heyteacher_logger/src/logger/logger_view.dart';
import 'package:flutter_heyteacher_logger/src/logger/logger_view_model.dart';

export 'src/l10n/flutter_heyteacher_logger.dart' show FlutterHeyteacherLoggerLocalizations;
/// Provides UI components and a model for viewing and managing application 
/// logs.
///
/// Key features include:
/// - [LoggerScreen]: A dedicated screen to display and filter log messages.
/// - [LoggerCard]: A convenient [Card] for navigating to the 
///   [LoggerScreen].
/// - [LoggingRouter]: Defines the routing for the logger UI.
/// - [LoggerViewModel]: Handles log capture, configuration (including level 
///   setting via
///   Firebase Remote Config), in-memory storage, and forwarding of structured 
///   logs to Firebase Analytics.

export 'src/logger/logger_view.dart'
    show
        EnableLogsStorageChoiceCard,
        LoggerCard,
        LoggerScreen,
        LoggingLevelDropDownMenuCard,
        LoggingRouter;
export 'src/logger/logger_view_model.dart' show LoggerViewModel;
