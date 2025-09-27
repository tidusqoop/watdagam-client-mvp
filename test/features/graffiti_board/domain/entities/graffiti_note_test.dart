import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:watdagam/features/graffiti_board/domain/entities/graffiti_note.dart';
import 'package:watdagam/features/graffiti_board/domain/value_objects/graffiti_content.dart';
import 'package:watdagam/features/graffiti_board/domain/value_objects/graffiti_metadata.dart';
import 'package:watdagam/features/graffiti_board/domain/value_objects/graffiti_position.dart';
import 'package:watdagam/features/graffiti_board/domain/value_objects/graffiti_properties.dart';

void main() {
  group('GraffitiNote Entity', () {
    late GraffitiNote testGraffiti;
    late GraffitiNote otherGraffiti;

    setUp(() {
      testGraffiti = GraffitiNote(
        id: 'graffiti123',
        wallId: 'wall456',
        userId: 'user789',
        content: const GraffitiContent(
          text: 'Hello World!',
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

      otherGraffiti = GraffitiNote(
        id: 'graffiti456',
        wallId: 'wall456',
        userId: 'user999',
        content: const GraffitiContent(
          text: 'Another graffiti',
          imagePath: null,
          size: GraffitiSize.small,
        ),
        properties: GraffitiProperties(
          position: const GraffitiPosition(
            offset: Offset(150, 220),
            size: Size(100, 80),
            zIndex: 1001,
          ),
          backgroundColor: Colors.red,
          opacity: 0.8,
        ),
        metadata: GraffitiMetadata(
          createdAt: DateTime(2024, 1, 1, 13, 0),
          isVisible: true,
        ),
      );
    });

    group('isOwnedBy', () {
      test('returns true when userId matches', () {
        // Act
        final result = testGraffiti.isOwnedBy('user789');

        // Assert
        expect(result, isTrue);
      });

      test('returns false when userId does not match', () {
        // Act
        final result = testGraffiti.isOwnedBy('different_user');

        // Assert
        expect(result, isFalse);
      });

      test('returns false for empty userId', () {
        // Act
        final result = testGraffiti.isOwnedBy('');

        // Assert
        expect(result, isFalse);
      });
    });

    group('isOverlapping', () {
      test('returns true when graffiti positions overlap', () {
        // Arrange - Create overlapping graffiti
        final overlappingGraffiti = otherGraffiti.copyWith(
          properties: otherGraffiti.properties.copyWith(
            position: const GraffitiPosition(
              offset: Offset(110, 210), // Overlaps with testGraffiti at (100, 200)
              size: Size(100, 80),
              zIndex: 1001,
            ),
          ),
        );

        // Act
        final result = testGraffiti.isOverlapping(overlappingGraffiti);

        // Assert
        expect(result, isTrue);
      });

      test('returns false when graffiti positions do not overlap', () {
        // Arrange - otherGraffiti is positioned to not overlap
        final nonOverlappingGraffiti = otherGraffiti.copyWith(
          properties: otherGraffiti.properties.copyWith(
            position: const GraffitiPosition(
              offset: Offset(300, 400), // Far from testGraffiti at (100, 200)
              size: Size(100, 80),
              zIndex: 1001,
            ),
          ),
        );

        // Act
        final result = testGraffiti.isOverlapping(nonOverlappingGraffiti);

        // Assert
        expect(result, isFalse);
      });

      test('returns false when comparing with itself', () {
        // Act
        final result = testGraffiti.isOverlapping(testGraffiti);

        // Assert
        expect(result, isTrue); // Same position should overlap
      });

      test('handles edge case where graffiti are adjacent but not overlapping', () {
        // Arrange - Adjacent graffiti (touching edges)
        final adjacentGraffiti = otherGraffiti.copyWith(
          properties: otherGraffiti.properties.copyWith(
            position: const GraffitiPosition(
              offset: Offset(240, 200), // Right edge touches testGraffiti's right edge
              size: Size(100, 80),
              zIndex: 1001,
            ),
          ),
        );

        // Act
        final result = testGraffiti.isOverlapping(adjacentGraffiti);

        // Assert
        expect(result, isFalse); // Adjacent but not overlapping
      });
    });

    group('updateContent', () {
      test('updates graffiti content', () {
        // Arrange
        const newContent = GraffitiContent(
          text: 'Updated text',
          imagePath: '/path/to/image.jpg',
          size: GraffitiSize.large,
        );

        // Act
        final updatedGraffiti = testGraffiti.updateContent(newContent);

        // Assert
        expect(updatedGraffiti.content.text, equals('Updated text'));
        expect(updatedGraffiti.content.imagePath, equals('/path/to/image.jpg'));
        expect(updatedGraffiti.content.size, equals(GraffitiSize.large));
        expect(updatedGraffiti.id, equals(testGraffiti.id)); // ID should not change
      });

      test('maintains other properties when updating content', () {
        // Arrange
        const newContent = GraffitiContent(
          text: 'New text',
          imagePath: null,
          size: GraffitiSize.small,
        );

        // Act
        final updatedGraffiti = testGraffiti.updateContent(newContent);

        // Assert
        expect(updatedGraffiti.wallId, equals(testGraffiti.wallId));
        expect(updatedGraffiti.userId, equals(testGraffiti.userId));
        expect(updatedGraffiti.properties, equals(testGraffiti.properties));
        expect(updatedGraffiti.metadata, equals(testGraffiti.metadata));
      });
    });

    group('updatePosition', () {
      test('updates graffiti position', () {
        // Arrange
        const newPosition = GraffitiPosition(
          offset: Offset(300, 400),
          size: Size(200, 150),
          zIndex: 2000,
        );

        // Act
        final updatedGraffiti = testGraffiti.updatePosition(newPosition);

        // Assert
        expect(updatedGraffiti.properties.position.offset, equals(const Offset(300, 400)));
        expect(updatedGraffiti.properties.position.size, equals(const Size(200, 150)));
        expect(updatedGraffiti.properties.position.zIndex, equals(2000));
      });

      test('maintains other properties when updating position', () {
        // Arrange
        const newPosition = GraffitiPosition(
          offset: Offset(300, 400),
          size: Size(200, 150),
          zIndex: 2000,
        );

        // Act
        final updatedGraffiti = testGraffiti.updatePosition(newPosition);

        // Assert
        expect(updatedGraffiti.content, equals(testGraffiti.content));
        expect(updatedGraffiti.properties.backgroundColor, equals(testGraffiti.properties.backgroundColor));
        expect(updatedGraffiti.properties.opacity, equals(testGraffiti.properties.opacity));
        expect(updatedGraffiti.metadata, equals(testGraffiti.metadata));
      });
    });

    group('updateVisibility', () {
      test('updates graffiti visibility', () {
        // Arrange
        expect(testGraffiti.metadata.isVisible, isTrue);

        // Act
        final hiddenGraffiti = testGraffiti.updateVisibility(false);

        // Assert
        expect(hiddenGraffiti.metadata.isVisible, isFalse);
      });

      test('maintains other properties when updating visibility', () {
        // Act
        final hiddenGraffiti = testGraffiti.updateVisibility(false);

        // Assert
        expect(hiddenGraffiti.content, equals(testGraffiti.content));
        expect(hiddenGraffiti.properties, equals(testGraffiti.properties));
        expect(hiddenGraffiti.metadata.createdAt, equals(testGraffiti.metadata.createdAt));
      });
    });

    group('bringToFront', () {
      test('updates z-index to bring graffiti to front', () {
        // Arrange
        final originalZIndex = testGraffiti.properties.position.zIndex;

        // Act
        final frontGraffiti = testGraffiti.bringToFront();

        // Assert
        expect(frontGraffiti.properties.position.zIndex, greaterThan(originalZIndex));
      });

      test('maintains other properties when bringing to front', () {
        // Act
        final frontGraffiti = testGraffiti.bringToFront();

        // Assert
        expect(frontGraffiti.content, equals(testGraffiti.content));
        expect(frontGraffiti.properties.position.offset, equals(testGraffiti.properties.position.offset));
        expect(frontGraffiti.properties.position.size, equals(testGraffiti.properties.position.size));
        expect(frontGraffiti.properties.backgroundColor, equals(testGraffiti.properties.backgroundColor));
        expect(frontGraffiti.metadata, equals(testGraffiti.metadata));
      });
    });

    group('isVisible', () {
      test('returns true when graffiti is visible', () {
        // Act
        final result = testGraffiti.isVisible;

        // Assert
        expect(result, isTrue);
      });

      test('returns false when graffiti is hidden', () {
        // Arrange
        final hiddenGraffiti = testGraffiti.updateVisibility(false);

        // Act
        final result = hiddenGraffiti.isVisible;

        // Assert
        expect(result, isFalse);
      });
    });

    group('equality and props', () {
      test('graffiti with same properties are equal', () {
        // Arrange
        final graffiti1 = GraffitiNote(
          id: 'graffiti123',
          wallId: 'wall456',
          userId: 'user789',
          content: const GraffitiContent(
            text: 'Hello World!',
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

        final graffiti2 = GraffitiNote(
          id: 'graffiti123',
          wallId: 'wall456',
          userId: 'user789',
          content: const GraffitiContent(
            text: 'Hello World!',
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

        // Assert
        expect(graffiti1, equals(graffiti2));
        expect(graffiti1.hashCode, equals(graffiti2.hashCode));
      });

      test('graffiti with different properties are not equal', () {
        // Arrange
        final differentGraffiti = testGraffiti.copyWith(id: 'different_id');

        // Assert
        expect(testGraffiti, isNot(equals(differentGraffiti)));
      });
    });
  });
}