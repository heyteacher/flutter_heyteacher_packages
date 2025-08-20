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
import 'package:flutter_heyteacher_utils/src/firebase/auth.dart';
import 'package:flutter_heyteacher_utils/src/logger/logger_data.dart';
import 'package:flutter_heyteacher_utils/worker.dart';
import 'package:logging/logging.dart';
import 'package:path_provider/path_provider.dart';

/// Manages the application's logging configuration and stores log records.
///
/// This class is a singleton and is responsible for:
/// - Configuring the root logger's level.
/// - Storing log records in temporary files in JSON format.
/// - Sending log records to Firebase Analytics.
class LoggerViewModel {
  final Logger _logger = Logger('LoggerViewModel');

  StreamSubscription? _loggerSubscription;

  final WriteLogsWorker _writeLogsWorker = WriteLogsWorker();

  /// The singleton instance of [LoggerViewModel].
  static LoggerViewModel? _instance;

  /// Flag to ensure configuration happens only once.
  bool _alreadyConfigured = false;

  final List<LogRecord> notSavedLogRecords = List.empty(growable: true);

  final StreamController<void> _updateStreamController =
      StreamController<void>.broadcast();
  Stream<void> get updateStream => _updateStreamController.stream;

  Level? _filterLevel;

  /// Provides the singleton instance of [LoggerViewModel].
  ///
  /// If an instance doesn't exist, it creates one.
  /// If [initialize] is `true` create one anywhere else.
  static LoggerViewModel instance({bool initialize = false}) => initialize
      ? _instance = LoggerViewModel._()
      : _instance ??= LoggerViewModel._();

  /// Disposes of the [LoggerViewModel] by canceling the logger subscription.
  ///
  /// This should be called when the logger model is no longer needed to prevent
  /// memory leaks.
  dispose() {
    _loggerSubscription?.cancel();
    _alreadyConfigured = false;
    _writeLogsWorker.close();
  }

  /// Private constructor for the singleton pattern.
  /// Initializes the logger configuration.
  /// If [reset] is true, it clears the temporary log directory.
  LoggerViewModel._();

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
  initialize({bool reset = true}) async {
    developer.log('flutter () <initialize>: reset $reset');
    // already configured, do nothing
    // Prevents re-configuration if already done.
    if (_alreadyConfigured) {
      developer
          .log('flutter () (initialize): reset $reset. Already configured');
      return;
    }
    _alreadyConfigured = true;
    FlutterError.onError = (FlutterErrorDetails details) {
      _logger.severe(
          '(FlutterError.onError)', details.exception, details.stack);
    };

    // if reset is true, delete all logs in the temporary directory except last
    // day
    if (reset) {
      final toDateTime =
          DateTime(clock.now().year, clock.now().month, clock.now().day);
      _logger.finest('(initialize): reset $reset. '
          'Reset all logs before $toDateTime');
      ResetLogsWorker resetLogsWorker = ResetLogsWorker();
      resetLogsWorker.execute(toDateTime).then((output) {
        if (output.error != null) {
          _logger.severe(
              '(initialize): reset error', output.error, output.stackTrace);
        }
        resetLogsWorker.close();
      });
    }

    // Set the root logger's level based on debug mode and Firebase Remote
    // Config.
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
    // initialize WriteLogsWorker in order to manage concurrent execution into
    // a single isolate
    _writeLogsWorker.initialize();
    // Listen to records from the root logger.
    _loggerSubscription = Logger.root.onRecord.listen((record) => _logRecord(
        record,
        version: version,
        deviceInfo: deviceInfo,
        identifierInfo: identifierInfo));
  }

  void _logRecord(LogRecord record,
      {required String version,
      required String deviceInfo,
      required String identifierInfo}) async {
    // Format error and stack trace for potential inclusion in messages.
    final String error = record.error != null ? '\n${record.error}' : '';
    final String stackTrace =
        record.stackTrace != null ? '\n${record.stackTrace}' : '';
    notSavedLogRecords.add(record);
    // reached 1K logs or an error is raised, write logs to file
    // Print the log message to the console if in debug mode.
    if (kDebugMode) {
      print('${FormatterHelper.timeWithSecondsFormat(record.time)} '
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
    // Message, error, and stacktrace are limited to 100 characters for
    // Firebase.
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
    // write log into file system
    _writeLogRecords(record);
  }

  /// Returns a string representation of the logs, formatted for display.
  Future<String> logs2Text(
      {DateTime? startTime, Level level = Level.ALL}) async {
    _logger.finest('<logs2Text>: ');
    final logs2TextWorker = Logs2TextWorker();
    final output = await logs2TextWorker.execute((
      startTime: startTime,
      filterLevel: level,
      notSavedLogRecords: notSavedLogRecords
    ));
    logs2TextWorker.close();
    if (output.error != null) {
      _logger.severe('(logs2Text): error', output.error, output.stackTrace);
      throw Exception(output.error.toString());
    }
    return output.output!;
  }

  /// Filters a log record based on its level and timestamp.
  ///
  /// Returns `true` if the log record should be included, `false` otherwise.
  ///
  /// - [logLevel]: The level of the log record.
  /// - [filterLevel]: The minimum level to be included. If `null` or `Level.ALL`,
  ///   all levels are included.
  /// - [logTime]: The timestamp of the log record.
  /// - [filterStartTime]: The start time for filtering. Only logs at or after
  ///   this time will be included. If `null`, no time-based filtering is done.
  bool _filterLog(
      {required Level logLevel,
      required Level? filterLevel,
      required DateTime logTime,
      required DateTime? filterStartTime}) {
    final levelMatch = filterLevel == null ||
        filterLevel == Level.ALL ||
        logLevel.value >= filterLevel.value;
    final timeMatch =
        filterStartTime == null || !logTime.isBefore(filterStartTime);
    return levelMatch && timeMatch;
  }

  /// Returns a list of log entries from the temporary log directory.
  ///
  /// This method reads all JSON files in the temporary log directory,
  /// decodes them into [LogEntry] objects, and returns a list of these entries.
  /// It does not follow links and lists files only in the top-level directory.
  /// The log entries are sorted by their time in ascending order.
  Future<List<LogEntry>> logs({
    DateTime? startTime,
    Level? filterLevel,
    List<LogRecord>? notSavedLogRecords,
    int? limit,
    required bool descending,
  }) async {
    final List<LogEntry> logEntries = [];

    filterLevel ??= _filterLevel;
    // convert not saved log records to log entries filtered by log level
    final notSavedLogEntries = notSavedLogRecords
        ?.where((logRecord) => _filterLog(
            logLevel: logRecord.level,
            filterLevel: filterLevel,
            logTime: logRecord.time,
            filterStartTime: startTime))
        .map((logRecord) => LogEntry(
            time: logRecord.time,
            level: logRecord.level,
            message: logRecord.message,
            loggerName: logRecord.loggerName));
    // add to log entries list if not null
    if (notSavedLogEntries != null) {
      logEntries.addAll(notSavedLogEntries);
    }
    // load log files from recent to old
    for (var file in await _logFiles(descending: descending)) {
      // load log entries from file and filter by level and add to log entries
      final logEntriesToAdd = _fromJson(file)
          .where((logEntry) => _filterLog(
              logLevel: logEntry.level,
              filterLevel: filterLevel,
              logTime: logEntry.time,
              filterStartTime: startTime))
          .toList();
      // add));
      logEntries.addAll(logEntriesToAdd);
      // if limit is reached, break
      if (limit != null && logEntries.length >= limit) {
        break;
      }
    }
    // sublist log entries to limit if set and sort descending by time
    return (logEntries
          ..sort((logEntryA, logEntryB) =>
              (descending ? -1 : 1) * logEntryA.time.compareTo(logEntryB.time)))
        .sublist(0, min(logEntries.length, limit ?? logEntries.length));
  }

  Future<void> _writeLogRecords(LogRecord record) async {
    //developer.log('flutter () <_writeLogRecords>:');
    try {
      if (notSavedLogRecords.length == 1000 ||
          record.level.value >= Level.SEVERE.value) {
        final response = await _writeLogsWorker.execute(notSavedLogRecords);
        if (response.error != null) {
          _logger.severe('(_logRecord): WriteLogsWorker error '
              '$record'
              '${response.error} stackTrace ${response.stackTrace}');
        } else {
          notSavedLogRecords.clear();
        }
      }
    } catch (error /*, stackTrace*/) {
      // developer.log('(_writeLogRecords): record '
      //     '$record'
      //     ' error $error stackTrace $stackTrace');
    }
  }

  List<LogEntry> _fromJson(FileSystemEntity file) {
    _logger.finest('<_fromJson>: file ${file.path}');
    String jsonString = '';
    try {
      jsonString = (file as File).readAsStringSync();
      final decoded = jsonDecode(jsonString);
      if (decoded is List<dynamic>) {
        return List<LogEntry>.from(
            decoded.map((log) => LogEntry.fromJson(log)));
      } else if (decoded is Map<String, dynamic>) {
        return [LogEntry.fromJson(decoded)];
      } else {
        throw Exception('unknow decoded type ${decoded.runtimeType}');
      }
    } on Exception catch (error, stackTrace) {
      file.delete();
      _logger.severe(
          '(_fromJson): file ${file.path}. Error on parse "$jsonString", deleted',
          error,
          stackTrace);
      // If an error occurs while reading the file, return a LogEntry with the
      // error.
      return [
        LogEntry(
          time: DateTime.now(),
          level: Level.SEVERE,
          message: 'Error reading log file: ${file.path}',
          loggerName: 'LoggerModel',
          error: error.toString(),
          stackTrace: stackTrace.toString(),
        )
      ];
    }
  }

  Future<Directory> get _tmpLogsDir async {
    /// The subscription to the root logger's `onRecord` stream.
    final tmpLogsDir =
        Directory('${(await getTemporaryDirectory()).path}/logs');
    // Check if the temporary logs directory exists, if not, create it.
    return (await tmpLogsDir.exists()) ? tmpLogsDir : tmpLogsDir.create();
  }

  Future<List<FileSystemEntity>> _logFiles({required bool descending}) async =>
      (await ((await _tmpLogsDir).list(recursive: false, followLinks: false))
          .where((file) => file is File && file.path.endsWith('.json'))
          .toList())
        // sort by modified date
        ..sort((fileA, fileB) =>
            (descending ? -1 : 1) *
            fileA.statSync().modified.compareTo(fileB.statSync().modified));

  void updateFilterLevel(Level? level) {
    _filterLevel = level;
    _updateStreamController.add(null);
  }

  void refresh() {
    _updateStreamController.add(null);
  }
}

/// A background worker that writes a [LogRecord] to a file in JSON format.
///
/// This worker is used to persist log entries to the device's temporary
/// directory.
class WriteLogsWorker extends Worker<List<LogRecord>, void> {
  /// Writes a [LogRecord] to a file in JSON format.
  @override
  String get debugName => runtimeType.toString();

  @override
  @protected
  Future<void> executeCallback(List<LogRecord> logRecords) async {
    if (logRecords.isEmpty) {
      return;
    }
    final logEntries = logRecords
        .map((logRecord) => LogEntry(
            time: logRecord.time,
            level: logRecord.level,
            message: logRecord.message,
            loggerName: logRecord.loggerName,
            error: logRecord.error?.toString(),
            stackTrace: logRecord.stackTrace?.toString()))
        .toList();
    final tmpLogDir = await LoggerViewModel.instance()._tmpLogsDir;
    final filename = FormatterHelper.machineDateTimeFormat(clock.now().toLocal());
    final file = File('${tmpLogDir.path}/$filename.json');
    // write the log entry to logs temporary directory as a JSON file
    await file.writeAsString(jsonEncode(logEntries));
  }
}

/// A background worker that deletes log files older than a specified
/// [DateTime].
///
/// This is used to clean up old log files from the temporary directory to
/// manage storage space.
class ResetLogsWorker extends Worker<DateTime, int> {
  /// Deletes log files older than the provided [toDateTime].
  @override
  String get debugName => runtimeType.toString();
  @override
  @protected
  Future<int> executeCallback(DateTime toDateTime) async {
    developer.log('flutter () <$runtimeType>: toDateTime $toDateTime ');
    final logsToBeDelated =
        (await LoggerViewModel.instance()._logFiles(descending: false)).where(
            (fileSystemEntity) =>
                fileSystemEntity.statSync().modified.isBefore(toDateTime));
    logsToBeDelated.forEach(_deleteFile);
    return logsToBeDelated.length;
  }

  void _deleteFile(FileSystemEntity file) {
    developer.log('flutter () <$runtimeType>: file ${file.path}. Deleted');
    file.delete();
    developer.log('flutter () ($runtimeType): file ${file.path}. Deleted');
  }
}

/// A background worker that reads all log entries and formats them into a
/// single, human-readable string.
///
/// Each log entry is formatted on a new line.
class Logs2TextWorker extends Worker<
    ({
      DateTime? startTime,
      Level? filterLevel,
      List<LogRecord> notSavedLogRecords
    }),
    String> {
  @override
  String get debugName => runtimeType.toString();

  /// Formats all log entries into a single string.
  @override
  @protected
  Future<String> executeCallback(
          ({
            DateTime? startTime,
            Level? filterLevel,
            List<LogRecord> notSavedLogRecords
          }) input) async =>
      (await LoggerViewModel.instance().logs(
              startTime: input.startTime,
              filterLevel: input.filterLevel,
              notSavedLogRecords: input.notSavedLogRecords,
              descending: false))
          .map((logEntry) => '${logEntry.time.toLocal().toIso8601String()} - '
              '[${logEntry.level.name}] - ${logEntry.loggerName} - '
              '${logEntry.message}'
              '${logEntry.error != null ? ' - ${logEntry.error}' : ''}'
              '${logEntry.stackTrace != null ? ' - ${logEntry.stackTrace}' : ''}')
          .join('\n');
}
