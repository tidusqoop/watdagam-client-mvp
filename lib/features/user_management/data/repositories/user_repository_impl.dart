import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/user_data_source.dart';
import '../models/user_model.dart';

/// Implementation of UserRepository that bridges domain and data layers
/// Converts between domain entities and data models
class UserRepositoryImpl implements UserRepository {
  final UserDataSource _dataSource;

  UserRepositoryImpl({
    required UserDataSource dataSource,
  }) : _dataSource = dataSource;

  @override
  Future<User?> getCurrentUser() async {
    final userModel = await _dataSource.getCurrentUser();
    return userModel?.toDomain();
  }

  @override
  Future<User?> getUserById(String id) async {
    final userModel = await _dataSource.getUserById(id);
    return userModel?.toDomain();
  }

  @override
  Future<User> createUser(User user) async {
    final userModel = UserModel.fromDomain(user);
    final createdModel = await _dataSource.createUser(userModel);
    return createdModel.toDomain();
  }

  @override
  Future<User> updateUser(User user) async {
    final userModel = UserModel.fromDomain(user);
    final updatedModel = await _dataSource.updateUser(userModel);
    return updatedModel.toDomain();
  }

  @override
  Future<void> markWallVisited(String userId, String wallId) async {
    await _dataSource.markWallVisited(userId, wallId);
  }

  @override
  Future<User?> signIn(String email, String password) async {
    // For MVP, we'll implement a simple check
    // In production, this would involve proper authentication
    final users = await _dataSource.getAllUsers();

    final user = users.cast<UserModel?>().firstWhere(
      (user) => user?.email == email,
      orElse: () => null,
    );

    // For MVP, we'll just check if email exists (no password validation)
    return user?.toDomain();
  }

  @override
  Future<User> signUp(String email, String password, String name) async {
    // Check if email already exists
    final emailExists = await _dataSource.emailExists(email);
    if (emailExists) {
      throw Exception('Email already registered');
    }

    // Create new user
    final newUser = User.create(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      email: email,
    );

    return await createUser(newUser);
  }

  @override
  Future<void> signOut() async {
    // For MVP, this is a no-op
    // In production, this would clear auth tokens, etc.
  }

  /// Additional helper methods for extended functionality

  /// Gets all users (useful for development/testing)
  Future<List<User>> getAllUsers() async {
    final userModels = await _dataSource.getAllUsers();
    return userModels.map((model) => model.toDomain()).toList();
  }

  /// Searches users by name or email
  Future<List<User>> searchUsers(String query) async {
    final userModels = await _dataSource.searchUsers(query);
    return userModels.map((model) => model.toDomain()).toList();
  }

  /// Checks if a user exists
  Future<bool> userExists(String id) async {
    return await _dataSource.userExists(id);
  }

  /// Checks if an email is already registered
  Future<bool> emailExists(String email) async {
    return await _dataSource.emailExists(email);
  }

  /// Gets users who visited a specific wall
  Future<List<User>> getUsersWhoVisitedWall(String wallId) async {
    final userModels = await _dataSource.getUsersWhoVisitedWall(wallId);
    return userModels.map((model) => model.toDomain()).toList();
  }

  /// Removes a wall from user's visited list
  Future<User> unmarkWallVisited(String userId, String wallId) async {
    final updatedModel = await _dataSource.unmarkWallVisited(userId, wallId);
    return updatedModel.toDomain();
  }

  /// Bulk creates users (for testing/seeding)
  Future<List<User>> createUsers(List<User> users) async {
    final userModels = users.map((user) => UserModel.fromDomain(user)).toList();
    final createdModels = await _dataSource.createUsers(userModels);
    return createdModels.map((model) => model.toDomain()).toList();
  }

  /// Deletes a user
  Future<void> deleteUser(String id) async {
    await _dataSource.deleteUser(id);
  }

  /// Clears all users (for testing)
  Future<void> clearAllUsers() async {
    await _dataSource.clearAllUsers();
  }
}