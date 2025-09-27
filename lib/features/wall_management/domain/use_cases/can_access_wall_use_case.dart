import '../../../../shared/domain/either/either.dart';
import '../../../../shared/domain/failures/failure.dart';
import '../../../../shared/domain/value_objects/location.dart';
import '../entities/wall.dart';
import '../repositories/wall_repository.dart';
import '../../../user_management/domain/repositories/user_repository.dart';

/// Use case for checking if a user can access a specific wall
/// Handles business logic for wall access permissions including
/// location-based access and user visit history
class CanAccessWallUseCase {
  final WallRepository _wallRepository;
  final UserRepository _userRepository;

  const CanAccessWallUseCase({
    required WallRepository wallRepository,
    required UserRepository userRepository,
  })  : _wallRepository = wallRepository,
        _userRepository = userRepository;

  /// Checks if a user can access a specific wall
  Future<Either<Failure, bool>> execute({
    required String wallId,
    required String userId,
    required Location userLocation,
  }) async {
    try {
      // Validate wall exists
      final wall = await _wallRepository.getWallById(wallId);
      if (wall == null) {
        return const Left(NotFoundFailure('Wall not found'));
      }

      // Validate user exists
      final user = await _userRepository.getUserById(userId);
      if (user == null) {
        return const Left(NotFoundFailure('User not found'));
      }

      // Check if user can access wall using domain logic
      final canAccess = user.canAccessWall(wall, userLocation);

      return Right(canAccess);
    } catch (e) {
      return Left(UnknownFailure('Failed to check wall access: $e'));
    }
  }

  /// Gets detailed access information for a wall
  Future<Either<Failure, WallAccessInfo>> getAccessInfo({
    required String wallId,
    required String userId,
    required Location userLocation,
  }) async {
    try {
      // Validate wall exists
      final wall = await _wallRepository.getWallById(wallId);
      if (wall == null) {
        return const Left(NotFoundFailure('Wall not found'));
      }

      // Validate user exists
      final user = await _userRepository.getUserById(userId);
      if (user == null) {
        return const Left(NotFoundFailure('User not found'));
      }

      // Calculate distance to wall
      final distanceKm = wall.location.distanceTo(userLocation);

      // Check if user has visited before
      final hasVisited = user.hasVisitedWall(wallId);

      // Check if wall is within access radius
      final isWithinRange = wall.isWithinAccessRange(userLocation);

      // Check overall access permission
      final canAccess = user.canAccessWall(wall, userLocation);

      // Check if user is blocked
      final isBlocked = wall.permissions.blockedUserIds.contains(userId);

      // Check if user is explicitly allowed
      final isExplicitlyAllowed = wall.permissions.allowedUserIds.contains(userId);

      // Create access info
      final accessInfo = WallAccessInfo(
        canAccess: canAccess,
        hasVisited: hasVisited,
        isWithinRange: isWithinRange,
        distanceKm: distanceKm,
        requiredDistanceKm: wall.permissions.accessRadius,
        isBlocked: isBlocked,
        isExplicitlyAllowed: isExplicitlyAllowed,
        accessType: wall.permissions.accessType,
        denyReason: _getDenyReason(
          canAccess: canAccess,
          isBlocked: isBlocked,
          isWithinRange: isWithinRange,
          hasVisited: hasVisited,
          wall: wall,
        ),
      );

      return Right(accessInfo);
    } catch (e) {
      return Left(UnknownFailure('Failed to get wall access info: $e'));
    }
  }

  /// Checks if a user can create graffiti on a wall
  Future<Either<Failure, bool>> canCreateGraffiti({
    required String wallId,
    required String userId,
    required Location userLocation,
  }) async {
    try {
      // First check basic access
      final accessResult = await execute(
        wallId: wallId,
        userId: userId,
        userLocation: userLocation,
      );

      if (accessResult.isLeft) {
        return accessResult.mapLeft((failure) => failure);
      }

      final canAccess = accessResult.getOrThrow();
      if (!canAccess) {
        return const Right(false);
      }

      // Get wall to check capacity
      final wall = await _wallRepository.getWallById(wallId);
      if (wall == null) {
        return const Left(NotFoundFailure('Wall not found'));
      }

      // Get user to validate permissions
      final user = await _userRepository.getUserById(userId);
      if (user == null) {
        return const Left(NotFoundFailure('User not found'));
      }

      // Check if wall can accommodate more graffiti
      final canAddGraffiti = wall.canAddGraffiti(user, userLocation);

      return Right(canAddGraffiti);
    } catch (e) {
      return Left(UnknownFailure('Failed to check graffiti creation permission: $e'));
    }
  }

  String? _getDenyReason({
    required bool canAccess,
    required bool isBlocked,
    required bool isWithinRange,
    required bool hasVisited,
    required Wall wall,
  }) {
    if (canAccess) return null;

    if (isBlocked) {
      return 'You are blocked from accessing this wall';
    }

    if (!isWithinRange && !hasVisited) {
      return 'You must be within ${wall.permissions.accessRadius.toStringAsFixed(1)}km of the wall to access it';
    }

    if (wall.metadata.isAtCapacity()) {
      return 'This wall has reached its maximum capacity';
    }

    switch (wall.permissions.accessType.name) {
      case 'private':
        return 'This is a private wall';
      case 'restricted':
        return 'You don\'t have permission to access this restricted wall';
      default:
        return 'Access denied';
    }
  }
}

/// Information about a user's access to a wall
class WallAccessInfo {
  final bool canAccess;
  final bool hasVisited;
  final bool isWithinRange;
  final double distanceKm;
  final double requiredDistanceKm;
  final bool isBlocked;
  final bool isExplicitlyAllowed;
  final dynamic accessType; // WallAccessType
  final String? denyReason;

  const WallAccessInfo({
    required this.canAccess,
    required this.hasVisited,
    required this.isWithinRange,
    required this.distanceKm,
    required this.requiredDistanceKm,
    required this.isBlocked,
    required this.isExplicitlyAllowed,
    required this.accessType,
    this.denyReason,
  });

  @override
  String toString() {
    return 'WallAccessInfo('
        'canAccess: $canAccess, '
        'hasVisited: $hasVisited, '
        'isWithinRange: $isWithinRange, '
        'distanceKm: ${distanceKm.toStringAsFixed(2)}, '
        'denyReason: $denyReason'
        ')';
  }
}