import 'package:isar/isar.dart';
import '../../../../shared/data/cache/cache_manager.dart';
import '../models/user_model.dart';
import 'user_data_source.dart';

/// Local implementation of UserDataSource using Isar database
/// Provides caching and offline-first functionality
class LocalUserDataSource implements UserDataSource {
  final Isar _isar;
  final CacheManager _cache;

  LocalUserDataSource({
    required Isar isar,
    required CacheManager cache,
  })  : _isar = isar,
        _cache = cache;

  @override
  Future<UserModel?> getCurrentUser() async {
    const cacheKey = 'current_user';

    // Check cache first
    final cached = _cache.get<UserModel>(cacheKey);
    if (cached != null) return cached;

    // Get from database (assuming first user is current user for MVP)
    final users = await _isar.userModels.where().findAll();
    final currentUser = users.isNotEmpty ? users.first : null;

    if (currentUser != null) {
      _cache.set(cacheKey, currentUser);
    }

    return currentUser;
  }

  @override
  Future<UserModel?> getUserById(String id) async {
    final cacheKey = 'user_$id';

    // Check cache first
    final cached = _cache.get<UserModel>(cacheKey);
    if (cached != null) return cached;

    // Query database
    final user = await _isar.userModels.where().idEqualTo(id).findFirst();

    if (user != null) {
      _cache.set(cacheKey, user);
    }

    return user;
  }

  @override
  Future<UserModel> createUser(UserModel user) async {
    await _isar.writeTxn(() async {
      await _isar.userModels.put(user);
    });

    // Cache the created user
    _cache.set('user_${user.id}', user);

    return user;
  }

  @override
  Future<UserModel> updateUser(UserModel user) async {
    await _isar.writeTxn(() async {
      await _isar.userModels.put(user);
    });

    // Update cache
    _cache.set('user_${user.id}', user);
    _cache.remove('current_user'); // Invalidate current user cache

    return user;
  }

  @override
  Future<void> deleteUser(String id) async {
    await _isar.writeTxn(() async {
      await _isar.userModels.where().idEqualTo(id).deleteAll();
    });

    // Remove from cache
    _cache.remove('user_$id');
    _cache.remove('current_user');
  }

  @override
  Future<UserModel> markWallVisited(String userId, String wallId) async {
    final user = await getUserById(userId);
    if (user == null) {
      throw Exception('User not found: $userId');
    }

    // Add wall to visited list if not already there
    final updatedVisitedWalls = List<String>.from(user.visitedWallIds);
    if (!updatedVisitedWalls.contains(wallId)) {
      updatedVisitedWalls.add(wallId);
    }

    final updatedUser = user.copyWith(visitedWallIds: updatedVisitedWalls);
    return await updateUser(updatedUser);
  }

  @override
  Future<UserModel> unmarkWallVisited(String userId, String wallId) async {
    final user = await getUserById(userId);
    if (user == null) {
      throw Exception('User not found: $userId');
    }

    // Remove wall from visited list
    final updatedVisitedWalls = List<String>.from(user.visitedWallIds)
      ..remove(wallId);

    final updatedUser = user.copyWith(visitedWallIds: updatedVisitedWalls);
    return await updateUser(updatedUser);
  }

  @override
  Future<List<UserModel>> getAllUsers() async {
    const cacheKey = 'all_users';

    // Check cache first
    final cached = _cache.get<List<UserModel>>(cacheKey);
    if (cached != null) return cached;

    // Query database
    final users = await _isar.userModels.where().findAll();

    // Cache results
    _cache.set(cacheKey, users, duration: const Duration(minutes: 30));

    return users;
  }

  @override
  Future<List<UserModel>> searchUsers(String query) async {
    final lowerQuery = query.toLowerCase();

    return await _isar.userModels
        .where()
        .filter()
        .nameContains(lowerQuery, caseSensitive: false)
        .or()
        .emailIsNotNull()
        .and()
        .emailContains(lowerQuery, caseSensitive: false)
        .findAll();
  }

  @override
  Future<bool> userExists(String id) async {
    final count = await _isar.userModels.where().idEqualTo(id).count();
    return count > 0;
  }

  @override
  Future<bool> emailExists(String email) async {
    final count = await _isar.userModels.where().emailEqualTo(email).count();
    return count > 0;
  }

  @override
  Future<List<UserModel>> getUsersWhoVisitedWall(String wallId) async {
    // Note: This requires filtering based on visitedWallIds JSON content
    // For now, we'll get all users and filter in memory
    final allUsers = await getAllUsers();
    return allUsers.where((user) => user.visitedWallIds.contains(wallId)).toList();
  }

  @override
  Future<List<UserModel>> createUsers(List<UserModel> users) async {
    await _isar.writeTxn(() async {
      await _isar.userModels.putAll(users);
    });

    // Cache created users
    for (final user in users) {
      _cache.set('user_${user.id}', user);
    }

    // Invalidate list caches
    _cache.remove('all_users');

    return users;
  }

  @override
  Future<void> clearAllUsers() async {
    await _isar.writeTxn(() async {
      await _isar.userModels.clear();
    });

    // Clear cache
    _cache.clear();
  }
}