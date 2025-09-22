import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/config.dart';
import 'storage_service.dart';

enum LogLevel { debug, info, warn, error, fatal }

extension LogLevelExtension on LogLevel {
  String get name {
    switch (this) {
      case LogLevel.debug:
        return 'DEBUG';
      case LogLevel.info:
        return 'INFO';
      case LogLevel.warn:
        return 'WARN';
      case LogLevel.error:
        return 'ERROR';
      case LogLevel.fatal:
        return 'FATAL';
    }
  }

  int get level {
    switch (this) {
      case LogLevel.debug:
        return 0;
      case LogLevel.info:
        return 1;
      case LogLevel.warn:
        return 2;
      case LogLevel.error:
        return 3;
      case LogLevel.fatal:
        return 4;
    }
  }
}

class LogEntry {
  final DateTime timestamp;
  final LogLevel level;
  final String message;
  final String? tag;
  final Map<String, dynamic>? metadata;
  final String? userId;
  final String? sessionId;

  LogEntry({
    required this.timestamp,
    required this.level,
    required this.message,
    this.tag,
    this.metadata,
    this.userId,
    this.sessionId,
  });

  Map<String, dynamic> toJson() => {
        'timestamp': timestamp.toIso8601String(),
        'level': level.name,
        'message': message,
        'tag': tag,
        'metadata': metadata,
        'userId': userId,
        'sessionId': sessionId,
      };

  @override
  String toString() {
    return '[${timestamp.toIso8601String()}] ${level.name} ${tag != null ? '[$tag] ' : ''}$message';
  }
}

class LoggingService {
  static final LoggingService _instance = LoggingService._internal();
  final List<LogEntry> _logBuffer = [];
  final int _maxBufferSize = 1000;
  bool _isInitialized = false;
  String? _currentSessionId;
  String? _currentUserId;
  late PackageInfo _packageInfo;
  Map<String, dynamic>? _deviceInfo;

  factory LoggingService() => _instance;

  LoggingService._internal();

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Generate session ID
      _currentSessionId = 'session_${DateTime.now().millisecondsSinceEpoch}';

      // Initialize Sentry for crash reporting
      if (appConfig.enableCrashReporting && appConfig.sentryDsn.isNotEmpty) {
        await SentryFlutter.init(
          (options) {
            options.dsn = appConfig.sentryDsn;
            options.environment = appConfig.appEnv;
            options.release = '${_packageInfo.version}+${_packageInfo.buildNumber}';
            options.sampleRate = appConfig.isProduction ? 0.1 : 1.0; // 10% sample in production
            options.maxBreadcrumbs = 50;
            options.enableTracing = true;
            options.tracesSampleRate = 0.1;
          },
        );
      }

      await _loadDeviceInfo();
      await _loadPackageInfo();

      _isInitialized = true;

      logInfo('LoggingService initialized', tag: 'AppInit');

    } catch (e) {
      debugPrint('Failed to initialize LoggingService: $e');
    }
  }

  Future<void> _loadDeviceInfo() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        _deviceInfo = androidInfo.toMap();
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        _deviceInfo = iosInfo.toMap();
      }
    } catch (e) {
      logError('Failed to load device info', error: e, tag: 'DeviceInfo');
    }
  }

  Future<void> _loadPackageInfo() async {
    try {
      _packageInfo = await PackageInfo.fromPlatform();
    } catch (e) {
      logError('Failed to load package info', error: e, tag: 'PackageInfo');
    }
  }

  void setUserId(String? userId) {
    _currentUserId = userId;
  }

  // Core logging methods
  void logDebug(String message, {String? tag, Map<String, dynamic>? metadata}) {
    _log(LogLevel.debug, message, tag: tag, metadata: metadata);
  }

  void logInfo(String message, {String? tag, Map<String, dynamic>? metadata}) {
    _log(LogLevel.info, message, tag: tag, metadata: metadata);
  }

  void logWarn(String message, {String? tag, Map<String, dynamic>? metadata}) {
    _log(LogLevel.warn, message, tag: tag, metadata: metadata);
  }

  void logError(String message, {
    Object? error,
    StackTrace? stackTrace,
    String? tag,
    Map<String, dynamic>? metadata
  }) {
    final errorMetadata = Map<String, dynamic>.from(metadata ?? {});
    if (error != null) {
      errorMetadata['error'] = error.toString();
    }
    if (stackTrace != null) {
      errorMetadata['stackTrace'] = stackTrace.toString();
    }

    _log(LogLevel.error, message, tag: tag, metadata: errorMetadata);

    // Send error to Sentry if available
    if (_isInitialized && appConfig.enableCrashReporting) {
      _reportErrorToSentry(message, error, stackTrace, tag);
    }
  }

  void logFatal(String message, {
    Object? error,
    StackTrace? stackTrace,
    String? tag,
    Map<String, dynamic>? metadata
  }) {
    final errorMetadata = Map<String, dynamic>.from(metadata ?? {});
    if (error != null) {
      errorMetadata['error'] = error.toString();
    }
    if (stackTrace != null) {
      errorMetadata['stackTrace'] = stackTrace.toString();
    }

    _log(LogLevel.fatal, message, tag: tag, metadata: errorMetadata);

    // Send fatal error to Sentry
    if (_isInitialized && appConfig.enableCrashReporting) {
      _reportErrorToSentry(message, error, stackTrace, tag, isFatal: true);
    }
  }

  void logNetwork(String url, String method, {
    int? statusCode,
    Duration? responseTime,
    String? error,
    String? tag,
    Map<String, dynamic>? additionalData
  }) {
    final metadata = Map<String, dynamic>.from(additionalData ?? {});
    metadata['url'] = url;
    metadata['method'] = method;
    if (statusCode != null) metadata['statusCode'] = statusCode;
    if (responseTime != null) metadata['responseTimeMs'] = responseTime.inMilliseconds;
    if (error != null) metadata['error'] = error;

    final level = (statusCode != null && statusCode >= 400) ? LogLevel.error : LogLevel.info;
    _log(level, 'Network Request: $method $url', tag: tag ?? 'Network', metadata: metadata);
  }

  void logAuth(String action, {
    String? userId,
    String? provider,
    bool success = true,
    String? error,
    String? tag
  }) {
    final metadata = <String, dynamic>{
      'action': action,
      'provider': provider ?? 'email',
      'success': success,
    };
    if (userId != null) metadata['userId'] = userId;
    if (error != null) metadata['error'] = error;

    _log(success ? LogLevel.info : LogLevel.warn, 'Auth: $action (${success ? 'success' : 'failed'})',
        tag: tag ?? 'Auth', metadata: metadata);
  }

  void logPerformance(String operation, Duration duration, {
    Map<String, dynamic>? metadata,
    String? tag
  }) {
    final perfMetadata = Map<String, dynamic>.from(metadata ?? {});
    perfMetadata['durationMs'] = duration.inMilliseconds;

    _log(LogLevel.info, 'Performance: $operation took ${duration.inMilliseconds}ms',
        tag: tag ?? 'Performance', metadata: perfMetadata);
  }

  void _log(LogLevel level, String message, {
    String? tag,
    Map<String, dynamic>? metadata
  }) {
    if (!_shouldLog(level)) return;

    final logEntry = LogEntry(
      timestamp: DateTime.now(),
      level: level,
      message: message,
      tag: tag,
      metadata: metadata,
      userId: _currentUserId,
      sessionId: _currentSessionId,
    );

    // Add to buffer
    _logBuffer.add(logEntry);

    // Keep buffer size under limit
    if (_logBuffer.length > _maxBufferSize) {
      _logBuffer.removeAt(0);
    }

    // Print to console in debug mode
    if (appConfig.enableDebug) {
      debugPrint(logEntry.toString());
    }

    // Persist important logs
    if (level.level >= LogLevel.error.level) {
      _persistLogEntry(logEntry);
    }
  }

  bool _shouldLog(LogLevel level) {
    if (!appConfig.enableDebug && level == LogLevel.debug) return false;
    return level.level >= _getMinLogLevel();
  }

  int _getMinLogLevel() {
    switch (appConfig.logLevel.toLowerCase()) {
      case 'error':
        return LogLevel.error.level;
      case 'warn':
        return LogLevel.warn.level;
      case 'info':
        return LogLevel.info.level;
      case 'debug':
        return LogLevel.debug.level;
      default:
        return LogLevel.info.level;
    }
  }

  Future<void> _persistLogEntry(LogEntry entry) async {
    try {
      final key = 'log_${entry.timestamp.millisecondsSinceEpoch}';
      await storageService.write(key, jsonEncode(entry.toJson()));
    } catch (e) {
      debugPrint('Failed to persist log entry: $e');
    }
  }

  Future<void> _reportErrorToSentry(String message, Object? error, StackTrace? stackTrace, String? tag, {bool isFatal = false}) async {
    try {
      final SentryId sentryId = await Sentry.captureMessage(
        message,
        level: isFatal ? SentryLevel.fatal : SentryLevel.error,
        withScope: (scope) {
          scope.setTag('tag', tag ?? 'unknown');
          scope.setExtra('sessionId', _currentSessionId);
          if (_currentUserId != null) {
            scope.setUser(SentryUser(id: _currentUserId));
          }
          if (_deviceInfo != null) {
            scope.setContexts('device', _deviceInfo!);
          }
          if (stackTrace != null) {
            scope.setExtra('stackTrace', stackTrace.toString());
          }
        },
      );
    } catch (e) {
      debugPrint('Failed to report error to Sentry: $e');
    }
  }

  // Log retrieval methods for debugging
  List<LogEntry> getRecentLogs({int limit = 100, LogLevel? minLevel}) {
    final filtered = minLevel != null
        ? _logBuffer.where((log) => log.level.level >= minLevel.level).toList()
        : _logBuffer;

    return filtered.reversed.take(limit).toList().reversed.toList();
  }

  List<LogEntry> getLogsByTag(String tag) {
    return _logBuffer.where((log) => log.tag == tag).toList();
  }

  Future<List<LogEntry>> getPersistedLogs({int limit = 50}) async {
    try {
      final logs = <LogEntry>[];
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys()
          .where((key) => key.startsWith('log_'))
          .toList()
        ..sort((a, b) => b.compareTo(a)); // Sort by timestamp descending

      for (final key in keys.take(limit)) {
        final data = prefs.getString(key);
        if (data != null) {
          try {
            final json = jsonDecode(data) as Map<String, dynamic>;
            logs.add(LogEntry(
              timestamp: DateTime.parse(json['timestamp']),
              level: LogLevel.values.firstWhere(
                (e) => e.name == json['level'],
                orElse: () => LogLevel.info,
              ),
              message: json['message'],
              tag: json['tag'],
              metadata: json['metadata'],
              userId: json['userId'],
              sessionId: json['sessionId'],
            ));
          } catch (e) {
            // Skip malformed log entries
            continue;
          }
        }
      }

      return logs;
    } catch (e) {
      logError('Failed to get persisted logs', error: e, tag: 'Logging');
      return [];
    }
  }

  // Cleanup methods
  Future<void> clearLogs() async {
    _logBuffer.clear();
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().where((key) => key.startsWith('log_'));
      for (final key in keys) {
        await prefs.remove(key);
      }
    } catch (e) {
      logError('Failed to clear logs', error: e, tag: 'Logging');
    }
  }

  Future<int> cleanupOldLogs(Duration maxAge) async {
    try {
      final cutoffDate = DateTime.now().subtract(maxAge);
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().where((key) => key.startsWith('log_'));

      int deletedCount = 0;
      for (final key in keys) {
        try {
          final data = prefs.getString(key);
          if (data != null) {
            final json = jsonDecode(data) as Map<String, dynamic>;
            final logTime = DateTime.parse(json['timestamp']);
            if (logTime.isBefore(cutoffDate)) {
              await prefs.remove(key);
              deletedCount++;
            }
          }
        } catch (e) {
          // Remove malformed entries
          await prefs.remove(key);
          deletedCount++;
        }
      }

      logInfo('Cleaned up $deletedCount old log entries', tag: 'Logging');
      return deletedCount;
    } catch (e) {
      logError('Failed to cleanup old logs', error: e, tag: 'Logging');
      return 0;
    }
  }

  // Analytics methods
  void trackEvent(String eventName, {Map<String, dynamic>? parameters, String? tag}) {
    final metadata = Map<String, dynamic>.from(parameters ?? {});
    metadata['event'] = eventName;

    logInfo('Analytics Event: $eventName', tag: tag ?? 'Analytics', metadata: metadata);

    // Here you could send to Firebase Analytics or other tracking services
  }

  void trackScreen(String screenName, {Map<String, dynamic>? parameters}) {
    final metadata = Map<String, dynamic>.from(parameters ?? {});
    metadata['screen'] = screenName;

    logInfo('Screen View: $screenName', tag: 'Navigation', metadata: metadata);
  }

  // Get current session info
  Map<String, String?> getSessionInfo() {
    return {
      'sessionId': _currentSessionId,
      'userId': _currentUserId,
      'appVersion': _packageInfo.version,
      'buildNumber': _packageInfo.buildNumber,
      'environment': appConfig.appEnv,
    };
  }
}

// Global logging instance
final logger = LoggingService();

// Convenient logging methods
void logDebug(String message, {String? tag, Map<String, dynamic>? metadata}) =>
    logger.logDebug(message, tag: tag, metadata: metadata);

void logInfo(String message, {String? tag, Map<String, dynamic>? metadata}) =>
    logger.logInfo(message, tag: tag, metadata: metadata);

void logWarn(String message, {String? tag, Map<String, dynamic>? metadata}) =>
    logger.logWarn(message, tag: tag, metadata: metadata);

void logError(String message, {
  Object? error,
  StackTrace? stackTrace,
  String? tag,
  Map<String, dynamic>? metadata
}) => logger.logError(message, error: error, stackTrace: stackTrace, tag: tag, metadata: metadata);

void logFatal(String message, {
  Object? error,
  StackTrace? stackTrace,
  String? tag,
  Map<String, dynamic>? metadata
}) => logger.logFatal(message, error: error, stackTrace: stackTrace, tag: tag, metadata: metadata);
