import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static AppConfig? _instance;
  late String baseUrl;
  late String socketUrl;
  late String googleClientId;
  late String googleRedirectUri;
  late String firebaseApiKey;
  late String firebaseAppId;
  late String firebaseProjectId;
  late String sentryDsn;
  late String appEnv;
  late String encryptionKey;
  late String openAiApiKey;
  late int sessionTimeout;
  late bool enableAnalytics;
  late bool enableCrashReporting;
  late bool enableDebug;
  late int maxAiTokens;

  factory AppConfig() {
    _instance ??= AppConfig._internal();
    return _instance!;
  }

  AppConfig._internal();

  Future<void> initialize() async {
    // Load environment variables
    loadConfig();
  }

  void loadConfig() {
    // Load environment variables from .env file
    if (!dotenv.isInitialized) {
      dotenv.load(fileName: ".env");
    }

    // API Configuration
    baseUrl = dotenv.get('API_BASE_URL', fallback: 'http://localhost:8000/api/v1');
    socketUrl = dotenv.get('SOCKET_URL', fallback: 'http://localhost:8000');

    // Google OAuth configuration
    bool isProduction = dotenv.get('APP_ENV', fallback: 'development') == 'production';
    googleClientId = isProduction
        ? dotenv.get('PROD_GOOGLE_CLIENT_ID', fallback: dotenv.get('GOOGLE_CLIENT_ID', fallback: ''))
        : dotenv.get('GOOGLE_CLIENT_ID', fallback: '');

    googleRedirectUri = isProduction
        ? dotenv.get('PROD_GOOGLE_REDIRECT_URI', fallback: dotenv.get('GOOGLE_REDIRECT_URI', fallback: ''))
        : dotenv.get('GOOGLE_REDIRECT_URI', fallback: '');

    // Firebase configuration
    firebaseApiKey = dotenv.get('FIREBASE_API_KEY', fallback: '');
    firebaseAppId = dotenv.get('FIREBASE_APP_ID', fallback: '');
    firebaseProjectId = dotenv.get('FIREBASE_PROJECT_ID', fallback: '');

    // Sentry configuration
    sentryDsn = dotenv.get('SENTRY_DSN', fallback: '');

    // AI configuration
    openAiApiKey = dotenv.get('OPENAI_API_KEY', fallback: 'your-openai-api-key-here');
    maxAiTokens = int.tryParse(dotenv.get('MAX_AI_TOKENS', fallback: '500')) ?? 500;

    // App configuration
    appEnv = dotenv.get('APP_ENV', fallback: 'development');
    encryptionKey = dotenv.get('ENCRYPTION_KEY', fallback: 'your-random-32-character-key-here');
    sessionTimeout = int.tryParse(dotenv.get('SESSION_TIMEOUT', fallback: '60')) ?? 60;

    // Feature flags
    enableAnalytics = _parseBool(dotenv.get('ENABLE_ANALYTICS', fallback: 'true'));
    enableCrashReporting = _parseBool(dotenv.get('ENABLE_CRASH_REPORTING', fallback: 'true'));
    enableDebug = _parseBool(dotenv.get('ENABLE_DEBUG', fallback: 'true'));
  }

  bool _parseBool(String value) {
    return value.toLowerCase() == 'true';
  }

  // Helper methods to check environment
  bool get isDevelopment => appEnv == 'development';
  bool get isStaging => appEnv == 'staging';
  bool get isProduction => appEnv == 'production';

  // Helper methods for configuration validation
  bool get hasValidGoogleConfig => googleClientId.isNotEmpty && googleRedirectUri.isNotEmpty;
  bool get hasValidFirebaseConfig => firebaseApiKey.isNotEmpty && firebaseProjectId.isNotEmpty;
  bool get hasValidAiConfig => openAiApiKey.isNotEmpty && openAiApiKey != 'your-openai-api-key-here';
  bool get hasValidEncryption => encryptionKey.isNotEmpty && encryptionKey != 'your-random-32-character-key-here';

  // Network timeout configurations
  int get connectionTimeout => int.tryParse(dotenv.get('CONNECTION_TIMEOUT_SECONDS', fallback: '10')) ?? 10;
  int get receiveTimeout => int.tryParse(dotenv.get('RECEIVE_TIMEOUT_SECONDS', fallback: '10')) ?? 10;
  int get retryAttempts => int.tryParse(dotenv.get('RETRY_ATTEMPTS', fallback: '3')) ?? 3;

  // Cache configuration
  int get cacheDurationMinutes => int.tryParse(dotenv.get('CACHE_DURATION_MINUTES', fallback: '30')) ?? 30;
  int get maxCacheSizeMB => int.tryParse(dotenv.get('MAX_CACHE_SIZE_MB', fallback: '50')) ?? 50;

  // Feature flags
  bool get isAiResumeBuilderEnabled => _parseBool(dotenv.get('FEATURE_AI_RESUME_BUILDER', fallback: 'true'));
  bool get isVideoCallingEnabled => _parseBool(dotenv.get('FEATURE_VIDEO_CALLING', fallback: 'true'));
  bool get isAdvancedAnalyticsEnabled => _parseBool(dotenv.get('FEATURE_ADVANCED_ANALYTICS', fallback: 'false'));
  bool get isOfflineModeEnabled => _parseBool(dotenv.get('FEATURE_OFFLINE_MODE', fallback: 'false'));

  // Logging configuration
  String get logLevel => dotenv.get('LOG_LEVEL', fallback: 'info');
  bool get showPerformanceOverlay => _parseBool(dotenv.get('SHOW_PERFORMANCE_OVERLAY', fallback: 'false'));
  bool get logNetworkRequests => _parseBool(dotenv.get('LOG_NETWORK_REQUESTS', fallback: 'true'));

  // Other external services
  String get githubClientId => dotenv.get('GITHUB_CLIENT_ID', fallback: '');
  String get githubClientSecret => dotenv.get('GITHUB_CLIENT_SECRET', fallback: '');
  String get linkedinClientId => dotenv.get('LINKEDIN_CLIENT_ID', fallback: '');
  String get linkedinClientSecret => dotenv.get('LINKEDIN_CLIENT_SECRET', fallback: '');

  // File upload configuration
  int get maxFileSizeMB => int.tryParse(dotenv.get('MAX_FILE_SIZE_MB', fallback: '10')) ?? 10;
  List<String> get supportedFileTypes => dotenv.get('SUPPORTED_FILE_TYPES', fallback: 'pdf,doc,docx,jpg,jpeg,png,gif').split(',');

  // Analytics tracking ID
  String get analyticsTrackingId => dotenv.get('ANALYTICS_TRACKING_ID', fallback: '');
}

// Global configuration instance
final appConfig = AppConfig();
