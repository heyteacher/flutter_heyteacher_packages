import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:logging/logging.dart';

part 'logger_data.g.dart';

/// Represents a single, serializable log entry.
///
/// This class is used to structure log data for storage and transmission,
/// converting a `logging` package [LogRecord] into a JSON-friendly format.
@JsonSerializable()
class LogEntry extends Equatable {
  /// Creates a [LogEntry] instance.
  const LogEntry({
    required this.time,
    required this.level,
    required this.message,
    required this.loggerName,
    this.error,
    this.stackTrace,
  });

  /// Creates a [LogEntry] from a JSON map.
  factory LogEntry.fromJson(Map<String, dynamic> json) =>
      _$LogEntryFromJson(json);

  /// Creates a [LogEntry] from a `logging` package [LogRecord].
  factory LogEntry.fromLogRecord(LogRecord record) => LogEntry(
    time: record.time,
    level: record.level,
    message: record.message,
    loggerName: record.loggerName,
    error: record.error?.toString(),
    stackTrace: record.stackTrace?.toString(),
  );

  /// The time the log event occurred.
  final DateTime time;

  /// The severity level of the log event.
  @JsonKey(fromJson: _levelFromJson, toJson: _levelToJson)
  final Level level;

  /// The log message.
  final String message;

  /// The name of the logger that produced the log.
  final String loggerName;

  /// The error object associated with the log, if any, converted to a string.
  final String? error;

  /// The stack trace associated with the error, if any, converted to a string.
  final String? stackTrace;

  @override
  List<Object?> get props => [
    time,
    level,
    message,
    loggerName,
    error,
    stackTrace,
  ];

  /// Converts this object into a JSON map.
  Map<String, dynamic> toJson() => _$LogEntryToJson(this);

  static Level _levelFromJson(dynamic jsonLevel) {
    return switch (jsonLevel as String) {
      'SEVERE' => Level.SEVERE,
      'WARNING' => Level.WARNING,
      'INFO' => Level.INFO,
      'CONFIG' => Level.CONFIG,
      'FINE' => Level.FINE,
      'FINER' => Level.FINER,
      'FINEST' => Level.FINEST,
      _ => Level.SHOUT,
    };
  }

  static String _levelToJson(Level level) => level.name;
}
