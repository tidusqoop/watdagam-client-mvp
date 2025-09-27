/// Represents a cached entry with expiration logic
class CacheEntry<T> {
  final T data;
  final DateTime expiresAt;

  const CacheEntry({
    required this.data,
    required this.expiresAt,
  });

  /// Checks if this cache entry has expired
  bool get isExpired => DateTime.now().isAfter(expiresAt);

  /// Checks if this cache entry is still valid
  bool get isValid => !isExpired;

  @override
  String toString() {
    return 'CacheEntry(data: $data, expiresAt: $expiresAt, isExpired: $isExpired)';
  }
}