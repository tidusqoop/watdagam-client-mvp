import '../../../../shared/domain/either/either.dart';
import '../../../../shared/domain/failures/failure.dart';
import '../entities/user.dart';
import '../repositories/user_repository.dart';

/// Use case for retrieving the current authenticated user
/// Handles business logic for user session management and authentication state
class GetCurrentUserUseCase {
  final UserRepository _userRepository;

  const GetCurrentUserUseCase({
    required UserRepository userRepository,
  }) : _userRepository = userRepository;

  /// Retrieves the current authenticated user
  Future<Either<Failure, User?>> execute() async {
    try {
      final user = await _userRepository.getCurrentUser();
      return Right(user);
    } catch (e) {
      return Left(UnknownFailure('Failed to get current user: $e'));
    }
  }

  /// Checks if a user is currently authenticated
  Future<Either<Failure, bool>> isAuthenticated() async {
    try {
      final isAuth = await _userRepository.isAuthenticated();
      return Right(isAuth);
    } catch (e) {
      return Left(AuthenticationFailure('Failed to check authentication status: $e'));
    }
  }

  /// Gets the current user or creates a guest user if no user is authenticated
  Future<Either<Failure, User>> executeOrCreateGuest() async {
    try {
      // First try to get current user
      final currentUser = await _userRepository.getCurrentUser();

      if (currentUser != null) {
        return Right(currentUser);
      }

      // If no current user, create a guest user
      final guestUser = await _userRepository.createGuestUser();
      return Right(guestUser);
    } catch (e) {
      return Left(UnknownFailure('Failed to get or create user: $e'));
    }
  }

  /// Refreshes the authentication token for the current user
  Future<Either<Failure, bool>> refreshAuthToken() async {
    try {
      final success = await _userRepository.refreshToken();
      if (!success) {
        return const Left(AuthenticationFailure('Token refresh failed'));
      }
      return const Right(true);
    } catch (e) {
      return Left(AuthenticationFailure('Failed to refresh token: $e'));
    }
  }

  /// Signs out the current user
  Future<Either<Failure, void>> signOut() async {
    try {
      await _userRepository.signOut();
      return const Right(null);
    } catch (e) {
      return Left(UnknownFailure('Failed to sign out: $e'));
    }
  }
}