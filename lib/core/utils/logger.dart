import 'dart:developer' as dev;
import 'package:intl/intl.dart';
import 'package:stack_trace/stack_trace.dart';

enum LogLevel {
  debug,
  info,
  warning,
  error,
  critical,
}

class Logger {
  final String name;
  static LogLevel _minLevel = LogLevel.debug;
  static final Map<LogLevel, String> _levelPrefixes = {
    LogLevel.debug: '🐛 DEBUG',
    LogLevel.info: 'ℹ️ INFO',
    LogLevel.warning: '⚠️ WARN',
    LogLevel.error: '❌ ERROR',
    LogLevel.critical: '🔥 CRITICAL',
  };

  const Logger(this.name);

  static void setMinLevel(LogLevel level) {
    _minLevel = level;
  }

  void _log(
    dynamic message, {
    required LogLevel level,
    dynamic error,
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
    bool showInRelease = false,
  }) {
    if (level.index < _minLevel.index && !showInRelease) return;

    final time = DateFormat('HH:mm:ss.SSS').format(DateTime.now());
    final levelPrefix = _levelPrefixes[level] ?? 'UNKNOWN';
    final formattedStack = _formatStackTrace(stackTrace ?? StackTrace.current);

    final buffer = StringBuffer()
      ..writeln('[$time] $levelPrefix [$name] $message')
      ..writeln('├─ 📍 ${formattedStack.location}');

    if (error != null) {
      buffer.writeln('├─ 🚨 $error');
    }

    if (context?.isNotEmpty ?? false) {
      buffer.writeln('└─ 📦 ${_formatContext(context!)}');
    } else {
      buffer.writeln('└───');
    }

    final output = buffer.toString();
    _logToConsole(level, output, error, stackTrace);
  }

  static void _logToConsole(
    LogLevel level,
    String message,
    dynamic error,
    StackTrace? stackTrace,
  ) {
    switch (level) {
      case LogLevel.debug:
      case LogLevel.info:
        dev.log(message, name: 'APP');
        break;
      case LogLevel.warning:
        dev.log('\x1B[33m$message\x1B[0m', name: 'APP');
        break;
      case LogLevel.error:
      case LogLevel.critical:
        dev.log('\x1B[31m$message\x1B[0m', 
                name: 'APP',
                error: error,
                stackTrace: stackTrace);
        break;
    }
  }

  static _FormattedStackFrame _formatStackTrace(StackTrace stackTrace) {
    final frames = Trace.from(stackTrace).frames;
    if (frames.isEmpty) return _FormattedStackFrame('unknown', '0');
    
    final frame = frames.firstWhere(
      (f) => !f.library.toLowerCase().contains('logger'),
      orElse: () => frames.first,
    );

    return _FormattedStackFrame(
      '${frame.library} - ${frame.member}',
      '${frame.line}'
    );
  }

  static String _formatContext(Map<String, dynamic> context) {
    return context.entries
        .map((e) => '${e.key}: ${e.value}')
        .join(' | ');
  }

  // Niveaux de log
  void debug(dynamic message, {Map<String, dynamic>? context}) {
    _log(message, level: LogLevel.debug, context: context);
  }

  void info(dynamic message, {Map<String, dynamic>? context}) {
    _log(message, level: LogLevel.info, context: context);
  }

  void warning(dynamic message, {dynamic error, StackTrace? stackTrace, Map<String, dynamic>? context}) {
    _log(message, level: LogLevel.warning, error: error, stackTrace: stackTrace, context: context);
  }

  void error(dynamic message, {dynamic error, StackTrace? stackTrace, Map<String, dynamic>? context}) {
    _log(message, level: LogLevel.error, error: error, stackTrace: stackTrace, context: context);
  }

  void critical(dynamic message, {dynamic error, StackTrace? stackTrace, Map<String, dynamic>? context}) {
    _log(message, level: LogLevel.critical, error: error, stackTrace: stackTrace, context: context, showInRelease: true);
  }
}

class _FormattedStackFrame {
  final String location;
  final String line;

  _FormattedStackFrame(this.location, this.line);

  @override
  String toString() => '$location:$line';
}
