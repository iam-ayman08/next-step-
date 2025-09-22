import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class PerformanceMonitor {
  static final PerformanceMonitor _instance = PerformanceMonitor._internal();
  factory PerformanceMonitor() => _instance;
  PerformanceMonitor._internal();

  final Map<String, Stopwatch> _timers = {};
  final Map<String, List<Duration>> _metrics = {};
  final Map<String, int> _counters = {};

  // Frame rate monitoring
  int _frameCount = 0;
  DateTime? _lastFrameTime;
  double _currentFPS = 60.0;
  final List<double> _fpsHistory = [];

  // Memory monitoring
  int _buildCount = 0;
  final Map<String, int> _widgetBuildCounts = {};

  // Network monitoring
  final Map<String, DateTime> _networkRequests = {};
  int _totalNetworkRequests = 0;
  Duration _totalNetworkTime = Duration.zero;

  // Start timing an operation
  void startTimer(String key) {
    _timers[key] = Stopwatch()..start();
  }

  // Stop timing and record the duration
  Duration? stopTimer(String key) {
    final timer = _timers.remove(key);
    if (timer != null) {
      timer.stop();
      final duration = timer.elapsed;
      _recordMetric(key, duration);
      return duration;
    }
    return null;
  }

  // Record a custom metric
  void recordMetric(String key, Duration duration) {
    _recordMetric(key, duration);
  }

  void _recordMetric(String key, Duration duration) {
    _metrics.putIfAbsent(key, () => []).add(duration);

    // Keep only last 100 measurements to prevent memory bloat
    if (_metrics[key]!.length > 100) {
      _metrics[key]!.removeAt(0);
    }

    if (kDebugMode) {
      developer.log('Performance: $key took ${duration.inMilliseconds}ms');
    }
  }

  // Increment a counter
  void incrementCounter(String key) {
    _counters[key] = (_counters[key] ?? 0) + 1;
  }

  // Get average duration for a metric
  Duration getAverageDuration(String key) {
    final durations = _metrics[key];
    if (durations == null || durations.isEmpty) return Duration.zero;

    final total = durations.fold<Duration>(
      Duration.zero,
      (sum, duration) => sum + duration,
    );
    return Duration(milliseconds: total.inMilliseconds ~/ durations.length);
  }

  // Get counter value
  int getCounter(String key) => _counters[key] ?? 0;

  // Frame rate monitoring
  void recordFrame() {
    _frameCount++;
    final now = DateTime.now();

    if (_lastFrameTime != null) {
      final frameTime = now.difference(_lastFrameTime!);
      final fps = 1000 / frameTime.inMilliseconds;

      // Smooth FPS calculation
      _currentFPS = (_currentFPS * 0.9) + (fps * 0.1);
      _fpsHistory.add(_currentFPS);

      // Keep only last 60 FPS readings
      if (_fpsHistory.length > 60) {
        _fpsHistory.removeAt(0);
      }
    }

    _lastFrameTime = now;
  }

  double getCurrentFPS() => _currentFPS;

  double getAverageFPS() {
    if (_fpsHistory.isEmpty) return 60.0;
    return _fpsHistory.reduce((a, b) => a + b) / _fpsHistory.length;
  }

  // Widget build monitoring
  void recordWidgetBuild(String widgetName) {
    _buildCount++;
    _widgetBuildCounts[widgetName] = (_widgetBuildCounts[widgetName] ?? 0) + 1;
  }

  int getWidgetBuildCount(String widgetName) =>
      _widgetBuildCounts[widgetName] ?? 0;

  // Network monitoring
  void startNetworkRequest(String url) {
    _networkRequests[url] = DateTime.now();
    _totalNetworkRequests++;
  }

  void endNetworkRequest(String url) {
    final startTime = _networkRequests.remove(url);
    if (startTime != null) {
      final duration = DateTime.now().difference(startTime);
      _totalNetworkTime += duration;
      recordMetric('network_request_$url', duration);
    }
  }

  Duration getAverageNetworkTime() {
    if (_totalNetworkRequests == 0) return Duration.zero;
    return Duration(
      milliseconds: _totalNetworkTime.inMilliseconds ~/ _totalNetworkRequests,
    );
  }

  // Performance report
  Map<String, dynamic> getPerformanceReport() {
    return {
      'fps': {'current': _currentFPS, 'average': getAverageFPS()},
      'builds': {
        'total': _buildCount,
        'widgets': Map.fromEntries(
          _widgetBuildCounts.entries
              .where(
                (e) => e.value > 10,
              ) // Only show widgets built more than 10 times
              .map((e) => MapEntry(e.key, e.value)),
        ),
      },
      'timers': Map.fromEntries(
        _metrics.entries.map(
          (e) => MapEntry(e.key, {
            'average': getAverageDuration(e.key).inMilliseconds,
            'count': e.value.length,
          }),
        ),
      ),
      'counters': Map.from(_counters),
      'network': {
        'total_requests': _totalNetworkRequests,
        'average_time': getAverageNetworkTime().inMilliseconds,
      },
    };
  }

  // Reset all metrics
  void reset() {
    _timers.clear();
    _metrics.clear();
    _counters.clear();
    _frameCount = 0;
    _lastFrameTime = null;
    _currentFPS = 60.0;
    _fpsHistory.clear();
    _buildCount = 0;
    _widgetBuildCounts.clear();
    _networkRequests.clear();
    _totalNetworkRequests = 0;
    _totalNetworkTime = Duration.zero;
  }

  // Log performance report
  void logPerformanceReport() {
    final report = getPerformanceReport();
    developer.log('=== PERFORMANCE REPORT ===');
    developer.log(
      'FPS: ${report['fps']['current'].toStringAsFixed(1)} (avg: ${report['fps']['average'].toStringAsFixed(1)})',
    );
    developer.log('Total builds: ${report['builds']['total']}');
    developer.log(
      'Network requests: ${report['network']['total_requests']} (avg: ${report['network']['average_time']}ms)',
    );

    if (report['timers'].isNotEmpty) {
      developer.log('=== TIMERS ===');
      (report['timers'] as Map).forEach((key, value) {
        developer.log('$key: ${value['average']}ms (count: ${value['count']})');
      });
    }
  }
}

// Performance monitoring widget wrapper
class PerformanceMonitoredWidget extends StatefulWidget {
  final Widget child;
  final String widgetName;
  final bool monitorBuilds;

  const PerformanceMonitoredWidget({
    super.key,
    required this.child,
    required this.widgetName,
    this.monitorBuilds = true,
  });

  @override
  State<PerformanceMonitoredWidget> createState() =>
      _PerformanceMonitoredWidgetState();
}

class _PerformanceMonitoredWidgetState
    extends State<PerformanceMonitoredWidget> {
  final PerformanceMonitor _monitor = PerformanceMonitor();

  @override
  void initState() {
    super.initState();
    _monitor.startTimer('widget_init_${widget.widgetName}');
  }

  @override
  Widget build(BuildContext context) {
    if (widget.monitorBuilds) {
      _monitor.recordWidgetBuild(widget.widgetName);
    }

    return widget.child;
  }

  @override
  void dispose() {
    _monitor.stopTimer('widget_init_${widget.widgetName}');
    super.dispose();
  }
}

// FPS Monitor overlay (for debugging)
class FPSMonitor extends StatefulWidget {
  final Widget child;
  final bool showOverlay;

  const FPSMonitor({super.key, required this.child, this.showOverlay = false});

  @override
  State<FPSMonitor> createState() => _FPSMonitorState();
}

class _FPSMonitorState extends State<FPSMonitor> with WidgetsBindingObserver {
  final PerformanceMonitor _monitor = PerformanceMonitor();
  Timer? _fpsTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _startFPSMonitoring();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _fpsTimer?.cancel();
    super.dispose();
  }

  void _startFPSMonitoring() {
    _fpsTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      _monitor.recordFrame();
      if (widget.showOverlay) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (widget.showOverlay)
          Positioned(
            top: 40,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${_monitor.getCurrentFPS().toStringAsFixed(1)} FPS',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// Memory optimization utilities
class MemoryOptimizer {
  static final MemoryOptimizer _instance = MemoryOptimizer._internal();
  factory MemoryOptimizer() => _instance;
  MemoryOptimizer._internal();

  final Map<String, WeakReference<Object>> _cache = {};
  final Map<String, DateTime> _cacheTimestamps = {};

  // Cache with automatic cleanup
  T? getCached<T>(String key) {
    final ref = _cache[key];
    if (ref != null && ref.target != null) {
      _cacheTimestamps[key] = DateTime.now(); // Update access time
      try {
        return ref.target as T;
      } catch (e) {
        // Type mismatch, remove invalid cache entry
        _cache.remove(key);
        _cacheTimestamps.remove(key);
        return null;
      }
    }
    // Clean up dead references
    _cache.remove(key);
    _cacheTimestamps.remove(key);
    return null;
  }

  void setCached<T>(String key, T value, {Duration? ttl}) {
    _cache[key] = WeakReference<Object>(value as Object);
    _cacheTimestamps[key] = DateTime.now();

    // Set up automatic cleanup if TTL is provided
    if (ttl != null) {
      Future.delayed(ttl, () {
        _cache.remove(key);
        _cacheTimestamps.remove(key);
      });
    }
  }

  // Clean up old cache entries
  void cleanupCache({Duration maxAge = const Duration(minutes: 30)}) {
    final now = DateTime.now();
    final keysToRemove = <String>[];

    _cacheTimestamps.forEach((key, timestamp) {
      if (now.difference(timestamp) > maxAge) {
        keysToRemove.add(key);
      }
    });

    for (final key in keysToRemove) {
      _cache.remove(key);
      _cacheTimestamps.remove(key);
    }
  }

  // Force garbage collection hint (for debugging)
  void suggestGC() {
    // This is just a hint to the VM
    // ignore: invalid_use_of_visible_for_testing_member
    // WidgetsBinding.instance.reassembleApplication(); // This forces a rebuild which can trigger GC
  }
}

// Debounce utility for performance
class Debouncer {
  final Duration delay;
  Timer? _timer;

  Debouncer({required this.delay});

  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(delay, action);
  }

  void cancel() {
    _timer?.cancel();
  }

  void dispose() {
    _timer?.cancel();
  }
}

// Throttle utility for performance
class Throttler {
  final Duration delay;
  DateTime? _lastExecution;

  Throttler({required this.delay});

  void run(VoidCallback action) {
    final now = DateTime.now();
    if (_lastExecution == null || now.difference(_lastExecution!) >= delay) {
      action();
      _lastExecution = now;
    }
  }
}
