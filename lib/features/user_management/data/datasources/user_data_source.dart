import '../models/user_model.dart';

/// Abstract data source interface for User operations
/// Defines contract for data access operations
abstract class UserDataSource {
  /// Retrieves the current user
  Future<UserModel?> getCurrentUser();

  /// Retrieves a user by ID
  Future<UserModel?> getUserById(String id);

  /// Creates a new user
  Future<UserModel> createUser(UserModel user);

  /// Updates an existing user
  Future<UserModel> updateUser(UserModel user);

  /// Deletes a user by ID
  Future<void> deleteUser(String id);

  /// Marks a wall as visited by the user
  Future<UserModel> markWallVisited(String userId, String wallId);

  /// Removes a wall from visited list
  Future<UserModel> unmarkWallVisited(String userId, String wallId);

  /// Gets all users (for admin purposes)
  Future<List<UserModel>> getAllUsers();

  /// Searches users by name or email
  Future<List<UserModel>> searchUsers(String query);

  /// Checks if a user exists by ID
  Future<bool> userExists(String id);

  /// Checks if an email is already registered
  Future<bool> emailExists(String email);

  /// Gets users who visited a specific wall
  Future<List<UserModel>> getUsersWhoVisitedWall(String wallId);

  /// Bulk creates users (for migration or testing)
  Future<List<UserModel>> createUsers(List<UserModel> users);

  /// Clears all user data (for testing/reset)
  Future<void> clearAllUsers();
}