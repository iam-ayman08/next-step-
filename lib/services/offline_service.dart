import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Offline data caching and synchronization service
class OfflineService {
  static const String _cachePrefix = 'offline_cache_';
  static const String _syncQueueKey = 'sync_queue';
  static const String _lastSyncKey = 'last_sync_time';
  static const Duration _cacheExpiry = Duration(hours: 24);

  static final OfflineService _instance = OfflineService._internal();
  factory OfflineService() => _instance;
  OfflineService._internal();

  final Map<String, dynamic> _memoryCache = {};
  bool _isOnline = true;

  // Cache data with expiry
  Future<void> cacheData(String key, dynamic data) async {
    try {
      final cacheEntry = {
        'data': data,
        'timestamp': DateTime.now().toIso8601String(),
        'expiry': DateTime.now().add(_cacheExpiry).toIso8601String(),
      };

      _memoryCache[key] = cacheEntry;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('$_cachePrefix$key', jsonEncode(cacheEntry));

      debugPrint('Data cached successfully: $key');
    } catch (e) {
      debugPrint('Failed to cache data: $e');
    }
  }

  // Retrieve cached data
  Future<dynamic> getCachedData(String key) async {
    try {
      // Check memory cache first
      if (_memoryCache.containsKey(key)) {
        final entry = _memoryCache[key];
        if (!_isExpired(entry)) {
          return entry['data'];
        } else {
          _memoryCache.remove(key);
        }
      }

      // Check persistent storage
      final prefs = await SharedPreferences.getInstance();
      final cachedString = prefs.getString('$_cachePrefix$key');

      if (cachedString != null) {
        final entry = jsonDecode(cachedString);
        if (!_isExpired(entry)) {
          _memoryCache[key] = entry;
          return entry['data'];
        } else {
          await prefs.remove('$_cachePrefix$key');
        }
      }
    } catch (e) {
      debugPrint('Failed to retrieve cached data: $e');
    }

    return null;
  }

  // Check if cache entry is expired
  bool _isExpired(Map<String, dynamic> entry) {
    final expiryString = entry['expiry'];
    if (expiryString == null) return false;

    final expiry = DateTime.parse(expiryString);
    return DateTime.now().isAfter(expiry);
  }

  // Clear expired cache entries
  Future<void> clearExpiredCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();

      for (final key in keys) {
        if (key.startsWith(_cachePrefix)) {
          final cachedString = prefs.getString(key);
          if (cachedString != null) {
            final entry = jsonDecode(cachedString);
            if (_isExpired(entry)) {
              await prefs.remove(key);
              _memoryCache.remove(key.replaceFirst(_cachePrefix, ''));
            }
          }
        }
      }

      debugPrint('Expired cache entries cleared');
    } catch (e) {
      debugPrint('Failed to clear expired cache: $e');
    }
  }

  // Clear all cache
  Future<void> clearAllCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();

      for (final key in keys) {
        if (key.startsWith(_cachePrefix)) {
          await prefs.remove(key);
        }
      }

      _memoryCache.clear();
      debugPrint('All cache cleared');
    } catch (e) {
      debugPrint('Failed to clear cache: $e');
    }
  }

  // Add operation to sync queue
  Future<void> addToSyncQueue(
    String operationId,
    Map<String, dynamic> operation,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final queue = await getSyncQueue();

      queue[operationId] = {
        ...operation,
        'timestamp': DateTime.now().toIso8601String(),
        'id': operationId,
      };

      await prefs.setString(_syncQueueKey, jsonEncode(queue));
      debugPrint('Operation added to sync queue: $operationId');
    } catch (e) {
      debugPrint('Failed to add operation to sync queue: $e');
    }
  }

  // Get sync queue
  Future<Map<String, dynamic>> getSyncQueue() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final queueString = prefs.getString(_syncQueueKey);

      if (queueString != null) {
        return Map<String, dynamic>.from(jsonDecode(queueString));
      }
    } catch (e) {
      debugPrint('Failed to get sync queue: $e');
    }

    return {};
  }

  // Remove operation from sync queue
  Future<void> removeFromSyncQueue(String operationId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final queue = await getSyncQueue();

      queue.remove(operationId);
      await prefs.setString(_syncQueueKey, jsonEncode(queue));

      debugPrint('Operation removed from sync queue: $operationId');
    } catch (e) {
      debugPrint('Failed to remove operation from sync queue: $e');
    }
  }

  // Process sync queue
  Future<void> processSyncQueue() async {
    if (!_isOnline) return;

    try {
      final queue = await getSyncQueue();

      for (final entry in queue.entries) {
        try {
          // Process each operation (this would be customized based on operation type)
          await _processOperation(entry.value);
          await removeFromSyncQueue(entry.key);
        } catch (e) {
          debugPrint('Failed to process operation ${entry.key}: $e');
          // Keep failed operations in queue for retry
        }
      }

      await setLastSyncTime(DateTime.now());
      debugPrint('Sync queue processed successfully');
    } catch (e) {
      debugPrint('Failed to process sync queue: $e');
    }
  }

  // Process individual operation (placeholder - customize based on your needs)
  Future<void> _processOperation(Map<String, dynamic> operation) async {
    final type = operation['type'];

    switch (type) {
      case 'create':
        // Handle create operations
        break;
      case 'update':
        // Handle update operations
        break;
      case 'delete':
        // Handle delete operations
        break;
      default:
        debugPrint('Unknown operation type: $type');
    }
  }

  // Set last sync time
  Future<void> setLastSyncTime(DateTime time) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_lastSyncKey, time.toIso8601String());
    } catch (e) {
      debugPrint('Failed to set last sync time: $e');
    }
  }

  // Get last sync time
  Future<DateTime?> getLastSyncTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timeString = prefs.getString(_lastSyncKey);

      if (timeString != null) {
        return DateTime.parse(timeString);
      }
    } catch (e) {
      debugPrint('Failed to get last sync time: $e');
    }

    return null;
  }

  // Set online status
  void setOnlineStatus(bool isOnline) {
    _isOnline = isOnline;
    if (isOnline) {
      // Trigger sync when coming back online
      processSyncQueue();
    }
  }

  // Get cache statistics
  Future<Map<String, dynamic>> getCacheStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      int totalEntries = 0;
      int expiredEntries = 0;

      for (final key in keys) {
        if (key.startsWith(_cachePrefix)) {
          totalEntries++;
          final cachedString = prefs.getString(key);
          if (cachedString != null) {
            final entry = jsonDecode(cachedString);
            if (_isExpired(entry)) {
              expiredEntries++;
            }
          }
        }
      }

      return {
        'totalEntries': totalEntries,
        'expiredEntries': expiredEntries,
        'memoryCacheSize': _memoryCache.length,
        'isOnline': _isOnline,
      };
    } catch (e) {
      debugPrint('Failed to get cache stats: $e');
      return {};
    }
  }

  // Initialize offline service
  Future<void> initialize() async {
    await clearExpiredCache();
    debugPrint('Offline service initialized');
  }
}

// Offline-aware data provider
class OfflineDataProvider<T> {
  final String cacheKey;
  final Future<T> Function() fetchFunction;
  final Duration cacheDuration;

  const OfflineDataProvider({
    required this.cacheKey,
    required this.fetchFunction,
    this.cacheDuration = const Duration(hours: 1),
  });

  Future<T?> getData() async {
    final offlineService = OfflineService();

    // Try to get cached data first
    final cachedData = await offlineService.getCachedData(cacheKey);
    if (cachedData != null) {
      return cachedData as T;
    }

    // If no cached data or cache expired, fetch fresh data
    try {
      final freshData = await fetchFunction();

      // Cache the fresh data
      await offlineService.cacheData(cacheKey, freshData);

      return freshData;
    } catch (e) {
      debugPrint('Failed to fetch fresh data: $e');
      // Return null if both cache and fresh data fail
      return null;
    }
  }

  Future<void> invalidateCache() async {
    final offlineService = OfflineService();
    await offlineService.cacheData(cacheKey, null);
  }
}

// Sync status indicator
enum SyncStatus { synced, syncing, offline, error }

class SyncIndicator extends StatelessWidget {
  final SyncStatus status;
  final VoidCallback? onTap;

  const SyncIndicator({super.key, required this.status, this.onTap});

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color color;
    String tooltip;

    switch (status) {
      case SyncStatus.synced:
        icon = Icons.cloud_done;
        color = Colors.green;
        tooltip = 'Data is synced';
        break;
      case SyncStatus.syncing:
        icon = Icons.sync;
        color = Colors.blue;
        tooltip = 'Syncing data...';
        break;
      case SyncStatus.offline:
        icon = Icons.cloud_off;
        color = Colors.orange;
        tooltip = 'Offline mode';
        break;
      case SyncStatus.error:
        icon = Icons.sync_problem;
        color = Colors.red;
        tooltip = 'Sync error - tap to retry';
        break;
    }

    return IconButton(
      icon: Icon(icon, color: color),
      onPressed: onTap,
      tooltip: tooltip,
    );
  }
}

// Conflict resolution handler
class ConflictResolver {
  static Future<ConflictResolution> resolveConflict(
    Map<String, dynamic> localData,
    Map<String, dynamic> remoteData,
    String conflictField,
  ) async {
    // This is a simple implementation - in a real app, you might show a dialog
    // to let the user choose which version to keep

    final localTimestamp = DateTime.parse(
      localData['updatedAt'] ??
          localData['timestamp'] ??
          DateTime.now().toIso8601String(),
    );
    final remoteTimestamp = DateTime.parse(
      remoteData['updatedAt'] ??
          remoteData['timestamp'] ??
          DateTime.now().toIso8601String(),
    );

    if (localTimestamp.isAfter(remoteTimestamp)) {
      return ConflictResolution.keepLocal;
    } else if (remoteTimestamp.isAfter(localTimestamp)) {
      return ConflictResolution.keepRemote;
    } else {
      // If timestamps are equal, keep the remote version
      return ConflictResolution.keepRemote;
    }
  }
}

enum ConflictResolution { keepLocal, keepRemote, merge }
