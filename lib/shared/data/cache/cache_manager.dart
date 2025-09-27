import 'cache_entry.dart';

/// In-memory cache manager with TTL (Time To Live) support
/// Provides efficient caching for frequently accessed data
class CacheManager {
  static const Duration CACHE_DURATION = Duration(hours: 1);

  final Map<String, CacheEntry> _cache = {};

  /// Retrieves a cached value by key
  /// Returns null if key doesn't exist or has expired
  T? get<T>(String key) {
    final entry = _cache[key];
    if (entry != null && !entry.isExpired) {
      return entry.data as T;
    }

    // Remove expired entry
    if (entry != null && entry.isExpired) {
      _cache.remove(key);
    }

    return null;
  }

  /// Stores a value in cache with optional custom duration
  void set<T>(String key, T data, {Duration? duration}) {
    _cache[key] = CacheEntry(
      data: data,
      expiresAt: DateTime.now().add(duration ?? CACHE_DURATION),
    );
  }

  /// Removes a specific key from cache
  void remove(String key) {
    _cache.remove(key);
  }

  /// Clears all cached entries
  void clear() {
    _cache.clear();
  }

  /// Removes all expired entries from cache
  void cleanupExpired() {
    final expiredKeys = _cache.entries
        .where((entry) => entry.value.isExpired)
        .map((entry) => entry.key)
        .toList();

    for (final key in expiredKeys) {
      _cache.remove(key);
    }
  }

  /// Checks if a key exists and is not expired
  bool contains(String key) {
    final entry = _cache[key];
    if (entry == null) return false;

    if (entry.isExpired) {
      _cache.remove(key);
      return false;
    }

    return true;
  }

  /// Returns the number of cached entries (including expired ones)
  int get size => _cache.length;

  /// Returns the number of valid (non-expired) entries
  int get validEntryCount => _cache.values.where((entry) => !entry.isExpired).length;

  /// Returns cache statistics for debugging
  Map<String, dynamic> get stats => {
    'totalEntries': size,
    'validEntries': validEntryCount,
    'expiredEntries': size - validEntryCount,
    'hitRatio': _hitCount / (_hitCount + _missCount).clamp(1, double.infinity),
    'hits': _hitCount,
    'misses': _missCount,
  };

  int _hitCount = 0;
  int _missCount = 0;

  /// Internal method to track cache hits/misses for statistics
  T? _getWithStats<T>(String key) {
    final result = get<T>(key);
    if (result != null) {
      _hitCount++;
    } else {
      _missCount++;
    }
    return result;
  }

  /// Gets value with cache statistics tracking
  T? getWithStats<T>(String key) => _getWithStats<T>(key);
}