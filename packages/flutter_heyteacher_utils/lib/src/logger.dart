library;

/// Provides UI components and a model for viewing and managing application logs.
///
/// Key features include:
/// - [LoggerScreen]: A dedicated screen to display and filter log messages.
/// - [LoggerListTile]: A convenient [ListTile] for navigating to the [LoggerScreen].
/// - [LoggingRouter]: Defines the routing for the logger UI.
/// - [LoggerModel]: Handles log capture, configuration (including level setting via
///   Firebase Remote Config), in-memory storage, and forwarding of structured logs
///   to Firebase Analytics.

import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_heyteacher_utils/info_device_package.dart';
import 'package:flutter_heyteacher_utils/localizations.dart';
import 'package:flutter_heyteacher_utils/theme.dart';
import 'package:flutter_heyteacher_utils/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../formats.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

class LogEntry {
  final DateTime time;
  final Level level;
  final String message;
  final String loggerName;
  final String? error;
  final String? stackTrace;

  LogEntry(
      {required this.time,
      required this.level,
      required this.message,
      required this.loggerName,
      this.error,
      this.stackTrace});

  factory LogEntry.fromJson(Map<String, dynamic> map) => LogEntry(
      time: DateTime.parse(map["time"]),
      level: switch (map["level"] as String) {
        "SEVERE" => Level.SEVERE,
        "WARNING" => Level.WARNING,
        "INFO" => Level.INFO,
        "CONFIG" => Level.CONFIG,
        "FINE" => Level.FINE,
        "FINER" => Level.FINER,
        "FINEST" => Level.FINEST,
        _ => Level.SHOUT
      },
      message: map["message"],
      loggerName: map["loggerName"],
      error: map["error"],
      stackTrace: map["stackTrace"]);

  Map<String, dynamic> toJson() => {
        "time": time.toIso8601String(),
        "level": level.name,
        "loggerName": loggerName,
        "message": message,
        "error": error,
        "stackTrace": stackTrace,
      };
}

/// A [StatelessWidget] that displays a [ListTile] for navigating to the [LoggerScreen].
class LoggerListTile extends StatelessWidget {
  /// The prefix for the route path to the logger screen.
  final String _pathPrefix;

  /// Creates a [LoggerListTile].
  /// Requires a [_pathPrefix] to construct the navigation route.
  const LoggerListTile(this._pathPrefix, {super.key});

  @override

  /// Builds the [ListTile] widget.
  ListTile build(BuildContext context) {
    return ListTile(
      key: ValueKey("lt_fhu_logger"),
      leading: Icon(
        Icons.list,
      ),
      title: Text(FlutterHeyteacherUtilsLocalizations.of(context)!.logging),
      onTap: () {
        // Navigates to the logger screen using GoRouter.
        GoRouter.of(context).go('$_pathPrefix/${LoggingRouter.path}');
      },
      trailing: Icon(Icons.keyboard_arrow_right),
    );
  }
}

/// Defines the routing for the logger screen.
class LoggingRouter {
  /// The path segment for the logger screen.
  static const path = 'logging';

  /// Builds a [GoRoute] for the logger screen.
  static GoRoute builder() => GoRoute(
      path: path,
      builder: (BuildContext context, GoRouterState state) => LoggerScreen());
}

///
/// A [StatelessWidget] that displays a list of log messages.
/// This screen allows users to view logs and filter them by level.
///
/// It listens to the root logger's `onRecord` stream and updates the UI
/// with new log entries as they arrive.
class LoggerScreen extends StatefulWidget {
  /// Creates a [LoggerScreen].
  const LoggerScreen({super.key});

  @override

  /// Creates the mutable state for this widget.
  State<LoggerScreen> createState() => _LoggerScreenState();
}

/// The state for the [LoggerScreen] widget.
class _LoggerScreenState extends State<LoggerScreen> {
  /// The currently selected [Level] to filter logs by. If null, no filter is applied.
  Level? _filterLevel;

  @override

  /// Builds the UI for the logger screen.
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: Text(FlutterHeyteacherUtilsLocalizations.of(context)!
            .logging),
        actions: [
          _buildLevelFilter(),
        ],
      ),
      body: FutureStreamBuilder<List<LogEntry>>(
          future: LoggerModel.instance().logs,
          stream: LoggerModel.instance().stream,
          // Displays each log message as a Text widget in a ListView.
          builder: (_, snapshot) => Padding(
            padding: const EdgeInsets.only(left: 4.0, right: 4.0),
            child: ListView(
                children: snapshot.data
                        ?.where((logEntry) =>
                            _filterLevel == null ||
                            logEntry.level == _filterLevel)
                        .map(
                          // Displays each log entry as a Card with details.
                          (logEntry) => Card(
                            color: _backgroundColor(logEntry.level),
                            child: ListTile(
                              leading: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(timeWithSecondsFormatter
                                        .format(logEntry.time))
                                  ]),
                              title: Text(logEntry.loggerName),
                              subtitle: Text(logEntry.message),
                              isThreeLine: true,
                            ),
                          ),
                        )
                        .toList() ??
                    []),
          )));

  /// Builds the dropdown menu for filtering log levels.
  Widget _buildLevelFilter() {
    return DropdownMenu<Level?>(
      enableSearch: false,
      enableFilter: false,
      inputDecorationTheme: InputDecorationTheme(
        isDense: true,
        contentPadding: const EdgeInsets.only(left: 20),
        constraints: BoxConstraints.tight(const Size.fromHeight(40)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      label: Text('Log Level', style: Theme.of(context).textTheme.labelSmall),
      textStyle: Theme.of(context).textTheme.labelSmall,
      trailingIcon: const Icon(Icons.filter_list),
      // Updates the _filterLevel and rebuilds the UI when a new level is selected.
      onSelected: (level) {
        _filterLevel = level;
        setState(() {});
      },
      dropdownMenuEntries: [
        null,
        Level.SEVERE,
        Level.WARNING,
        Level.INFO,
      ]
          .map<DropdownMenuEntry<Level?>>((level) => DropdownMenuEntry<Level?>(
                value: level,
                label: level?.name ?? '',
              ))
          .toList(),
    );
  }

  /// Determines the background color for a log entry based on its [Level].
  Color? _backgroundColor(Level level) => switch (level) {
        Level.SHOUT => ThemeModel.instance().redColor.withValues(alpha: 0.4),
        Level.SEVERE => ThemeModel.instance().redColor.withValues(alpha: 0.4),
        Level.WARNING =>
          ThemeModel.instance().orangeColor.withValues(alpha: 0.4),
        Level.INFO => ThemeModel.instance().blueColor.withValues(alpha: 0.4),
        Level.CONFIG => ThemeModel.instance().blueColor.withValues(alpha: 0.4),
        _ =>
          ThemeModel.instance().theme.colorScheme.surface.withValues(alpha: 0.4)
      };
}

/// Manages the application's logging configuration and stores log records.
///
/// This class is a singleton and is responsible for:
/// - Configuring the root logger's level.
/// - Listening to log records.
/// - Storing a list of recent log records.
/// - Sending log records to Firebase Analytics.
class LoggerModel {
  final _log = Logger('LoggerModel');

  /// The singleton instance of [LoggerModel].
  static LoggerModel? _instance;

  final _sharedPreferences = SharedPreferencesAsync();

  static const _sharedPreferencesLogsKey = 'flutter_heyteacher_utils_logs';

  /// A stream controller to broadcast locale changes.
  final StreamController<List<LogEntry>> _streamController =
      StreamController<List<LogEntry>>.broadcast();

  /// The subscription to the root logger's `onRecord` stream.
  StreamSubscription<LogRecord>? _loggerSubscription;

  /// Gets the list of stored [LogEntry] objects.
  Stream<List<LogEntry>> get stream => _streamController.stream;

  Future<List<LogEntry>> get logs async =>
      (await _sharedPreferences.getStringList(_sharedPreferencesLogsKey))
          ?.map((logEntry) => LogEntry.fromJson(jsonDecode(logEntry)))
          .toList() ??
      [];

  Future<String> get logs2Text async => (await LoggerModel.instance().logs)
      .reversed
      .map((logEntry) => '${timeWithSecondsFormatter.format(logEntry.time)} - '
          '[${logEntry.level.name}] - ${logEntry.loggerName} - '
          '${logEntry.message}'
          '${logEntry.error != null ? ' - ${logEntry.error}' : ''}'
          '${logEntry.stackTrace != null ? ' - ${logEntry.stackTrace}' : ''}')
      .join('\n');

  ///

  /// Provides the singleton instance of [LoggerModel].
  ///
  /// If an instance doesn't exist, it creates one.
  /// If [initialize] is `true` create one anywhere else.
  static LoggerModel instance({bool initialize = false}) =>
      initialize ? LoggerModel._() : _instance ??= LoggerModel._();

  /// Disposes of the [LoggerModel] by canceling the logger subscription.
  ///
  /// This should be called when the logger model is no longer needed to prevent memory leaks.
  dispose() {
    _loggerSubscription?.cancel();
  }

  /// Private constructor for the singleton pattern.
  /// Initializes the logger configuration.
  LoggerModel._();

  /// Flag to ensure configuration happens only once.
  bool _alreadyConfigured = false;

  /// Configures the root logger for the application.
  ///
  /// Sets the logger's level based on `kDebugMode` and Firebase Remote Config.
  /// It then attaches a listener that processes log records to:
  /// 1. Print formatted logs to the console if `kDebugMode` is true.
  /// 2. Send structured log events to Firebase Analytics, including version,
  ///    device info, level, message, error (if any), stack trace (if any), and a user identifier.
  ///    Message, error, and stack trace are truncated to 100 characters for Firebase.
  configure() async {
    // already configured, do nothing
    // Prevents re-configuration if already done.
    if (_alreadyConfigured) {
      _log.warning('already configured');
      return;
    }
    _alreadyConfigured = true;

    // Set the root logger's level based on debug mode and Firebase Remote Config.
    Logger.root.level = Level(
        kDebugMode
            ? "FINE"
            : FirebaseRemoteConfig.instance.getString("loggerRootLevelName"),
        kDebugMode
            ? 500
            : FirebaseRemoteConfig.instance.getInt("loggerRootLevelValue"));

    // Asynchronously fetch package version and device information.
    final version = await InfoDevicePackageModel.instance.packageVersion;
    final deviceInfo = await InfoDevicePackageModel.instance.deviceInfo;
    // Get the unique identifier for the device/user.
    final identifierInfo = InfoDevicePackageModel.instance.identifierInfo;

    // Listen to records from the root logger.
    _loggerSubscription = Logger.root.onRecord.listen((record) {
      // Format error and stack trace for potential inclusion in messages.
      final String error = record.error != null ? "\n${record.error}" : "";
      final String stackTrace =
          record.stackTrace != null ? "\n${record.stackTrace}" : "";
      // Add the raw LogRecord to the beginning of the list.
      _addLog(record);

      // Print the log message to the console if in debug mode.
      if (kDebugMode) {
        print('${timeWithSecondsFormatter.format(record.time)} '
            '- version $version '
            '- $deviceInfo '
            '- ${record.level.name} '
            '- $identifierInfo '
            '- ${record.loggerName} '
            '- ${record.message} '
            '$error'
            '$stackTrace');
      }

      // Send the log event to Firebase Analytics.
      // Message, error, and stacktrace are limited to 100 characters for Firebase.
      FirebaseAnalytics.instance.logEvent(name: "logger", parameters: {
        "time": record.time.toLocal().toIso8601String(),
        "version": version,
        "device": deviceInfo,
        "level": record.level.name,
        "kDebugMode": kDebugMode.toString(),
        "name": record.loggerName,
        "message":
            // Truncate message to 100 characters for Firebase.
            record.message.substring(0, min(record.message.length, 100)),
        if (record.error != null)
          // Truncate error to 100 characters for Firebase.
          "error": error.substring(0, min(error.length, 100)).trim(),
        if (record.stackTrace != null)
          // Truncate stack trace to 100 characters for Firebase.
          "stackTrace":
              stackTrace.substring(0, min(stackTrace.length, 100)).trim(),
        "uid": identifierInfo
      });
    });
  }

  Future<void> _addLog(LogRecord record) async {
    List<String> logs =
        await _sharedPreferences.getStringList(_sharedPreferencesLogsKey) ?? [];

    // Add the raw LogRecord to the beginning of the list.
    final logEntry = LogEntry(
        time: record.time,
        level: record.level,
        message: record.message,
        loggerName: record.loggerName,
        error: record.error?.toString(),
        stackTrace: record.stackTrace?.toString());

    // Maintain a maximum of 1000 logs in memory.
    if (logs.length >= 1000) logs.removeLast();

    // update logs in shared preferences
    await _sharedPreferences.setStringList(
        _sharedPreferencesLogsKey, [jsonEncode(logEntry), ...logs]);

    // yield logs updated to the stream
    _streamController.sink.add([
      logEntry,
      ...logs.map((logEntry) => LogEntry.fromJson(jsonDecode(logEntry)))
    ]);
  }
}
