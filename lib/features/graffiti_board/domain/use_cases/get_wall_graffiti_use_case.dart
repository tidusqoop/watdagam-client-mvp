import '../../../../shared/domain/either/either.dart';
import '../../../../shared/domain/failures/failure.dart';
import '../../domain/entities/graffiti_note.dart';
import '../../domain/repositories/graffiti_repository.dart';
import '../../../wall_management/domain/repositories/wall_repository.dart';

/// Use case for retrieving graffiti notes for a specific wall
/// Handles business logic for graffiti querying including filtering and sorting
class GetWallGraffitiUseCase {
  final GraffitiRepository _graffitiRepository;
  final WallRepository _wallRepository;

  const GetWallGraffitiUseCase({
    required GraffitiRepository graffitiRepository,
    required WallRepository wallRepository,
  })  : _graffitiRepository = graffitiRepository,
        _wallRepository = wallRepository;

  /// Retrieves graffiti notes for a specific wall
  Future<Either<Failure, List<GraffitiNote>>> execute({
    required String wallId,
    bool onlyVisible = true,
    int? limit,
    String? sortBy, // 'created', 'popular', 'recent'
  }) async {
    try {
      // Validate wall exists
      final wall = await _wallRepository.getWallById(wallId);
      if (wall == null) {
        return const Left(NotFoundFailure('Wall not found'));
      }

      List<GraffitiNote> graffitis;

      // Get graffiti based on visibility filter
      if (onlyVisible) {
        graffitis = await _graffitiRepository.getVisibleGraffiti(wallId);
      } else {
        graffitis = await _graffitiRepository.getGraffitiByWall(wallId);
      }

      // Apply sorting
      switch (sortBy) {
        case 'recent':
          graffitis = await _graffitiRepository.getRecentGraffiti(
            wallId: wallId,
            limit: limit ?? 20,
          );
          break;
        case 'popular':
          graffitis = await _graffitiRepository.getPopularGraffiti(
            wallId: wallId,
            limit: limit ?? 10,
          );
          break;
        case 'created':
        default:
          // Sort by creation date (newest first)
          graffitis.sort((a, b) => b.metadata.createdAt.compareTo(a.metadata.createdAt));
          break;
      }

      // Apply limit if specified and not already applied by repository method
      if (limit != null && (sortBy == null || sortBy == 'created')) {
        graffitis = graffitis.take(limit).toList();
      }

      return Right(graffitis);
    } catch (e) {
      return Left(UnknownFailure('Failed to retrieve graffiti: $e'));
    }
  }

  /// Retrieves graffiti notes by user for a specific wall
  Future<Either<Failure, List<GraffitiNote>>> getByUser({
    required String wallId,
    required String userId,
    bool onlyVisible = true,
  }) async {
    try {
      // Validate wall exists
      final wall = await _wallRepository.getWallById(wallId);
      if (wall == null) {
        return const Left(NotFoundFailure('Wall not found'));
      }

      // Get all graffiti by user
      final allUserGraffiti = await _graffitiRepository.getGraffitiByUser(userId);

      // Filter by wall and visibility
      final wallGraffiti = allUserGraffiti.where((graffiti) {
        final isOnWall = graffiti.wallId == wallId;
        final isVisible = !onlyVisible || graffiti.metadata.isVisible;
        return isOnWall && isVisible;
      }).toList();

      // Sort by creation date (newest first)
      wallGraffiti.sort((a, b) => b.metadata.createdAt.compareTo(a.metadata.createdAt));

      return Right(wallGraffiti);
    } catch (e) {
      return Left(UnknownFailure('Failed to retrieve user graffiti: $e'));
    }
  }

  /// Retrieves graffiti notes with images for a specific wall
  Future<Either<Failure, List<GraffitiNote>>> getWithImages({
    required String wallId,
    int limit = 20,
  }) async {
    try {
      // Validate wall exists
      final wall = await _wallRepository.getWallById(wallId);
      if (wall == null) {
        return const Left(NotFoundFailure('Wall not found'));
      }

      final graffitis = await _graffitiRepository.getGraffitiWithImages(
        wallId: wallId,
        limit: limit,
      );

      return Right(graffitis);
    } catch (e) {
      return Left(UnknownFailure('Failed to retrieve graffiti with images: $e'));
    }
  }

  /// Searches graffiti notes by text content
  Future<Either<Failure, List<GraffitiNote>>> searchByText({
    required String wallId,
    required String query,
    int limit = 50,
  }) async {
    try {
      // Validate wall exists
      final wall = await _wallRepository.getWallById(wallId);
      if (wall == null) {
        return const Left(NotFoundFailure('Wall not found'));
      }

      // Validate search query
      if (query.trim().isEmpty) {
        return const Left(ValidationFailure('Search query cannot be empty'));
      }

      final graffitis = await _graffitiRepository.searchGraffitiByText(
        query: query.trim(),
        wallId: wallId,
        limit: limit,
      );

      return Right(graffitis);
    } catch (e) {
      return Left(UnknownFailure('Failed to search graffiti: $e'));
    }
  }
}