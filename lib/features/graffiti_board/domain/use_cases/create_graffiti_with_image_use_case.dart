import 'package:flutter/material.dart';
import '../../../../shared/domain/either/either.dart';
import '../../../../shared/domain/failures/failure.dart';
import '../../../../shared/domain/services/image_service.dart';
import '../entities/graffiti_note.dart';
import '../repositories/graffiti_repository.dart';
import '../value_objects/graffiti_content.dart';
import '../value_objects/graffiti_properties.dart';
import '../value_objects/graffiti_metadata.dart';
import '../value_objects/graffiti_position.dart';
import '../../data/models/graffiti_note.dart';

/// Use case for creating graffiti notes with image support
class CreateGraffitiWithImageUseCase {
  final GraffitiRepository _graffitiRepository;
  final ImageService _imageService;

  const CreateGraffitiWithImageUseCase({
    required GraffitiRepository graffitiRepository,
    required ImageService imageService,
  }) : _graffitiRepository = graffitiRepository,
       _imageService = imageService;

  /// Creates a new graffiti note with optional image processing
  Future<Either<Failure, GraffitiNote>> execute({
    required String wallId,
    required String userId,
    required String text,
    required GraffitiSize size,
    required Offset position,
    String? imagePath,
    Color? backgroundColor,
    AuthorAlignment authorAlignment = AuthorAlignment.center,
    String? author,
  }) async {
    try {
      // Validate input parameters
      final validationResult = _validateInput(
        text: text,
        size: size,
        position: position,
        imagePath: imagePath,
      );
      
      if (validationResult != null) {
        return Left(validationResult);
      }

      // Process image if provided
      String? processedImagePath;
      if (imagePath != null && imagePath.isNotEmpty) {
        final imageProcessingResult = await _processImage(
          imagePath: imagePath,
          targetSize: size.dimensions,
        );
        
        if (imageProcessingResult.isLeft()) {
          return Left(imageProcessingResult.left);
        }
        
        processedImagePath = imageProcessingResult.right;
      }

      // Generate unique ID
      final String id = _generateGraffitiId();

      // Create graffiti content
      final content = GraffitiContent(
        text: text.trim(),
        imagePath: processedImagePath,
        size: size,
      );

      // Validate content
      if (!content.isValid()) {
        return Left(ValidationFailure('Invalid graffiti content'));
      }

      // Create graffiti properties with collision detection
      final properties = await _createGraffitiProperties(
        wallId: wallId,
        offset: position,
        size: size.dimensions,
        backgroundColor: backgroundColor,
      );

      // Create graffiti metadata
      final metadata = GraffitiMetadata.createDefault();

      // Create graffiti note entity
      final graffitiNote = GraffitiNote(
        id: id,
        wallId: wallId,
        userId: userId,
        content: content,
        properties: properties,
        metadata: metadata,
      );

      // Save to repository
      final saveResult = await _graffitiRepository.create(graffitiNote);
      
      return Right(saveResult);
    } catch (e) {
      return Left(UnknownFailure('Failed to create graffiti: ${e.toString()}'));
    }
  }

  /// Validates input parameters for graffiti creation
  Failure? _validateInput({
    required String text,
    required GraffitiSize size,
    required Offset position,
    String? imagePath,
  }) {
    // Validate text
    if (text.trim().isEmpty) {
      return ValidationFailure('Text content cannot be empty');
    }

    if (text.length > size.maxCharacters) {
      return ValidationFailure(
        'Text length (${text.length}) exceeds size limit (${size.maxCharacters})',
      );
    }

    // Validate position
    if (position.dx < 0 || position.dy < 0) {
      return ValidationFailure('Position coordinates must be non-negative');
    }

    // Validate image if provided
    if (imagePath != null && imagePath.isNotEmpty) {
      if (!_imageService.isValidImageExtension(imagePath)) {
        return ValidationFailure('Invalid image file extension');
      }
    }

    return null;
  }

  /// Processes the provided image for graffiti use
  Future<Either<Failure, String>> _processImage({
    required String imagePath,
    required Size targetSize,
  }) async {
    try {
      // Validate image file
      final bool isValid = await _imageService.isValidImage(imagePath);
      if (!isValid) {
        return Left(ValidationFailure('Invalid or corrupted image file'));
      }

      // Check image file size
      final int fileSize = await _imageService.getImageFileSize(imagePath);
      if (!_imageService.isValidImageSize(fileSize)) {
        return Left(ValidationFailure('Image file size exceeds maximum limit'));
      }

      // Process and optimize image
      final String processedImagePath = await _imageService.processAndStore(
        imagePath: imagePath,
        targetSize: targetSize,
      );

      return Right(processedImagePath);
    } catch (e) {
      return Left(ImageProcessingFailure('Failed to process image: ${e.toString()}'));
    }
  }

  /// Creates graffiti properties with collision detection
  Future<GraffitiProperties> _createGraffitiProperties({
    required String wallId,
    required Offset offset,
    required Size size,
    Color? backgroundColor,
  }) async {
    // Get existing graffiti for collision detection
    final existingGraffiti = await _graffitiRepository.getGraffitiByWall(wallId);
    
    // Calculate z-index to place new graffiti on top
    int maxZIndex = 0;
    for (final graffiti in existingGraffiti) {
      if (graffiti.zIndex > maxZIndex) {
        maxZIndex = graffiti.zIndex;
      }
    }

    // Create position with collision-aware z-index
    final position = GraffitiPosition(
      offset: offset,
      size: size,
      zIndex: maxZIndex + 1,
    );

    // Check for overlaps and adjust if necessary
    final adjustedPosition = _adjustPositionForCollisions(
      position: position,
      existingGraffiti: existingGraffiti,
    );

    // Create properties with default or specified background color
    return GraffitiProperties.createDefault(
      offset: adjustedPosition.offset,
      size: adjustedPosition.size,
      backgroundColor: backgroundColor,
    ).copyWith(
      position: adjustedPosition,
    );
  }

  /// Adjusts position to minimize overlaps with existing graffiti
  GraffitiPosition _adjustPositionForCollisions({
    required GraffitiPosition position,
    required List<GraffitiNote> existingGraffiti,
  }) {
    // Simple collision detection - check for overlaps
    final Rect newBounds = Rect.fromLTWH(
      position.offset.dx,
      position.offset.dy,
      position.size.width,
      position.size.height,
    );

    bool hasCollision = false;
    for (final graffiti in existingGraffiti) {
      final Rect existingBounds = graffiti.bounds;
      if (newBounds.overlaps(existingBounds)) {
        hasCollision = true;
        break;
      }
    }

    // If no collision, return original position
    if (!hasCollision) {
      return position;
    }

    // Try to find a nearby position with minimal overlap
    // This is a simplified collision resolution strategy
    const int maxAttempts = 10;
    const double offsetIncrement = 20.0;

    for (int attempt = 1; attempt <= maxAttempts; attempt++) {
      final List<Offset> candidateOffsets = [
        Offset(position.offset.dx + (offsetIncrement * attempt), position.offset.dy),
        Offset(position.offset.dx, position.offset.dy + (offsetIncrement * attempt)),
        Offset(position.offset.dx - (offsetIncrement * attempt), position.offset.dy),
        Offset(position.offset.dx, position.offset.dy - (offsetIncrement * attempt)),
        Offset(
          position.offset.dx + (offsetIncrement * attempt * 0.7),
          position.offset.dy + (offsetIncrement * attempt * 0.7),
        ),
      ];

      for (final candidateOffset in candidateOffsets) {
        // Ensure position stays within reasonable bounds
        if (candidateOffset.dx < 0 || candidateOffset.dy < 0) continue;

        final Rect candidateBounds = Rect.fromLTWH(
          candidateOffset.dx,
          candidateOffset.dy,
          position.size.width,
          position.size.height,
        );

        bool hasCollisionAtCandidate = false;
        for (final graffiti in existingGraffiti) {
          if (candidateBounds.overlaps(graffiti.bounds)) {
            hasCollisionAtCandidate = true;
            break;
          }
        }

        if (!hasCollisionAtCandidate) {
          return position.copyWith(offset: candidateOffset);
        }
      }
    }

    // If we couldn't find a collision-free position, return original with higher z-index
    return position.copyWith(zIndex: position.zIndex + 100);
  }

  /// Generates a unique identifier for graffiti notes
  String _generateGraffitiId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = (timestamp % 10000).toString().padLeft(4, '0');
    return 'graffiti_${timestamp}_$random';
  }
}

/// Batch creation use case for multiple graffiti notes
class CreateMultipleGraffitiUseCase {
  final CreateGraffitiWithImageUseCase _createGraffitiUseCase;

  const CreateMultipleGraffitiUseCase({
    required CreateGraffitiWithImageUseCase createGraffitiUseCase,
  }) : _createGraffitiUseCase = createGraffitiUseCase;

  /// Creates multiple graffiti notes in batch
  Future<Either<Failure, List<GraffitiNote>>> execute({
    required List<GraffitiCreationRequest> requests,
  }) async {
    final List<GraffitiNote> createdGraffiti = [];
    final List<String> failures = [];

    for (int i = 0; i < requests.length; i++) {
      final request = requests[i];
      
      final result = await _createGraffitiUseCase.execute(
        wallId: request.wallId,
        userId: request.userId,
        text: request.text,
        size: request.size,
        position: request.position,
        imagePath: request.imagePath,
        backgroundColor: request.backgroundColor,
        authorAlignment: request.authorAlignment,
        author: request.author,
      );

      if (result.isRight()) {
        createdGraffiti.add(result.right);
      } else {
        failures.add('Request ${i + 1}: ${result.left.message}');
      }
    }

    if (failures.isNotEmpty && createdGraffiti.isEmpty) {
      return Left(BatchOperationFailure('All graffiti creation failed: ${failures.join(', ')}'));
    }

    if (failures.isNotEmpty) {
      // Partial success - log failures but return successful creations
      print('Some graffiti creation failed: ${failures.join(', ')}');
    }

    return Right(createdGraffiti);
  }
}

/// Request model for graffiti creation
class GraffitiCreationRequest {
  final String wallId;
  final String userId;
  final String text;
  final GraffitiSize size;
  final Offset position;
  final String? imagePath;
  final Color? backgroundColor;
  final AuthorAlignment authorAlignment;
  final String? author;

  const GraffitiCreationRequest({
    required this.wallId,
    required this.userId,
    required this.text,
    required this.size,
    required this.position,
    this.imagePath,
    this.backgroundColor,
    this.authorAlignment = AuthorAlignment.center,
    this.author,
  });
}

/// Custom failures for graffiti creation
class ValidationFailure extends Failure {
  const ValidationFailure(String message) : super(message);
}

class ImageProcessingFailure extends Failure {
  const ImageProcessingFailure(String message) : super(message);
}

class BatchOperationFailure extends Failure {
  const BatchOperationFailure(String message) : super(message);
}

class UnknownFailure extends Failure {
  const UnknownFailure(String message) : super(message);
}