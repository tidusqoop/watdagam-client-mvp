import 'package:equatable/equatable.dart';
import '../../../../shared/domain/value_objects/location.dart';
import '../value_objects/user_preferences.dart';

// Forward declaration to avoid circular dependency
// class Wall;

/// Represents a user in the system with their preferences and wall visit history.
/// Contains domain logic for wall access permissions and visit tracking.
class User extends Equatable {
  final String id;
  final String name;
  final String? email;
  final String? avatarPath;
  final DateTime createdAt;
  final UserPreferences preferences;
  final List<String> visitedWallIds;

  const User({
    required this.id,
    required this.name,
    this.email,
    this.avatarPath,
    required this.createdAt,
    required this.preferences,
    required this.visitedWallIds,
  });

  /// Creates a new user with default preferences
  factory User.create({
    required String id,
    required String name,
    String? email,
    String? avatarPath,
    UserPreferences? preferences,
  }) {
    return User(
      id: id,
      name: name,
      email: email,
      avatarPath: avatarPath,
      createdAt: DateTime.now(),
      preferences: preferences ?? UserPreferences.defaults(),
      visitedWallIds: const [],
    );
  }

  /// Creates a guest user with privacy-focused preferences
  factory User.guest() {
    return User(
      id: 'guest_${DateTime.now().millisecondsSinceEpoch}',
      name: '익명 사용자',
      email: null,
      avatarPath: null,
      createdAt: DateTime.now(),
      preferences: UserPreferences.privacyFocused(),
      visitedWallIds: const [],
    );
  }

  // Domain methods

  /// Checks if the user has visited a specific wall
  bool hasVisitedWall(String wallId) => visitedWallIds.contains(wallId);

  /// Checks if the user can access a wall based on visit history or proximity
  /// Note: Wall parameter uses dynamic type to avoid circular dependency
  bool canAccessWall(dynamic wall, Location currentLocation) {
    // Check if user has visited this wall before
    if (hasVisitedWall(wall.id)) return true;

    // Check if user has location tracking enabled
    if (!preferences.enableLocationTracking) return false;

    // Check if wall is within access range
    return wall.isWithinAccessRange(currentLocation);
  }

  /// Returns the number of walls visited by this user
  int get visitedWallCount => visitedWallIds.length;

  /// Checks if this is a new user (created within last 7 days)
  bool get isNewUser {
    final daysSinceCreation = DateTime.now().difference(createdAt).inDays;
    return daysSinceCreation <= 7;
  }

  /// Checks if this is a guest user
  bool get isGuest => id.startsWith('guest_');

  /// Checks if this is a registered user
  bool get isRegistered => !isGuest && email != null;

  /// Checks if user has an avatar
  bool get hasAvatar => avatarPath != null && avatarPath!.isNotEmpty;

  /// Returns the display name for the user
  String get displayName {
    if (name.trim().isEmpty) {
      return isGuest ? '익명 사용자' : '사용자';
    }
    return name;
  }

  /// Creates a copy of this user with optionally updated values
  User copyWith({
    String? id,
    String? name,
    String? email,
    String? avatarPath,
    DateTime? createdAt,
    UserPreferences? preferences,
    List<String>? visitedWallIds,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarPath: avatarPath ?? this.avatarPath,
      createdAt: createdAt ?? this.createdAt,
      preferences: preferences ?? this.preferences,
      visitedWallIds: visitedWallIds ?? this.visitedWallIds,
    );
  }

  /// Adds a wall to the visited walls list
  User addVisitedWall(String wallId) {
    if (hasVisitedWall(wallId)) return this;

    final updatedVisitedWalls = List<String>.from(visitedWallIds)..add(wallId);
    return copyWith(visitedWallIds: updatedVisitedWalls);
  }

  /// Removes a wall from the visited walls list
  User removeVisitedWall(String wallId) {
    if (!hasVisitedWall(wallId)) return this;

    final updatedVisitedWalls = List<String>.from(visitedWallIds)..remove(wallId);
    return copyWith(visitedWallIds: updatedVisitedWalls);
  }

  /// Updates user preferences
  User updatePreferences(UserPreferences newPreferences) {
    return copyWith(preferences: newPreferences);
  }

  /// Updates user profile information
  User updateProfile({
    String? name,
    String? email,
    String? avatarPath,
  }) {
    return copyWith(
      name: name ?? this.name,
      email: email ?? this.email,
      avatarPath: avatarPath ?? this.avatarPath,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    email,
    avatarPath,
    createdAt,
    preferences,
    visitedWallIds,
  ];

  @override
  String toString() {
    return 'User(id: $id, name: $name, email: $email, '
           'visitedWalls: ${visitedWallIds.length}, '
           'isGuest: $isGuest)';
  }
}