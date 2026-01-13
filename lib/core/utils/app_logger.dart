import 'dart:convert';
import 'package:logger/logger.dart';

/// Niveaux de log personnalisés
enum LogLevel {
  debug,
  info,
  warning,
  error,
  critical,
}

/// Classe utilitaire pour formater les messages de log
class LogMessage {
  final String message;
  final String? tag;
  final Map<String, dynamic>? context;
  final dynamic error;
  final StackTrace? stackTrace;
  final DateTime timestamp;
  final LogLevel level;

  LogMessage({
    required this.message,
    this.tag,
    this.context,
    this.error,
    this.stackTrace,
    DateTime? timestamp,
    this.level = LogLevel.debug,
  }) : timestamp = timestamp ?? DateTime.now();

  @override
  String toString() {
    final buffer = StringBuffer();
    
    // Niveau et horodatage
    buffer.write('${_levelEmoji[level]} [${_formatTime(timestamp)}]');
    
    // Tag
    if (tag != null) {
      buffer.write(' [$tag]');
    }
    
    // Message
    buffer.write(' $message');
    
    // Contexte
    if (context?.isNotEmpty ?? false) {
      try {
        final jsonString = const JsonEncoder.withIndent('  ').convert(context);
        buffer.write('\n↳ Contexte: $jsonString');
      } catch (e) {
        buffer.write('\n↳ Contexte: ${context.toString()}');
      }
    }
    
    // Erreur
    if (error != null) {
      buffer.write('\n↳ Erreur: $error');
    }
    
    // Stack trace
    if (stackTrace != null) {
      buffer.write('\n↳ Stack trace: $stackTrace');
    }
    
    return buffer.toString();
  }
  
  static String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:${time.second.toString().padLeft(2, '0')}.${time.millisecond.toString().padLeft(3, '0')}';
  }
  
  static const Map<LogLevel, String> _levelEmoji = {
    LogLevel.debug: '🐛',
    LogLevel.info: 'ℹ️',
    LogLevel.warning: '⚠️',
    LogLevel.error: '❌',
    LogLevel.critical: '🔥',
  };
}

/// Classe principale de gestion des logs
class AppLogger {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,          // Nombre de méthodes à afficher dans la stack trace
      errorMethodCount: 5,     // Nombre de méthodes à afficher en cas d'erreur
      lineLength: 200,         // Largeur de la sortie des logs
      colors: true,            // Activer les couleurs
      printEmojis: true,       // Activer les emojis
      printTime: false,        // On gère nous-mêmes l'horodatage
    ),
  );

  /// Enregistre un message de débogage
  static void debug(
    dynamic message, {
    String? tag,
    Map<String, dynamic>? context,
    dynamic error,
    StackTrace? stackTrace,
  }) {
    _log(
      message,
      level: LogLevel.debug,
      tag: tag,
      context: context,
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Enregistre un message d'information
  static void info(
    dynamic message, {
    String? tag,
    Map<String, dynamic>? context,
    dynamic error,
    StackTrace? stackTrace,
  }) {
    _log(
      message,
      level: LogLevel.info,
      tag: tag,
      context: context,
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Enregistre un message d'avertissement
  static void warning(
    dynamic message, {
    String? tag,
    Map<String, dynamic>? context,
    dynamic error,
    StackTrace? stackTrace,
  }) {
    _log(
      message,
      level: LogLevel.warning,
      tag: tag,
      context: context,
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Enregistre un message d'erreur
  static void error(
    dynamic message, {
    String? tag,
    Map<String, dynamic>? context,
    dynamic error,
    StackTrace? stackTrace,
  }) {
    _log(
      message,
      level: LogLevel.error,
      tag: tag,
      context: context,
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Enregistre un message critique
  static void critical(
    dynamic message, {
    String? tag,
    Map<String, dynamic>? context,
    dynamic error,
    StackTrace? stackTrace,
  }) {
    _log(
      message,
      level: LogLevel.critical,
      tag: tag,
      context: context,
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Méthode interne pour gérer tous les logs
  static void _log(
    dynamic message, {
    required LogLevel level,
    String? tag,
    Map<String, dynamic>? context,
    dynamic error,
    StackTrace? stackTrace,
  }) {
    final logMessage = LogMessage(
      message: message.toString(),
      tag: tag,
      context: context,
      error: error,
      stackTrace: stackTrace,
      level: level,
    );

    // Envoyer au logger approprié selon le niveau
    switch (level) {
      case LogLevel.debug:
        _logger.d(logMessage.toString());
        break;
      case LogLevel.info:
        _logger.i(logMessage.toString());
        break;
      case LogLevel.warning:
        _logger.w(logMessage.toString(), error: error, stackTrace: stackTrace);
        break;
      case LogLevel.error:
      case LogLevel.critical:
        _logger.e(logMessage.toString(), error: error, stackTrace: stackTrace);
        break;
    }
  }
}
