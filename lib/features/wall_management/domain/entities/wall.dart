import 'package:equatable/equatable.dart';
import '../../../../shared/domain/value_objects/location.dart';
import '../value_objects/wall_location.dart';
import '../value_objects/wall_metadata.dart';
import '../value_objects/wall_permissions.dart';

// Forward declaration to avoid circular dependency
// class User;

/// Represents a wall entity where graffiti notes can be placed.
/// Contains domain logic for access control, capacity management, and location-based features.
class Wall extends Equatable {
  final String id;
  final String name;
  final String description;
  final WallLocation location;
  final WallMetadata metadata;
  final List<String> graffitiNoteIds;
  final WallPermissions permissions;

  const Wall({
    required this.id,
    required this.name,
    required this.description,
    required this.location,
    required this.metadata,
    required this.graffitiNoteIds,
    required this.permissions,
  });

  /// Creates a new public wall
  factory Wall.createPublic({
    required String id,
    required String name,
    required String description,
    required WallLocation location,
    int maxCapacity = 100,
  }) {
    return Wall(
      id: id,
      name: name,
      description: description,
      location: location,
      metadata: WallMetadata.createPublic(maxCapacity: maxCapacity),
      graffitiNoteIds: const [],
      permissions: WallPermissions.proximityBased(),
    );
  }

  /// Creates a new private wall with an owner
  factory Wall.createPrivate({
    required String id,
    required String name,
    required String description,
    required WallLocation location,
    required String ownerId,
    int maxCapacity = 50,
  }) {
    return Wall(
      id: id,
      name: name,
      description: description,
      location: location,
      metadata: WallMetadata.createDefault(
        maxCapacity: maxCapacity,
        ownerId: ownerId,
      ),
      graffitiNoteIds: const [],
      permissions: WallPermissions.ownerOnly(ownerId: ownerId),
    );
  }

  // Domain methods

  /// Checks if this wall is within access range of a user's location
  bool isWithinAccessRange(Location userLocation) {
    if (!permissions.isProximityBased) return true;

    return location.distanceTo(userLocation) <= permissions.accessRadius;
  }

  /// Checks if a user can add graffiti to this wall
  /// Note: User parameter uses dynamic type to avoid circular dependency
  bool canAddGraffiti(dynamic user, Location userLocation) {
    // Check wall metadata constraints
    if (!metadata.canAddGraffiti()) return false;

    // Check permissions
    return permissions.canAccess(user, userLocation);
  }

  /// Checks if a user can access this wall for viewing
  /// Note: User parameter uses dynamic type to avoid circular dependency
  bool canAccess(dynamic user, Location userLocation) {
    if (!metadata.isAccessible) return false;
    return permissions.canAccess(user, userLocation);
  }

  /// Returns the distance to a user's location in kilometers
  double distanceToUser(Location userLocation) {
    return location.distanceTo(userLocation);
  }

  /// Checks if this wall is owned by a specific user
  bool isOwnedBy(String userId) {
    return metadata.hasOwner && metadata.ownerId == userId;
  }

  /// Returns the number of graffiti notes on this wall
  int get graffitiCount => graffitiNoteIds.length;

  /// Checks if this wall is at capacity
  bool get isAtCapacity => metadata.isAtCapacity();

  /// Checks if this wall is nearly full
  bool get isNearlyFull => metadata.isNearlyFull;

  /// Returns the remaining capacity
  int get remainingCapacity => metadata.remainingCapacity;

  /// Returns the capacity utilization as a percentage
  double get capacityUtilization => metadata.capacityUtilization;

  /// Checks if this wall is public
  bool get isPublic => metadata.isPublic && permissions.isPublic;

  /// Checks if this wall is private
  bool get isPrivate => !isPublic;

  /// Checks if this wall is new (created within last 7 days)
  bool get isNew => metadata.isNew;

  /// Checks if this wall is active
  bool get isActive => metadata.status == WallStatus.active;

  /// Creates a copy of this wall with optionally updated values
  Wall copyWith({
    String? id,
    String? name,
    String? description,
    WallLocation? location,
    WallMetadata? metadata,
    List<String>? graffitiNoteIds,
    WallPermissions? permissions,
  }) {
    return Wall(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      location: location ?? this.location,
      metadata: metadata ?? this.metadata,
      graffitiNoteIds: graffitiNoteIds ?? this.graffitiNoteIds,
      permissions: permissions ?? this.permissions,
    );
  }

  /// Adds a graffiti note to this wall
  Wall addGraffiti(String graffitiNoteId) {
    if (graffitiNoteIds.contains(graffitiNoteId)) return this;

    final updatedGraffitiIds = List<String>.from(graffitiNoteIds)..add(graffitiNoteId);
    final updatedMetadata = metadata.addGraffiti();

    return copyWith(
      graffitiNoteIds: updatedGraffitiIds,
      metadata: updatedMetadata,
    );
  }

  /// Removes a graffiti note from this wall
  Wall removeGraffiti(String graffitiNoteId) {
    if (!graffitiNoteIds.contains(graffitiNoteId)) return this;

    final updatedGraffitiIds = List<String>.from(graffitiNoteIds)..remove(graffitiNoteId);
    final updatedMetadata = metadata.removeGraffiti();

    return copyWith(
      graffitiNoteIds: updatedGraffitiIds,
      metadata: updatedMetadata,
    );
  }

  /// Updates the wall metadata
  Wall updateMetadata(WallMetadata newMetadata) {
    return copyWith(metadata: newMetadata);
  }

  /// Updates the wall permissions
  Wall updatePermissions(WallPermissions newPermissions) {
    return copyWith(permissions: newPermissions);
  }

  /// Updates the wall information
  Wall updateInfo({
    String? name,
    String? description,
    WallLocation? location,
  }) {
    return copyWith(
      name: name ?? this.name,
      description: description ?? this.description,
      location: location ?? this.location,
    );
  }

  /// Deactivates the wall
  Wall deactivate() {
    final updatedMetadata = metadata.updateStatus(WallStatus.inactive);
    return copyWith(metadata: updatedMetadata);
  }

  /// Activates the wall
  Wall activate() {
    final updatedMetadata = metadata.updateStatus(WallStatus.active);
    return copyWith(metadata: updatedMetadata);
  }

  /// Puts the wall in maintenance mode
  Wall setMaintenance() {
    final updatedMetadata = metadata.updateStatus(WallStatus.maintenance);
    return copyWith(metadata: updatedMetadata);
  }

  /// Archives the wall
  Wall archive() {
    final updatedMetadata = metadata.updateStatus(WallStatus.archived);
    return copyWith(metadata: updatedMetadata);
  }

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    location,
    metadata,
    graffitiNoteIds,
    permissions,
  ];

  @override
  String toString() {
    return 'Wall(id: $id, name: $name, '
           'graffiti: ${graffitiCount}/${metadata.maxCapacity}, '
           'status: ${metadata.status.name}, '
           'isPublic: $isPublic)';
  }
}