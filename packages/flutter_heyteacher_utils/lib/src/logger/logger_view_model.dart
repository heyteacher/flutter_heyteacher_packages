import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';
import 'dart:math';
import 'package:clock/clock.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_heyteacher_utils/formats.dart';
import 'package:flutter_heyteacher_utils/info_device_package.dart';
import 'package:flutter_heyteacher_utils/platform_helper.dart';
import 'package:flutter_heyteacher_utils/src/firebase/auth.dart';
import 'package:flutter_heyteacher_utils/src/firebase/remote_config.dart';
import 'package:flutter_heyteacher_utils/src/logger/logger_data.dart';
import 'package:flutter_heyteacher_utils/worker.dart';
import 'package:logging/logging.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages the application's logging configuration and stores log records.
///
/// This class is a singleton and is responsible for:
/// - Configuring the root logger's level.
/// - Storing log records in temporary files in JSON format.
/// - Sending log records to Firebase Analytics.
class LoggerViewModel {
  /// Private constructor for the singleton pattern.
  /// Initializes the logger configuration.
  LoggerViewModel._();
  final Logger _logger = Logger('LoggerViewModel');

  StreamSubscription<LogRecord>? _loggerSubscription;
  StreamSubscription<LogRecord>? _loggerForTestSubscription;

  final Worker<List<LogEntry>, void> _writeLogsWorker = Worker(
    writeLogsWorkerIsolate,
  );

  /// The singleton instance of [LoggerViewModel].
  static LoggerViewModel? _instance;

  /// Flag to ensure configuration happens only once.
  bool _alreadyConfigured = false;

  /// A list of [LogEntry]s that have been captured but not yet written to
  /// persistent storage.
  final List<LogEntry> notSavedLogEntries = List.empty(growable: true);

  final StreamController<void> _updateStreamController =
      StreamController<void>.broadcast();

  /// A stream that emits an event whenever the log view needs to be updated,
  /// for example, when filters change.
  Stream<void> get updateStream => _updateStreamController.stream;

  Level? _filterLevel;
  String? _filterText;

  /// The name for the `FINEST` log level.
  static const String finestLoggerName = 'FINEST';

  /// The value for the `FINEST` log level.
  static const int finestLoggerValue = 300;

  /// Provides the singleton instance of [LoggerViewModel].
  ///
  /// If an instance doesn't exist, it creates one.
  /// If [initialize] is `true` create one anywhere else.
  // ignore: prefer_constructors_over_static_methods
  static LoggerViewModel instance({bool initialize = false}) => initialize
      ? _instance = LoggerViewModel._()
      : _instance ??= LoggerViewModel._();

  /// Disposes of the [LoggerViewModel] by canceling the logger subscription.
  ///
  /// This should be called when the logger model is no longer needed to prevent
  /// memory leaks.
  void dispose() {
    unawaited(_loggerSubscription?.cancel());
    unawaited(_loggerForTestSubscription?.cancel());
    unawaited(_updateStreamController.close());
    _alreadyConfigured = false;
    _writeLogsWorker.close();
  }

  /// Configures the root logger for the application.
  ///
  /// Sets the logger's level based on `kDebugMode` and Firebase Remote Config.
  /// It then attaches  a listener that processes log records to:
  /// 1. Print formatted logs to the console if `kDebugMode` is true.
  /// 2. Send structured log events to Firebase Analytics, including version,
  ///    device info, level, message, error (if any), stack trace (if any), and
  ///    a user identifier.
  ///    Message, error, and stack trace are truncated to 100 characters for
  ///    Firebase.
  ///
  /// If [reset] is true, it clears the temporary log directory.
  Future<void> initialize({bool reset = true, bool reconfigure = false}) async {
    _logger.finer('<initialize>: reset $reset');
    // already configured, do nothing
    // Prevents re-configuration if already done.
    if (_alreadyConfigured && !reconfigure) {
      _logger.finer(
        '(initialize): reset $reset reconfigure $reconfigure. '
        'Already configured',
      );
      return;
    }
    _alreadyConfigured = true;
    FlutterError.onError = (details) {
      _logger.severe(
        '(FlutterError.onError) ${details.summary}',
        details.exception,
        details.stack,
      );
    };

    // if reset is true, delete all logs in the temporary directory except last
    // day
    if (reset) {
      final toDateTime = DateTime(
        clock.now().year,
        clock.now().month,
        clock.now().day,
      );
      developer.log(
        'flutter() ${clock.now().toIso8601String()} (initialize): '
        'reset $reset reconfigure $reconfigure. '
        'Reset all logs before $toDateTime',
      );
      final resetLogsWorker = Worker(resetLogsWorkerIsolate);
      unawaited(
        resetLogsWorker.execute(toDateTime).then((output) {
          if (output.error != null) {
            _logger.severe(
              '(initialize): reset error ${output.error} '
              'stackTrace ${output.stackTrace}',
            );
          }
          resetLogsWorker.close();
        }),
      );
    }

    // Set the root logger's level based on debug mode and Firebase Remote
    // Config.
    Logger.root.level = await level;

    // Asynchronously fetch package version and device information.
    final version = await InfoDevicePackageViewModel.instance.packageVersion;
    final deviceInfo = await InfoDevicePackageViewModel.instance.deviceInfo;
    // Get the unique identifier for the device/user.
    final identifierInfo = InfoDevicePackageViewModel.instance.identifierInfo;
    // initialize WriteLogsWorker in order to manage concurrent execution into
    // a single isolate
    unawaited(_writeLogsWorker.initialize());
    // Listen to records from the root logger.
    _loggerSubscription = Logger.root.onRecord.listen(
      (logRecord) => _logEntry(
        LogEntry.fromLogRecord(logRecord),
        version: version,
        deviceInfo: deviceInfo,
        identifierInfo: identifierInfo,
      ),
    );
  }

  @visibleForTesting
  /// Initializes a basic logger for testing purposes.
  ///
  /// This method sets the root logger's level to `ALL` and attaches a listener
  /// that prints formatted log records to the console when in `kDebugMode`.
  /// It's designed to provide simple, readable log output for unit and widget
  /// tests.
  void initializeLogForTest([Level level = Level.ALL]) {
    Logger.root.level = level;
    _alreadyConfigured = true;
    unawaited(_loggerForTestSubscription?.cancel());
    _loggerForTestSubscription = Logger.root.onRecord.listen((record) {
      // format error and stack trace
      final error = record.error != null ? '\n${record.error}' : '';
      final stackTrace = record.stackTrace != null
          ? '\n${record.stackTrace}'
          : '';
      // get uid from firebase auth
      // print in standard output
      if (kDebugMode) {
        print(
          '${FormatterHelper.timeWithSecondsFormat(record.time)} '
          '- ${record.level.name} '
          '- ${record.loggerName} '
          '- ${record.message} '
          '$error'
          '$stackTrace',
        );
      }
    });
  }

  /// Gets the current effective logging [Level].
  ///
  /// The level is determined by the following order of precedence:
  /// 1. A value set locally via [SharedPreferences].
  /// 2. A `FINEST` level if the current user's UID matches the one in
  ///    remote config.
  /// 3. The default level from Firebase Remote Config for the current
  ///    build mode.
  Future<Level> get level async => Level(
    await _sharedPrefsLoggerName ??
        ((FirebaseRemoteConfig.instance.getString(
                  FHURemoteConfigKeys.loggerUIDRootLevelFinest.name,
                ) ==
                AuthViewModel.instance.uid)
            ? finestLoggerName
            : FirebaseRemoteConfig.instance.getString(
                FHURemoteConfigKeys.levelName,
              )),
    (await _sharedPrefsLoggerValue) ??
        ((FirebaseRemoteConfig.instance.getString(
                  FHURemoteConfigKeys.loggerUIDRootLevelFinest.name,
                ) ==
                AuthViewModel.instance.uid)
            ? finestLoggerValue
            : FirebaseRemoteConfig.instance.getInt(
                FHURemoteConfigKeys.levelValue,
              )),
  );

  /// Sets the logger level locally, overriding the remote config.
  ///
  /// This stores the selected [level] in [SharedPreferences]. If [level] is
  /// `null`, the local override is removed, and the logger reverts to the
  /// level specified by remote config.
  Future<void> setLevel(Level? level, {int? index}) async {
    if (level == null) {
      await SharedPreferencesAsync().remove(
        FlutterHeyteacherUtilsSharedPreferencesKeys.htuLoggerLevelName.name,
      );
      await SharedPreferencesAsync().remove(
        FlutterHeyteacherUtilsSharedPreferencesKeys.htuLoggerLevelValue.name,
      );
    } else {
      await SharedPreferencesAsync().setString(
        FlutterHeyteacherUtilsSharedPreferencesKeys.htuLoggerLevelName.name,
        level.name,
      );
      await SharedPreferencesAsync().setInt(
        FlutterHeyteacherUtilsSharedPreferencesKeys.htuLoggerLevelValue.name,
        level.value,
      );
    }
    unawaited(initialize(reconfigure: true));
  }

  /// Determines whether log storage is enabled.
  ///
  /// Checks for a local override in [SharedPreferences] first. If not present,
  /// it falls back to the value from Firebase Remote Config.
  Future<bool> get enableLogsStorage async =>
      (await SharedPreferencesAsync().getBool(
        FlutterHeyteacherUtilsSharedPreferencesKeys.htuEnableLogsStorage.name,
      )) ??
      RemoteConfigViewModel.instance.getBool(
        FHURemoteConfigKeys.enableLogsStorage.name,
      );

  Future<String?> get _sharedPrefsLoggerName async =>
      SharedPreferencesAsync().getString(
        FlutterHeyteacherUtilsSharedPreferencesKeys.htuLoggerLevelName.name,
      );

  Future<int?> get _sharedPrefsLoggerValue async =>
      SharedPreferencesAsync().getInt(
        FlutterHeyteacherUtilsSharedPreferencesKeys.htuLoggerLevelValue.name,
      );

  Future<void> _logEntry(
    LogEntry entry, {
    required String version,
    required String deviceInfo,
    required String identifierInfo,
  }) async {
    // Format error and stack trace for potential inclusion in messages.
    final error = entry.error != null ? '\n${entry.error}' : '';
    final stackTrace = entry.stackTrace != null ? '\n${entry.stackTrace}' : '';
    notSavedLogEntries.add(entry);
    // reached 1K logs or an error is raised, write logs to file
    // Print the log message to the console if in debug mode.
    if (kDebugMode) {
      print(
        '${FormatterHelper.timeWithSecondsFormat(entry.time)} '
        '- version $version '
        '- $deviceInfo '
        '- ${entry.level.name} '
        '- $identifierInfo '
        '- ${entry.loggerName} '
        '- ${entry.message} '
        '$error'
        '$stackTrace',
      );
    }
    // Send the log event to Firebase Analytics.
    // Message, error, and stacktrace are limited to 100 characters for
    // Firebase.
    unawaited(
      FirebaseAnalytics.instance.logEvent(
        name: 'logger',
        parameters: {
          'time': entry.time.toLocal().toIso8601String(),
          'version': version,
          'device': deviceInfo,
          'level': entry.level.name,
          'kDebugMode': kDebugMode.toString(),
          'name': entry.loggerName,
          'message':
              // Truncate message to 100 characters for Firebase.
              entry.message.substring(0, min(entry.message.length, 100)),
          if (entry.error != null)
            // Truncate error to 100 characters for Firebase.
            'error': error.substring(0, min(error.length, 100)).trim(),
          if (entry.stackTrace != null)
            // Truncate stack trace to 100 characters for Firebase.
            'stackTrace': stackTrace
                .substring(0, min(stackTrace.length, 100))
                .trim(),
          'uid': identifierInfo,
        },
      ),
    );
    // write log into file system
    unawaited(_writeLogEntry(entry));
  }

  /// Returns a string representation of the logs, formatted for display.
  Future<String> logs2Text({
    DateTime? startTime,
    Level level = Level.ALL,
  }) async {
    _logger.finer('<logs2Text>: ');
    final logs2TextWorker = Worker(logs2TextWorkerIsolate);
    final output = await logs2TextWorker.execute((
      startTime: startTime,
      filterLevel: level,
      notSavedEntries: notSavedLogEntries,
    ));
    logs2TextWorker.close();
    if (output.error != null) {
      _logger.severe(
        '(logs2Text): reset error ${output.error} '
        'stackTrace ${output.stackTrace}',
      );
      throw Exception(output.error.toString());
    }
    return output.output!;
  }

  /// Filters a log record based on its level and timestamp.
  ///
  /// Returns `true` if the log record should be included, `false` otherwise.
  ///
  /// - [level]: The level of the log record.
  /// - [filterLevel]: The minimum level to be included. If `null` or
  ///   `Level.ALL`,
  ///   all levels are included.
  /// - [time]: The timestamp of the log record.
  /// - [filterStartTime]: The start time for filtering. Only logs at or after
  ///   this time will be included. If `null`, no time-based filtering is done.
  bool _filterLog({
    required String loggerName,
    required String message,
    required DateTime time,
    required Level level,
    required String? error,
    required String? stackTrace,
    required Level? filterLevel,
    required DateTime? filterStartTime,
    required String? filterText,
  }) {
    final textMatch =
        filterText == null ||
        filterText.isEmpty ||
        message.toLowerCase().contains(filterText.toLowerCase()) ||
        loggerName.toLowerCase().contains(filterText.toLowerCase()) ||
        (error?.toLowerCase().contains(filterText.toLowerCase()) ?? false) ||
        (stackTrace?.toString().toLowerCase().contains(
              filterText.toLowerCase(),
            ) ??
            false);
    final levelMatch =
        filterLevel == null ||
        filterLevel == Level.ALL ||
        level.value >= filterLevel.value;
    final timeMatch =
        filterStartTime == null || !time.isBefore(filterStartTime);
    return textMatch && levelMatch && timeMatch;
  }

  /// Returns a list of log entries from the temporary log directory.
  ///
  /// This method reads all JSON files in the temporary log directory,
  /// decodes them into [LogEntry] objects, and returns a list of these entries.
  /// It does not follow links and lists files only in the top-level directory.
  /// The log entries are sorted by their time in ascending order.
  Future<List<LogEntry>> logs({
    required bool descending,
    DateTime? startTime,
    Level? filterLevel,
    Iterable<LogEntry>? notSavedLogEntry,
    int? limit,
  }) async {
    final logEntries = <LogEntry>[];

    filterLevel ??= _filterLevel;
    // convert not saved log records to log entries filtered by log level
    final filteredNotSavedLogEntries = notSavedLogEntry?.where(
      (logEntry) => _filterLog(
        loggerName: logEntry.loggerName,
        message: logEntry.message,
        time: logEntry.time,
        level: logEntry.level,
        error: logEntry.error,
        stackTrace: logEntry.stackTrace?.toString(),
        filterLevel: filterLevel,
        filterText: _filterText,
        filterStartTime: startTime,
      ),
    );
    // add to log entries list if not null
    if (filteredNotSavedLogEntries != null) {
      logEntries.addAll(filteredNotSavedLogEntries);
    }
    // load log files from recent to old
    for (final file in await _logFiles(descending: descending)) {
      // load log entries from file and filter by level and add to log entries
      final logEntriesToAdd = _fromJson(file)
          .where(
            (logEntry) => _filterLog(
              loggerName: logEntry.loggerName,
              message: logEntry.message,
              time: logEntry.time,
              level: logEntry.level,
              error: logEntry.error,
              stackTrace: logEntry.stackTrace,
              filterLevel: filterLevel,
              filterText: _filterText,
              filterStartTime: startTime,
            ),
          )
          .toList();
      // add));
      logEntries.addAll(logEntriesToAdd);
      // if limit is reached, break
      if (limit != null && logEntries.length >= limit) {
        break;
      }
    }
    // sublist log entries to limit if set and sort descending by time
    return (logEntries..sort(
          (logEntryA, logEntryB) =>
              (descending ? -1 : 1) * logEntryA.time.compareTo(logEntryB.time),
        ))
        .sublist(0, min(logEntries.length, limit ?? logEntries.length));
  }

  Future<void> _writeLogEntry(LogEntry logEntry) async {
    //developer.log('flutter () <_writeLogEntry>:');
    try {
      if (notSavedLogEntries.length == 1000 ||
          logEntry.level.value >= Level.SEVERE.value) {
        final response = await _writeLogsWorker.execute(notSavedLogEntries);
        if (response.error != null) {
          _logger.severe(
            '(_writeLogEntry): WriteLogsWorker error '
            '$logEntry'
            '${response.error} stackTrace ${response.stackTrace}',
          );
        } else {
          notSavedLogEntries.clear();
        }
      }
    } on Exception {
      // developer.log('(_writeLogEntry): record '
      //     '$record'
      //     ' error $error stackTrace $stackTrace');
    }
  }

  List<LogEntry> _fromJson(FileSystemEntity file) {
    developer.log(
      'flutter () ${clock.now().toIso8601String()} '
      '<LoggerViewModel._fromJson>: file ${file.path}',
    );
    var jsonString = '';
    try {
      jsonString = (file as File).readAsStringSync();
      final decoded = jsonDecode(jsonString);
      if (decoded is List<dynamic>) {
        return List<LogEntry>.from(
          decoded.map((log) => LogEntry.fromJson(log as Map<String, dynamic>)),
        );
      } else if (decoded is Map<String, dynamic>) {
        return [LogEntry.fromJson(decoded)];
      } else {
        throw Exception('unknow decoded type ${decoded.runtimeType}');
      }
    } on Exception catch (error, stackTrace) {
      unawaited(file.delete());
      _logger.severe(
        '(_fromJson): file ${file.path}. Error on parse "$jsonString", deleted',
        error,
        stackTrace,
      );
      // If an error occurs while reading the file, return a LogEntry with the
      // error.
      return [
        LogEntry(
          time: clock.now(),
          level: Level.SEVERE,
          message: 'Error reading log file: ${file.path}',
          loggerName: 'LoggerModel',
          error: error.toString(),
          stackTrace: stackTrace.toString(),
        ),
      ];
    }
  }

  Future<Directory> get _tmpLogsDir async {
    /// The subscription to the root logger's `onRecord` stream.
    final tmpLogsDir = Directory(
      '${(await getTemporaryDirectory()).path}/logs',
    );
    // Check if the temporary logs directory exists, if not, create it.
    return tmpLogsDir.existsSync() ? tmpLogsDir : tmpLogsDir.create();
  }

  Future<List<FileSystemEntity>> _logFiles({required bool descending}) async =>
      (await ((await _tmpLogsDir).list(followLinks: false))
            .where((file) => file is File && file.path.endsWith('.json'))
            .toList())
        // sort by modified date
        ..sort(
          (fileA, fileB) =>
              (descending ? -1 : 1) *
              fileA.statSync().modified.compareTo(fileB.statSync().modified),
        );

  /// Updates the log filter to the specified [level].
  ///
  /// Setting [level] to `null` removes the level filter.
  /// Notifies listeners via [updateStream] to rebuild the log view.
  void updateFilterLevel(Level? level) {
    _filterLevel = level;
    _updateStreamController.add(null);
  }

  /// Notifies listeners via [updateStream] to refresh the log view.
  void refresh() {
    _updateStreamController.add(null);
  }

  /// Updates the log filter to only show entries containing [value].
  ///
  /// The search is case-insensitive.
  /// Notifies listeners via [updateStream] to rebuild the log view.
  void updateFilterText(String value) {
    _filterText = value;
    _updateStreamController.add(null);
  }
}

/// A background worker that writes [LogEntry] list to a file in JSON format.
///
/// This worker is used to persist log entries to the device's temporary
/// directory.

Future<void> writeLogsWorkerIsolate(Iterable<LogEntry> logEntries) async {
  if (PlatformHelper.isWeb) {
    return;
  }
  developer.log(
    'flutter () ${clock.now().toIso8601String()} <WriteLogsWorkerIsolate>: '
    'logEntries.length ${logEntries.length} ',
  );
  if (logEntries.isEmpty) {
    return;
  }
  final tmpLogDir = await LoggerViewModel.instance()._tmpLogsDir;
  final filename = FormatterHelper.machineDateTimeFormat(
    clock.now().toLocal(),
  );
  final file = File('${tmpLogDir.path}/$filename.json');
  // write the log entry to logs temporary directory as a JSON file
  await file.writeAsString(jsonEncode(logEntries));
}

/// A background worker that deletes log files older than a specified
/// [DateTime].
///
/// This is used to clean up old log files from the temporary directory to
/// manage storage space.

Future<int> resetLogsWorkerIsolate(DateTime toDateTime) async {
  if (PlatformHelper.isWeb) {
    return 0;
  }
  developer.log(
    'flutter () ${clock.now().toIso8601String()} <ResetLogsWorkerIsolate>: '
    'toDateTime $toDateTime ',
  );
  final logsToBeDelated =
      (await LoggerViewModel.instance()._logFiles(descending: false)).where(
        (fileSystemEntity) =>
            fileSystemEntity.statSync().modified.isBefore(toDateTime),
      )..forEach(_deleteFile);
  return logsToBeDelated.length;
}

void _deleteFile(FileSystemEntity file) {
  developer.log(
    'flutter () ${clock.now().toIso8601String()} <ResetLogsWorkerIsolate>: '
    'file ${file.path}. Deleted',
  );
  unawaited(file.delete());
  developer.log(
    'flutter () ${clock.now().toIso8601String()} (ResetLogsWorkerIsolate): '
    'file ${file.path}. Deleted',
  );
}

/// A background worker that reads all log entries and formats them into a
/// single, human-readable string.
///
/// Each log entry is formatted on a new line.

Future<String> logs2TextWorkerIsolate(
  ({
    DateTime? startTime,
    Level? filterLevel,
    Iterable<LogEntry> notSavedEntries,
  })
  input,
) async =>
    (await LoggerViewModel.instance().logs(
          startTime: input.startTime,
          filterLevel: input.filterLevel,
          notSavedLogEntry: input.notSavedEntries,
          descending: false,
        ))
        .map(
          (logEntry) =>
              '${logEntry.time.toLocal().toIso8601String()} - '
              '[${logEntry.level.name}] - ${logEntry.loggerName} - '
              '${logEntry.message}'
              '${logEntry.error != null ? ' - ${logEntry.error}' : ''}'
              '${logEntry.stackTrace != null ? ' - ${logEntry.stackTrace}' : ''
                        ''}',
        )
        .join('\n');
