import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:path/path.dart' as path;
import 'package:watdagam/features/graffiti_board/data/datasources/local_graffiti_data_source.dart';
import 'package:watdagam/features/graffiti_board/data/models/graffiti_note_model.dart';
import 'package:watdagam/features/graffiti_board/data/repositories/graffiti_repository_impl.dart';
import 'package:watdagam/features/graffiti_board/domain/entities/graffiti_note.dart';
import 'package:watdagam/features/graffiti_board/domain/value_objects/graffiti_content.dart';
import 'package:watdagam/features/graffiti_board/domain/value_objects/graffiti_metadata.dart';
import 'package:watdagam/features/graffiti_board/domain/value_objects/graffiti_position.dart';
import 'package:watdagam/features/graffiti_board/domain/value_objects/graffiti_properties.dart';
import 'package:watdagam/shared/data/cache/cache_manager.dart';
import 'package:flutter/material.dart';

void main() {
  group('GraffitiRepository Integration Tests', () {
    late Isar isar;
    late GraffitiRepositoryImpl repository;
    late LocalGraffitiDataSource dataSource;
    late CacheManager cacheManager;
    late Directory tempDir;

    setUpAll(() async {
      // Create temporary directory for test database
      tempDir = await Directory.systemTemp.createTemp('graffiti_test_');
    });

    setUp(() async {
      // Initialize Isar with test schemas
      isar = await Isar.open(
        [GraffitiNoteModelSchema],
        directory: tempDir.path,
        name: 'test_graffiti_${DateTime.now().millisecondsSinceEpoch}',
      );

      cacheManager = CacheManager();
      dataSource = LocalGraffitiDataSource(isar, cacheManager);
      repository = GraffitiRepositoryImpl(dataSource);
    });

    tearDown(() async {
      await isar.close(deleteFromDisk: true);
      cacheManager.clear();
    });

    tearDownAll(() async {
      // Clean up temporary directory
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    group('CRUD Operations', () {
      test('creates and retrieves graffiti note', () async {
        // Arrange
        final graffiti = GraffitiNote(
          id: 'graffiti123',
          wallId: 'wall456',
          userId: 'user789',
          content: const GraffitiContent(
            text: 'Hello Integration Test!',
            imagePath: null,
            size: GraffitiSize.medium,
          ),
          properties: GraffitiProperties(
            position: const GraffitiPosition(
              offset: Offset(100, 200),
              size: Size(140, 100),
              zIndex: 1000,
            ),
            backgroundColor: Colors.blue,
            opacity: 0.9,
          ),
          metadata: GraffitiMetadata(
            createdAt: DateTime(2024, 1, 1, 12, 0),
            isVisible: true,
          ),
        );

        // Act
        final createdGraffiti = await repository.create(graffiti);
        final retrievedGraffiti = await repository.getGraffitiById(graffiti.id);

        // Assert
        expect(createdGraffiti.id, equals(graffiti.id));
        expect(retrievedGraffiti, isNotNull);
        expect(retrievedGraffiti!.id, equals(graffiti.id));
        expect(retrievedGraffiti.content.text, equals('Hello Integration Test!'));
        expect(retrievedGraffiti.wallId, equals('wall456'));
        expect(retrievedGraffiti.userId, equals('user789'));
      });

      test('updates existing graffiti note', () async {
        // Arrange
        final originalGraffiti = GraffitiNote(
          id: 'graffiti123',
          wallId: 'wall456',
          userId: 'user789',
          content: const GraffitiContent(
            text: 'Original text',
            imagePath: null,
            size: GraffitiSize.medium,
          ),
          properties: GraffitiProperties(
            position: const GraffitiPosition(
              offset: Offset(100, 200),
              size: Size(140, 100),
              zIndex: 1000,
            ),
            backgroundColor: Colors.blue,
            opacity: 0.9,
          ),
          metadata: GraffitiMetadata(
            createdAt: DateTime(2024, 1, 1, 12, 0),
            isVisible: true,
          ),
        );

        await repository.create(originalGraffiti);

        final updatedGraffiti = originalGraffiti.copyWith(
          content: const GraffitiContent(
            text: 'Updated text',
            imagePath: '/path/to/image.jpg',
            size: GraffitiSize.large,
          ),
        );

        // Act
        final result = await repository.update(updatedGraffiti);
        final retrieved = await repository.getGraffitiById(originalGraffiti.id);

        // Assert
        expect(result.content.text, equals('Updated text'));
        expect(result.content.imagePath, equals('/path/to/image.jpg'));
        expect(retrieved!.content.text, equals('Updated text'));
      });

      test('deletes graffiti note', () async {
        // Arrange
        final graffiti = GraffitiNote(
          id: 'graffiti123',
          wallId: 'wall456',
          userId: 'user789',
          content: const GraffitiContent(
            text: 'To be deleted',
            imagePath: null,
            size: GraffitiSize.medium,
          ),
          properties: GraffitiProperties(
            position: const GraffitiPosition(
              offset: Offset(100, 200),
              size: Size(140, 100),
              zIndex: 1000,
            ),
            backgroundColor: Colors.blue,
            opacity: 0.9,
          ),
          metadata: GraffitiMetadata(
            createdAt: DateTime(2024, 1, 1, 12, 0),
            isVisible: true,
          ),
        );

        await repository.create(graffiti);
        expect(await repository.getGraffitiById(graffiti.id), isNotNull);

        // Act
        await repository.delete(graffiti.id);

        // Assert
        final deleted = await repository.getGraffitiById(graffiti.id);
        expect(deleted, isNull);
      });
    });

    group('Querying Operations', () {
      late List<GraffitiNote> testGraffitis;

      setUp(() async {
        // Create test data
        testGraffitis = [
          GraffitiNote(
            id: 'graffiti1',
            wallId: 'wall1',
            userId: 'user1',
            content: const GraffitiContent(
              text: 'First graffiti',
              imagePath: null,
              size: GraffitiSize.small,
            ),
            properties: GraffitiProperties(
              position: const GraffitiPosition(
                offset: Offset(100, 100),
                size: Size(100, 80),
                zIndex: 1000,
              ),
              backgroundColor: Colors.red,
              opacity: 0.9,
            ),
            metadata: GraffitiMetadata(
              createdAt: DateTime(2024, 1, 1, 10, 0),
              isVisible: true,
            ),
          ),
          GraffitiNote(
            id: 'graffiti2',
            wallId: 'wall1',
            userId: 'user2',
            content: const GraffitiContent(
              text: 'Second graffiti',
              imagePath: '/path/to/image.jpg',
              size: GraffitiSize.medium,
            ),
            properties: GraffitiProperties(
              position: const GraffitiPosition(
                offset: Offset(200, 200),
                size: Size(140, 100),
                zIndex: 1001,
              ),
              backgroundColor: Colors.green,
              opacity: 0.8,
            ),
            metadata: GraffitiMetadata(
              createdAt: DateTime(2024, 1, 1, 11, 0),
              isVisible: true,
            ),
          ),
          GraffitiNote(
            id: 'graffiti3',
            wallId: 'wall2',
            userId: 'user1',
            content: const GraffitiContent(
              text: 'Third graffiti',
              imagePath: null,
              size: GraffitiSize.large,
            ),
            properties: GraffitiProperties(
              position: const GraffitiPosition(
                offset: Offset(300, 300),
                size: Size(200, 140),
                zIndex: 1002,
              ),
              backgroundColor: Colors.blue,
              opacity: 0.7,
            ),
            metadata: GraffitiMetadata(
              createdAt: DateTime(2024, 1, 1, 12, 0),
              isVisible: false, // Hidden graffiti
            ),
          ),
        ];

        // Insert test data
        for (final graffiti in testGraffitis) {
          await repository.create(graffiti);
        }
      });

      test('retrieves graffiti by wall ID', () async {
        // Act
        final wallGraffitis = await repository.getGraffitiByWall('wall1');

        // Assert
        expect(wallGraffitis.length, equals(2));
        expect(wallGraffitis.map((g) => g.id), containsAll(['graffiti1', 'graffiti2']));
      });

      test('retrieves graffiti by user ID', () async {
        // Act
        final userGraffitis = await repository.getGraffitiByUser('user1');

        // Assert
        expect(userGraffitis.length, equals(2));
        expect(userGraffitis.map((g) => g.id), containsAll(['graffiti1', 'graffiti3']));
      });

      test('retrieves visible graffiti only', () async {
        // Act
        final visibleGraffitis = await repository.getVisibleGraffiti('wall1');

        // Assert
        expect(visibleGraffitis.length, equals(2));
        expect(visibleGraffitis.every((g) => g.metadata.isVisible), isTrue);
      });

      test('retrieves hidden graffiti only', () async {
        // Act
        final hiddenGraffitis = await repository.getHiddenGraffiti('wall2');

        // Assert
        expect(hiddenGraffitis.length, equals(1));
        expect(hiddenGraffitis.first.id, equals('graffiti3'));
        expect(hiddenGraffitis.first.metadata.isVisible, isFalse);
      });

      test('retrieves graffiti by size', () async {
        // Act
        final mediumGraffitis = await repository.getGraffitiBySize(
          wallId: 'wall1',
          size: GraffitiSize.medium,
        );

        // Assert
        expect(mediumGraffitis.length, equals(1));
        expect(mediumGraffitis.first.id, equals('graffiti2'));
        expect(mediumGraffitis.first.content.size, equals(GraffitiSize.medium));
      });

      test('retrieves graffiti with images', () async {
        // Act
        final graffitiWithImages = await repository.getGraffitiWithImages(
          wallId: 'wall1',
          limit: 10,
        );

        // Assert
        expect(graffitiWithImages.length, equals(1));
        expect(graffitiWithImages.first.id, equals('graffiti2'));
        expect(graffitiWithImages.first.content.imagePath, isNotNull);
      });

      test('retrieves text-only graffiti', () async {
        // Act
        final textOnlyGraffitis = await repository.getTextOnlyGraffiti(
          wallId: 'wall1',
          limit: 10,
        );

        // Assert
        expect(textOnlyGraffitis.length, equals(1));
        expect(textOnlyGraffitis.first.id, equals('graffiti1'));
        expect(textOnlyGraffitis.first.content.imagePath, isNull);
      });

      test('searches graffiti by text content', () async {
        // Act
        final searchResults = await repository.searchGraffitiByText(
          query: 'Second',
          wallId: 'wall1',
          limit: 10,
        );

        // Assert
        expect(searchResults.length, equals(1));
        expect(searchResults.first.id, equals('graffiti2'));
        expect(searchResults.first.content.text, contains('Second'));
      });

      test('retrieves recent graffiti', () async {
        // Act
        final recentGraffitis = await repository.getRecentGraffiti(
          wallId: 'wall1',
          limit: 10,
        );

        // Assert
        expect(recentGraffitis.length, equals(2));
        // Should be ordered by creation time (most recent first)
        expect(recentGraffitis.first.id, equals('graffiti2'));
        expect(recentGraffitis.last.id, equals('graffiti1'));
      });
    });

    group('Batch Operations', () {
      test('creates multiple graffiti in batch', () async {
        // Arrange
        final graffitis = [
          GraffitiNote(
            id: 'batch1',
            wallId: 'wall1',
            userId: 'user1',
            content: const GraffitiContent(
              text: 'Batch graffiti 1',
              imagePath: null,
              size: GraffitiSize.small,
            ),
            properties: GraffitiProperties(
              position: const GraffitiPosition(
                offset: Offset(100, 100),
                size: Size(100, 80),
                zIndex: 1000,
              ),
              backgroundColor: Colors.red,
              opacity: 0.9,
            ),
            metadata: GraffitiMetadata(
              createdAt: DateTime(2024, 1, 1, 10, 0),
              isVisible: true,
            ),
          ),
          GraffitiNote(
            id: 'batch2',
            wallId: 'wall1',
            userId: 'user1',
            content: const GraffitiContent(
              text: 'Batch graffiti 2',
              imagePath: null,
              size: GraffitiSize.medium,
            ),
            properties: GraffitiProperties(
              position: const GraffitiPosition(
                offset: Offset(200, 200),
                size: Size(140, 100),
                zIndex: 1001,
              ),
              backgroundColor: Colors.blue,
              opacity: 0.9,
            ),
            metadata: GraffitiMetadata(
              createdAt: DateTime(2024, 1, 1, 11, 0),
              isVisible: true,
            ),
          ),
        ];

        // Act
        final created = await repository.createBatch(graffitis);

        // Assert
        expect(created.length, equals(2));

        final retrieved = await repository.getGraffitiByWall('wall1');
        expect(retrieved.length, equals(2));
        expect(retrieved.map((g) => g.id), containsAll(['batch1', 'batch2']));
      });

      test('deletes multiple graffiti in batch', () async {
        // Arrange
        final graffitis = [
          GraffitiNote(
            id: 'delete1',
            wallId: 'wall1',
            userId: 'user1',
            content: const GraffitiContent(
              text: 'To delete 1',
              imagePath: null,
              size: GraffitiSize.small,
            ),
            properties: GraffitiProperties(
              position: const GraffitiPosition(
                offset: Offset(100, 100),
                size: Size(100, 80),
                zIndex: 1000,
              ),
              backgroundColor: Colors.red,
              opacity: 0.9,
            ),
            metadata: GraffitiMetadata(
              createdAt: DateTime(2024, 1, 1, 10, 0),
              isVisible: true,
            ),
          ),
          GraffitiNote(
            id: 'delete2',
            wallId: 'wall1',
            userId: 'user1',
            content: const GraffitiContent(
              text: 'To delete 2',
              imagePath: null,
              size: GraffitiSize.medium,
            ),
            properties: GraffitiProperties(
              position: const GraffitiPosition(
                offset: Offset(200, 200),
                size: Size(140, 100),
                zIndex: 1001,
              ),
              backgroundColor: Colors.blue,
              opacity: 0.9,
            ),
            metadata: GraffitiMetadata(
              createdAt: DateTime(2024, 1, 1, 11, 0),
              isVisible: true,
            ),
          ),
        ];

        await repository.createBatch(graffitis);
        expect((await repository.getGraffitiByWall('wall1')).length, equals(2));

        // Act
        await repository.deleteBatch(['delete1', 'delete2']);

        // Assert
        expect((await repository.getGraffitiByWall('wall1')).length, equals(0));
        expect(await repository.getGraffitiById('delete1'), isNull);
        expect(await repository.getGraffitiById('delete2'), isNull);
      });
    });

    group('Collision Detection', () {
      test('detects overlap between graffiti positions', () async {
        // Arrange - Create graffiti at position (100, 100) with size (140, 100)
        final existingGraffiti = GraffitiNote(
          id: 'existing',
          wallId: 'wall1',
          userId: 'user1',
          content: const GraffitiContent(
            text: 'Existing graffiti',
            imagePath: null,
            size: GraffitiSize.medium,
          ),
          properties: GraffitiProperties(
            position: const GraffitiPosition(
              offset: Offset(100, 100),
              size: Size(140, 100),
              zIndex: 1000,
            ),
            backgroundColor: Colors.red,
            opacity: 0.9,
          ),
          metadata: GraffitiMetadata(
            createdAt: DateTime(2024, 1, 1, 10, 0),
            isVisible: true,
          ),
        );

        await repository.create(existingGraffiti);

        // Act - Check for overlap with a position that overlaps
        final wouldOverlap = await repository.wouldCauseOverlap(
          wallId: 'wall1',
          x: 150, // Overlaps with existing graffiti
          y: 150,
          width: 100,
          height: 80,
        );

        // Act - Check for overlap with a position that doesn't overlap
        final wouldNotOverlap = await repository.wouldCauseOverlap(
          wallId: 'wall1',
          x: 300, // Far from existing graffiti
          y: 300,
          width: 100,
          height: 80,
        );

        // Assert
        expect(wouldOverlap, isTrue);
        expect(wouldNotOverlap, isFalse);
      });

      test('finds overlapping graffiti in area', () async {
        // Arrange
        final graffitis = [
          GraffitiNote(
            id: 'overlap1',
            wallId: 'wall1',
            userId: 'user1',
            content: const GraffitiContent(
              text: 'Overlapping 1',
              imagePath: null,
              size: GraffitiSize.medium,
            ),
            properties: GraffitiProperties(
              position: const GraffitiPosition(
                offset: Offset(100, 100),
                size: Size(140, 100),
                zIndex: 1000,
              ),
              backgroundColor: Colors.red,
              opacity: 0.9,
            ),
            metadata: GraffitiMetadata(
              createdAt: DateTime(2024, 1, 1, 10, 0),
              isVisible: true,
            ),
          ),
          GraffitiNote(
            id: 'overlap2',
            wallId: 'wall1',
            userId: 'user2',
            content: const GraffitiContent(
              text: 'Overlapping 2',
              imagePath: null,
              size: GraffitiSize.small,
            ),
            properties: GraffitiProperties(
              position: const GraffitiPosition(
                offset: Offset(150, 150),
                size: Size(100, 80),
                zIndex: 1001,
              ),
              backgroundColor: Colors.blue,
              opacity: 0.9,
            ),
            metadata: GraffitiMetadata(
              createdAt: DateTime(2024, 1, 1, 11, 0),
              isVisible: true,
            ),
          ),
          GraffitiNote(
            id: 'nooverlap',
            wallId: 'wall1',
            userId: 'user3',
            content: const GraffitiContent(
              text: 'No overlap',
              imagePath: null,
              size: GraffitiSize.small,
            ),
            properties: GraffitiProperties(
              position: const GraffitiPosition(
                offset: Offset(400, 400),
                size: Size(100, 80),
                zIndex: 1002,
              ),
              backgroundColor: Colors.green,
              opacity: 0.9,
            ),
            metadata: GraffitiMetadata(
              createdAt: DateTime(2024, 1, 1, 12, 0),
              isVisible: true,
            ),
          ),
        ];

        await repository.createBatch(graffitis);

        // Act - Find graffiti overlapping with area (50, 50, 200, 200)
        final overlapping = await repository.findOverlappingGraffiti(
          wallId: 'wall1',
          x: 50,
          y: 50,
          width: 200,
          height: 200,
        );

        // Assert
        expect(overlapping.length, equals(2));
        expect(overlapping.map((g) => g.id), containsAll(['overlap1', 'overlap2']));
      });
    });

    group('Performance and Edge Cases', () {
      test('handles large number of graffiti efficiently', () async {
        // Arrange - Create 100 graffiti notes
        final largeGraffitiList = List.generate(100, (index) {
          return GraffitiNote(
            id: 'graffiti_$index',
            wallId: 'wall_large',
            userId: 'user_${index % 10}', // 10 different users
            content: GraffitiContent(
              text: 'Graffiti number $index',
              imagePath: index % 3 == 0 ? '/image_$index.jpg' : null,
              size: GraffitiSize.values[index % 3],
            ),
            properties: GraffitiProperties(
              position: GraffitiPosition(
                offset: Offset((index % 10) * 50.0, (index ~/ 10) * 40.0),
                size: const Size(100, 80),
                zIndex: 1000 + index,
              ),
              backgroundColor: Colors.blue,
              opacity: 0.9,
            ),
            metadata: GraffitiMetadata(
              createdAt: DateTime(2024, 1, 1).add(Duration(minutes: index)),
              isVisible: index % 5 != 0, // Every 5th graffiti is hidden
            ),
          );
        });

        final stopwatch = Stopwatch()..start();

        // Act
        await repository.createBatch(largeGraffitiList);
        final allGraffitis = await repository.getGraffitiByWall('wall_large');
        final visibleGraffitis = await repository.getVisibleGraffiti('wall_large');
        final user0Graffitis = await repository.getGraffitiByUser('user_0');

        stopwatch.stop();

        // Assert
        expect(allGraffitis.length, equals(100));
        expect(visibleGraffitis.length, equals(80)); // 20% are hidden
        expect(user0Graffitis.length, equals(10)); // User 0 has 10 graffiti
        expect(stopwatch.elapsedMilliseconds, lessThan(1000)); // Should complete within 1 second
      });

      test('handles concurrent operations correctly', () async {
        // Arrange
        final futures = <Future>[];

        // Act - Perform multiple concurrent operations
        for (int i = 0; i < 10; i++) {
          futures.add(repository.create(GraffitiNote(
            id: 'concurrent_$i',
            wallId: 'wall_concurrent',
            userId: 'user_concurrent',
            content: GraffitiContent(
              text: 'Concurrent graffiti $i',
              imagePath: null,
              size: GraffitiSize.medium,
            ),
            properties: GraffitiProperties(
              position: GraffitiPosition(
                offset: Offset(i * 50.0, i * 40.0),
                size: const Size(140, 100),
                zIndex: 1000 + i,
              ),
              backgroundColor: Colors.blue,
              opacity: 0.9,
            ),
            metadata: GraffitiMetadata(
              createdAt: DateTime.now(),
              isVisible: true,
            ),
          )));
        }

        await Future.wait(futures);

        // Assert
        final allGraffitis = await repository.getGraffitiByWall('wall_concurrent');
        expect(allGraffitis.length, equals(10));

        // Verify all graffiti were created correctly
        for (int i = 0; i < 10; i++) {
          final graffiti = await repository.getGraffitiById('concurrent_$i');
          expect(graffiti, isNotNull);
          expect(graffiti!.content.text, equals('Concurrent graffiti $i'));
        }
      });
    });
  });
}