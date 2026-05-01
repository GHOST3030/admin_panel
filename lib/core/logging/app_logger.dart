import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

final class AppLogger {
  AppLogger._();

  static bool _initialized = false;

  static void init() {
    if (_initialized) return;
    _initialized = true;

    Logger.root.level = kDebugMode ? Level.ALL : Level.INFO;

    Logger.root.onRecord.listen((record) {
      final entry = _buildEntry(record);
      final json = jsonEncode(entry);

      developer.log(
        json,
        name: record.loggerName,
        level: record.level.value,
        time: record.time,
        error: record.error,
        stackTrace: record.stackTrace,
      );

      if (kDebugMode) {
        _printPretty(record);
      }
    });
  }

  static Logger getLogger(String module) => Logger(module);

  static Map<String, dynamic> _buildEntry(LogRecord record) {
    final entry = <String, dynamic>{
      'timestamp': record.time.toUtc().toIso8601String(),
      'level': record.level.name,
      'logger': record.loggerName,
      'message': record.message,
    };

    if (record.error != null) {
      entry['error'] = record.error.toString();
    }
    if (record.stackTrace != null) {
      entry['stackTrace'] = record.stackTrace.toString().split('\n').take(5).toList();
    }

    return entry;
  }

  static void _printPretty(LogRecord record) {
    final prefix = _levelPrefix(record.level);
    final buffer = StringBuffer()
      ..write('$prefix [${record.loggerName}] ${record.message}');

    if (record.error != null) {
      buffer.write(' | error=${record.error}');
    }

    debugPrint(buffer.toString());

    if (record.stackTrace != null) {
      debugPrint(record.stackTrace.toString());
    }
  }

  static String _levelPrefix(Level level) {
    if (level >= Level.SHOUT) return '💀 CRITICAL';
    if (level >= Level.SEVERE) return '🔴 ERROR';
    if (level >= Level.WARNING) return '🟡 WARNING';
    if (level >= Level.INFO) return '🟢 INFO';
    if (level >= Level.CONFIG) return '⚙️ CONFIG';
    if (level >= Level.FINE) return '🔵 DEBUG';
    return '⚪ TRACE';
  }

  static Map<String, dynamic> sanitize(Map<String, dynamic> data) {
    const redactedKeys = {
      'password',
      'token',
      'secret',
      'anonKey',
      'anon_key',
      'authorization',
      'cookie',
    };

    return data.map((key, value) {
      if (redactedKeys.contains(key.toLowerCase())) {
        return MapEntry(key, '***REDACTED***');
      }
      if (value is Map<String, dynamic>) {
        return MapEntry(key, sanitize(value));
      }
      return MapEntry(key, value);
    });
  }
}
