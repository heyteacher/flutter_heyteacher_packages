// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'logger_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LogEntry _$LogEntryFromJson(Map<String, dynamic> json) => LogEntry(
  time: DateTime.parse(json['time'] as String),
  level: LogEntry._levelFromJson(json['level']),
  message: json['message'] as String,
  loggerName: json['loggerName'] as String,
  error: json['error'] as String?,
  stackTrace: json['stackTrace'] as String?,
);

Map<String, dynamic> _$LogEntryToJson(LogEntry instance) => <String, dynamic>{
  'time': instance.time.toIso8601String(),
  'level': LogEntry._levelToJson(instance.level),
  'message': instance.message,
  'loggerName': instance.loggerName,
  'error': instance.error,
  'stackTrace': instance.stackTrace,
};
