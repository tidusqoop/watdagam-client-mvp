import '../../../../shared/domain/either/either.dart';
import '../../../../shared/domain/failures/failure.dart';
import '../../../../shared/domain/services/location_service.dart';
import '../../../../shared/domain/value_objects/location.dart';
import '../entities/wall.dart';
import '../repositories/wall_repository.dart';

/// Use case for retrieving walls near a user's location
/// Handles business logic for wall discovery including distance calculation
/// and filtering based on user preferences
class GetNearbyWallsUseCase {
  final WallRepository _wallRepository;
  final LocationService _locationService;

  const GetNearbyWallsUseCase({
    required WallRepository wallRepository,
    required LocationService locationService,
  })  : _wallRepository = wallRepository,
        _locationService = locationService;

  /// Retrieves walls within the specified radius of a location
  Future<Either<Failure, List<Wall>>> execute({
    Location? userLocation,
    double? radiusKm,
    String? statusFilter, // 'active', 'archived', null for all
    int? limit,
    bool sortByDistance = true,
  }) async {
    try {
      // Get user location if not provided
      Location location;
      if (userLocation != null) {
        location = userLocation;
      } else {
        try {
          location = await _locationService.getCurrentLocation();
        } catch (e) {
          return Left(LocationFailure('Failed to get current location: $e'));
        }
      }

      // Validate radius
      final searchRadius = radiusKm ?? 10.0;
      if (searchRadius <= 0) {
        return const Left(ValidationFailure('Search radius must be positive'));
      }

      if (searchRadius > 100) {
        return const Left(ValidationFailure('Search radius cannot exceed 100km'));
      }

      // Get nearby walls
      List<Wall> walls = await _wallRepository.getNearbyWalls(
        location: location,
        radiusKm: searchRadius,
      );

      // Apply status filter if specified
      if (statusFilter != null) {
        walls = walls.where((wall) {
          switch (statusFilter.toLowerCase()) {
            case 'active':
              return wall.metadata.status.name == 'active';
            case 'archived':
              return wall.metadata.status.name == 'archived';
            default:
              return true;
          }
        }).toList();
      }

      // Calculate distances and sort if requested
      if (sortByDistance) {
        for (int i = 0; i < walls.length; i++) {
          final distance = _locationService.calculateDistance(
            location,
            Location(
              latitude: walls[i].location.latitude,
              longitude: walls[i].location.longitude,
            ),
          );
          // Store distance in a way that can be used for sorting
          walls[i] = walls[i].copyWith(
            metadata: walls[i].metadata.copyWith(),
          );
        }

        // Sort by distance (closest first)
        walls.sort((a, b) {
          final distanceA = _locationService.calculateDistance(
            location,
            Location(
              latitude: a.location.latitude,
              longitude: a.location.longitude,
            ),
          );
          final distanceB = _locationService.calculateDistance(
            location,
            Location(
              latitude: b.location.latitude,
              longitude: b.location.longitude,
            ),
          );
          return distanceA.compareTo(distanceB);
        });
      }

      // Apply limit if specified
      if (limit != null && limit > 0) {
        walls = walls.take(limit).toList();
      }

      return Right(walls);
    } catch (e) {
      return Left(UnknownFailure('Failed to retrieve nearby walls: $e'));
    }
  }

  /// Retrieves popular walls near a location
  Future<Either<Failure, List<Wall>>> getPopular({
    Location? userLocation,
    double? radiusKm,
    int limit = 10,
  }) async {
    try {
      // Get user location if not provided
      Location location;
      if (userLocation != null) {
        location = userLocation;
      } else {
        location = await _locationService.getCurrentLocation();
      }

      final walls = await _wallRepository.getPopularWalls(
        limit: limit,
        userLocation: location,
        maxDistance: radiusKm ?? 10.0,
      );

      return Right(walls);
    } catch (e) {
      return Left(UnknownFailure('Failed to retrieve popular walls: $e'));
    }
  }

  /// Retrieves recently created walls near a location
  Future<Either<Failure, List<Wall>>> getRecent({
    Location? userLocation,
    double? radiusKm,
    int limit = 10,
  }) async {
    try {
      // Get user location if not provided
      Location location;
      if (userLocation != null) {
        location = userLocation;
      } else {
        location = await _locationService.getCurrentLocation();
      }

      final walls = await _wallRepository.getRecentWalls(
        limit: limit,
        userLocation: location,
        maxDistance: radiusKm ?? 10.0,
      );

      return Right(walls);
    } catch (e) {
      return Left(UnknownFailure('Failed to retrieve recent walls: $e'));
    }
  }

  /// Searches for walls by name or description near a location
  Future<Either<Failure, List<Wall>>> search({
    required String query,
    Location? userLocation,
    double? radiusKm,
    int limit = 20,
  }) async {
    try {
      // Validate search query
      if (query.trim().isEmpty) {
        return const Left(ValidationFailure('Search query cannot be empty'));
      }

      // Get user location if not provided
      Location location;
      if (userLocation != null) {
        location = userLocation;
      } else {
        location = await _locationService.getCurrentLocation();
      }

      final walls = await _wallRepository.searchWalls(
        query: query.trim(),
        userLocation: location,
        maxDistance: radiusKm ?? 50.0, // Larger radius for search
      );

      // Apply limit if specified
      final limitedWalls = limit > 0 ? walls.take(limit).toList() : walls;

      return Right(limitedWalls);
    } catch (e) {
      return Left(UnknownFailure('Failed to search walls: $e'));
    }
  }
}