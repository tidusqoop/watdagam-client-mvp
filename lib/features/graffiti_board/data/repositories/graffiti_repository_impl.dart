import '../../domain/entities/graffiti_note.dart';
import '../../domain/repositories/graffiti_repository.dart';
import '../datasources/graffiti_data_source.dart';
import '../models/graffiti_note_model.dart';

/// Implementation of GraffitiRepository that bridges domain and data layers
/// Converts between domain entities and data models
class GraffitiRepositoryImpl implements GraffitiRepository {
  final GraffitiDataSource _dataSource;

  GraffitiRepositoryImpl({
    required GraffitiDataSource dataSource,
  }) : _dataSource = dataSource;

  @override
  Future<List<GraffitiNote>> getGraffitiByWall(String wallId) async {
    final graffitiModels = await _dataSource.getGraffitiByWall(wallId);
    return graffitiModels.map((model) => model.toDomain()).toList();
  }

  @override
  Future<List<GraffitiNote>> getGraffitiByUser(String userId) async {
    final graffitiModels = await _dataSource.getGraffitiByUser(userId);
    return graffitiModels.map((model) => model.toDomain()).toList();
  }

  @override
  Future<GraffitiNote> create(GraffitiNote graffiti) async {
    final graffitiModel = GraffitiNoteModel.fromDomain(graffiti);
    final createdModel = await _dataSource.createGraffiti(graffitiModel);
    return createdModel.toDomain();
  }

  @override
  Future<GraffitiNote> update(GraffitiNote graffiti) async {
    final graffitiModel = GraffitiNoteModel.fromDomain(graffiti);
    final updatedModel = await _dataSource.updateGraffiti(graffitiModel);
    return updatedModel.toDomain();
  }

  @override
  Future<void> delete(String id) async {
    await _dataSource.deleteGraffiti(id);
  }

  @override
  Future<List<GraffitiNote>> createBatch(List<GraffitiNote> graffitis) async {
    final graffitiModels = graffitis
        .map((graffiti) => GraffitiNoteModel.fromDomain(graffiti))
        .toList();
    final createdModels = await _dataSource.createGraffitisBatch(graffitiModels);
    return createdModels.map((model) => model.toDomain()).toList();
  }

  @override
  Future<void> syncWithServer() async {
    await _dataSource.syncWithServer();
  }

  /// Additional helper methods for extended functionality

  /// Gets a graffiti note by ID
  Future<GraffitiNote?> getGraffitiById(String id) async {
    final graffitiModel = await _dataSource.getGraffitiById(id);
    return graffitiModel?.toDomain();
  }

  /// Gets paginated graffiti for a wall
  Future<List<GraffitiNote>> getWallGraffitiPaginated(
    String wallId, {
    int limit = 50,
    int offset = 0,
  }) async {
    final graffitiModels = await _dataSource.getWallGraffitiPaginated(
      wallId,
      limit: limit,
      offset: offset,
    );
    return graffitiModels.map((model) => model.toDomain()).toList();
  }

  /// Gets graffiti created after a specific timestamp
  Future<List<GraffitiNote>> getGraffitiAfter(DateTime timestamp) async {
    final graffitiModels = await _dataSource.getGraffitiAfter(timestamp);
    return graffitiModels.map((model) => model.toDomain()).toList();
  }

  /// Gets graffiti notes with images
  Future<List<GraffitiNote>> getGraffitiWithImages() async {
    final graffitiModels = await _dataSource.getGraffitiWithImages();
    return graffitiModels.map((model) => model.toDomain()).toList();
  }

  /// Gets recent graffiti across all walls
  Future<List<GraffitiNote>> getRecentGraffiti({int limit = 10}) async {
    final graffitiModels = await _dataSource.getRecentGraffiti(limit: limit);
    return graffitiModels.map((model) => model.toDomain()).toList();
  }

  /// Searches graffiti by text content
  Future<List<GraffitiNote>> searchGraffitiByText(String query) async {
    final graffitiModels = await _dataSource.searchGraffitiByText(query);
    return graffitiModels.map((model) => model.toDomain()).toList();
  }

  /// Gets all graffiti notes (for admin/development purposes)
  Future<List<GraffitiNote>> getAllGraffiti() async {
    final graffitiModels = await _dataSource.getAllGraffiti();
    return graffitiModels.map((model) => model.toDomain()).toList();
  }

  /// Gets graffiti count for a specific wall
  Future<int> getGraffitiCountForWall(String wallId) async {
    return await _dataSource.getGraffitiCountForWall(wallId);
  }

  /// Gets graffiti count for a specific user
  Future<int> getGraffitiCountForUser(String userId) async {
    return await _dataSource.getGraffitiCountForUser(userId);
  }

  /// Checks if a graffiti note exists
  Future<bool> graffitiExists(String id) async {
    return await _dataSource.graffitiExists(id);
  }

  /// Updates graffiti visibility
  Future<GraffitiNote> updateGraffitiVisibility(
    String id,
    bool isVisible,
  ) async {
    final updatedModel = await _dataSource.updateGraffitiVisibility(id, isVisible);
    return updatedModel.toDomain();
  }

  /// Gets hidden graffiti for moderation
  Future<List<GraffitiNote>> getHiddenGraffiti() async {
    final graffitiModels = await _dataSource.getHiddenGraffiti();
    return graffitiModels.map((model) => model.toDomain()).toList();
  }

  /// Gets graffiti by size
  Future<List<GraffitiNote>> getGraffitiBySize(String sizeName) async {
    final graffitiModels = await _dataSource.getGraffitiBySize(sizeName);
    return graffitiModels.map((model) => model.toDomain()).toList();
  }

  /// Deletes all graffiti for a wall
  Future<void> deleteAllGraffitiForWall(String wallId) async {
    await _dataSource.deleteAllGraffitiForWall(wallId);
  }

  /// Deletes all graffiti by a user
  Future<void> deleteAllGraffitiByUser(String userId) async {
    await _dataSource.deleteAllGraffitiByUser(userId);
  }

  /// Clears all graffiti data (for testing)
  Future<void> clearAllGraffiti() async {
    await _dataSource.clearAllGraffiti();
  }

  /// Shows a hidden graffiti
  Future<GraffitiNote> showGraffiti(String id) async {
    return await updateGraffitiVisibility(id, true);
  }

  /// Hides a graffiti
  Future<GraffitiNote> hideGraffiti(String id) async {
    return await updateGraffitiVisibility(id, false);
  }

  /// Gets visible graffiti for a wall
  Future<List<GraffitiNote>> getVisibleGraffitiByWall(String wallId) async {
    final allGraffiti = await getGraffitiByWall(wallId);
    return allGraffiti.where((graffiti) => graffiti.metadata.isVisible).toList();
  }

  /// Gets user statistics
  Future<Map<String, int>> getUserGraffitiStats(String userId) async {
    final userGraffiti = await getGraffitiByUser(userId);
    final totalCount = userGraffiti.length;
    final visibleCount = userGraffiti.where((g) => g.metadata.isVisible).length;
    final hiddenCount = totalCount - visibleCount;
    final withImagesCount = userGraffiti.where((g) => g.content.hasImage).length;

    return {
      'total': totalCount,
      'visible': visibleCount,
      'hidden': hiddenCount,
      'withImages': withImagesCount,
    };
  }

  /// Gets wall statistics
  Future<Map<String, int>> getWallGraffitiStats(String wallId) async {
    final wallGraffiti = await getGraffitiByWall(wallId);
    final totalCount = wallGraffiti.length;
    final visibleCount = wallGraffiti.where((g) => g.metadata.isVisible).length;
    final hiddenCount = totalCount - visibleCount;
    final uniqueUsers = wallGraffiti.map((g) => g.userId).toSet().length;

    return {
      'total': totalCount,
      'visible': visibleCount,
      'hidden': hiddenCount,
      'uniqueUsers': uniqueUsers,
    };
  }
}