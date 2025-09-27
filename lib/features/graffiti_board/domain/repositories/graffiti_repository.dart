import '../entities/graffiti_note.dart';
import '../value_objects/graffiti_content.dart';

/// Abstract repository interface for GraffitiNote entity operations.
/// Provides methods for graffiti management, querying, and persistence.
abstract class GraffitiRepository {
  /// Retrieves all graffiti notes for a specific wall
  Future<List<GraffitiNote>> getGraffitiByWall(String wallId);

  /// Retrieves all graffiti notes created by a specific user
  Future<List<GraffitiNote>> getGraffitiByUser(String userId);

  /// Retrieves a graffiti note by its unique identifier
  Future<GraffitiNote?> getGraffitiById(String id);

  /// Retrieves multiple graffiti notes by their IDs
  Future<List<GraffitiNote>> getGraffitiByIds(List<String> graffitiIds);

  /// Retrieves graffiti notes by size
  Future<List<GraffitiNote>> getGraffitiBySize({
    required String wallId,
    required GraffitiSize size,
  });

  /// Retrieves graffiti notes created within a time range
  Future<List<GraffitiNote>> getGraffitiByTimeRange({
    required String wallId,
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Retrieves recent graffiti notes for a wall
  Future<List<GraffitiNote>> getRecentGraffiti({
    required String wallId,
    int limit = 20,
  });

  /// Retrieves the most popular graffiti notes (by interaction/age)
  Future<List<GraffitiNote>> getPopularGraffiti({
    required String wallId,
    int limit = 10,
  });

  /// Searches graffiti notes by text content
  Future<List<GraffitiNote>> searchGraffitiByText({
    required String query,
    String? wallId,
    String? userId,
    int limit = 50,
  });

  /// Retrieves graffiti notes with images
  Future<List<GraffitiNote>> getGraffitiWithImages({
    required String wallId,
    int limit = 20,
  });

  /// Retrieves graffiti notes that are text-only
  Future<List<GraffitiNote>> getTextOnlyGraffiti({
    required String wallId,
    int limit = 20,
  });

  /// Retrieves visible graffiti notes for a wall
  Future<List<GraffitiNote>> getVisibleGraffiti(String wallId);

  /// Retrieves hidden graffiti notes for a wall
  Future<List<GraffitiNote>> getHiddenGraffiti(String wallId);

  // Write operations

  /// Creates a new graffiti note
  Future<GraffitiNote> create(GraffitiNote graffiti);

  /// Updates an existing graffiti note
  Future<GraffitiNote> update(GraffitiNote graffiti);

  /// Deletes a graffiti note by its ID
  Future<void> delete(String id);

  /// Hides a graffiti note (soft delete)
  Future<GraffitiNote> hideGraffiti(String id);

  /// Shows a hidden graffiti note
  Future<GraffitiNote> showGraffiti(String id);

  /// Updates the position of a graffiti note
  Future<GraffitiNote> updatePosition({
    required String id,
    required double x,
    required double y,
  });

  /// Updates the content of a graffiti note
  Future<GraffitiNote> updateContent({
    required String id,
    required GraffitiContent content,
  });

  /// Updates the visibility of a graffiti note
  Future<GraffitiNote> updateVisibility({
    required String id,
    required bool isVisible,
  });

  /// Moves graffiti note to front (updates z-index)
  Future<GraffitiNote> bringToFront(String id);

  // Batch operations

  /// Creates multiple graffiti notes in a single operation
  Future<List<GraffitiNote>> createBatch(List<GraffitiNote> graffitis);

  /// Updates multiple graffiti notes in a single operation
  Future<List<GraffitiNote>> updateBatch(List<GraffitiNote> graffitis);

  /// Deletes multiple graffiti notes in a single operation
  Future<void> deleteBatch(List<String> graffitiIds);

  /// Hides multiple graffiti notes
  Future<List<GraffitiNote>> hideBatch(List<String> graffitiIds);

  /// Shows multiple graffiti notes
  Future<List<GraffitiNote>> showBatch(List<String> graffitiIds);

  /// Updates positions for multiple graffiti notes
  Future<List<GraffitiNote>> updatePositionsBatch(
    Map<String, Map<String, double>> positions,
  );

  // Collision detection and spatial queries

  /// Finds graffiti notes that overlap with a given area
  Future<List<GraffitiNote>> findOverlappingGraffiti({
    required String wallId,
    required double x,
    required double y,
    required double width,
    required double height,
  });

  /// Checks if a position would cause overlap with existing graffiti
  Future<bool> wouldCauseOverlap({
    required String wallId,
    required double x,
    required double y,
    required double width,
    required double height,
    String? excludeGraffitiId,
  });

  /// Finds the next available position for a graffiti note
  Future<Map<String, double>?> findAvailablePosition({
    required String wallId,
    required double width,
    required double height,
    double? preferredX,
    double? preferredY,
  });

  /// Gets graffiti notes within a specific area
  Future<List<GraffitiNote>> getGraffitiInArea({
    required String wallId,
    required double x,
    required double y,
    required double width,
    required double height,
  });

  // Synchronization (for future server integration)

  /// Synchronizes local graffiti data with server
  Future<void> syncWithServer();

  /// Gets graffiti notes that need to be synchronized
  Future<List<GraffitiNote>> getUnsyncedGraffiti();

  /// Marks a graffiti note as synchronized
  Future<void> markGraffitiSynced(String graffitiId);

  /// Handles conflict resolution during sync
  Future<GraffitiNote> resolveConflict({
    required GraffitiNote localGraffiti,
    required GraffitiNote serverGraffiti,
  });

  // Analytics and statistics

  /// Gets statistics for a wall's graffiti
  Future<Map<String, dynamic>> getWallGraffitiStats(String wallId);

  /// Gets statistics for a user's graffiti
  Future<Map<String, dynamic>> getUserGraffitiStats(String userId);

  /// Gets overall graffiti statistics
  Future<Map<String, dynamic>> getOverallGraffitiStats();

  /// Gets graffiti density information for a wall
  Future<Map<String, dynamic>> getGraffitiDensity(String wallId);

  /// Gets graffiti activity over time
  Future<List<Map<String, dynamic>>> getGraffitiActivity({
    required String wallId,
    required DateTime startDate,
    required DateTime endDate,
    String? groupBy, // 'hour', 'day', 'week', 'month'
  });

  // Cleanup and maintenance

  /// Removes old hidden graffiti notes
  Future<void> cleanupOldHiddenGraffiti({int olderThanDays = 30});

  /// Optimizes graffiti storage (compacts data, removes duplicates)
  Future<void> optimizeStorage();

  /// Validates graffiti data integrity
  Future<List<String>> validateDataIntegrity();

  /// Repairs corrupted graffiti data
  Future<void> repairCorruptedData(List<String> corruptedGraffitiIds);
}