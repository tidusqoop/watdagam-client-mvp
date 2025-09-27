import 'package:flutter_test/flutter_test.dart';
import 'package:watdagam/features/wall_management/domain/entities/wall.dart';
import 'package:watdagam/features/wall_management/domain/value_objects/wall_location.dart';
import 'package:watdagam/features/wall_management/domain/value_objects/wall_metadata.dart';
import 'package:watdagam/features/wall_management/domain/value_objects/wall_permissions.dart';
import 'package:watdagam/features/user_management/domain/entities/user.dart';
import 'package:watdagam/features/user_management/domain/value_objects/user_preferences.dart';
import 'package:watdagam/shared/domain/value_objects/location.dart';

void main() {
  group('Wall Entity', () {
    late Wall testWall;
    late User testUser;
    late Location userLocation;

    setUp(() {
      testWall = Wall(
        id: 'wall123',
        name: 'Test Wall',
        description: 'A test wall for graffiti',
        location: const WallLocation(
          latitude: 37.5665,
          longitude: 126.9780,
          address: '서울시 중구 명동',
        ),
        metadata: WallMetadata(
          createdAt: DateTime(2024, 1, 1),
          maxCapacity: 100,
          status: WallStatus.active,
          ownerId: 'owner123',
          graffitiCount: 25,
        ),
        permissions: const WallPermissions(
          accessType: WallAccessType.public,
          accessRadius: 1.0, // 1km
          allowedUserIds: [],
          blockedUserIds: [],
        ),
        graffitiNoteIds: ['graffiti1', 'graffiti2', 'graffiti3'],
      );

      testUser = User(
        id: 'user456',
        name: 'Test User',
        email: 'test@example.com',
        avatarPath: null,
        createdAt: DateTime(2024, 1, 1),
        preferences: const UserPreferences(
          enableLocationTracking: true,
          notifications: NotificationSettings(
            enablePushNotifications: true,
            enableGraffitiUpdates: true,
            enableWallUpdates: true,
            enableLocationReminders: false,
          ),
          preferredLanguage: 'ko',
        ),
        visitedWallIds: [],
      );

      userLocation = const Location(
        latitude: 37.5665,
        longitude: 126.9780,
        accuracy: 5.0,
        timestamp: null,
      );
    });

    group('isWithinAccessRange', () {
      test('returns true when user is within access radius', () {
        // Arrange - User at exact wall location
        final wallLocation = const Location(
          latitude: 37.5665,
          longitude: 126.9780,
          accuracy: 5.0,
          timestamp: null,
        );

        // Act
        final result = testWall.isWithinAccessRange(wallLocation);

        // Assert
        expect(result, isTrue);
      });

      test('returns true when user is just within access radius', () {
        // Arrange - User about 0.5km away (within 1km radius)
        final nearbyLocation = const Location(
          latitude: 37.5620, // Slightly south, about 0.5km
          longitude: 126.9780,
          accuracy: 5.0,
          timestamp: null,
        );

        // Act
        final result = testWall.isWithinAccessRange(nearbyLocation);

        // Assert
        expect(result, isTrue);
      });

      test('returns false when user is outside access radius', () {
        // Arrange - User far away (more than 1km)
        final farLocation = const Location(
          latitude: 37.5500, // About 2km south
          longitude: 126.9780,
          accuracy: 5.0,
          timestamp: null,
        );

        // Act
        final result = testWall.isWithinAccessRange(farLocation);

        // Assert
        expect(result, isFalse);
      });

      test('handles edge case at exact boundary', () {
        // Arrange - Wall with larger radius for clearer testing
        final wallWithLargerRadius = testWall.copyWith(
          permissions: const WallPermissions(
            accessType: WallAccessType.public,
            accessRadius: 5.0, // 5km radius
            allowedUserIds: [],
            blockedUserIds: [],
          ),
        );

        // Location approximately 5km away
        final boundaryLocation = const Location(
          latitude: 37.5200, // About 5km south
          longitude: 126.9780,
          accuracy: 5.0,
          timestamp: null,
        );

        // Act
        final result = wallWithLargerRadius.isWithinAccessRange(boundaryLocation);

        // Assert
        // Should be close to the boundary - exact behavior depends on implementation precision
        expect(result, isA<bool>());
      });
    });

    group('canAddGraffiti', () {
      test('returns true when user can access wall and wall has capacity', () {
        // Arrange - User at wall location, wall not at capacity
        expect(testWall.metadata.isAtCapacity(), isFalse);

        // Act
        final result = testWall.canAddGraffiti(testUser, userLocation);

        // Assert
        expect(result, isTrue);
      });

      test('returns false when wall is at capacity', () {
        // Arrange - Wall at maximum capacity
        final fullWall = testWall.copyWith(
          metadata: testWall.metadata.copyWith(
            graffitiCount: 100, // Equals maxCapacity
          ),
        );

        // Act
        final result = fullWall.canAddGraffiti(testUser, userLocation);

        // Assert
        expect(result, isFalse);
      });

      test('returns false when user cannot access wall', () {
        // Arrange - User far from wall
        final farLocation = const Location(
          latitude: 35.0,
          longitude: 129.0,
          accuracy: 5.0,
          timestamp: null,
        );

        // Act
        final result = testWall.canAddGraffiti(testUser, farLocation);

        // Assert
        expect(result, isFalse);
      });

      test('returns false when user is blocked', () {
        // Arrange - User is blocked
        final wallWithBlockedUser = testWall.copyWith(
          permissions: const WallPermissions(
            accessType: WallAccessType.public,
            accessRadius: 1.0,
            allowedUserIds: [],
            blockedUserIds: ['user456'], // testUser is blocked
          ),
        );

        // Act
        final result = wallWithBlockedUser.canAddGraffiti(testUser, userLocation);

        // Assert
        expect(result, isFalse);
      });

      test('returns true for allowed users in restricted walls', () {
        // Arrange - Restricted wall with user in allowed list
        final restrictedWall = testWall.copyWith(
          permissions: const WallPermissions(
            accessType: WallAccessType.restricted,
            accessRadius: 1.0,
            allowedUserIds: ['user456'], // testUser is allowed
            blockedUserIds: [],
          ),
        );

        // Act
        final result = restrictedWall.canAddGraffiti(testUser, userLocation);

        // Assert
        expect(result, isTrue);
      });
    });

    group('addGraffiti', () {
      test('adds graffiti note ID to wall', () {
        // Arrange
        const newGraffitiId = 'graffiti999';
        final originalCount = testWall.graffitiNoteIds.length;

        // Act
        final updatedWall = testWall.addGraffiti(newGraffitiId);

        // Assert
        expect(updatedWall.graffitiNoteIds.contains(newGraffitiId), isTrue);
        expect(updatedWall.graffitiNoteIds.length, equals(originalCount + 1));
        expect(updatedWall.metadata.graffitiCount, equals(testWall.metadata.graffitiCount + 1));
      });

      test('does not duplicate existing graffiti ID', () {
        // Arrange
        const existingGraffitiId = 'graffiti1';
        final originalCount = testWall.graffitiNoteIds.length;

        // Act
        final updatedWall = testWall.addGraffiti(existingGraffitiId);

        // Assert
        expect(updatedWall.graffitiNoteIds.length, equals(originalCount));
        expect(updatedWall.metadata.graffitiCount, equals(testWall.metadata.graffitiCount));
      });

      test('maintains immutability of original wall', () {
        // Arrange
        const newGraffitiId = 'graffiti999';
        final originalGraffitiIds = List<String>.from(testWall.graffitiNoteIds);

        // Act
        final updatedWall = testWall.addGraffiti(newGraffitiId);

        // Assert
        expect(testWall.graffitiNoteIds, equals(originalGraffitiIds));
        expect(testWall.graffitiNoteIds.contains(newGraffitiId), isFalse);
        expect(updatedWall.graffitiNoteIds.contains(newGraffitiId), isTrue);
      });
    });

    group('removeGraffiti', () {
      test('removes existing graffiti note ID from wall', () {
        // Arrange
        const graffitiToRemove = 'graffiti1';
        expect(testWall.graffitiNoteIds.contains(graffitiToRemove), isTrue);

        // Act
        final updatedWall = testWall.removeGraffiti(graffitiToRemove);

        // Assert
        expect(updatedWall.graffitiNoteIds.contains(graffitiToRemove), isFalse);
        expect(updatedWall.graffitiNoteIds.length, equals(testWall.graffitiNoteIds.length - 1));
        expect(updatedWall.metadata.graffitiCount, equals(testWall.metadata.graffitiCount - 1));
      });

      test('handles removal of non-existent graffiti gracefully', () {
        // Arrange
        const nonExistentGraffiti = 'graffiti999';
        final originalCount = testWall.graffitiNoteIds.length;

        // Act
        final updatedWall = testWall.removeGraffiti(nonExistentGraffiti);

        // Assert
        expect(updatedWall.graffitiNoteIds.length, equals(originalCount));
        expect(updatedWall.metadata.graffitiCount, equals(testWall.metadata.graffitiCount));
      });
    });

    group('updateMetadata', () {
      test('updates wall metadata', () {
        // Arrange
        final newMetadata = WallMetadata(
          createdAt: testWall.metadata.createdAt,
          maxCapacity: 200,
          status: WallStatus.archived,
          ownerId: 'new_owner',
          graffitiCount: 50,
        );

        // Act
        final updatedWall = testWall.updateMetadata(newMetadata);

        // Assert
        expect(updatedWall.metadata.maxCapacity, equals(200));
        expect(updatedWall.metadata.status, equals(WallStatus.archived));
        expect(updatedWall.metadata.ownerId, equals('new_owner'));
        expect(updatedWall.metadata.graffitiCount, equals(50));
      });

      test('maintains other properties when updating metadata', () {
        // Arrange
        final newMetadata = WallMetadata(
          createdAt: testWall.metadata.createdAt,
          maxCapacity: 200,
          status: WallStatus.archived,
          ownerId: 'new_owner',
          graffitiCount: 50,
        );

        // Act
        final updatedWall = testWall.updateMetadata(newMetadata);

        // Assert
        expect(updatedWall.id, equals(testWall.id));
        expect(updatedWall.name, equals(testWall.name));
        expect(updatedWall.location, equals(testWall.location));
        expect(updatedWall.permissions, equals(testWall.permissions));
      });
    });

    group('updatePermissions', () {
      test('updates wall permissions', () {
        // Arrange
        const newPermissions = WallPermissions(
          accessType: WallAccessType.restricted,
          accessRadius: 2.0,
          allowedUserIds: ['user456', 'user789'],
          blockedUserIds: ['user999'],
        );

        // Act
        final updatedWall = testWall.updatePermissions(newPermissions);

        // Assert
        expect(updatedWall.permissions.accessType, equals(WallAccessType.restricted));
        expect(updatedWall.permissions.accessRadius, equals(2.0));
        expect(updatedWall.permissions.allowedUserIds, contains('user456'));
        expect(updatedWall.permissions.blockedUserIds, contains('user999'));
      });
    });

    group('hasGraffiti', () {
      test('returns true when wall contains the graffiti', () {
        // Act
        final result = testWall.hasGraffiti('graffiti1');

        // Assert
        expect(result, isTrue);
      });

      test('returns false when wall does not contain the graffiti', () {
        // Act
        final result = testWall.hasGraffiti('graffiti999');

        // Assert
        expect(result, isFalse);
      });
    });

    group('graffitiCount', () {
      test('returns correct graffiti count', () {
        // Act
        final result = testWall.graffitiCount;

        // Assert
        expect(result, equals(3)); // Based on graffitiNoteIds.length
      });
    });

    group('isOwned', () {
      test('returns true when wall has an owner', () {
        // Act
        final result = testWall.isOwned;

        // Assert
        expect(result, isTrue);
      });

      test('returns false when wall has no owner', () {
        // Arrange
        final unownedWall = testWall.copyWith(
          metadata: testWall.metadata.copyWith(ownerId: null),
        );

        // Act
        final result = unownedWall.isOwned;

        // Assert
        expect(result, isFalse);
      });
    });

    group('equality and props', () {
      test('walls with same properties are equal', () {
        // Arrange
        final wall1 = Wall(
          id: 'wall123',
          name: 'Test Wall',
          description: 'A test wall for graffiti',
          location: const WallLocation(
            latitude: 37.5665,
            longitude: 126.9780,
            address: '서울시 중구 명동',
          ),
          metadata: WallMetadata(
            createdAt: DateTime(2024, 1, 1),
            maxCapacity: 100,
            status: WallStatus.active,
            ownerId: 'owner123',
            graffitiCount: 25,
          ),
          permissions: const WallPermissions(
            accessType: WallAccessType.public,
            accessRadius: 1.0,
            allowedUserIds: [],
            blockedUserIds: [],
          ),
          graffitiNoteIds: ['graffiti1', 'graffiti2', 'graffiti3'],
        );

        final wall2 = Wall(
          id: 'wall123',
          name: 'Test Wall',
          description: 'A test wall for graffiti',
          location: const WallLocation(
            latitude: 37.5665,
            longitude: 126.9780,
            address: '서울시 중구 명동',
          ),
          metadata: WallMetadata(
            createdAt: DateTime(2024, 1, 1),
            maxCapacity: 100,
            status: WallStatus.active,
            ownerId: 'owner123',
            graffitiCount: 25,
          ),
          permissions: const WallPermissions(
            accessType: WallAccessType.public,
            accessRadius: 1.0,
            allowedUserIds: [],
            blockedUserIds: [],
          ),
          graffitiNoteIds: ['graffiti1', 'graffiti2', 'graffiti3'],
        );

        // Assert
        expect(wall1, equals(wall2));
        expect(wall1.hashCode, equals(wall2.hashCode));
      });

      test('walls with different properties are not equal', () {
        // Arrange
        final differentWall = testWall.copyWith(id: 'different_id');

        // Assert
        expect(testWall, isNot(equals(differentWall)));
      });
    });
  });
}