import 'package:equatable/equatable.dart';
import 'package:logging/logging.dart';

class LogEntry extends Equatable {
  final DateTime time;
  final Level level;
  final String message;
  final String loggerName;
  final String? error;
  final String? stackTrace;

  const LogEntry(
      {required this.time,
      required this.level,
      required this.message,
      required this.loggerName,
      this.error,
      this.stackTrace});

  @override
  List<Object?> get props =>
      [time, level, message, loggerName, error, stackTrace];

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
