import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../services/logging_service.dart';
import '../services/performance_service.dart';
import '../utils/config.dart';

/// Enhanced error boundary widget that catches and reports Flutter errors
class EnhancedErrorBoundary extends StatefulWidget {
  final Widget child;
  final String? widgetName;
  final String? routeName;
  final bool showErrorScreen;
  final Widget Function(FlutterErrorDetails error)? errorBuilder;
  final void Function(FlutterErrorDetails error)? onError;
  final Map<String, dynamic>? additionalMetadata;

  const EnhancedErrorBoundary({
    super.key,
    required this.child,
    this.widgetName,
    this.routeName,
    this.showErrorScreen = true,
    this.errorBuilder,
    this.onError,
    this.additionalMetadata,
  });

  @override
  State<EnhancedErrorBoundary> createState() => _EnhancedErrorBoundaryState();
}

class _EnhancedErrorBoundaryState extends State<EnhancedErrorBoundary> {
  FlutterErrorDetails? _errorDetails;
  bool _hasError = false;
  DateTime? _errorTime;

  @override
  void initState() {
    super.initState();
    // Start tracking this widget performance
    performanceMonitor.startTimer('error_boundary_init_${widget.widgetName ?? 'unknown'}', metadata: {
      'widgetType': 'ErrorBoundary',
      'widgetName': widget.widgetName,
      'routeName': widget.routeName,
    });
  }

  void _reportError(FlutterErrorDetails error) {
    _hasError = true;
    _errorDetails = error;
    _errorTime = DateTime.now();

    final errorMetadata = {
      'widgetName': widget.widgetName,
      'routeName': widget.routeName,
      'errorType': 'FlutterError',
      'library': error.library,
      'context': error.context.toString(),
      'stackTrace': error.stack.toString(),
      'exception': error.exception.toString(),
      'errorTime': _errorTime.toString(),
    };

    logError(
      'Widget error caught by EnhancedErrorBoundary',
      error: error.exception,
      stackTrace: error.stack,
      tag: 'ErrorBoundary',
      metadata: errorMetadata
    );

    // Call custom error handler if provided
    widget.onError?.call(error);
  }

  void _resetError() {
    setState(() {
      _hasError = false;
      _errorDetails = null;
      _errorTime = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError && widget.showErrorScreen) {
      return _buildErrorScreen();
    }

    // Use custom error builder if provided
    if (_hasError && widget.errorBuilder != null && _errorDetails != null) {
      try {
        return widget.errorBuilder!(_errorDetails!);
      } catch (e) {
        // Fallback to default error screen if error builder fails
        return _buildErrorScreen();
      }
    }

    // Wrap child with ErrorBoundary to catch Flutter framework errors
    ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
      _reportError(errorDetails);

      if (widget.errorBuilder != null) {
        try {
          return widget.errorBuilder!(errorDetails);
        } catch (e) {
          logError('Error in custom error builder', error: e, tag: 'ErrorBoundary');
        }
      }

      return _buildErrorScreen();
    };

    return widget.child;
  }

  Widget _buildErrorScreen() {
    return Container(
      color: Colors.red[50],
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 80,
                  color: Colors.red[400],
                ),
                const SizedBox(height: 20),
                Text(
                  'Oops! Something went wrong',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.red[800],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  'The widget in ${widget.widgetName ?? 'this page'} has encountered an error.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.red[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _resetError,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Try Again'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[600],
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                TextButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Go Back'),
                ),
                const SizedBox(height: 20),
                Text(
                  'Error reported to developers',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    performanceMonitor.endTimer('error_boundary_init_${widget.widgetName ?? 'unknown'}', additionalMetadata: {
      'disposed': true,
      'hadError': _hasError,
    });
    super.dispose();
  }
}

/// Performance tracked error boundary wrapper
class PerformanceTrackedErrorBoundary extends EnhancedErrorBoundary {
  final Map<String, dynamic>? additionalMetadata;

  const PerformanceTrackedErrorBoundary({
    super.key,
    required super.child,
    super.widgetName,
    super.routeName,
    super.showErrorScreen,
    super.errorBuilder,
    super.onError,
    this.additionalMetadata,
  });

  @override
  _PerformanceTrackedErrorBoundaryState createState() => _PerformanceTrackedErrorBoundaryState();
}

class _PerformanceTrackedErrorBoundaryState extends _EnhancedErrorBoundaryState {
  late String _widgetId;

  @override
  void initState() {
    super.initState();
    _widgetId = 'tracked_error_boundary_${DateTime.now().millisecondsSinceEpoch}';

    // Performance tracking for tracked error boundary
    performanceMonitor.startTimer(_widgetId, metadata: {
      ...?widget.additionalMetadata,
      'boundaries.managed': 'EnhancedErrorBoundary',
      'tracking.enabled': true,
    });
  }

  @override
  void _reportError(FlutterErrorDetails error) {
    // Add performance data to error report
    final performanceData = {
      'performanceWidgetId': _widgetId,
      'trackedMetrics': performanceMonitor.getRecentMetrics(limit: 5),
    };

    logError(
      'Tracked widget error occurred',
      error: error.exception,
      stackTrace: error.stack,
      tag: 'PerformanceTrackedError',
      metadata: {...performanceData, ...?widget.additionalMetadata}
    );

    super._reportError(error);
  }

  @override
  void dispose() {
    performanceMonitor.endTimer(_widgetId, additionalMetadata: {
      'tracking.ended': true,
      'trackedMetrics': performanceMonitor.getRecentMetrics(limit: 10, maxAge: Duration(hours: 1)),
    });
    super.dispose();
  }
}

/// Global error handler that can be used across the app
class AppErrorHandler {
  static FlutterExceptionHandler? _originalErrorHandler;

  static void initialize() {
    // Store original handler
    _originalErrorHandler = FlutterError.onError;

    // Set our enhanced error handler
    FlutterError.onError = (errorDetails) {
      _handleFlutterError(errorDetails);
    };
  }

  static void _handleFlutterError(FlutterErrorDetails errorDetails) {
    // Log the error
    logFatal(
      'Unhandled Flutter error',
      error: errorDetails.exception,
      stackTrace: errorDetails.stack,
      tag: 'GlobalErrorHandler',
      metadata: {
        'errorDetails': errorDetails.toString(),
        'library': errorDetails.library,
        'context': errorDetails.context.toString(),
      }
    );

    // Call original handler if exists
    if (_originalErrorHandler != null) {
      _originalErrorHandler!(errorDetails);
    }

    // Show user-friendly error UI in debug mode
    if (appConfig.enableDebug) {
      // You could show a notification or overlay here
      _showErrorNotification(errorDetails.exception.toString());
    }
  }

  static void _showErrorNotification(String message) {
    // This is a simple implementation - you could use a more sophisticated notification system
    debugPrint('Error Notification: $message');
  }

  static Future<void> reportFatalError(dynamic error, StackTrace stackTrace, {
    String? context,
    Map<String, dynamic>? additionalData
  }) async {
    logFatal(
      'Fatal app error',
      error: error,
      stackTrace: stackTrace,
      tag: 'FatalError',
      metadata: {
        'context': context,
        'timestamp': DateTime.now().toIso8601String(),
        if (additionalData != null) ...additionalData,
        'isFatal': true,
      }
    );
  }

  static void reset() {
    if (_originalErrorHandler != null) {
      FlutterError.onError = _originalErrorHandler;
    }
  }
}

/// Convenient error boundary for page-level wrapping
class PageErrorBoundary extends EnhancedErrorBoundary {
  final bool allowPopOnError;

  const PageErrorBoundary({
    super.key,
    required super.child,
    required super.widgetName,
    super.routeName,
    super.showErrorScreen = true,
    this.allowPopOnError = true,
  });

  @override
  _PageErrorBoundaryState createState() => _PageErrorBoundaryState();
}

class _PageErrorBoundaryState extends _EnhancedErrorBoundaryState {
  @override
  Widget _buildErrorScreen() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Error'),
        backgroundColor: Colors.red[600],
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 80,
                  color: Colors.red[400],
                ),
                const SizedBox(height: 20),
                Text(
                  'Page Error',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.red[800],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  'Something went wrong in the ${widget.widgetName ?? 'page'}.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.red[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _resetError,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Try Again'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[600],
                      foregroundColor: Colors.white,
                    ),
                  ),
                const SizedBox(height: 20),
                Text(
                  'Error automatically reported to our team',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
