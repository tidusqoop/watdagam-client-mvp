import '../../../../shared/domain/value_objects/location.dart';
import '../../domain/entities/wall.dart';
import '../../domain/repositories/wall_repository.dart';
import '../datasources/wall_data_source.dart';
import '../models/wall_model.dart';

/// Implementation of WallRepository that bridges domain and data layers
/// Converts between domain entities and data models
class WallRepositoryImpl implements WallRepository {
  final WallDataSource _dataSource;

  WallRepositoryImpl({
    required WallDataSource dataSource,
  }) : _dataSource = dataSource;

  @override
  Future<List<Wall>> getNearbyWalls({
    required Location location,
    required double radiusKm,
  }) async {
    final wallModels = await _dataSource.getNearbyWalls(
      location: location,
      radiusKm: radiusKm,
    );
    return wallModels.map((model) => model.toDomain()).toList();
  }

  @override
  Future<Wall?> getWallById(String id) async {
    final wallModel = await _dataSource.getWallById(id);
    return wallModel?.toDomain();
  }

  @override
  Future<List<Wall>> getVisitedWalls(String userId) async {
    final wallModels = await _dataSource.getVisitedWalls(userId);
    return wallModels.map((model) => model.toDomain()).toList();
  }

  @override
  Future<List<Wall>> getWallsInBounds({
    required Location southWest,
    required Location northEast,
  }) async {
    final wallModels = await _dataSource.getWallsInBounds(
      southWest: southWest,
      northEast: northEast,
    );
    return wallModels.map((model) => model.toDomain()).toList();
  }

  @override
  Future<Wall> createWall(Wall wall) async {
    final wallModel = WallModel.fromDomain(wall);
    final createdModel = await _dataSource.createWall(wallModel);
    return createdModel.toDomain();
  }

  @override
  Future<Wall> updateWall(Wall wall) async {
    final wallModel = WallModel.fromDomain(wall);
    final updatedModel = await _dataSource.updateWall(wallModel);
    return updatedModel.toDomain();
  }

  @override
  Future<void> deleteWall(String id) async {
    await _dataSource.deleteWall(id);
  }

  /// Additional helper methods for extended functionality

  /// Gets walls owned by a specific user
  Future<List<Wall>> getWallsOwnedBy(String userId) async {
    final wallModels = await _dataSource.getWallsOwnedBy(userId);
    return wallModels.map((model) => model.toDomain()).toList();
  }

  /// Searches walls by name or description
  Future<List<Wall>> searchWalls(String query) async {
    final wallModels = await _dataSource.searchWalls(query);
    return wallModels.map((model) => model.toDomain()).toList();
  }

  /// Gets all walls (useful for development/testing)
  Future<List<Wall>> getAllWalls() async {
    final wallModels = await _dataSource.getAllWalls();
    return wallModels.map((model) => model.toDomain()).toList();
  }

  /// Gets walls by status
  Future<List<Wall>> getWallsByStatus(String status) async {
    final wallModels = await _dataSource.getWallsByStatus(status);
    return wallModels.map((model) => model.toDomain()).toList();
  }

  /// Gets walls with available capacity
  Future<List<Wall>> getWallsWithCapacity() async {
    final wallModels = await _dataSource.getWallsWithCapacity();
    return wallModels.map((model) => model.toDomain()).toList();
  }

  /// Gets recently created walls
  Future<List<Wall>> getRecentWalls({int limit = 10}) async {
    final wallModels = await _dataSource.getRecentWalls(limit: limit);
    return wallModels.map((model) => model.toDomain()).toList();
  }

  /// Gets popular walls (high graffiti count)
  Future<List<Wall>> getPopularWalls({int limit = 10}) async {
    final wallModels = await _dataSource.getPopularWalls(limit: limit);
    return wallModels.map((model) => model.toDomain()).toList();
  }

  /// Checks if a wall exists
  Future<bool> wallExists(String id) async {
    return await _dataSource.wallExists(id);
  }

  /// Bulk creates walls (for testing/seeding)
  Future<List<Wall>> createWalls(List<Wall> walls) async {
    final wallModels = walls.map((wall) => WallModel.fromDomain(wall)).toList();
    final createdModels = await _dataSource.createWalls(wallModels);
    return createdModels.map((model) => model.toDomain()).toList();
  }

  /// Updates wall graffiti count
  Future<Wall> updateGraffitiCount(String wallId, int newCount) async {
    final updatedModel = await _dataSource.updateGraffitiCount(wallId, newCount);
    return updatedModel.toDomain();
  }

  /// Increments wall graffiti count
  Future<Wall> incrementGraffitiCount(String wallId) async {
    final updatedModel = await _dataSource.incrementGraffitiCount(wallId);
    return updatedModel.toDomain();
  }

  /// Decrements wall graffiti count
  Future<Wall> decrementGraffitiCount(String wallId) async {
    final updatedModel = await _dataSource.decrementGraffitiCount(wallId);
    return updatedModel.toDomain();
  }

  /// Clears all walls (for testing)
  Future<void> clearAllWalls() async {
    await _dataSource.clearAllWalls();
  }

  /// Calculates distance from a location to a wall
  Future<double> getDistanceToWall(String wallId, Location userLocation) async {
    final wall = await getWallById(wallId);
    if (wall == null) {
      throw Exception('Wall not found: $wallId');
    }

    return wall.location.distanceTo(userLocation);
  }

  /// Gets walls within a specific distance from user location
  Future<List<Wall>> getWallsWithinDistance({
    required Location userLocation,
    required double maxDistanceKm,
  }) async {
    return await getNearbyWalls(
      location: userLocation,
      radiusKm: maxDistanceKm,
    );
  }

  /// Gets the closest wall to a location
  Future<Wall?> getClosestWall(Location userLocation) async {
    final nearbyWalls = await getNearbyWalls(
      location: userLocation,
      radiusKm: 50.0, // Search within 50km
    );

    if (nearbyWalls.isEmpty) return null;

    // The first wall is the closest (sorted by distance in data source)
    return nearbyWalls.first;
  }
}