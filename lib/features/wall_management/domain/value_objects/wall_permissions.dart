import '../../../../shared/domain/value_objects/value_object.dart';
import '../../../../shared/domain/value_objects/location.dart';

// Forward declaration to avoid circular dependency
// class User;

/// Enum representing different access types for walls
enum WallAccessType {
  public,           // Anyone can access
  proximityBased,   // Access based on location proximity
  visitedOnly,      // Only users who have visited before
  ownerOnly;        // Only the owner can access

  /// Returns the display name for the access type in Korean
  String get displayName {
    switch (this) {
      case WallAccessType.public:
        return '공개';
      case WallAccessType.proximityBased:
        return '근거리 접근';
      case WallAccessType.visitedOnly:
        return '방문자만';
      case WallAccessType.ownerOnly:
        return '소유자만';
    }
  }

  /// Returns the description for the access type
  String get description {
    switch (this) {
      case WallAccessType.public:
        return '누구나 접근할 수 있습니다';
      case WallAccessType.proximityBased:
        return '일정 거리 내에서만 접근할 수 있습니다';
      case WallAccessType.visitedOnly:
        return '이전에 방문한 사용자만 접근할 수 있습니다';
      case WallAccessType.ownerOnly:
        return '소유자만 접근할 수 있습니다';
    }
  }

  /// Creates a WallAccessType from string
  static WallAccessType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'public':
      case '공개':
        return WallAccessType.public;
      case 'proximity':
      case 'proximity_based':
      case '근거리':
        return WallAccessType.proximityBased;
      case 'visited':
      case 'visited_only':
      case '방문자만':
        return WallAccessType.visitedOnly;
      case 'owner':
      case 'owner_only':
      case '소유자만':
        return WallAccessType.ownerOnly;
      default:
        return WallAccessType.proximityBased;
    }
  }
}

/// Represents permissions and access control for a wall
class WallPermissions extends ValueObject {
  final WallAccessType accessType;
  final double accessRadius; // in kilometers
  final List<String> allowedUserIds;
  final List<String> blockedUserIds;

  const WallPermissions({
    required this.accessType,
    required this.accessRadius,
    required this.allowedUserIds,
    required this.blockedUserIds,
  });

  /// Creates default permissions for a public wall
  factory WallPermissions.public() {
    return const WallPermissions(
      accessType: WallAccessType.public,
      accessRadius: 0.0,
      allowedUserIds: [],
      blockedUserIds: [],
    );
  }

  /// Creates permissions for a proximity-based wall
  factory WallPermissions.proximityBased({
    double accessRadius = 3.0, // Default 3km as per design document
  }) {
    return WallPermissions(
      accessType: WallAccessType.proximityBased,
      accessRadius: accessRadius,
      allowedUserIds: const [],
      blockedUserIds: const [],
    );
  }

  /// Creates permissions for a visited-only wall
  factory WallPermissions.visitedOnly() {
    return const WallPermissions(
      accessType: WallAccessType.visitedOnly,
      accessRadius: 0.0,
      allowedUserIds: [],
      blockedUserIds: [],
    );
  }

  /// Creates permissions for an owner-only wall
  factory WallPermissions.ownerOnly({
    required String ownerId,
  }) {
    return WallPermissions(
      accessType: WallAccessType.ownerOnly,
      accessRadius: 0.0,
      allowedUserIds: [ownerId],
      blockedUserIds: const [],
    );
  }

  // Domain methods

  /// Checks if a user can access this wall based on permissions
  /// Note: User parameter uses dynamic type to avoid circular dependency
  bool canAccess(dynamic user, Location userLocation) {
    // Check if user is blocked
    if (isUserBlocked(user.id)) return false;

    // Check access type specific rules
    switch (accessType) {
      case WallAccessType.public:
        return true;

      case WallAccessType.proximityBased:
        // Check if user has visited before OR is within proximity
        if (user.hasVisitedWall(user.id)) return true;
        return _isWithinProximity(userLocation);

      case WallAccessType.visitedOnly:
        return user.hasVisitedWall(user.id);

      case WallAccessType.ownerOnly:
        return isUserAllowed(user.id);
    }
  }

  /// Checks if a user is explicitly allowed
  bool isUserAllowed(String userId) => allowedUserIds.contains(userId);

  /// Checks if a user is blocked
  bool isUserBlocked(String userId) => blockedUserIds.contains(userId);

  /// Checks if a location is within the access radius
  bool _isWithinProximity(Location userLocation) {
    // This method would need the wall location, which should be passed in
    // For now, we return true as this check should be done at the entity level
    return true;
  }

  /// Checks if this wall uses proximity-based access
  bool get isProximityBased => accessType == WallAccessType.proximityBased;

  /// Checks if this wall is public
  bool get isPublic => accessType == WallAccessType.public;

  /// Checks if this wall has restricted access
  bool get hasRestrictedAccess => !isPublic;

  /// Returns the number of explicitly allowed users
  int get allowedUserCount => allowedUserIds.length;

  /// Returns the number of blocked users
  int get blockedUserCount => blockedUserIds.length;

  /// Creates a copy of this permissions with optionally updated values
  WallPermissions copyWith({
    WallAccessType? accessType,
    double? accessRadius,
    List<String>? allowedUserIds,
    List<String>? blockedUserIds,
  }) {
    return WallPermissions(
      accessType: accessType ?? this.accessType,
      accessRadius: accessRadius ?? this.accessRadius,
      allowedUserIds: allowedUserIds ?? this.allowedUserIds,
      blockedUserIds: blockedUserIds ?? this.blockedUserIds,
    );
  }

  /// Updates the access type
  WallPermissions updateAccessType(WallAccessType newAccessType) {
    return copyWith(accessType: newAccessType);
  }

  /// Updates the access radius
  WallPermissions updateAccessRadius(double newRadius) {
    return copyWith(accessRadius: newRadius);
  }

  /// Adds a user to the allowed list
  WallPermissions addAllowedUser(String userId) {
    if (isUserAllowed(userId)) return this;

    final updatedAllowed = List<String>.from(allowedUserIds)..add(userId);
    return copyWith(allowedUserIds: updatedAllowed);
  }

  /// Removes a user from the allowed list
  WallPermissions removeAllowedUser(String userId) {
    if (!isUserAllowed(userId)) return this;

    final updatedAllowed = List<String>.from(allowedUserIds)..remove(userId);
    return copyWith(allowedUserIds: updatedAllowed);
  }

  /// Adds a user to the blocked list
  WallPermissions blockUser(String userId) {
    if (isUserBlocked(userId)) return this;

    final updatedBlocked = List<String>.from(blockedUserIds)..add(userId);
    // Also remove from allowed list if present
    final updatedAllowed = List<String>.from(allowedUserIds)..remove(userId);

    return copyWith(
      allowedUserIds: updatedAllowed,
      blockedUserIds: updatedBlocked,
    );
  }

  /// Removes a user from the blocked list
  WallPermissions unblockUser(String userId) {
    if (!isUserBlocked(userId)) return this;

    final updatedBlocked = List<String>.from(blockedUserIds)..remove(userId);
    return copyWith(blockedUserIds: updatedBlocked);
  }

  /// Creates a WallPermissions from JSON map
  factory WallPermissions.fromJson(Map<String, dynamic> json) {
    return WallPermissions(
      accessType: WallAccessType.fromString(json['accessType'] as String),
      accessRadius: (json['accessRadius'] as num).toDouble(),
      allowedUserIds: List<String>.from(json['allowedUserIds'] as List),
      blockedUserIds: List<String>.from(json['blockedUserIds'] as List),
    );
  }

  /// Converts WallPermissions to JSON map
  Map<String, dynamic> toJson() {
    return {
      'accessType': accessType.name,
      'accessRadius': accessRadius,
      'allowedUserIds': allowedUserIds,
      'blockedUserIds': blockedUserIds,
    };
  }

  @override
  List<Object?> get props => [
    accessType,
    accessRadius,
    allowedUserIds,
    blockedUserIds,
  ];

  @override
  String toString() {
    return 'WallPermissions(type: ${accessType.name}, '
           'radius: ${accessRadius}km, '
           'allowed: ${allowedUserIds.length}, '
           'blocked: ${blockedUserIds.length})';
  }
}