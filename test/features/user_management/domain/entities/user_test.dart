import 'package:flutter_test/flutter_test.dart';
import 'package:watdagam/features/user_management/domain/entities/user.dart';
import 'package:watdagam/features/user_management/domain/value_objects/user_preferences.dart';
import 'package:watdagam/features/wall_management/domain/entities/wall.dart';
import 'package:watdagam/features/wall_management/domain/value_objects/wall_location.dart';
import 'package:watdagam/features/wall_management/domain/value_objects/wall_metadata.dart';
import 'package:watdagam/features/wall_management/domain/value_objects/wall_permissions.dart';
import 'package:watdagam/shared/domain/value_objects/location.dart';

void main() {
  group('User Entity', () {
    late User testUser;
    late Wall testWall;
    late Location userLocation;

    setUp(() {
      testUser = User(
        id: 'user123',
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
        visitedWallIds: ['wall1', 'wall2'],
      );

      testWall = Wall(
        id: 'wall3',
        name: 'Test Wall',
        description: 'A test wall',
        location: const WallLocation(
          latitude: 37.5665,
          longitude: 126.9780,
          address: '서울시 중구',
        ),
        metadata: WallMetadata(
          createdAt: DateTime(2024, 1, 1),
          maxCapacity: 100,
          status: WallStatus.active,
          ownerId: null,
          graffitiCount: 50,
        ),
        permissions: const WallPermissions(
          accessType: WallAccessType.public,
          accessRadius: 1.0, // 1km
          allowedUserIds: [],
          blockedUserIds: [],
        ),
        graffitiNoteIds: [],
      );

      userLocation = const Location(
        latitude: 37.5665,
        longitude: 126.9780,
        accuracy: 5.0,
        timestamp: null,
      );
    });

    group('hasVisitedWall', () {
      test('returns true when user has visited the wall', () {
        // Arrange
        final visitedWallId = 'wall1';

        // Act
        final result = testUser.hasVisitedWall(visitedWallId);

        // Assert
        expect(result, isTrue);
      });

      test('returns false when user has not visited the wall', () {
        // Arrange
        final unvisitedWallId = 'wall999';

        // Act
        final result = testUser.hasVisitedWall(unvisitedWallId);

        // Assert
        expect(result, isFalse);
      });

      test('returns false for empty wall ID', () {
        // Act
        final result = testUser.hasVisitedWall('');

        // Assert
        expect(result, isFalse);
      });
    });

    group('canAccessWall', () {
      test('returns true for visited walls regardless of location', () {
        // Arrange
        final visitedWall = testWall.copyWith(id: 'wall1'); // wall1 is in visitedWallIds
        final farLocation = const Location(
          latitude: 35.0,
          longitude: 129.0,
          accuracy: 5.0,
          timestamp: null,
        );

        // Act
        final result = testUser.canAccessWall(visitedWall, farLocation);

        // Assert
        expect(result, isTrue);
      });

      test('returns true for nearby unvisited walls', () {
        // Arrange
        final nearbyLocation = const Location(
          latitude: 37.5666, // Very close to wall location
          longitude: 126.9781,
          accuracy: 5.0,
          timestamp: null,
        );

        // Act
        final result = testUser.canAccessWall(testWall, nearbyLocation);

        // Assert
        expect(result, isTrue);
      });

      test('returns false for distant unvisited walls', () {
        // Arrange
        final farLocation = const Location(
          latitude: 35.0,
          longitude: 129.0,
          accuracy: 5.0,
          timestamp: null,
        );

        // Act
        final result = testUser.canAccessWall(testWall, farLocation);

        // Assert
        expect(result, isFalse);
      });

      test('returns false for blocked users regardless of location or visits', () {
        // Arrange
        final blockedWall = testWall.copyWith(
          id: 'wall1', // User has visited this wall
          permissions: const WallPermissions(
            accessType: WallAccessType.public,
            accessRadius: 1.0,
            allowedUserIds: [],
            blockedUserIds: ['user123'], // User is blocked
          ),
        );

        // Act
        final result = testUser.canAccessWall(blockedWall, userLocation);

        // Assert
        expect(result, isFalse);
      });

      test('returns true for allowed users in restricted walls', () {
        // Arrange
        final restrictedWall = testWall.copyWith(
          permissions: const WallPermissions(
            accessType: WallAccessType.restricted,
            accessRadius: 1.0,
            allowedUserIds: ['user123'], // User is explicitly allowed
            blockedUserIds: [],
          ),
        );

        // Act
        final result = testUser.canAccessWall(restrictedWall, userLocation);

        // Assert
        expect(result, isTrue);
      });

      test('returns false for non-allowed users in restricted walls', () {
        // Arrange
        final restrictedWall = testWall.copyWith(
          permissions: const WallPermissions(
            accessType: WallAccessType.restricted,
            accessRadius: 1.0,
            allowedUserIds: ['other_user'], // User is not allowed
            blockedUserIds: [],
          ),
        );

        // Act
        final result = testUser.canAccessWall(restrictedWall, userLocation);

        // Assert
        expect(result, isFalse);
      });

      test('returns false for private walls', () {
        // Arrange
        final privateWall = testWall.copyWith(
          permissions: const WallPermissions(
            accessType: WallAccessType.private,
            accessRadius: 1.0,
            allowedUserIds: [],
            blockedUserIds: [],
          ),
        );

        // Act
        final result = testUser.canAccessWall(privateWall, userLocation);

        // Assert
        expect(result, isFalse);
      });
    });

    group('addVisitedWall', () {
      test('adds new wall to visited walls list', () {
        // Arrange
        const newWallId = 'wall999';
        expect(testUser.hasVisitedWall(newWallId), isFalse);

        // Act
        final updatedUser = testUser.addVisitedWall(newWallId);

        // Assert
        expect(updatedUser.hasVisitedWall(newWallId), isTrue);
        expect(updatedUser.visitedWallIds.contains(newWallId), isTrue);
        expect(updatedUser.visitedWallIds.length, equals(3));
      });

      test('does not duplicate existing visited wall', () {
        // Arrange
        const existingWallId = 'wall1';
        expect(testUser.hasVisitedWall(existingWallId), isTrue);
        final originalCount = testUser.visitedWallIds.length;

        // Act
        final updatedUser = testUser.addVisitedWall(existingWallId);

        // Assert
        expect(updatedUser.visitedWallIds.length, equals(originalCount));
        expect(updatedUser.hasVisitedWall(existingWallId), isTrue);
      });

      test('maintains immutability of original user', () {
        // Arrange
        const newWallId = 'wall999';
        final originalVisitedCount = testUser.visitedWallIds.length;

        // Act
        final updatedUser = testUser.addVisitedWall(newWallId);

        // Assert
        expect(testUser.visitedWallIds.length, equals(originalVisitedCount));
        expect(testUser.hasVisitedWall(newWallId), isFalse);
        expect(updatedUser.hasVisitedWall(newWallId), isTrue);
      });
    });

    group('removeVisitedWall', () {
      test('removes existing visited wall', () {
        // Arrange
        const wallToRemove = 'wall1';
        expect(testUser.hasVisitedWall(wallToRemove), isTrue);

        // Act
        final updatedUser = testUser.removeVisitedWall(wallToRemove);

        // Assert
        expect(updatedUser.hasVisitedWall(wallToRemove), isFalse);
        expect(updatedUser.visitedWallIds.length, equals(1));
        expect(updatedUser.visitedWallIds.contains('wall2'), isTrue);
      });

      test('handles removal of non-existent wall gracefully', () {
        // Arrange
        const nonExistentWall = 'wall999';
        final originalCount = testUser.visitedWallIds.length;

        // Act
        final updatedUser = testUser.removeVisitedWall(nonExistentWall);

        // Assert
        expect(updatedUser.visitedWallIds.length, equals(originalCount));
        expect(updatedUser.visitedWallIds, equals(testUser.visitedWallIds));
      });
    });

    group('updateProfile', () {
      test('updates user profile information', () {
        // Act
        final updatedUser = testUser.updateProfile(
          name: 'Updated Name',
          email: 'updated@example.com',
          avatarPath: '/path/to/avatar.jpg',
        );

        // Assert
        expect(updatedUser.name, equals('Updated Name'));
        expect(updatedUser.email, equals('updated@example.com'));
        expect(updatedUser.avatarPath, equals('/path/to/avatar.jpg'));
        expect(updatedUser.id, equals(testUser.id)); // ID should not change
        expect(updatedUser.createdAt, equals(testUser.createdAt)); // CreatedAt should not change
      });

      test('maintains original values when null parameters provided', () {
        // Act
        final updatedUser = testUser.updateProfile(
          name: null,
          email: null,
          avatarPath: null,
        );

        // Assert
        expect(updatedUser.name, equals(testUser.name));
        expect(updatedUser.email, equals(testUser.email));
        expect(updatedUser.avatarPath, equals(testUser.avatarPath));
      });
    });

    group('equality and props', () {
      test('users with same properties are equal', () {
        // Arrange
        final user1 = User(
          id: 'user123',
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
          visitedWallIds: ['wall1', 'wall2'],
        );

        final user2 = User(
          id: 'user123',
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
          visitedWallIds: ['wall1', 'wall2'],
        );

        // Assert
        expect(user1, equals(user2));
        expect(user1.hashCode, equals(user2.hashCode));
      });

      test('users with different properties are not equal', () {
        // Arrange
        final differentUser = testUser.copyWith(id: 'different_id');

        // Assert
        expect(testUser, isNot(equals(differentUser)));
      });
    });
  });
}