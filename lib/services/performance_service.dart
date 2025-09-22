import 'dart:async';
import 'dart:collection';
import 'package:flutter/material.dart';
import '../services/logging_service.dart';

class PerformanceMetric {
  final String name;
  final Duration duration;
  final DateTime startTime;
  final DateTime endTime;
  final Map<String, dynamic>? metadata;

  PerformanceMetric({
    required this.name,
    required this.duration,
    required this.startTime,
    required this.endTime,
    this.metadata,
  });

  @override
  String toString() {
    return '$name: ${duration.inMilliseconds}ms (${startTime.toIso8601String()})';
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'duration': duration.inMilliseconds,
    'startTime': startTime.toIso8601String(),
    'endTime': endTime.toIso8601String(),
    'metadata': metadata,
  };
}

class PerformanceMonitor {
  final _metrics = Queue<PerformanceMetric>();
  final _timers = <String, Stopwatch>{};
  final _thresholds = <String, Duration>{};
  final int _maxMetrics = 1000;
  Timer? _cleanupTimer;

  // Default thresholds for common operations
  static const Duration defaultUITimeout = Duration(seconds: 3);
  static const Duration defaultApiTimeout = Duration(seconds: 10);
  static const Duration defaultImageLoadTimeout = Duration(seconds: 5);
  static const Duration defaultNavigationTimeout = Duration(milliseconds: 500);

  PerformanceMonitor() {
    _initializeThresholds();
    _startCleanupTimer();
  }

  Future<void> initialize() async {
    // Any async initialization can be done here
    logInfo('Performance monitor initialized', tag: 'Performance');
  }

  void _initializeThresholds() {
    _thresholds.addAll({
      'ui_render': defaultUITimeout,
      'api_call': defaultApiTimeout,
      'image_load': defaultImageLoadTimeout,
      'navigation': defaultNavigationTimeout,
      'database_query': Duration(milliseconds: 100),
      'widget_build': Duration(milliseconds: 16), // 60fps threshold
    });
  }

  void startTimer(String operationName, {Map<String, dynamic>? metadata}) {
    if (_timers.containsKey(operationName)) {
      logWarn('Timer already exists for $operationName', tag: 'Performance');
      return;
    }

    _timers[operationName] = Stopwatch()..start();

    if (metadata != null) {
      logDebug('Started timer for $operationName', metadata: metadata, tag: 'Performance');
    } else {
      logDebug('Started timer for $operationName', tag: 'Performance');
    }
  }

  void endTimer(String operationName, {Map<String, dynamic>? additionalMetadata}) {
    final stopwatch = _timers.remove(operationName);
    if (stopwatch == null) {
      logWarn('Timer not found for $operationName', tag: 'Performance');
      return;
    }

    stopwatch.stop();
    final duration = stopwatch.elapsed;

    final startTime = DateTime.now().subtract(duration);
    final endTime = DateTime.now();

    final metadata = <String, dynamic>{
      if (additionalMetadata != null) ...additionalMetadata,
    };
    metadata['operation'] = operationName;

    final metric = PerformanceMetric(
      name: operationName,
      duration: duration,
      startTime: startTime,
      endTime: endTime,
      metadata: metadata,
    );

    _addMetric(metric);

    logInfo('Performance: $operationName took ${duration.inMilliseconds}ms', metadata: metadata, tag: 'Performance');

    // Check if duration exceeds threshold
    _checkThreshold(operationName, duration);
  }

  void trackAsyncOperation(String operationName, Future<void> Function() operation, {
    Map<String, dynamic>? metadata
  }) async {
    startTimer(operationName, metadata: metadata);
    try {
      await operation();
    } finally {
      endTimer(operationName, additionalMetadata: metadata);
    }
  }

  void measureSyncOperation(String operationName, void Function() operation, {
    Map<String, dynamic>? metadata
  }) {
    startTimer(operationName, metadata: metadata);
    try {
      operation();
    } finally {
      endTimer(operationName, additionalMetadata: metadata);
    }
  }

  void _addMetric(PerformanceMetric metric) {
    _metrics.add(metric);

    // Keep buffer size under limit
    if (_metrics.length > _maxMetrics) {
      _metrics.removeFirst();
    }
  }

  void _checkThreshold(String operationName, Duration duration) {
    final threshold = _thresholds[operationName];
    if (threshold != null && duration > threshold) {
      logWarn(
        'Performance threshold exceeded for $operationName',
        metadata: {
          'duration': '${duration.inMilliseconds}ms',
          'threshold': '${threshold.inMilliseconds}ms',
          'exceededBy': '${(duration - threshold).inMilliseconds}ms'
        },
        tag: 'PerformanceWarning'
      );
    }
  }

  void setThreshold(String operationName, Duration threshold) {
    _thresholds[operationName] = threshold;
    logDebug('Set performance threshold for $operationName: ${threshold.inMilliseconds}ms', tag: 'Performance');
  }

  List<PerformanceMetric> getRecentMetrics({int limit = 100, Duration? maxAge}) {
    final filtered = maxAge != null
      ? _metrics.where((metric) => DateTime.now().difference(metric.endTime) <= maxAge)
      : _metrics;

    return filtered.toList().reversed.take(limit).toList().reversed.toList();
  }

  Map<String, Duration> getAverageDurations({Duration? withinTimePeriod}) {
    final metrics = withinTimePeriod != null
      ? getRecentMetrics(maxAge: withinTimePeriod)
      : _metrics.toList();

    final operationDurations = <String, List<Duration>>{};
    for (final metric in metrics) {
      operationDurations.putIfAbsent(metric.name, () => []).add(metric.duration);
    }

    final averages = <String, Duration>{};
    for (final entry in operationDurations.entries) {
      final averageMs = entry.value.map((d) => d.inMilliseconds).reduce((a, b) => a + b) ~/ entry.value.length;
      averages[entry.key] = Duration(milliseconds: averageMs);
    }

    return averages;
  }

  Map<String, int> getMetricsCount({Duration? withinTimePeriod}) {
    final metrics = withinTimePeriod != null
      ? getRecentMetrics(maxAge: withinTimePeriod)
      : _metrics.toList();

    final counts = <String, int>{};
    for (final metric in metrics) {
      counts[metric.name] = (counts[metric.name] ?? 0) + 1;
    }

    return counts;
  }

  void reportPerformanceStats({Duration withinPeriod = const Duration(hours: 1)}) {
    final metrics = getRecentMetrics(maxAge: withinPeriod);
    final averages = getAverageDurations(withinTimePeriod: withinPeriod);
    final counts = getMetricsCount(withinTimePeriod: withinPeriod);

    logInfo('Performance Report (${withinPeriod.inMinutes}min):', metadata: {
      'totalMetrics': metrics.length,
      'operationCounts': counts,
      'averageDurations': averages.map((k, v) => MapEntry(k, '${v.inMilliseconds}ms')),
    }, tag: 'PerformanceReport');
  }

  void clearMetrics() {
    _metrics.clear();
    logInfo('Cleared all performance metrics', tag: 'Performance');
  }

  void _startCleanupTimer() {
    _cleanupTimer = Timer.periodic(
      const Duration(hours: 1),
      (_) => _cleanupOldMetrics(),
    );
  }

  void _cleanupOldMetrics({Duration maxAge = const Duration(hours: 24)}) {
    final beforeCount = _metrics.length;
    final cutoffTime = DateTime.now().subtract(maxAge);
    _metrics.removeWhere((metric) => metric.endTime.isBefore(cutoffTime));
    final afterCount = _metrics.length;

    if (beforeCount != afterCount) {
      logInfo('Cleaned up ${beforeCount - afterCount} old performance metrics', tag: 'Performance');
    }
  }

  void dispose() {
    _cleanupTimer?.cancel();
    _timers.clear();
    _metrics.clear();
  }
}

// Global performance monitor instance
final performanceMonitor = PerformanceMonitor();

// Performance monitoring widgets
class PerformanceTrackingWidget extends StatefulWidget {
  final Widget child;
  final String operationName;
  final Map<String, dynamic>? metadata;

  const PerformanceTrackingWidget({
    super.key,
    required this.child,
    this.operationName = 'widget_build',
    this.metadata,
  });

  @override
  State<PerformanceTrackingWidget> createState() => _PerformanceTrackingWidgetState();
}

class _PerformanceTrackingWidgetState extends State<PerformanceTrackingWidget> {
  late Stopwatch _buildStopwatch;

  @override
  void initState() {
    super.initState();
    _buildStopwatch = Stopwatch();
  }

  @override
  Widget build(BuildContext context) {
    _buildStopwatch.reset();
    _buildStopwatch.start();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _buildStopwatch.stop();
      final buildTime = _buildStopwatch.elapsed;

      performanceMonitor.endTimer(widget.operationName, additionalMetadata: {
        ...?widget.metadata,
        'widgetType': widget.child.runtimeType.toString(),
        'context': context.hashCode,
        'buildTime': '${buildTime.inMilliseconds}ms',
      });
    });

    performanceMonitor.startTimer(widget.operationName, metadata: {
      ...?widget.metadata,
      'widgetType': widget.child.runtimeType.toString(),
      'isRebuild': true,
    });

    return widget.child;
  }

  @override
  void dispose() {
    super.dispose();
  }
}

// Route performance tracking
class PerformanceRouteObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    final routeName = route.settings.name ?? route.runtimeType.toString();
    performanceMonitor.startTimer('navigation_push_$routeName', metadata: {
      'routeName': routeName,
      'previousRoute': previousRoute?.settings.name,
    });
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    final routeName = route.settings.name ?? route.runtimeType.toString();
    performanceMonitor.endTimer('navigation_pop_$routeName', additionalMetadata: {
      'routeName': routeName,
      'previousRoute': previousRoute?.settings.name,
    });
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    final newRouteName = newRoute?.settings.name ?? newRoute?.runtimeType.toString();
    final oldRouteName = oldRoute?.settings.name ?? oldRoute?.runtimeType.toString();

    performanceMonitor.endTimer('navigation_replace_$oldRouteName');
    performanceMonitor.startTimer('navigation_replace_$newRouteName', metadata: {
      'newRoute': newRouteName,
      'oldRoute': oldRouteName,
    });
  }
}

// Performance tracking extensions
extension PerformanceExtensions on PerformanceMonitor {
  Future<T> measureAsync<T>(
    String operationName,
    Future<T> Function() operation, {
    Map<String, dynamic>? metadata,
  }) async {
    startTimer(operationName, metadata: metadata);
    try {
      final result = await operation();
      endTimer(operationName, additionalMetadata: {'success': true});
      return result;
    } catch (error) {
      endTimer(operationName, additionalMetadata: {
        'error': error.toString(),
        'success': false,
      });
      rethrow;
    }
  }

  T measureSync<T>(String operationName, T Function() operation, {
    Map<String, dynamic>? metadata,
  }) {
    startTimer(operationName, metadata: metadata);
    try {
      final result = operation();
      endTimer(operationName, additionalMetadata: {'success': true});
      return result;
    } catch (error) {
      endTimer(operationName, additionalMetadata: {
        'error': error.toString(),
        'success': false,
      });
      rethrow;
    }
  }
}

// Convenient global functions
void measurePerformance(String operation, void Function() operationFunction, {
  Map<String, dynamic>? metadata
}) {
  performanceMonitor.measureSyncOperation(operation, operationFunction, metadata: metadata);
}

Future<void> measurePerformanceAsync(String operation, Future<void> Function() operationFunction, {
  Map<String, dynamic>? metadata
}) async {
  performanceMonitor.trackAsyncOperation(operation, operationFunction, metadata: metadata);
}
