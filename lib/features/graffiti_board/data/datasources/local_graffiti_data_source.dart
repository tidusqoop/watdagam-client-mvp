import 'package:isar/isar.dart';
import '../../../../shared/data/cache/cache_manager.dart';
import '../models/graffiti_note_model.dart';
import 'graffiti_data_source.dart';

/// Local implementation of GraffitiDataSource using Isar database
/// Provides caching and offline-first functionality
class LocalGraffitiDataSource implements GraffitiDataSource {
  final Isar _isar;
  final CacheManager _cache;

  LocalGraffitiDataSource({
    required Isar isar,
    required CacheManager cache,
  })  : _isar = isar,
        _cache = cache;

  @override
  Future<List<GraffitiNoteModel>> getGraffitiByWall(String wallId) async {
    final cacheKey = 'graffiti_wall_$wallId';

    // Check cache first
    final cached = _cache.get<List<GraffitiNoteModel>>(cacheKey);
    if (cached != null) return cached;

    // Query database
    final graffitis = await _isar.graffitiNoteModels
        .where()
        .wallIdEqualTo(wallId)
        .sortByCreatedAtDesc()
        .findAll();

    // Cache results
    _cache.set(cacheKey, graffitis);

    return graffitis;
  }

  @override
  Future<List<GraffitiNoteModel>> getGraffitiByUser(String userId) async {
    final cacheKey = 'graffiti_user_$userId';

    // Check cache first
    final cached = _cache.get<List<GraffitiNoteModel>>(cacheKey);
    if (cached != null) return cached;

    // Query database
    final graffitis = await _isar.graffitiNoteModels
        .where()
        .userIdEqualTo(userId)
        .sortByCreatedAtDesc()
        .findAll();

    // Cache results
    _cache.set(cacheKey, graffitis);

    return graffitis;
  }

  @override
  Future<GraffitiNoteModel?> getGraffitiById(String id) async {
    final cacheKey = 'graffiti_$id';

    // Check cache first
    final cached = _cache.get<GraffitiNoteModel>(cacheKey);
    if (cached != null) return cached;

    // Query database
    final graffiti = await _isar.graffitiNoteModels
        .where()
        .idEqualTo(id)
        .findFirst();

    if (graffiti != null) {
      _cache.set(cacheKey, graffiti);
    }

    return graffiti;
  }

  @override
  Future<GraffitiNoteModel> createGraffiti(GraffitiNoteModel graffiti) async {
    await _isar.writeTxn(() async {
      await _isar.graffitiNoteModels.put(graffiti);
    });

    // Cache the created graffiti
    _cache.set('graffiti_${graffiti.id}', graffiti);

    // Invalidate related caches
    _cache.remove('graffiti_wall_${graffiti.wallId}');
    _cache.remove('graffiti_user_${graffiti.userId}');
    _cache.remove('all_graffiti');
    _cache.remove('recent_graffiti');

    return graffiti;
  }

  @override
  Future<GraffitiNoteModel> updateGraffiti(GraffitiNoteModel graffiti) async {
    await _isar.writeTxn(() async {
      await _isar.graffitiNoteModels.put(graffiti);
    });

    // Update cache
    _cache.set('graffiti_${graffiti.id}', graffiti);

    // Invalidate related caches
    _cache.remove('graffiti_wall_${graffiti.wallId}');
    _cache.remove('graffiti_user_${graffiti.userId}');

    return graffiti;
  }

  @override
  Future<void> deleteGraffiti(String id) async {
    // Get graffiti first to know which caches to invalidate
    final graffiti = await getGraffitiById(id);

    await _isar.writeTxn(() async {
      await _isar.graffitiNoteModels.where().idEqualTo(id).deleteAll();
    });

    // Remove from cache
    _cache.remove('graffiti_$id');

    if (graffiti != null) {
      _cache.remove('graffiti_wall_${graffiti.wallId}');
      _cache.remove('graffiti_user_${graffiti.userId}');
    }

    _cache.remove('all_graffiti');
    _cache.remove('recent_graffiti');
  }

  @override
  Future<List<GraffitiNoteModel>> getWallGraffitiPaginated(
    String wallId, {
    int limit = 50,
    int offset = 0,
  }) async {
    return await _isar.graffitiNoteModels
        .where()
        .wallIdEqualTo(wallId)
        .sortByCreatedAtDesc()
        .offset(offset)
        .limit(limit)
        .findAll();
  }

  @override
  Future<List<GraffitiNoteModel>> getGraffitiAfter(DateTime timestamp) async {
    return await _isar.graffitiNoteModels
        .where()
        .createdAtGreaterThan(timestamp)
        .sortByCreatedAtDesc()
        .findAll();
  }

  @override
  Future<List<GraffitiNoteModel>> getGraffitiWithImages() async {
    return await _isar.graffitiNoteModels
        .where()
        .imagePathIsNotNull()
        .sortByCreatedAtDesc()
        .findAll();
  }

  @override
  Future<List<GraffitiNoteModel>> getRecentGraffiti({int limit = 10}) async {
    const cacheKey = 'recent_graffiti';

    // Check cache first
    final cached = _cache.get<List<GraffitiNoteModel>>(cacheKey);
    if (cached != null && cached.length >= limit) {
      return cached.take(limit).toList();
    }

    // Query database
    final graffitis = await _isar.graffitiNoteModels
        .where()
        .sortByCreatedAtDesc()
        .limit(limit)
        .findAll();

    // Cache results
    _cache.set(cacheKey, graffitis);

    return graffitis;
  }

  @override
  Future<List<GraffitiNoteModel>> searchGraffitiByText(String query) async {
    // Note: This is a simplified search - in production would use full-text search
    final allGraffiti = await getAllGraffiti();
    final lowerQuery = query.toLowerCase();

    return allGraffiti.where((graffiti) {
      return graffiti.content.text.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  @override
  Future<List<GraffitiNoteModel>> getAllGraffiti() async {
    const cacheKey = 'all_graffiti';

    // Check cache first
    final cached = _cache.get<List<GraffitiNoteModel>>(cacheKey);
    if (cached != null) return cached;

    // Query database
    final graffitis = await _isar.graffitiNoteModels
        .where()
        .sortByCreatedAtDesc()
        .findAll();

    // Cache results
    _cache.set(cacheKey, graffitis, duration: const Duration(minutes: 30));

    return graffitis;
  }

  @override
  Future<int> getGraffitiCountForWall(String wallId) async {
    return await _isar.graffitiNoteModels
        .where()
        .wallIdEqualTo(wallId)
        .count();
  }

  @override
  Future<int> getGraffitiCountForUser(String userId) async {
    return await _isar.graffitiNoteModels
        .where()
        .userIdEqualTo(userId)
        .count();
  }

  @override
  Future<bool> graffitiExists(String id) async {
    final count = await _isar.graffitiNoteModels
        .where()
        .idEqualTo(id)
        .count();
    return count > 0;
  }

  @override
  Future<List<GraffitiNoteModel>> createGraffitisBatch(
    List<GraffitiNoteModel> graffitis,
  ) async {
    await _isar.writeTxn(() async {
      await _isar.graffitiNoteModels.putAll(graffitis);
    });

    // Cache created graffitis
    for (final graffiti in graffitis) {
      _cache.set('graffiti_${graffiti.id}', graffiti);
    }

    // Invalidate list caches
    _cache.remove('all_graffiti');
    _cache.remove('recent_graffiti');

    // Invalidate wall and user specific caches
    final wallIds = graffitis.map((g) => g.wallId).toSet();
    final userIds = graffitis.map((g) => g.userId).toSet();

    for (final wallId in wallIds) {
      _cache.remove('graffiti_wall_$wallId');
    }

    for (final userId in userIds) {
      _cache.remove('graffiti_user_$userId');
    }

    return graffitis;
  }

  @override
  Future<GraffitiNoteModel> updateGraffitiVisibility(
    String id,
    bool isVisible,
  ) async {
    final graffiti = await getGraffitiById(id);
    if (graffiti == null) {
      throw Exception('Graffiti not found: $id');
    }

    final updatedMetadata = graffiti.metadata.copyWith(isVisible: isVisible);
    final updatedGraffiti = graffiti.copyWith(metadata: updatedMetadata);

    return await updateGraffiti(updatedGraffiti);
  }

  @override
  Future<List<GraffitiNoteModel>> getHiddenGraffiti() async {
    final allGraffiti = await getAllGraffiti();
    return allGraffiti.where((graffiti) => !graffiti.metadata.isVisible).toList();
  }

  @override
  Future<List<GraffitiNoteModel>> getGraffitiBySize(String sizeName) async {
    final allGraffiti = await getAllGraffiti();
    return allGraffiti.where((graffiti) => graffiti.content.size.name == sizeName).toList();
  }

  @override
  Future<void> deleteAllGraffitiForWall(String wallId) async {
    await _isar.writeTxn(() async {
      await _isar.graffitiNoteModels
          .where()
          .wallIdEqualTo(wallId)
          .deleteAll();
    });

    // Invalidate caches
    _cache.remove('graffiti_wall_$wallId');
    _cache.remove('all_graffiti');
    _cache.remove('recent_graffiti');
  }

  @override
  Future<void> deleteAllGraffitiByUser(String userId) async {
    await _isar.writeTxn(() async {
      await _isar.graffitiNoteModels
          .where()
          .userIdEqualTo(userId)
          .deleteAll();
    });

    // Invalidate caches
    _cache.remove('graffiti_user_$userId');
    _cache.remove('all_graffiti');
    _cache.remove('recent_graffiti');
  }

  @override
  Future<void> clearAllGraffiti() async {
    await _isar.writeTxn(() async {
      await _isar.graffitiNoteModels.clear();
    });

    // Clear cache
    _cache.clear();
  }

  @override
  Future<void> syncWithServer() async {
    // Placeholder for future server synchronization
    // This would implement:
    // 1. Upload local changes to server
    // 2. Download server changes
    // 3. Resolve conflicts
    // 4. Update local cache
  }
}