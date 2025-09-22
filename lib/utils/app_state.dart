import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_provider.dart';
import '../services/logging_service.dart';
import '../services/storage_service.dart';
import 'config.dart';

class AppStateManager extends ChangeNotifier {
  bool _isInitialized = false;
  bool _isLoading = true;
  String? _loadingMessage;
  Object? _initializationError;

  bool get isInitialized => _isInitialized;
  bool get isLoading => _isLoading;
  String? get loadingMessage => _loadingMessage;
  Object? get initializationError => _initializationError;

  Future<void> initializeApp(BuildContext context) async {
    try {
      _loadingMessage = 'Loading app configuration...';

      // Initialize configuration
      await appConfig.initialize();

      // Initialize logging service
      await logger.initialize();

      // Initialize auth provider
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // Try to restore previous session
      await _restoreSession();

      _isInitialized = true;
      _isLoading = false;
      _loadingMessage = null;

      logInfo('App initialized successfully', tag: 'AppInit');

      notifyListeners();

    } catch (error, stackTrace) {
      _initializationError = error;
      _isLoading = false;
      _loadingMessage = null;

      logFatal('Failed to initialize app', error: error, stackTrace: stackTrace, tag: 'AppInit');

      notifyListeners();
    }
  }

  Future<void> _restoreSession() async {
    try {
      _loadingMessage = 'Restoring session...';

      // Check for stored authentication
      final session = await storageService.getUserSession();

      if (session['user_id'] != null && session['auth_token'] != null) {
        // Validate token if still valid
        if (await storageService.isSessionValid()) {
          logInfo('Valid session restored for user: ${session['user_id']}', tag: 'Session');
          return;
        } else {
          logWarn('Session expired, clearing stored data', tag: 'Session');
          await storageService.clearUserSession();
        }
      }
    } catch (e) {
      logError('Failed to restore session', error: e, tag: 'Session');
    }
  }

  void retryInitialization(BuildContext context) {
    _isInitialized = false;
    _isLoading = true;
    _initializationError = null;
    notifyListeners();

    initializeApp(context);
  }
}

// Multi-provider setup for the app
class AppProviders extends StatelessWidget {
  final Widget child;

  const AppProviders({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => AppStateManager()),
      ],
      child: child,
    );
  }
}

// Provider helpers for easy access
T? tryRead<T>(BuildContext context) {
  try {
    return Provider.of<T>(context, listen: false);
  } catch (e) {
    logError('Failed to read provider', error: e, tag: 'Provider');
    return null;
  }
}

T readProvider<T>(BuildContext context) {
  try {
    return Provider.of<T>(context, listen: false);
  } catch (e) {
    logError('Failed to read provider', error: e, tag: 'Provider');
    rethrow;
  }
}
