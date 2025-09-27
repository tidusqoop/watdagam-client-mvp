import '../models/graffiti_note_model.dart';

/// Abstract data source interface for GraffitiNote operations
/// Defines contract for data access operations
abstract class GraffitiDataSource {
  /// Retrieves all graffiti notes for a specific wall
  Future<List<GraffitiNoteModel>> getGraffitiByWall(String wallId);

  /// Retrieves all graffiti notes created by a specific user
  Future<List<GraffitiNoteModel>> getGraffitiByUser(String userId);

  /// Retrieves a graffiti note by ID
  Future<GraffitiNoteModel?> getGraffitiById(String id);

  /// Creates a new graffiti note
  Future<GraffitiNoteModel> createGraffiti(GraffitiNoteModel graffiti);

  /// Updates an existing graffiti note
  Future<GraffitiNoteModel> updateGraffiti(GraffitiNoteModel graffiti);

  /// Deletes a graffiti note by ID
  Future<void> deleteGraffiti(String id);

  /// Gets paginated graffiti for a wall
  Future<List<GraffitiNoteModel>> getWallGraffitiPaginated(
    String wallId, {
    int limit = 50,
    int offset = 0,
  });

  /// Gets graffiti notes created after a specific timestamp
  Future<List<GraffitiNoteModel>> getGraffitiAfter(DateTime timestamp);

  /// Gets graffiti notes with images
  Future<List<GraffitiNoteModel>> getGraffitiWithImages();

  /// Gets recent graffiti across all walls
  Future<List<GraffitiNoteModel>> getRecentGraffiti({int limit = 10});

  /// Searches graffiti by text content
  Future<List<GraffitiNoteModel>> searchGraffitiByText(String query);

  /// Gets all graffiti notes (for admin purposes)
  Future<List<GraffitiNoteModel>> getAllGraffiti();

  /// Gets graffiti count for a specific wall
  Future<int> getGraffitiCountForWall(String wallId);

  /// Gets graffiti count for a specific user
  Future<int> getGraffitiCountForUser(String userId);

  /// Checks if a graffiti note exists by ID
  Future<bool> graffitiExists(String id);

  /// Bulk creates graffiti notes (for migration or testing)
  Future<List<GraffitiNoteModel>> createGraffitisBatch(
    List<GraffitiNoteModel> graffitis,
  );

  /// Updates graffiti visibility
  Future<GraffitiNoteModel> updateGraffitiVisibility(
    String id,
    bool isVisible,
  );

  /// Gets hidden graffiti for moderation
  Future<List<GraffitiNoteModel>> getHiddenGraffiti();

  /// Gets graffiti by size
  Future<List<GraffitiNoteModel>> getGraffitiBySize(String sizeName);

  /// Deletes all graffiti for a wall
  Future<void> deleteAllGraffitiForWall(String wallId);

  /// Deletes all graffiti by a user
  Future<void> deleteAllGraffitiByUser(String userId);

  /// Clears all graffiti data (for testing/reset)
  Future<void> clearAllGraffiti();

  /// Synchronizes with server (for future implementation)
  Future<void> syncWithServer();
}