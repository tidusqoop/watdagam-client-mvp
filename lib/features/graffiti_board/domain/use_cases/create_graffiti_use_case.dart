import 'package:flutter/material.dart';
import '../../../../shared/domain/either/either.dart';
import '../../../../shared/domain/failures/failure.dart';
import '../../../../shared/domain/services/image_service.dart';
import '../../domain/entities/graffiti_note.dart';
import '../../domain/repositories/graffiti_repository.dart';
import '../../domain/value_objects/graffiti_content.dart';
import '../../domain/value_objects/graffiti_metadata.dart';
import '../../domain/value_objects/graffiti_position.dart';
import '../../domain/value_objects/graffiti_properties.dart';
import '../../../user_management/domain/repositories/user_repository.dart';

/// Use case for creating graffiti notes with optional image support
/// Handles business logic for graffiti creation including validation,
/// image processing, and collision detection
class CreateGraffitiUseCase {
  final GraffitiRepository _graffitiRepository;
  final UserRepository _userRepository;
  final ImageService? _imageService;

  const CreateGraffitiUseCase({
    required GraffitiRepository graffitiRepository,
    required UserRepository userRepository,
    ImageService? imageService,
  })  : _graffitiRepository = graffitiRepository,
        _userRepository = userRepository,
        _imageService = imageService;

  /// Creates a new graffiti note with the provided parameters
  Future<Either<Failure, GraffitiNote>> execute({
    required String wallId,
    required String userId,
    required String text,
    required GraffitiSize size,
    required Offset position,
    String? imagePath,
    Color? backgroundColor,
    double opacity = 0.9,
  }) async {
    try {
      // Validate user exists
      final user = await _userRepository.getUserById(userId);
      if (user == null) {
        return const Left(NotFoundFailure('User not found'));
      }

      // Validate text content
      if (text.trim().isEmpty) {
        return const Left(ValidationFailure('Graffiti text cannot be empty'));
      }

      // Process image if provided
      String? processedImagePath;
      if (imagePath != null && _imageService != null) {
        try {
          processedImagePath = await _imageService!.processAndStore(
            imagePath: imagePath,
            targetSize: size.dimensions,
          );
        } catch (e) {
          return Left(ImageProcessingFailure('Failed to process image: $e'));
        }
      }

      // Check for collision with existing graffiti
      final wouldOverlap = await _graffitiRepository.wouldCauseOverlap(
        wallId: wallId,
        x: position.dx,
        y: position.dy,
        width: size.dimensions.width,
        height: size.dimensions.height,
      );

      if (wouldOverlap) {
        return const Left(ConflictFailure('Graffiti would overlap with existing content'));
      }

      // Generate unique ID
      final graffitiId = _generateId();

      // Create graffiti note
      final graffiti = GraffitiNote(
        id: graffitiId,
        wallId: wallId,
        userId: userId,
        content: GraffitiContent(
          text: text,
          imagePath: processedImagePath,
          size: size,
        ),
        properties: GraffitiProperties(
          position: GraffitiPosition(
            offset: position,
            size: size.dimensions,
            zIndex: DateTime.now().millisecondsSinceEpoch,
          ),
          backgroundColor: backgroundColor ?? _getRandomColor(),
          opacity: opacity.clamp(0.1, 1.0),
        ),
        metadata: GraffitiMetadata(
          createdAt: DateTime.now(),
          isVisible: true,
        ),
      );

      // Save to repository
      final result = await _graffitiRepository.create(graffiti);
      return Right(result);
    } catch (e) {
      return Left(CreationFailure('Failed to create graffiti: $e'));
    }
  }

  /// Generates a unique ID for the graffiti note
  String _generateId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = DateTime.now().microsecond;
    return 'graffiti_${timestamp}_$random';
  }

  /// Returns a random background color from predefined palette
  Color _getRandomColor() {
    final colors = [
      const Color(0xFFFFE5B4), // Peach
      const Color(0xFFB4E5FF), // Sky blue
      const Color(0xFFE5B4FF), // Lavender
      const Color(0xFFB4FFB4), // Light green
      const Color(0xFFFFB4B4), // Light coral
      const Color(0xFFFFFFB4), // Light yellow
      const Color(0xFFFFB4E5), // Pink
      const Color(0xFFE5FFB4), // Light lime
    ];

    final index = DateTime.now().millisecond % colors.length;
    return colors[index];
  }
}