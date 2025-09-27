import '../../../../shared/domain/either/either.dart';
import '../../../../shared/domain/failures/failure.dart';
import '../entities/user.dart';
import '../repositories/user_repository.dart';
import '../value_objects/user_preferences.dart';

/// Use case for updating user preferences and settings
/// Handles business logic for user preference management including validation
class UpdateUserPreferencesUseCase {
  final UserRepository _userRepository;

  const UpdateUserPreferencesUseCase({
    required UserRepository userRepository,
  }) : _userRepository = userRepository;

  /// Updates user preferences
  Future<Either<Failure, User>> execute({
    required String userId,
    required UserPreferences preferences,
  }) async {
    try {
      // Validate user exists
      final existingUser = await _userRepository.getUserById(userId);
      if (existingUser == null) {
        return const Left(NotFoundFailure('User not found'));
      }

      // Update user preferences
      final updatedUser = await _userRepository.updateUserPreferences(
        userId: userId,
        preferences: preferences,
      );

      return Right(updatedUser);
    } catch (e) {
      return Left(UpdateFailure('Failed to update user preferences: $e'));
    }
  }

  /// Updates location tracking preference
  Future<Either<Failure, User>> updateLocationTracking({
    required String userId,
    required bool enableLocationTracking,
  }) async {
    try {
      // Get current user
      final user = await _userRepository.getUserById(userId);
      if (user == null) {
        return const Left(NotFoundFailure('User not found'));
      }

      // Update location tracking preference
      final updatedPreferences = user.preferences.updateLocationTracking(
        enableLocationTracking,
      );

      return await execute(
        userId: userId,
        preferences: updatedPreferences,
      );
    } catch (e) {
      return Left(UpdateFailure('Failed to update location tracking: $e'));
    }
  }

  /// Updates notification settings
  Future<Either<Failure, User>> updateNotifications({
    required String userId,
    required NotificationSettings notifications,
  }) async {
    try {
      // Get current user
      final user = await _userRepository.getUserById(userId);
      if (user == null) {
        return const Left(NotFoundFailure('User not found'));
      }

      // Update notification settings
      final updatedPreferences = user.preferences.updateNotifications(
        notifications,
      );

      return await execute(
        userId: userId,
        preferences: updatedPreferences,
      );
    } catch (e) {
      return Left(UpdateFailure('Failed to update notifications: $e'));
    }
  }

  /// Updates preferred language
  Future<Either<Failure, User>> updateLanguage({
    required String userId,
    required String language,
  }) async {
    try {
      // Validate language code
      if (!_isValidLanguageCode(language)) {
        return const Left(ValidationFailure('Invalid language code'));
      }

      // Get current user
      final user = await _userRepository.getUserById(userId);
      if (user == null) {
        return const Left(NotFoundFailure('User not found'));
      }

      // Update preferred language
      final updatedPreferences = user.preferences.updateLanguage(language);

      return await execute(
        userId: userId,
        preferences: updatedPreferences,
      );
    } catch (e) {
      return Left(UpdateFailure('Failed to update language preference: $e'));
    }
  }

  /// Updates specific notification setting
  Future<Either<Failure, User>> updateNotificationSetting({
    required String userId,
    required NotificationSettingType type,
    required bool enabled,
  }) async {
    try {
      // Get current user
      final user = await _userRepository.getUserById(userId);
      if (user == null) {
        return const Left(NotFoundFailure('User not found'));
      }

      // Update specific notification setting
      final currentNotifications = user.preferences.notifications;
      NotificationSettings updatedNotifications;

      switch (type) {
        case NotificationSettingType.push:
          updatedNotifications = currentNotifications.copyWith(
            enablePushNotifications: enabled,
          );
          break;
        case NotificationSettingType.graffiti:
          updatedNotifications = currentNotifications.copyWith(
            enableGraffitiUpdates: enabled,
          );
          break;
        case NotificationSettingType.wall:
          updatedNotifications = currentNotifications.copyWith(
            enableWallUpdates: enabled,
          );
          break;
        case NotificationSettingType.location:
          updatedNotifications = currentNotifications.copyWith(
            enableLocationReminders: enabled,
          );
          break;
      }

      return await updateNotifications(
        userId: userId,
        notifications: updatedNotifications,
      );
    } catch (e) {
      return Left(UpdateFailure('Failed to update notification setting: $e'));
    }
  }

  /// Resets preferences to default values
  Future<Either<Failure, User>> resetToDefaults({
    required String userId,
  }) async {
    try {
      // Create default preferences
      const defaultPreferences = UserPreferences(
        enableLocationTracking: true,
        notifications: NotificationSettings(
          enablePushNotifications: true,
          enableGraffitiUpdates: true,
          enableWallUpdates: true,
          enableLocationReminders: false,
        ),
        preferredLanguage: 'ko',
      );

      return await execute(
        userId: userId,
        preferences: defaultPreferences,
      );
    } catch (e) {
      return Left(UpdateFailure('Failed to reset preferences: $e'));
    }
  }

  /// Validates if a language code is supported
  bool _isValidLanguageCode(String languageCode) {
    const supportedLanguages = ['ko', 'en', 'ja', 'zh'];
    return supportedLanguages.contains(languageCode.toLowerCase());
  }
}

/// Enum for notification setting types
enum NotificationSettingType {
  push,
  graffiti,
  wall,
  location,
}