/// Provides UI components and a model for viewing and managing application
/// logs.
///
/// Key features include:
/// - [LoggerScreen]: A dedicated screen to display and filter log messages.
/// - [LoggerListTile]: A convenient [Card] for navigating to the
///   [LoggerScreen].
/// - [LoggingRouter]: Defines the routing for the logger UI.
/// - [LoggerViewModel]: Handles log capture, configuration (including level
///   setting via
///   Firebase Remote Config), in-memory storage, and forwarding of structured
///   logs to Firebase Analytics.
library;

import 'package:flutter/material.dart';
import 'package:flutter_heyteacher_logger/src/logger/view/logger_list_tile.dart';
import 'package:flutter_heyteacher_logger/src/logger/view/logger_screen.dart';
import 'package:flutter_heyteacher_logger/src/logger/view_model/logger_view_model.dart';

export 'src/l10n/flutter_heyteacher_logger.dart'
    show FlutterHeyteacherLoggerLocalizations;
export 'src/logger/view/enable_logs_storage_choice_list_tile.dart'
    show EnableLogsStorageChoiceListTile;
export 'src/logger/view/logger_list_tile.dart' show LoggerListTile;
export 'src/logger/view/logger_screen.dart' show LoggerScreen, LoggingRouter;
export 'src/logger/view/logging_level_drop_down_menu_list_tile.dart'
    show LoggingLevelDropDownMenuListTile;
export 'src/logger/view_model/logger_view_model.dart' show LoggerViewModel;
