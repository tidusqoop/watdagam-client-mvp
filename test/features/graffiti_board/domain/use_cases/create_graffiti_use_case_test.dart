import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:watdagam/features/graffiti_board/domain/entities/graffiti_note.dart';
import 'package:watdagam/features/graffiti_board/domain/repositories/graffiti_repository.dart';
import 'package:watdagam/features/graffiti_board/domain/use_cases/create_graffiti_use_case.dart';
import 'package:watdagam/features/graffiti_board/domain/value_objects/graffiti_content.dart';
import 'package:watdagam/features/user_management/domain/entities/user.dart';
import 'package:watdagam/features/user_management/domain/repositories/user_repository.dart';
import 'package:watdagam/features/user_management/domain/value_objects/user_preferences.dart';
import 'package:watdagam/shared/domain/failures/failure.dart';
import 'package:watdagam/shared/domain/services/image_service.dart';

// Mock classes for testing
class MockGraffitiRepository implements GraffitiRepository {
  final List<GraffitiNote> _graffitis = [];
  bool shouldThrowError = false;
  bool shouldCauseOverlap = false;

  @override
  Future<GraffitiNote> create(GraffitiNote graffiti) async {
    if (shouldThrowError) {
      throw Exception('Database error');
    }
    _graffitis.add(graffiti);
    return graffiti;
  }

  @override
  Future<bool> wouldCauseOverlap({
    required String wallId,
    required double x,
    required double y,
    required double width,
    required double height,
    String? excludeGraffitiId,
  }) async {
    return shouldCauseOverlap;
  }

  // Implement other required methods with minimal functionality
  @override
  Future<List<GraffitiNote>> getGraffitiByWall(String wallId) async => [];

  @override
  Future<List<GraffitiNote>> getGraffitiByUser(String userId) async => [];

  @override
  Future<GraffitiNote?> getGraffitiById(String id) async => null;

  @override
  Future<List<GraffitiNote>> getGraffitiByIds(List<String> graffitiIds) async => [];

  @override
  Future<List<GraffitiNote>> getGraffitiBySize({
    required String wallId,
    required GraffitiSize size,
  }) async => [];

  @override
  Future<List<GraffitiNote>> getGraffitiByTimeRange({
    required String wallId,
    required DateTime startDate,
    required DateTime endDate,
  }) async => [];

  @override
  Future<List<GraffitiNote>> getRecentGraffiti({
    required String wallId,
    int limit = 20,
  }) async => [];

  @override
  Future<List<GraffitiNote>> getPopularGraffiti({
    required String wallId,
    int limit = 10,
  }) async => [];

  @override
  Future<List<GraffitiNote>> searchGraffitiByText({
    required String query,
    String? wallId,
    String? userId,
    int limit = 50,
  }) async => [];

  @override
  Future<List<GraffitiNote>> getGraffitiWithImages({
    required String wallId,
    int limit = 20,
  }) async => [];

  @override
  Future<List<GraffitiNote>> getTextOnlyGraffiti({
    required String wallId,
    int limit = 20,
  }) async => [];

  @override
  Future<List<GraffitiNote>> getVisibleGraffiti(String wallId) async => [];

  @override
  Future<List<GraffitiNote>> getHiddenGraffiti(String wallId) async => [];

  @override
  Future<GraffitiNote> update(GraffitiNote graffiti) async => graffiti;

  @override
  Future<void> delete(String id) async {}

  @override
  Future<GraffitiNote> hideGraffiti(String id) async => _graffitis.first;

  @override
  Future<GraffitiNote> showGraffiti(String id) async => _graffitis.first;

  @override
  Future<GraffitiNote> updatePosition({
    required String id,
    required double x,
    required double y,
  }) async => _graffitis.first;

  @override
  Future<GraffitiNote> updateContent({
    required String id,
    required GraffitiContent content,
  }) async => _graffitis.first;

  @override
  Future<GraffitiNote> updateVisibility({
    required String id,
    required bool isVisible,
  }) async => _graffitis.first;

  @override
  Future<GraffitiNote> bringToFront(String id) async => _graffitis.first;

  @override
  Future<List<GraffitiNote>> createBatch(List<GraffitiNote> graffitis) async => graffitis;

  @override
  Future<List<GraffitiNote>> updateBatch(List<GraffitiNote> graffitis) async => graffitis;

  @override
  Future<void> deleteBatch(List<String> graffitiIds) async {}

  @override
  Future<List<GraffitiNote>> hideBatch(List<String> graffitiIds) async => [];

  @override
  Future<List<GraffitiNote>> showBatch(List<String> graffitiIds) async => [];

  @override
  Future<List<GraffitiNote>> updatePositionsBatch(
    Map<String, Map<String, double>> positions,
  ) async => [];

  @override
  Future<List<GraffitiNote>> findOverlappingGraffiti({
    required String wallId,
    required double x,
    required double y,
    required double width,
    required double height,
  }) async => [];

  @override
  Future<Map<String, double>?> findAvailablePosition({
    required String wallId,
    required double width,
    required double height,
    double? preferredX,
    double? preferredY,
  }) async => null;

  @override
  Future<List<GraffitiNote>> getGraffitiInArea({
    required String wallId,
    required double x,
    required double y,
    required double width,
    required double height,
  }) async => [];

  @override
  Future<void> syncWithServer() async {}

  @override
  Future<List<GraffitiNote>> getUnsyncedGraffiti() async => [];

  @override
  Future<void> markGraffitiSynced(String graffitiId) async {}

  @override
  Future<GraffitiNote> resolveConflict({
    required GraffitiNote localGraffiti,
    required GraffitiNote serverGraffiti,
  }) async => localGraffiti;

  @override
  Future<Map<String, dynamic>> getWallGraffitiStats(String wallId) async => {};

  @override
  Future<Map<String, dynamic>> getUserGraffitiStats(String userId) async => {};

  @override
  Future<Map<String, dynamic>> getOverallGraffitiStats() async => {};

  @override
  Future<Map<String, dynamic>> getGraffitiDensity(String wallId) async => {};

  @override
  Future<List<Map<String, dynamic>>> getGraffitiActivity({
    required String wallId,
    required DateTime startDate,
    required DateTime endDate,
    String? groupBy,
  }) async => [];

  @override
  Future<void> cleanupOldHiddenGraffiti({int olderThanDays = 30}) async {}

  @override
  Future<void> optimizeStorage() async {}

  @override
  Future<List<String>> validateDataIntegrity() async => [];

  @override
  Future<void> repairCorruptedData(List<String> corruptedGraffitiIds) async {}
}

class MockUserRepository implements UserRepository {
  final Map<String, User> _users = {};
  bool shouldThrowError = false;

  void addUser(User user) {
    _users[user.id] = user;
  }

  @override
  Future<User?> getUserById(String id) async {
    if (shouldThrowError) {
      throw Exception('Database error');
    }
    return _users[id];
  }

  // Implement other required methods with minimal functionality
  @override
  Future<User?> getCurrentUser() async => null;

  @override
  Future<User?> getUserByEmail(String email) async => null;

  @override
  Future<List<User>> getUsersByIds(List<String> userIds) async => [];

  @override
  Future<List<User>> searchUsers({
    required String query,
    int limit = 10,
  }) async => [];

  @override
  Future<List<User>> getUsersWhoVisitedWall(String wallId) async => [];

  @override
  Future<User> createUser(User user) async => user;

  @override
  Future<User> updateUser(User user) async => user;

  @override
  Future<void> deleteUser(String id) async {}

  @override
  Future<User> updateUserProfile({
    required String userId,
    String? name,
    String? email,
    String? avatarPath,
  }) async => _users[userId]!;

  @override
  Future<User> updateUserPreferences({
    required String userId,
    required UserPreferences preferences,
  }) async => _users[userId]!;

  @override
  Future<void> markWallVisited(String userId, String wallId) async {}

  @override
  Future<void> unmarkWallVisited(String userId, String wallId) async {}

  @override
  Future<User> setUserAvatar(String userId, String avatarPath) async => _users[userId]!;

  @override
  Future<User> removeUserAvatar(String userId) async => _users[userId]!;

  @override
  Future<User?> signIn(String email, String password) async => null;

  @override
  Future<User> signUp(String email, String password, String name) async => _users.values.first;

  @override
  Future<void> signOut() async {}

  @override
  Future<bool> refreshToken() async => true;

  @override
  Future<bool> isAuthenticated() async => true;

  @override
  Future<void> resetPassword(String email) async {}

  @override
  Future<void> changePassword(String userId, String oldPassword, String newPassword) async {}

  @override
  Future<void> verifyEmail(String userId, String verificationCode) async {}

  @override
  Future<void> resendEmailVerification(String email) async {}

  @override
  Future<User> createGuestUser() async => _users.values.first;

  @override
  Future<User> convertGuestToRegistered({
    required String guestUserId,
    required String email,
    required String password,
    String? name,
  }) async => _users[guestUserId]!;

  @override
  Future<void> cleanupOldGuestUsers({int olderThanDays = 30}) async {}

  @override
  Future<User> updatePrivacySettings({
    required String userId,
    required Map<String, bool> privacySettings,
  }) async => _users[userId]!;

  @override
  Future<Map<String, dynamic>> exportUserData(String userId) async => {};

  @override
  Future<void> deleteAllUserData(String userId) async {}

  @override
  Future<void> logUserActivity({
    required String userId,
    required String activity,
    Map<String, dynamic>? metadata,
  }) async {}

  @override
  Future<List<User>> createUsers(List<User> users) async => users;

  @override
  Future<List<User>> updateUsers(List<User> users) async => users;

  @override
  Future<void> deleteUsers(List<String> userIds) async {}

  @override
  Future<void> syncWithServer() async {}

  @override
  Future<List<User>> getUnsyncedUsers() async => [];

  @override
  Future<void> markUserSynced(String userId) async {}

  @override
  Future<Map<String, dynamic>> getUserStatistics() async => {};

  @override
  Future<Map<String, dynamic>> getUserActivityStats(String userId) async => {};

  @override
  Future<Map<String, dynamic>> getUserEngagementMetrics(String userId) async => {};
}

class MockImageService implements ImageService {
  bool shouldThrowError = false;
  String? processedImagePath;

  @override
  Future<String> processAndStore({
    required String imagePath,
    required Size targetSize,
  }) async {
    if (shouldThrowError) {
      throw Exception('Image processing error');
    }
    return processedImagePath ?? '/processed/image.jpg';
  }

  // Implement other required methods
  @override
  Future<String> pickFromCamera() async => '/camera/image.jpg';

  @override
  Future<String> pickFromGallery() async => '/gallery/image.jpg';

  @override
  Future<void> deleteImage(String path) async {}

  @override
  Future<dynamic> resizeImage(dynamic image, Size targetSize) async => image;

  @override
  Future<dynamic> compressImage(dynamic image, int qualityPercent) async => image;
}

void main() {
  group('CreateGraffitiUseCase', () {
    late CreateGraffitiUseCase useCase;
    late MockGraffitiRepository mockGraffitiRepository;
    late MockUserRepository mockUserRepository;
    late MockImageService mockImageService;
    late User testUser;

    setUp(() {
      mockGraffitiRepository = MockGraffitiRepository();
      mockUserRepository = MockUserRepository();
      mockImageService = MockImageService();

      useCase = CreateGraffitiUseCase(
        graffitiRepository: mockGraffitiRepository,
        userRepository: mockUserRepository,
        imageService: mockImageService,
      );

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
        visitedWallIds: [],
      );

      mockUserRepository.addUser(testUser);
    });

    group('successful creation', () {
      test('creates graffiti successfully with valid parameters', () async {
        // Arrange
        const wallId = 'wall123';
        const userId = 'user123';
        const text = 'Hello World!';
        const size = GraffitiSize.medium;
        const position = Offset(100, 200);

        // Act
        final result = await useCase.execute(
          wallId: wallId,
          userId: userId,
          text: text,
          size: size,
          position: position,
        );

        // Assert
        expect(result.isRight, isTrue);
        final graffiti = result.getOrThrow();
        expect(graffiti.wallId, equals(wallId));
        expect(graffiti.userId, equals(userId));
        expect(graffiti.content.text, equals(text));
        expect(graffiti.content.size, equals(size));
        expect(graffiti.properties.position.offset, equals(position));
      });

      test('creates graffiti with image when image path provided', () async {
        // Arrange
        const wallId = 'wall123';
        const userId = 'user123';
        const text = 'Hello World!';
        const size = GraffitiSize.large;
        const position = Offset(100, 200);
        const imagePath = '/path/to/image.jpg';
        mockImageService.processedImagePath = '/processed/image.jpg';

        // Act
        final result = await useCase.execute(
          wallId: wallId,
          userId: userId,
          text: text,
          size: size,
          position: position,
          imagePath: imagePath,
        );

        // Assert
        expect(result.isRight, isTrue);
        final graffiti = result.getOrThrow();
        expect(graffiti.content.imagePath, equals('/processed/image.jpg'));
      });

      test('creates graffiti with custom background color and opacity', () async {
        // Arrange
        const wallId = 'wall123';
        const userId = 'user123';
        const text = 'Custom graffiti';
        const size = GraffitiSize.small;
        const position = Offset(50, 150);
        const backgroundColor = Colors.red;
        const opacity = 0.7;

        // Act
        final result = await useCase.execute(
          wallId: wallId,
          userId: userId,
          text: text,
          size: size,
          position: position,
          backgroundColor: backgroundColor,
          opacity: opacity,
        );

        // Assert
        expect(result.isRight, isTrue);
        final graffiti = result.getOrThrow();
        expect(graffiti.properties.backgroundColor, equals(backgroundColor));
        expect(graffiti.properties.opacity, equals(opacity));
      });

      test('clamps opacity to valid range', () async {
        // Arrange
        const wallId = 'wall123';
        const userId = 'user123';
        const text = 'Test';
        const size = GraffitiSize.medium;
        const position = Offset(100, 200);

        // Act - Test with opacity too high
        final result1 = await useCase.execute(
          wallId: wallId,
          userId: userId,
          text: text,
          size: size,
          position: position,
          opacity: 1.5,
        );

        // Act - Test with opacity too low
        final result2 = await useCase.execute(
          wallId: wallId,
          userId: userId,
          text: text,
          size: size,
          position: position,
          opacity: -0.5,
        );

        // Assert
        expect(result1.isRight, isTrue);
        expect(result1.getOrThrow().properties.opacity, equals(1.0));

        expect(result2.isRight, isTrue);
        expect(result2.getOrThrow().properties.opacity, equals(0.1));
      });
    });

    group('validation failures', () {
      test('fails when user does not exist', () async {
        // Arrange
        const wallId = 'wall123';
        const userId = 'nonexistent_user';
        const text = 'Hello World!';
        const size = GraffitiSize.medium;
        const position = Offset(100, 200);

        // Act
        final result = await useCase.execute(
          wallId: wallId,
          userId: userId,
          text: text,
          size: size,
          position: position,
        );

        // Assert
        expect(result.isLeft, isTrue);
        expect(result.getLeftOrNull(), isA<NotFoundFailure>());
      });

      test('fails when text is empty', () async {
        // Arrange
        const wallId = 'wall123';
        const userId = 'user123';
        const text = '   '; // Empty/whitespace text
        const size = GraffitiSize.medium;
        const position = Offset(100, 200);

        // Act
        final result = await useCase.execute(
          wallId: wallId,
          userId: userId,
          text: text,
          size: size,
          position: position,
        );

        // Assert
        expect(result.isLeft, isTrue);
        expect(result.getLeftOrNull(), isA<ValidationFailure>());
      });

      test('fails when position would cause overlap', () async {
        // Arrange
        mockGraffitiRepository.shouldCauseOverlap = true;
        const wallId = 'wall123';
        const userId = 'user123';
        const text = 'Hello World!';
        const size = GraffitiSize.medium;
        const position = Offset(100, 200);

        // Act
        final result = await useCase.execute(
          wallId: wallId,
          userId: userId,
          text: text,
          size: size,
          position: position,
        );

        // Assert
        expect(result.isLeft, isTrue);
        expect(result.getLeftOrNull(), isA<ConflictFailure>());
      });

      test('fails when image processing fails', () async {
        // Arrange
        mockImageService.shouldThrowError = true;
        const wallId = 'wall123';
        const userId = 'user123';
        const text = 'Hello World!';
        const size = GraffitiSize.medium;
        const position = Offset(100, 200);
        const imagePath = '/path/to/image.jpg';

        // Act
        final result = await useCase.execute(
          wallId: wallId,
          userId: userId,
          text: text,
          size: size,
          position: position,
          imagePath: imagePath,
        );

        // Assert
        expect(result.isLeft, isTrue);
        expect(result.getLeftOrNull(), isA<ImageProcessingFailure>());
      });
    });

    group('error handling', () {
      test('handles repository creation errors', () async {
        // Arrange
        mockGraffitiRepository.shouldThrowError = true;
        const wallId = 'wall123';
        const userId = 'user123';
        const text = 'Hello World!';
        const size = GraffitiSize.medium;
        const position = Offset(100, 200);

        // Act
        final result = await useCase.execute(
          wallId: wallId,
          userId: userId,
          text: text,
          size: size,
          position: position,
        );

        // Assert
        expect(result.isLeft, isTrue);
        expect(result.getLeftOrNull(), isA<CreationFailure>());
      });

      test('handles user repository errors', () async {
        // Arrange
        mockUserRepository.shouldThrowError = true;
        const wallId = 'wall123';
        const userId = 'user123';
        const text = 'Hello World!';
        const size = GraffitiSize.medium;
        const position = Offset(100, 200);

        // Act
        final result = await useCase.execute(
          wallId: wallId,
          userId: userId,
          text: text,
          size: size,
          position: position,
        );

        // Assert
        expect(result.isLeft, isTrue);
        expect(result.getLeftOrNull(), isA<CreationFailure>());
      });
    });

    group('edge cases', () {
      test('handles null image service gracefully', () async {
        // Arrange
        final useCaseWithoutImageService = CreateGraffitiUseCase(
          graffitiRepository: mockGraffitiRepository,
          userRepository: mockUserRepository,
          imageService: null,
        );

        // Act
        final result = await useCaseWithoutImageService.execute(
          wallId: 'wall123',
          userId: 'user123',
          text: 'Hello World!',
          size: GraffitiSize.medium,
          position: const Offset(100, 200),
          imagePath: '/path/to/image.jpg', // Image path provided but no service
        );

        // Assert
        expect(result.isRight, isTrue);
        final graffiti = result.getOrThrow();
        expect(graffiti.content.imagePath, isNull); // Image should not be processed
      });

      test('generates unique IDs for different graffiti', () async {
        // Arrange
        const wallId = 'wall123';
        const userId = 'user123';
        const text = 'Hello World!';
        const size = GraffitiSize.medium;
        const position1 = Offset(100, 200);
        const position2 = Offset(300, 400);

        // Act
        final result1 = await useCase.execute(
          wallId: wallId,
          userId: userId,
          text: text,
          size: size,
          position: position1,
        );

        final result2 = await useCase.execute(
          wallId: wallId,
          userId: userId,
          text: text,
          size: size,
          position: position2,
        );

        // Assert
        expect(result1.isRight, isTrue);
        expect(result2.isRight, isTrue);

        final graffiti1 = result1.getOrThrow();
        final graffiti2 = result2.getOrThrow();

        expect(graffiti1.id, isNot(equals(graffiti2.id)));
      });
    });
  });
}