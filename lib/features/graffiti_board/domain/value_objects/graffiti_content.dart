import 'package:flutter/material.dart';
import '../../../../shared/domain/value_objects/value_object.dart';

/// Enum representing the available sizes for graffiti notes
/// Each size has specific dimensions and character limits
enum GraffitiSize {
  small(Size(100, 80), 50),
  medium(Size(140, 100), 100),
  large(Size(200, 140), 200);

  const GraffitiSize(this.dimensions, this.maxCharacters);

  final Size dimensions;
  final int maxCharacters;

  /// Returns the display name for the size
  String get displayName {
    switch (this) {
      case GraffitiSize.small:
        return '소';
      case GraffitiSize.medium:
        return '중';
      case GraffitiSize.large:
        return '대';
    }
  }

  /// Returns the description for the size
  String get description {
    return '최대 $maxCharacters자';
  }

  /// Returns the size from a string value
  static GraffitiSize fromString(String value) {
    switch (value.toLowerCase()) {
      case 'small':
      case '소':
        return GraffitiSize.small;
      case 'medium':
      case '중':
        return GraffitiSize.medium;
      case 'large':
      case '대':
        return GraffitiSize.large;
      default:
        return GraffitiSize.medium;
    }
  }
}

/// Represents the content of a graffiti note including text, optional image, and size
class GraffitiContent extends ValueObject {
  final String text;
  final String? imagePath;
  final GraffitiSize size;

  const GraffitiContent({
    required this.text,
    this.imagePath,
    required this.size,
  });

  /// Creates a text-only graffiti content
  factory GraffitiContent.textOnly({
    required String text,
    required GraffitiSize size,
  }) {
    return GraffitiContent(
      text: text,
      imagePath: null,
      size: size,
    );
  }

  /// Creates graffiti content with both text and image
  factory GraffitiContent.withImage({
    required String text,
    required String imagePath,
    required GraffitiSize size,
  }) {
    return GraffitiContent(
      text: text,
      imagePath: imagePath,
      size: size,
    );
  }

  /// Validates if the content is valid
  bool isValid() {
    return text.trim().isNotEmpty &&
           text.length <= size.maxCharacters &&
           _isValidImagePath();
  }

  /// Checks if the text length is within the size limit
  bool isTextLengthValid() {
    return text.length <= size.maxCharacters;
  }

  /// Returns the remaining characters allowed for this size
  int get remainingCharacters {
    return size.maxCharacters - text.length;
  }

  /// Checks if this content has an image
  bool get hasImage => imagePath != null && imagePath!.isNotEmpty;

  /// Checks if this content is text-only
  bool get isTextOnly => !hasImage;

  /// Returns the trimmed text
  String get trimmedText => text.trim();

  /// Validates if the image path is valid (basic validation)
  bool _isValidImagePath() {
    if (imagePath == null || imagePath!.isEmpty) return true;

    final String path = imagePath!.toLowerCase();
    return path.endsWith('.jpg') ||
           path.endsWith('.jpeg') ||
           path.endsWith('.png') ||
           path.endsWith('.webp');
  }

  /// Creates a copy of this content with optionally updated values
  GraffitiContent copyWith({
    String? text,
    String? imagePath,
    GraffitiSize? size,
  }) {
    return GraffitiContent(
      text: text ?? this.text,
      imagePath: imagePath ?? this.imagePath,
      size: size ?? this.size,
    );
  }

  /// Removes the image from this content
  GraffitiContent removeImage() {
    return copyWith(imagePath: null);
  }

  /// Updates the text of this content
  GraffitiContent updateText(String newText) {
    return copyWith(text: newText);
  }

  /// Updates the size of this content
  GraffitiContent changeSize(GraffitiSize newSize) {
    return copyWith(size: newSize);
  }

  @override
  List<Object?> get props => [text, imagePath, size];

  @override
  String toString() {
    return 'GraffitiContent(text: "${text.length > 20 ? "${text.substring(0, 20)}..." : text}", '
           'hasImage: $hasImage, size: ${size.name})';
  }
}