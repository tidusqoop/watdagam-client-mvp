import '../entities/user.dart';
import '../value_objects/user_preferences.dart';

/// Abstract repository interface for User entity operations.
/// Provides methods for user management, authentication, and profile operations.
abstract class UserRepository {
  /// Retrieves the currently authenticated user
  Future<User?> getCurrentUser();

  /// Retrieves a user by their unique identifier
  Future<User?> getUserById(String id);

  /// Retrieves users by their email address
  Future<User?> getUserByEmail(String email);

  /// Retrieves multiple users by their IDs
  Future<List<User>> getUsersByIds(List<String> userIds);

  /// Searches for users by name or email
  Future<List<User>> searchUsers({
    required String query,
    int limit = 10,
  });

  /// Retrieves users who have visited a specific wall
  Future<List<User>> getUsersWhoVisitedWall(String wallId);

  // Write operations

  /// Creates a new user
  Future<User> createUser(User user);

  /// Updates an existing user
  Future<User> updateUser(User user);

  /// Deletes a user by their ID
  Future<void> deleteUser(String id);

  /// Updates user profile information
  Future<User> updateUserProfile({
    required String userId,
    String? name,
    String? email,
    String? avatarPath,
  });

  /// Updates user preferences
  Future<User> updateUserPreferences({
    required String userId,
    required UserPreferences preferences,
  });

  /// Marks a wall as visited by the user
  Future<void> markWallVisited(String userId, String wallId);

  /// Unmarks a wall as visited by the user
  Future<void> unmarkWallVisited(String userId, String wallId);

  /// Sets the user's avatar
  Future<User> setUserAvatar(String userId, String avatarPath);

  /// Removes the user's avatar
  Future<User> removeUserAvatar(String userId);

  // Authentication methods

  /// Signs in a user with email and password
  Future<User?> signIn(String email, String password);

  /// Signs up a new user with email, password, and name
  Future<User> signUp(String email, String password, String name);

  /// Signs out the current user
  Future<void> signOut();

  /// Refreshes the authentication token
  Future<bool> refreshToken();

  /// Checks if a user is currently authenticated
  Future<bool> isAuthenticated();

  /// Resets a user's password
  Future<void> resetPassword(String email);

  /// Changes a user's password
  Future<void> changePassword(String userId, String oldPassword, String newPassword);

  /// Verifies a user's email address
  Future<void> verifyEmail(String userId, String verificationCode);

  /// Resends email verification
  Future<void> resendEmailVerification(String email);

  // Guest user operations

  /// Creates a guest user
  Future<User> createGuestUser();

  /// Converts a guest user to a registered user
  Future<User> convertGuestToRegistered({
    required String guestUserId,
    required String email,
    required String password,
    String? name,
  });

  /// Deletes guest users older than specified days
  Future<void> cleanupOldGuestUsers({int olderThanDays = 30});

  // Privacy and security

  /// Updates user privacy settings
  Future<User> updatePrivacySettings({
    required String userId,
    required Map<String, bool> privacySettings,
  });

  /// Gets user's data export
  Future<Map<String, dynamic>> exportUserData(String userId);

  /// Deletes all user data (GDPR compliance)
  Future<void> deleteAllUserData(String userId);

  /// Logs user activity
  Future<void> logUserActivity({
    required String userId,
    required String activity,
    Map<String, dynamic>? metadata,
  });

  // Batch operations

  /// Creates multiple users
  Future<List<User>> createUsers(List<User> users);

  /// Updates multiple users
  Future<List<User>> updateUsers(List<User> users);

  /// Deletes multiple users
  Future<void> deleteUsers(List<String> userIds);

  // Synchronization (for future server integration)

  /// Synchronizes local user data with server
  Future<void> syncWithServer();

  /// Gets users that need to be synchronized
  Future<List<User>> getUnsyncedUsers();

  /// Marks a user as synchronized
  Future<void> markUserSynced(String userId);

  // Statistics and analytics

  /// Gets user statistics (total count, active count, etc.)
  Future<Map<String, dynamic>> getUserStatistics();

  /// Gets activity statistics for a specific user
  Future<Map<String, dynamic>> getUserActivityStats(String userId);

  /// Gets user engagement metrics
  Future<Map<String, dynamic>> getUserEngagementMetrics(String userId);
}