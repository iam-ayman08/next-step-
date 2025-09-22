import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ErrorBoundary extends StatefulWidget {
  final Widget child;
  final Widget? errorWidget;
  final Function(Object error, StackTrace stackTrace)? onError;

  const ErrorBoundary({
    super.key,
    required this.child,
    this.errorWidget,
    this.onError,
  });

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  Object? _error;
  StackTrace? _stackTrace;

  @override
  void initState() {
    super.initState();
    // Set up error handling for this subtree
    ErrorWidget.builder = (FlutterErrorDetails details) {
      _handleError(details.exception, details.stack ?? StackTrace.current);
      return _buildErrorWidget();
    };
  }

  void _handleError(Object error, StackTrace stackTrace) {
    setState(() {
      _error = error;
      _stackTrace = stackTrace;
    });

    widget.onError?.call(error, stackTrace);

    // Log error for debugging (in production, send to analytics)
    debugPrint('Error caught by ErrorBoundary: $error');
    debugPrint('Stack trace: $stackTrace');
  }

  Widget _buildErrorWidget() {
    if (widget.errorWidget != null) {
      return widget.errorWidget!;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, color: Colors.red[600], size: 48),
          const SizedBox(height: 16),
          Text(
            'Something went wrong',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.red[800],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'We encountered an unexpected error. Please try again.',
            style: GoogleFonts.inter(fontSize: 14, color: Colors.red[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _error = null;
                _stackTrace = null;
              });
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[600],
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return _buildErrorWidget();
    }

    return widget.child;
  }
}

// Specialized error boundary for network operations
class NetworkErrorBoundary extends StatefulWidget {
  final Widget child;
  final VoidCallback? onRetry;
  final String? customMessage;

  const NetworkErrorBoundary({
    super.key,
    required this.child,
    this.onRetry,
    this.customMessage,
  });

  @override
  State<NetworkErrorBoundary> createState() => _NetworkErrorBoundaryState();
}

class _NetworkErrorBoundaryState extends State<NetworkErrorBoundary> {
  Object? _error;

  void _handleError(Object error) {
    setState(() => _error = error);
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi_off, size: 64, color: Colors.orange[400]),
            const SizedBox(height: 16),
            Text(
              widget.customMessage ?? 'Network Error',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please check your internet connection and try again.',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[400]
                    : Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                setState(() => _error = null);
                widget.onRetry?.call();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.secondary,
                foregroundColor: Theme.of(context).colorScheme.onSecondary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return widget.child;
  }
}

// Loading states widget
class LoadingState extends StatelessWidget {
  final String? message;
  final double? size;
  final Color? color;

  const LoadingState({super.key, this.message, this.size, this.color});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: size ?? 40,
            height: size ?? 40,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(
                color ?? Theme.of(context).colorScheme.secondary,
              ),
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[400]
                    : Colors.grey[600],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// Skeleton loading for better UX
class SkeletonLoader extends StatefulWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const SkeletonLoader({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
  });

  @override
  State<SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<SkeletonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius ?? BorderRadius.circular(8),
            gradient: LinearGradient(
              colors: [
                Colors.grey[300]!.withValues(alpha: 0.5),
                Colors.grey[200]!.withValues(alpha: 0.8),
                Colors.grey[300]!.withValues(alpha: 0.5),
              ],
              stops: [0.0, _animation.value, 1.0],
            ),
          ),
        );
      },
    );
  }
}

// Shimmer effect for loading states
class ShimmerEffect extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const ShimmerEffect({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 1500),
  });

  @override
  State<ShimmerEffect> createState() => _ShimmerEffectState();
}

class _ShimmerEffectState extends State<ShimmerEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this)
      ..repeat();

    _animation = Tween<double>(
      begin: -1.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) {
        return LinearGradient(
          colors: [
            Colors.grey[300]!.withValues(alpha: 0.3),
            Colors.white.withValues(alpha: 0.8),
            Colors.grey[300]!.withValues(alpha: 0.3),
          ],
          stops: [0.0, _animation.value * 0.5 + 0.5, 1.0],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ).createShader(bounds);
      },
      child: widget.child,
    );
  }
}

// Async operation wrapper with loading and error states
class AsyncWrapper<T> extends StatelessWidget {
  final Future<T>? future;
  final Widget Function(T data) builder;
  final Widget? loadingWidget;
  final Widget Function(Object error)? errorBuilder;
  final VoidCallback? onRetry;

  const AsyncWrapper({
    super.key,
    required this.future,
    required this.builder,
    this.loadingWidget,
    this.errorBuilder,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return loadingWidget ?? const LoadingState(message: 'Loading...');
        }

        if (snapshot.hasError) {
          return errorBuilder?.call(snapshot.error!) ??
              NetworkErrorBoundary(
                onRetry: onRetry,
                customMessage: 'Failed to load data',
                child: const SizedBox.shrink(),
              );
        }

        if (snapshot.hasData) {
          return builder(snapshot.data as T);
        }

        return const LoadingState(message: 'Loading...');
      },
    );
  }
}

// Stream wrapper for reactive data
class StreamWrapper<T> extends StatelessWidget {
  final Stream<T>? stream;
  final Widget Function(T data) builder;
  final Widget? loadingWidget;
  final Widget Function(Object error)? errorBuilder;
  final T? initialData;

  const StreamWrapper({
    super.key,
    required this.stream,
    required this.builder,
    this.loadingWidget,
    this.errorBuilder,
    this.initialData,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<T>(
      stream: stream,
      initialData: initialData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            initialData == null) {
          return loadingWidget ?? const LoadingState(message: 'Loading...');
        }

        if (snapshot.hasError) {
          return errorBuilder?.call(snapshot.error!) ??
              NetworkErrorBoundary(
                customMessage: 'Failed to load data',
                child: const SizedBox.shrink(),
              );
        }

        if (snapshot.hasData) {
          return builder(snapshot.data as T);
        }

        return const LoadingState(message: 'Loading...');
      },
    );
  }
}
