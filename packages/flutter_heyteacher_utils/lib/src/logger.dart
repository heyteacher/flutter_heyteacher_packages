library;

/// Provides UI components and a model for viewing and managing application logs.
///
/// Key features include:
/// - [LoggerScreen]: A dedicated screen to display and filter log messages.
/// - [LoggerListTile]: A convenient [ListTile] for navigating to the [LoggerScreen].
/// - [LoggingRouter]: Defines the routing for the logger UI.
/// - [LoggerViewModel]: Handles log capture, configuration (including level setting via
///   Firebase Remote Config), in-memory storage, and forwarding of structured logs
///   to Firebase Analytics.

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_heyteacher_utils/info_device_package.dart';
import 'package:flutter_heyteacher_utils/locale.dart';
import 'package:flutter_heyteacher_utils/src/firebase/auth.dart';
import 'package:flutter_heyteacher_utils/theme.dart';
import 'package:flutter_heyteacher_utils/widgets.dart';
import 'package:go_router/go_router.dart';
import '../formats.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:path_provider/path_provider.dart';

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
      time: DateTime.parse(map['time']),
      level: switch (map['level'] as String) {
        'SEVERE' => Level.SEVERE,
        'WARNING' => Level.WARNING,
        'INFO' => Level.INFO,
        'CONFIG' => Level.CONFIG,
        'FINE' => Level.FINE,
        'FINER' => Level.FINER,
        'FINEST' => Level.FINEST,
        _ => Level.SHOUT
      },
      message: map['message'],
      loggerName: map['loggerName'],
      error: map['error'],
      stackTrace: map['stackTrace']);

  Map<String, dynamic> toJson() => {
        'time': time.toLocal().toIso8601String(),
        'level': level.name,
        'loggerName': loggerName,
        'message': message,
        'error': error,
        'stackTrace': stackTrace,
      };
}

class LoggerCard extends StatelessWidget {
  /// The prefix for the route path to the logger screen.
  final String _pathPrefix;

  /// Creates a [LoggerCard].
  /// Requires a [_pathPrefix] to construct the navigation route.
  const LoggerCard(this._pathPrefix, {super.key});

  @override
  StreamBuilder<bool> build(context) => StreamBuilder<bool>(
      stream: InfoDevicePackageViewModel.instance.tapCounterReachedStream,
      builder: (_, tapCounterReachedSnapshot) => Visibility(
            visible: kDebugMode || (tapCounterReachedSnapshot.data ?? false),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                child: ListTile(
                  key: const ValueKey('lt_fhu_logger'),
                  leading: const Icon(
                    Icons.list,
                  ),
                  title: Text(
                      FlutterHeyteacherUtilsLocalizations.of(context)!.logging),
                  onTap: () {
                    // Navigates to the logger screen using GoRouter.
                    GoRouter.of(context)
                        .go('$_pathPrefix/${LoggingRouter.path}');
                  },
                  trailing: const Icon(Icons.keyboard_arrow_right),
                ),
              ),
            ),
          ));
}

/// Defines the routing for the logger screen.
class LoggingRouter {
  static const String path = 'logging';

  /// Builds a [GoRoute] for the logger screen.
  static GoRoute builder() => GoRoute(
      path: path,
      builder: (BuildContext context, GoRouterState state) =>
          const LoggerScreen());
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

  /// Builds the UI for the logger screen.
  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: Text(FlutterHeyteacherUtilsLocalizations.of(context)!.logging),
        actions: [
          _buildLevelFilterDropdown(),
          // add refresh button to reload logs
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Rebuilds the UI to refresh the logs.
              setState(() {});
            },
          )
        ],
      ),
      body: FutureBuilder<List<LogEntry>>(
          future: LoggerViewModel.instance()._logs(filterLevel: _filterLevel),
          // Displays each log message as a Text widget in a ListView.
          builder: (_, snapshot) => Padding(
                padding: const EdgeInsets.only(left: 4.0, right: 4.0),
                child: snapshot.hasError // show error view
                    ? ErrorView(snapshot.error, snapshot.stackTrace)
                    : !snapshot.hasData // show progress indicator
                        ? const ProgressIndicatorView()
                        : ListView(
                            children: snapshot.data!
                                .map(
                                  (logEntry) => Card(
                                    color: _backgroundColor(logEntry.level),
                                    child: ListTile(
                                      leading: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(timeWithSecondsFormatter
                                                .format(logEntry.time)),
                                            Text(logEntry.level.name,
                                                style: TextStyle(
                                                    color: _backgroundColor(
                                                            logEntry.level)
                                                        ?.withValues(
                                                            alpha: 0.8))),
                                          ]),
                                      title: Text(logEntry.loggerName),
                                      subtitle: Text(logEntry.message),
                                      isThreeLine: true,
                                      trailing: logEntry.error != null
                                          ? IconButton(
                                              icon: const Icon(Icons.info),
                                              onPressed: () =>
                                                  showConfirmCancelDialog(
                                                      context: context,
                                                      content:
                                                          '${logEntry.error}\n\n'
                                                          '${logEntry.stackTrace ?? ''}'),
                                            )
                                          : null,
                                    ),
                                  ),
                                )
                                .toList()),
              )));

  /// Builds the dropdown menu for filtering log levels.
  Widget _buildLevelFilterDropdown() => DropdownMenu<Level?>(
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
        onSelected: (level) => setState(() => _filterLevel = level),
        dropdownMenuEntries: [
          null,
          Level.SHOUT,
          Level.SEVERE,
          Level.WARNING,
          Level.CONFIG,
          Level.INFO,
          Level.FINE,
          Level.FINER,
          Level.FINEST,
        ]
            .map<DropdownMenuEntry<Level?>>(
                (level) => DropdownMenuEntry<Level?>(
                      value: level,
                      label: level?.name ?? '',
                    ))
            .toList(),
      );

  /// Determines the background color for a log entry based on its [Level].
  Color? _backgroundColor(Level level) => switch (level) {
        Level.SHOUT =>
          ThemeViewModel.instance().redColor.withValues(alpha: 0.4),
        Level.SEVERE =>
          ThemeViewModel.instance().redColor.withValues(alpha: 0.4),
        Level.WARNING =>
          ThemeViewModel.instance().orangeColor.withValues(alpha: 0.4),
        Level.CONFIG =>
          ThemeViewModel.instance().orangeColor.withValues(alpha: 0.4),
        Level.CONFIG =>
          ThemeViewModel.instance().yellowColor.withValues(alpha: 0.4),
        Level.INFO =>
          ThemeViewModel.instance().greenColor.withValues(alpha: 0.4),
        _ => ThemeViewModel.instance().blueColor.withValues(alpha: 0.4)
      };
}

/// Manages the application's logging configuration and stores log records.
///
/// This class is a singleton and is responsible for:
/// - Configuring the root logger's level.
/// - Storing log records in temporary files in JSON format.
/// - Sending log records to Firebase Analytics.
class LoggerViewModel {
  final _log = Logger('LoggerModel');

  /// The singleton instance of [LoggerViewModel].
  static LoggerViewModel? _instance;

  /// The subscription to the root logger's `onRecord` stream.
  StreamSubscription<LogRecord>? _loggerSubscription;

  /// Returns the temporary directory for logs.
  Future<Directory> get _tmpLogsDir async {
    final tmpLogsDir =
        Directory('${(await getTemporaryDirectory()).path}/logs');
    // Check if the temporary logs directory exists, if not, create it.
    return (await tmpLogsDir.exists()) ? tmpLogsDir : tmpLogsDir.create();
  }

  /// Returns a list of log entries from the temporary log directory.
  ///
  /// This method reads all JSON files in the temporary log directory,
  /// decodes them into [LogEntry] objects, and returns a list of these entries.
  /// It does not follow links and lists files only in the top-level directory.
  /// The log entries are sorted by their time in ascending order.
  Future<List<LogEntry>> _logs({Level? filterLevel}) async {
    final List<LogEntry> logEntries = [];
    for (var file in await _logFiles) {
      final logEntry = _fromJson(file);
      if (filterLevel == null || logEntry.level == filterLevel) {
        logEntries.add(logEntry);
      }
    }
    logEntries.sort(
        (logEntryA, logEntryB) => logEntryA.time.compareTo(logEntryB.time));
    return logEntries;
  }

  Future<List<FileSystemEntity>> get _logFiles async =>
      ((await _tmpLogsDir).list(recursive: false, followLinks: false))
          .where((file) => file is File && file.path.endsWith('.json'))
          .toList();

  LogEntry _fromJson(FileSystemEntity file) {
    String jsonString = '';
    try {
      jsonString = (file as File).readAsStringSync();
      return LogEntry.fromJson(jsonDecode(jsonString) as Map<String, dynamic>);
    } on Exception catch (e, s) {
      file.delete();
      if (kDebugMode) {
        print('Error reading log file: ${file.path} content $jsonString');
      }
      // If an error occurs while reading the file, return a LogEntry with the error.
      return LogEntry(
        time: DateTime.now(),
        level: Level.SEVERE,
        message: 'Error reading log file: ${file.path}',
        loggerName: 'LoggerModel',
        error: e.toString(),
        stackTrace: s.toString(),
      );
    }
  }

  /// Returns a string representation of the logs, formatted for display.
  Future<String> get logs2Text async => (await _logs())
      .map((logEntry) => '${timeWithSecondsFormatter.format(logEntry.time)} - '
          '[${logEntry.level.name}] - ${logEntry.loggerName} - '
          '${logEntry.message}'
          '${logEntry.error != null ? ' - ${logEntry.error}' : ''}'
          '${logEntry.stackTrace != null ? ' - ${logEntry.stackTrace}' : ''}')
      .join('\n');

  /// Provides the singleton instance of [LoggerViewModel].
  ///
  /// If an instance doesn't exist, it creates one.
  /// If [initialize] is `true` create one anywhere else.
  static LoggerViewModel instance({bool initialize = true}) =>
      initialize ? LoggerViewModel._() : _instance ??= LoggerViewModel._();

  /// Disposes of the [LoggerViewModel] by canceling the logger subscription.
  ///
  /// This should be called when the logger model is no longer needed to prevent memory leaks.
  dispose() {
    _loggerSubscription?.cancel();
    _instance = null;
    _alreadyConfigured = false;
  }

  /// Private constructor for the singleton pattern.
  /// Initializes the logger configuration.
  /// If [reset] is true, it clears the temporary log directory.
  LoggerViewModel._();

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
  ///
  /// If [reset] is true, it clears the temporary log directory.
  initialize({bool reset = false}) async {
    // already configured, do nothing
    // Prevents re-configuration if already done.
    if (_alreadyConfigured) {
      _log.finest('already configured');
      return;
    }
    _alreadyConfigured = true;

    FlutterError.onError = (FlutterErrorDetails details) {
      _log.severe('FlutterError', details.exception, details.stack);
    };

    // if reset is true, delete all logs in the temporary directory
    if (reset) {
      await resetLogs(
          fromDateTime:
              DateTime(clock.now().year, clock.now().month, clock.now().day));
    }

    // Set the root logger's level based on debug mode and Firebase Remote Config.
    Logger.root.level = Level(
        (FirebaseRemoteConfig.instance.getString('loggerUIDRootLevelFinest') ==
                AuthViewModel.instance().uid)
            ? 'FINEST'
            : kDebugMode
                ? FirebaseRemoteConfig.instance
                    .getString('loggerDebugRootLevelName')
                : FirebaseRemoteConfig.instance
                    .getString('loggerRootLevelName'),
        (FirebaseRemoteConfig.instance.getString('loggerUIDRootLevelFinest') ==
                AuthViewModel.instance().uid)
            ? 300
            : kDebugMode
                ? FirebaseRemoteConfig.instance
                    .getInt('loggerDebugRootLevelValue')
                : FirebaseRemoteConfig.instance.getInt('loggerRootLevelValue'));

    // Asynchronously fetch package version and device information.
    final version = await InfoDevicePackageViewModel.instance.packageVersion;
    final deviceInfo = await InfoDevicePackageViewModel.instance.deviceInfo;
    // Get the unique identifier for the device/user.
    final identifierInfo = InfoDevicePackageViewModel.instance.identifierInfo;

    // Listen to records from the root logger.
    _loggerSubscription = Logger.root.onRecord.listen((record) {
      // Format error and stack trace for potential inclusion in messages.
      final String error = record.error != null ? '\n${record.error}' : '';
      final String stackTrace =
          record.stackTrace != null ? '\n${record.stackTrace}' : '';
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
      FirebaseAnalytics.instance.logEvent(name: 'logger', parameters: {
        'time': record.time.toLocal().toIso8601String(),
        'version': version,
        'device': deviceInfo,
        'level': record.level.name,
        'kDebugMode': kDebugMode.toString(),
        'name': record.loggerName,
        'message':
            // Truncate message to 100 characters for Firebase.
            record.message.substring(0, min(record.message.length, 100)),
        if (record.error != null)
          // Truncate error to 100 characters for Firebase.
          'error': error.substring(0, min(error.length, 100)).trim(),
        if (record.stackTrace != null)
          // Truncate stack trace to 100 characters for Firebase.
          'stackTrace':
              stackTrace.substring(0, min(stackTrace.length, 100)).trim(),
        'uid': identifierInfo
      });
    });
  }

  Future<void> resetLogs({required DateTime fromDateTime}) async {
    (await _logFiles).where(
      (fileSystemEntity) {
        try {
          return LogEntry.fromJson(
                  jsonDecode((fileSystemEntity as File).readAsStringSync()))
              .time
              .isBefore(fromDateTime);
        } catch (e, s) {
          if (kDebugMode) {
            print(
                'Error reading log file: ${fileSystemEntity.path} content ${(fileSystemEntity as File).readAsStringSync()} error $e stackTrace $s');
          }
          return true;
        }
      },
    ).forEach(_deleteFile);
  }

  Future<void> _addLog(LogRecord record) async {
    // Create a LogEntry from the LogRecord.
    final logEntry = LogEntry(
        time: record.time,
        level: record.level,
        message: record.message,
        loggerName: record.loggerName,
        error: record.error?.toString(),
        stackTrace: record.stackTrace?.toString());

    // write the log entry to logs temporary directory as a JSON file
    final tmpLogDir = await _tmpLogsDir;
    final file = File(
        '${tmpLogDir.path}/${record.time.toLocal().toIso8601String().replaceAll(':', '-')}.json');
    await file.writeAsString(jsonEncode(logEntry));
  }

  void _deleteFile(FileSystemEntity element) {
    if (element is File) {
      element.delete();
      if (kDebugMode) {
        print('file ${element.path} deleted');
      }
    }
  }
}
