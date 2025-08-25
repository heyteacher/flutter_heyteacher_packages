import 'package:equatable/equatable.dart';
import 'package:logging/logging.dart';

import 'package:json_annotation/json_annotation.dart';

part 'logger_data.g.dart';

@JsonSerializable()
class LogEntry extends Equatable {
  final DateTime time;
  @JsonKey(fromJson: _levelFromJson, toJson: _levelToJson)
  final Level level;
  final String message;
  final String loggerName;
  final String? error;
  final String? stackTrace;

  const LogEntry({
    required this.time,
    required this.level,
    required this.message,
    required this.loggerName,
    this.error,
    this.stackTrace,
  });

  @override
  List<Object?> get props => [
    time,
    level,
    message,
    loggerName,
    error,
    stackTrace,
  ];

  factory LogEntry.fromJson(Map<String, dynamic> json) =>
      _$LogEntryFromJson(json);

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
