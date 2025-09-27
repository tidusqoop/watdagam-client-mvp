import '../../../../shared/domain/value_objects/location.dart';
import '../models/wall_model.dart';

/// Abstract data source interface for Wall operations
/// Defines contract for data access operations
abstract class WallDataSource {
  /// Retrieves walls near a given location within radius
  Future<List<WallModel>> getNearbyWalls({
    required Location location,
    required double radiusKm,
  });

  /// Retrieves a wall by ID
  Future<WallModel?> getWallById(String id);

  /// Retrieves walls within bounding box coordinates
  Future<List<WallModel>> getWallsInBounds({
    required Location southWest,
    required Location northEast,
  });

  /// Gets walls visited by a specific user
  Future<List<WallModel>> getVisitedWalls(String userId);

  /// Gets walls owned by a specific user
  Future<List<WallModel>> getWallsOwnedBy(String userId);

  /// Creates a new wall
  Future<WallModel> createWall(WallModel wall);

  /// Updates an existing wall
  Future<WallModel> updateWall(WallModel wall);

  /// Deletes a wall by ID
  Future<void> deleteWall(String id);

  /// Searches walls by name or description
  Future<List<WallModel>> searchWalls(String query);

  /// Gets all walls (for admin purposes)
  Future<List<WallModel>> getAllWalls();

  /// Gets walls by status
  Future<List<WallModel>> getWallsByStatus(String status);

  /// Gets walls with available capacity
  Future<List<WallModel>> getWallsWithCapacity();

  /// Gets recently created walls
  Future<List<WallModel>> getRecentWalls({int limit = 10});

  /// Gets popular walls (high graffiti count)
  Future<List<WallModel>> getPopularWalls({int limit = 10});

  /// Checks if a wall exists by ID
  Future<bool> wallExists(String id);

  /// Bulk creates walls (for migration or testing)
  Future<List<WallModel>> createWalls(List<WallModel> walls);

  /// Updates wall graffiti count
  Future<WallModel> updateGraffitiCount(String wallId, int newCount);

  /// Increments wall graffiti count
  Future<WallModel> incrementGraffitiCount(String wallId);

  /// Decrements wall graffiti count
  Future<WallModel> decrementGraffitiCount(String wallId);

  /// Clears all wall data (for testing/reset)
  Future<void> clearAllWalls();
}