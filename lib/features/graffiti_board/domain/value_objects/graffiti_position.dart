import 'package:flutter/material.dart';
import '../../../../shared/domain/value_objects/value_object.dart';

/// Represents the position and dimensions of a graffiti note on the canvas.
/// Includes collision detection logic for overlapping graffiti notes.
class GraffitiPosition extends ValueObject {
  final Offset offset;
  final Size size;
  final int zIndex;

  const GraffitiPosition({
    required this.offset,
    required this.size,
    required this.zIndex,
  });

  /// Creates a GraffitiPosition with current timestamp as zIndex
  factory GraffitiPosition.create({
    required Offset offset,
    required Size size,
  }) {
    return GraffitiPosition(
      offset: offset,
      size: size,
      zIndex: DateTime.now().millisecondsSinceEpoch,
    );
  }

  /// Creates a GraffitiPosition at the origin with given size
  factory GraffitiPosition.zero(Size size) {
    return GraffitiPosition(
      offset: Offset.zero,
      size: size,
      zIndex: 0,
    );
  }

  /// Returns the rectangle bounds of this position
  Rect get bounds => Rect.fromLTWH(offset.dx, offset.dy, size.width, size.height);

  /// Returns the center point of this position
  Offset get center => Offset(
    offset.dx + size.width / 2,
    offset.dy + size.height / 2,
  );

  /// Checks if this position overlaps with another position
  bool overlaps(GraffitiPosition other) {
    return bounds.overlaps(other.bounds);
  }

  /// Checks if this position contains a specific point
  bool contains(Offset point) {
    return bounds.contains(point);
  }

  /// Returns the area of this position
  double get area => size.width * size.height;

  /// Returns the overlap area with another position
  double overlapArea(GraffitiPosition other) {
    final intersection = bounds.intersect(other.bounds);
    if (intersection.isEmpty) return 0.0;
    return intersection.width * intersection.height;
  }

  /// Returns the percentage of overlap with another position
  double overlapPercentage(GraffitiPosition other) {
    final overlapSize = overlapArea(other);
    if (overlapSize == 0.0) return 0.0;
    return overlapSize / area;
  }

  /// Checks if this position is completely within the given bounds
  bool isWithinBounds(Rect bounds) {
    return bounds.contains(this.bounds.topLeft) &&
           bounds.contains(this.bounds.bottomRight);
  }

  /// Creates a copy of this position with optionally updated values
  GraffitiPosition copyWith({
    Offset? offset,
    Size? size,
    int? zIndex,
  }) {
    return GraffitiPosition(
      offset: offset ?? this.offset,
      size: size ?? this.size,
      zIndex: zIndex ?? this.zIndex,
    );
  }

  /// Moves this position by the given delta
  GraffitiPosition translate(Offset delta) {
    return copyWith(offset: offset + delta);
  }

  /// Resizes this position to the given size
  GraffitiPosition resize(Size newSize) {
    return copyWith(size: newSize);
  }

  /// Updates the z-index of this position
  GraffitiPosition bringToFront() {
    return copyWith(zIndex: DateTime.now().millisecondsSinceEpoch);
  }

  /// Creates a GraffitiPosition from JSON map
  factory GraffitiPosition.fromJson(Map<String, dynamic> json) {
    return GraffitiPosition(
      offset: Offset(
        (json['offsetX'] as num).toDouble(),
        (json['offsetY'] as num).toDouble(),
      ),
      size: Size(
        (json['sizeWidth'] as num).toDouble(),
        (json['sizeHeight'] as num).toDouble(),
      ),
      zIndex: json['zIndex'] as int,
    );
  }

  /// Converts GraffitiPosition to JSON map
  Map<String, dynamic> toJson() {
    return {
      'offsetX': offset.dx,
      'offsetY': offset.dy,
      'sizeWidth': size.width,
      'sizeHeight': size.height,
      'zIndex': zIndex,
    };
  }

  @override
  List<Object?> get props => [offset, size, zIndex];

  @override
  String toString() {
    return 'GraffitiPosition(offset: $offset, size: $size, zIndex: $zIndex)';
  }
}