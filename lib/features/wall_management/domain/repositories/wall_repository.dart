import '../../../../shared/domain/value_objects/location.dart';
import '../entities/wall.dart';

/// Abstract repository interface for Wall entity operations.
/// Provides methods for wall discovery, management, and persistence.
abstract class WallRepository {
  /// Retrieves walls within a specified radius from a location
  Future<List<Wall>> getNearbyWalls({
    required Location location,
    required double radiusKm,
  });

  /// Retrieves a wall by its unique identifier
  Future<Wall?> getWallById(String id);

  /// Retrieves all walls visited by a specific user
  Future<List<Wall>> getVisitedWalls(String userId);

  /// Retrieves all walls within the specified geographic bounds
  Future<List<Wall>> getWallsInBounds({
    required Location southWest,
    required Location northEast,
  });

  /// Retrieves all walls owned by a specific user
  Future<List<Wall>> getWallsByOwner(String ownerId);

  /// Retrieves walls by their status
  Future<List<Wall>> getWallsByStatus(List<String> statuses);

  /// Searches for walls by name or description
  Future<List<Wall>> searchWalls({
    required String query,
    Location? userLocation,
    double? maxDistance,
  });

  /// Retrieves the most popular walls (by graffiti count)
  Future<List<Wall>> getPopularWalls({
    int limit = 10,
    Location? userLocation,
    double? maxDistance,
  });

  /// Retrieves recently created walls
  Future<List<Wall>> getRecentWalls({
    int limit = 10,
    Location? userLocation,
    double? maxDistance,
  });

  // Write operations

  /// Creates a new wall
  Future<Wall> createWall(Wall wall);

  /// Updates an existing wall
  Future<Wall> updateWall(Wall wall);

  /// Deletes a wall by its ID
  Future<void> deleteWall(String id);

  /// Marks a wall as visited by a user
  Future<void> markWallVisited(String wallId, String userId);

  /// Unmarks a wall as visited by a user
  Future<void> unmarkWallVisited(String wallId, String userId);

  /// Updates the graffiti count for a wall
  Future<void> updateGraffitiCount(String wallId, int newCount);

  /// Archives a wall (soft delete)
  Future<void> archiveWall(String wallId);

  /// Restores an archived wall
  Future<void> restoreWall(String wallId);

  // Batch operations

  /// Creates multiple walls in a single operation
  Future<List<Wall>> createWalls(List<Wall> walls);

  /// Updates multiple walls in a single operation
  Future<List<Wall>> updateWalls(List<Wall> walls);

  /// Deletes multiple walls in a single operation
  Future<void> deleteWalls(List<String> wallIds);

  // Synchronization (for future server integration)

  /// Synchronizes local wall data with server
  Future<void> syncWithServer();

  /// Gets walls that need to be synchronized
  Future<List<Wall>> getUnsyncedWalls();

  /// Marks a wall as synchronized
  Future<void> markWallSynced(String wallId);

  // Statistics and analytics

  /// Gets wall statistics (total count, active count, etc.)
  Future<Map<String, dynamic>> getWallStatistics();

  /// Gets usage statistics for a specific wall
  Future<Map<String, dynamic>> getWallUsageStats(String wallId);
}