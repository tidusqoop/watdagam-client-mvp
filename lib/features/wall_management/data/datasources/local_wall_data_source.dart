import 'dart:math';
import 'package:isar/isar.dart';
import '../../../../shared/domain/value_objects/location.dart';
import '../../../../shared/data/cache/cache_manager.dart';
import '../models/wall_model.dart';
import 'wall_data_source.dart';

/// Local implementation of WallDataSource using Isar database
/// Provides geo-spatial queries and caching for offline-first functionality
class LocalWallDataSource implements WallDataSource {
  final Isar _isar;
  final CacheManager _cache;

  LocalWallDataSource({
    required Isar isar,
    required CacheManager cache,
  })  : _isar = isar,
        _cache = cache;

  @override
  Future<List<WallModel>> getNearbyWalls({
    required Location location,
    required double radiusKm,
  }) async {
    final cacheKey = 'nearby_walls_${location.latitude}_${location.longitude}_$radiusKm';

    // Check cache first
    final cached = _cache.get<List<WallModel>>(cacheKey);
    if (cached != null) return cached;

    // Calculate bounding box for efficient query
    final latDelta = radiusKm / 111.0; // 1 degree lat ≈ 111km
    final lngDelta = radiusKm / (111.0 * cos(location.latitude * pi / 180));

    // Query database with bounding box
    final walls = await _isar.wallModels
        .where()
        .latitudeBetween(
          location.latitude - latDelta,
          location.latitude + latDelta,
        )
        .and()
        .longitudeBetween(
          location.longitude - lngDelta,
          location.longitude + lngDelta,
        )
        .findAll();

    // Filter by exact distance using Haversine formula
    final filtered = walls.where((wall) {
      final distance = wall.distanceToLocation(location.latitude, location.longitude);
      return distance <= radiusKm;
    }).toList();

    // Sort by distance
    filtered.sort((a, b) {
      final distanceA = a.distanceToLocation(location.latitude, location.longitude);
      final distanceB = b.distanceToLocation(location.latitude, location.longitude);
      return distanceA.compareTo(distanceB);
    });

    // Cache results
    _cache.set(cacheKey, filtered);

    return filtered;
  }

  @override
  Future<WallModel?> getWallById(String id) async {
    final cacheKey = 'wall_$id';

    // Check cache first
    final cached = _cache.get<WallModel>(cacheKey);
    if (cached != null) return cached;

    // Query database
    final wall = await _isar.wallModels.where().idEqualTo(id).findFirst();

    if (wall != null) {
      _cache.set(cacheKey, wall);
    }

    return wall;
  }

  @override
  Future<List<WallModel>> getWallsInBounds({
    required Location southWest,
    required Location northEast,
  }) async {
    final cacheKey = 'walls_bounds_${southWest.latitude}_${southWest.longitude}_${northEast.latitude}_${northEast.longitude}';

    // Check cache first
    final cached = _cache.get<List<WallModel>>(cacheKey);
    if (cached != null) return cached;

    // Query database
    final walls = await _isar.wallModels
        .where()
        .latitudeBetween(southWest.latitude, northEast.latitude)
        .and()
        .longitudeBetween(southWest.longitude, northEast.longitude)
        .findAll();

    // Cache results
    _cache.set(cacheKey, walls);

    return walls;
  }

  @override
  Future<List<WallModel>> getVisitedWalls(String userId) async {
    // This would require a more complex query or denormalization
    // For now, we'll implement a simple approach
    final allWalls = await getAllWalls();
    // In a real implementation, this would be optimized with proper indexing
    return allWalls; // Placeholder - would need user-wall relationship table
  }

  @override
  Future<List<WallModel>> getWallsOwnedBy(String userId) async {
    // Note: This requires filtering based on metadata JSON content
    // For now, we'll get all walls and filter in memory
    final allWalls = await getAllWalls();
    return allWalls.where((wall) => wall.metadata.ownerId == userId).toList();
  }

  @override
  Future<WallModel> createWall(WallModel wall) async {
    await _isar.writeTxn(() async {
      await _isar.wallModels.put(wall);
    });

    // Cache the created wall
    _cache.set('wall_${wall.id}', wall);

    // Invalidate list caches
    _cache.remove('all_walls');

    return wall;
  }

  @override
  Future<WallModel> updateWall(WallModel wall) async {
    await _isar.writeTxn(() async {
      await _isar.wallModels.put(wall);
    });

    // Update cache
    _cache.set('wall_${wall.id}', wall);

    return wall;
  }

  @override
  Future<void> deleteWall(String id) async {
    await _isar.writeTxn(() async {
      await _isar.wallModels.where().idEqualTo(id).deleteAll();
    });

    // Remove from cache
    _cache.remove('wall_$id');
    _cache.remove('all_walls');
  }

  @override
  Future<List<WallModel>> searchWalls(String query) async {
    final lowerQuery = query.toLowerCase();

    return await _isar.wallModels
        .where()
        .filter()
        .nameContains(lowerQuery, caseSensitive: false)
        .or()
        .descriptionContains(lowerQuery, caseSensitive: false)
        .findAll();
  }

  @override
  Future<List<WallModel>> getAllWalls() async {
    const cacheKey = 'all_walls';

    // Check cache first
    final cached = _cache.get<List<WallModel>>(cacheKey);
    if (cached != null) return cached;

    // Query database
    final walls = await _isar.wallModels.where().findAll();

    // Cache results
    _cache.set(cacheKey, walls, duration: const Duration(minutes: 30));

    return walls;
  }

  @override
  Future<List<WallModel>> getWallsByStatus(String status) async {
    // Note: This requires filtering based on metadata JSON content
    final allWalls = await getAllWalls();
    return allWalls.where((wall) => wall.metadata.status.name == status).toList();
  }

  @override
  Future<List<WallModel>> getWallsWithCapacity() async {
    final allWalls = await getAllWalls();
    return allWalls.where((wall) => !wall.metadata.isAtCapacity()).toList();
  }

  @override
  Future<List<WallModel>> getRecentWalls({int limit = 10}) async {
    final walls = await _isar.wallModels
        .where()
        .sortByCreatedAtDesc()
        .limit(limit)
        .findAll();

    return walls;
  }

  @override
  Future<List<WallModel>> getPopularWalls({int limit = 10}) async {
    final allWalls = await getAllWalls();

    // Sort by graffiti count (popularity metric)
    allWalls.sort((a, b) => b.metadata.graffitiCount.compareTo(a.metadata.graffitiCount));

    return allWalls.take(limit).toList();
  }

  @override
  Future<bool> wallExists(String id) async {
    final count = await _isar.wallModels.where().idEqualTo(id).count();
    return count > 0;
  }

  @override
  Future<List<WallModel>> createWalls(List<WallModel> walls) async {
    await _isar.writeTxn(() async {
      await _isar.wallModels.putAll(walls);
    });

    // Cache created walls
    for (final wall in walls) {
      _cache.set('wall_${wall.id}', wall);
    }

    // Invalidate list caches
    _cache.remove('all_walls');

    return walls;
  }

  @override
  Future<WallModel> updateGraffitiCount(String wallId, int newCount) async {
    final wall = await getWallById(wallId);
    if (wall == null) {
      throw Exception('Wall not found: $wallId');
    }

    final updatedMetadata = wall.metadata.copyWith(graffitiCount: newCount);
    final updatedWall = wall.copyWith(metadata: updatedMetadata);

    return await updateWall(updatedWall);
  }

  @override
  Future<WallModel> incrementGraffitiCount(String wallId) async {
    final wall = await getWallById(wallId);
    if (wall == null) {
      throw Exception('Wall not found: $wallId');
    }

    final updatedMetadata = wall.metadata.addGraffiti();
    final updatedWall = wall.copyWith(metadata: updatedMetadata);

    return await updateWall(updatedWall);
  }

  @override
  Future<WallModel> decrementGraffitiCount(String wallId) async {
    final wall = await getWallById(wallId);
    if (wall == null) {
      throw Exception('Wall not found: $wallId');
    }

    final updatedMetadata = wall.metadata.removeGraffiti();
    final updatedWall = wall.copyWith(metadata: updatedMetadata);

    return await updateWall(updatedWall);
  }

  @override
  Future<void> clearAllWalls() async {
    await _isar.writeTxn(() async {
      await _isar.wallModels.clear();
    });

    // Clear cache
    _cache.clear();
  }
}