import 'package:flutter/material.dart';
import '../../../../shared/domain/value_objects/value_object.dart';
import 'graffiti_position.dart';

/// Represents the visual properties of a graffiti note including position, color, and opacity
class GraffitiProperties extends ValueObject {
  final GraffitiPosition position;
  final Color backgroundColor;
  final double opacity;

  const GraffitiProperties({
    required this.position,
    required this.backgroundColor,
    required this.opacity,
  });

  /// Creates default graffiti properties
  factory GraffitiProperties.createDefault({
    required Offset offset,
    required Size size,
    Color? backgroundColor,
  }) {
    return GraffitiProperties(
      position: GraffitiPosition.create(offset: offset, size: size),
      backgroundColor: backgroundColor ?? _getRandomBackgroundColor(),
      opacity: 0.9,
    );
  }

  /// Creates graffiti properties with specified position
  factory GraffitiProperties.withPosition({
    required GraffitiPosition position,
    Color? backgroundColor,
    double opacity = 0.9,
  }) {
    return GraffitiProperties(
      position: position,
      backgroundColor: backgroundColor ?? _getRandomBackgroundColor(),
      opacity: opacity,
    );
  }

  /// Returns a random background color from a predefined palette
  static Color _getRandomBackgroundColor() {
    final colors = [
      const Color(0xFFFFE5E5), // Light Pink
      const Color(0xFFE5F3FF), // Light Blue
      const Color(0xFFE5FFE5), // Light Green
      const Color(0xFFFFF5E5), // Light Orange
      const Color(0xFFF0E5FF), // Light Purple
      const Color(0xFFFFFFE5), // Light Yellow
      const Color(0xFFE5FFFF), // Light Cyan
      const Color(0xFFFFE5F5), // Light Rose
    ];

    final random = DateTime.now().millisecondsSinceEpoch % colors.length;
    return colors[random];
  }

  /// Returns the bounds of this graffiti note
  Rect get bounds => position.bounds;

  /// Returns the center point of this graffiti note
  Offset get center => position.center;

  /// Returns the z-index of this graffiti note
  int get zIndex => position.zIndex;

  /// Checks if this graffiti overlaps with another graffiti's properties
  bool overlaps(GraffitiProperties other) {
    return position.overlaps(other.position);
  }

  /// Returns the overlap percentage with another graffiti's properties
  double overlapPercentage(GraffitiProperties other) {
    return position.overlapPercentage(other.position);
  }

  /// Checks if this graffiti is within the given bounds
  bool isWithinBounds(Rect bounds) {
    return position.isWithinBounds(bounds);
  }

  /// Checks if this graffiti contains a specific point
  bool contains(Offset point) {
    return position.contains(point);
  }

  /// Returns the effective color with opacity applied
  Color get effectiveColor {
    return backgroundColor.withOpacity(opacity);
  }

  /// Checks if the graffiti is visible (opacity > 0)
  bool get isVisible => opacity > 0.0;

  /// Checks if the graffiti is fully opaque
  bool get isOpaque => opacity >= 1.0;

  /// Checks if the graffiti is transparent
  bool get isTransparent => opacity < 1.0;

  /// Creates a copy of this properties with optionally updated values
  GraffitiProperties copyWith({
    GraffitiPosition? position,
    Color? backgroundColor,
    double? opacity,
  }) {
    return GraffitiProperties(
      position: position ?? this.position,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      opacity: opacity ?? this.opacity,
    );
  }

  /// Moves this graffiti by the given delta
  GraffitiProperties translate(Offset delta) {
    return copyWith(position: position.translate(delta));
  }

  /// Resizes this graffiti to the given size
  GraffitiProperties resize(Size newSize) {
    return copyWith(position: position.resize(newSize));
  }

  /// Brings this graffiti to the front by updating its z-index
  GraffitiProperties bringToFront() {
    return copyWith(position: position.bringToFront());
  }

  /// Updates the background color
  GraffitiProperties updateColor(Color newColor) {
    return copyWith(backgroundColor: newColor);
  }

  /// Updates the opacity
  GraffitiProperties updateOpacity(double newOpacity) {
    final clampedOpacity = newOpacity.clamp(0.0, 1.0);
    return copyWith(opacity: clampedOpacity);
  }

  /// Makes the graffiti more transparent
  GraffitiProperties makeMoreTransparent([double amount = 0.1]) {
    final newOpacity = (opacity - amount).clamp(0.0, 1.0);
    return updateOpacity(newOpacity);
  }

  /// Makes the graffiti more opaque
  GraffitiProperties makeMoreOpaque([double amount = 0.1]) {
    final newOpacity = (opacity + amount).clamp(0.0, 1.0);
    return updateOpacity(newOpacity);
  }

  @override
  List<Object?> get props => [position, backgroundColor, opacity];

  @override
  String toString() {
    return 'GraffitiProperties(position: $position, '
           'color: $backgroundColor, opacity: $opacity)';
  }
}