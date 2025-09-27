import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import '../value_objects/graffiti_content.dart';
import '../value_objects/graffiti_properties.dart';
import '../value_objects/graffiti_metadata.dart';
import '../value_objects/graffiti_position.dart';

/// Enhanced graffiti note entity with domain logic for content management, collision detection, and user ownership
class GraffitiNote extends Equatable {
  final String id;
  final String wallId;
  final String userId;
  final GraffitiContent content;
  final GraffitiProperties properties;
  final GraffitiMetadata metadata;

  const GraffitiNote({
    required this.id,
    required this.wallId,
    required this.userId,
    required this.content,
    required this.properties,
    required this.metadata,
  });

  /// Creates a new graffiti note
  factory GraffitiNote.create({
    required String id,
    required String wallId,
    required String userId,
    required String text,
    required GraffitiSize size,
    required Offset position,
    String? imagePath,
    Color? backgroundColor,
  }) {
    final content = GraffitiContent(
      text: text,
      imagePath: imagePath,
      size: size,
    );

    final properties = GraffitiProperties.createDefault(
      offset: position,
      size: size.dimensions,
      backgroundColor: backgroundColor,
    );

    final metadata = GraffitiMetadata.createDefault();

    return GraffitiNote(
      id: id,
      wallId: wallId,
      userId: userId,
      content: content,
      properties: properties,
      metadata: metadata,
    );
  }

  /// Creates a graffiti note from existing data
  factory GraffitiNote.fromData({
    required String id,
    required String wallId,
    required String userId,
    required GraffitiContent content,
    required GraffitiProperties properties,
    required GraffitiMetadata metadata,
  }) {
    return GraffitiNote(
      id: id,
      wallId: wallId,
      userId: userId,
      content: content,
      properties: properties,
      metadata: metadata,
    );
  }

  // Domain methods

  /// Checks if this graffiti note is owned by a specific user
  bool isOwnedBy(String userId) => this.userId == userId;

  /// Checks if this graffiti note overlaps with another graffiti note
  bool isOverlapping(GraffitiNote other) {
    return properties.overlaps(other.properties);
  }

  /// Returns the overlap percentage with another graffiti note
  double overlapPercentage(GraffitiNote other) {
    return properties.overlapPercentage(other.properties);
  }

  /// Checks if this graffiti note is visible
  bool get isVisible => metadata.isVisible && properties.isVisible;

  /// Checks if this graffiti note is hidden
  bool get isHidden => !isVisible;

  /// Checks if this graffiti note has valid content
  bool get hasValidContent => content.isValid();

  /// Checks if this graffiti note has an image
  bool get hasImage => content.hasImage;

  /// Checks if this graffiti note is text-only
  bool get isTextOnly => content.isTextOnly;

  /// Returns the display text (trimmed)
  String get displayText => content.trimmedText;

  /// Returns the size of this graffiti note
  GraffitiSize get size => content.size;

  /// Returns the position of this graffiti note
  GraffitiPosition get position => properties.position;

  /// Returns the bounds of this graffiti note
  Rect get bounds => properties.bounds;

  /// Returns the center point of this graffiti note
  Offset get center => properties.center;

  /// Returns the z-index of this graffiti note
  int get zIndex => properties.zIndex;

  /// Returns the age of this graffiti note in days
  int get ageInDays => metadata.ageInDays;

  /// Returns a human-readable relative time string
  String get relativeTimeString => metadata.relativeTimeString;

  /// Checks if this graffiti note is new
  bool get isNew => metadata.isNew;

  /// Checks if this graffiti note is recent
  bool get isRecent => metadata.isRecent;

  /// Checks if this graffiti note is old
  bool get isOld => metadata.isOld;

  /// Checks if this graffiti note contains a specific point
  bool contains(Offset point) {
    return properties.contains(point);
  }

  /// Checks if this graffiti note is within the given bounds
  bool isWithinBounds(Rect bounds) {
    return properties.isWithinBounds(bounds);
  }

  /// Creates a copy of this graffiti note with optionally updated values
  GraffitiNote copyWith({
    String? id,
    String? wallId,
    String? userId,
    GraffitiContent? content,
    GraffitiProperties? properties,
    GraffitiMetadata? metadata,
  }) {
    return GraffitiNote(
      id: id ?? this.id,
      wallId: wallId ?? this.wallId,
      userId: userId ?? this.userId,
      content: content ?? this.content,
      properties: properties ?? this.properties,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Updates the content of this graffiti note
  GraffitiNote updateContent(GraffitiContent newContent) {
    return copyWith(content: newContent);
  }

  /// Updates the text of this graffiti note
  GraffitiNote updateText(String newText) {
    final updatedContent = content.updateText(newText);
    return copyWith(content: updatedContent);
  }

  /// Updates the size of this graffiti note
  GraffitiNote changeSize(GraffitiSize newSize) {
    final updatedContent = content.changeSize(newSize);
    final updatedProperties = properties.resize(newSize.dimensions);
    return copyWith(
      content: updatedContent,
      properties: updatedProperties,
    );
  }

  /// Adds an image to this graffiti note
  GraffitiNote addImage(String imagePath) {
    final updatedContent = content.copyWith(imagePath: imagePath);
    return copyWith(content: updatedContent);
  }

  /// Removes the image from this graffiti note
  GraffitiNote removeImage() {
    final updatedContent = content.removeImage();
    return copyWith(content: updatedContent);
  }

  /// Moves this graffiti note by the given delta
  GraffitiNote move(Offset delta) {
    final updatedProperties = properties.translate(delta);
    return copyWith(properties: updatedProperties);
  }

  /// Moves this graffiti note to a specific position
  GraffitiNote moveTo(Offset newPosition) {
    final currentPosition = properties.position;
    final newGraffitiPosition = currentPosition.copyWith(offset: newPosition);
    final updatedProperties = properties.copyWith(position: newGraffitiPosition);
    return copyWith(properties: updatedProperties);
  }

  /// Brings this graffiti note to the front
  GraffitiNote bringToFront() {
    final updatedProperties = properties.bringToFront();
    return copyWith(properties: updatedProperties);
  }

  /// Updates the background color of this graffiti note
  GraffitiNote updateColor(Color newColor) {
    final updatedProperties = properties.updateColor(newColor);
    return copyWith(properties: updatedProperties);
  }

  /// Updates the opacity of this graffiti note
  GraffitiNote updateOpacity(double newOpacity) {
    final updatedProperties = properties.updateOpacity(newOpacity);
    return copyWith(properties: updatedProperties);
  }

  /// Shows this graffiti note
  GraffitiNote show() {
    final updatedMetadata = metadata.show();
    return copyWith(metadata: updatedMetadata);
  }

  /// Hides this graffiti note
  GraffitiNote hide() {
    final updatedMetadata = metadata.hide();
    return copyWith(metadata: updatedMetadata);
  }

  /// Toggles the visibility of this graffiti note
  GraffitiNote toggleVisibility() {
    final updatedMetadata = metadata.toggleVisibility();
    return copyWith(metadata: updatedMetadata);
  }

  @override
  List<Object?> get props => [
    id,
    wallId,
    userId,
    content,
    properties,
    metadata,
  ];

  @override
  String toString() {
    return 'GraffitiNote(id: $id, text: "${displayText.length > 20 ? "${displayText.substring(0, 20)}..." : displayText}", '
           'size: ${size.name}, position: ${position.offset}, '
           'age: $relativeTimeString, visible: $isVisible)';
  }
}