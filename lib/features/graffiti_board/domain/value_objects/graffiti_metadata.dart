import '../../../../shared/domain/value_objects/value_object.dart';

/// Represents metadata associated with a graffiti note including creation time and visibility
class GraffitiMetadata extends ValueObject {
  final DateTime createdAt;
  final bool isVisible;

  const GraffitiMetadata({
    required this.createdAt,
    required this.isVisible,
  });

  /// Creates default graffiti metadata
  factory GraffitiMetadata.createDefault() {
    return GraffitiMetadata(
      createdAt: DateTime.now(),
      isVisible: true,
    );
  }

  /// Creates hidden graffiti metadata
  factory GraffitiMetadata.createHidden() {
    return GraffitiMetadata(
      createdAt: DateTime.now(),
      isVisible: false,
    );
  }

  /// Returns the age of the graffiti in days
  int get ageInDays => DateTime.now().difference(createdAt).inDays;

  /// Returns the age of the graffiti in hours
  int get ageInHours => DateTime.now().difference(createdAt).inHours;

  /// Returns the age of the graffiti in minutes
  int get ageInMinutes => DateTime.now().difference(createdAt).inMinutes;

  /// Checks if the graffiti is new (created within last hour)
  bool get isNew => ageInHours < 1;

  /// Checks if the graffiti is recent (created within last 24 hours)
  bool get isRecent => ageInDays < 1;

  /// Checks if the graffiti is old (created more than 7 days ago)
  bool get isOld => ageInDays > 7;

  /// Returns a human-readable relative time string
  String get relativeTimeString {
    if (ageInMinutes < 1) {
      return '방금 전';
    } else if (ageInMinutes < 60) {
      return '${ageInMinutes}분 전';
    } else if (ageInHours < 24) {
      return '${ageInHours}시간 전';
    } else if (ageInDays < 30) {
      return '${ageInDays}일 전';
    } else {
      final months = (ageInDays / 30).floor();
      return '${months}개월 전';
    }
  }

  /// Returns a formatted creation date string
  String get formattedDate {
    return '${createdAt.year}-${createdAt.month.toString().padLeft(2, '0')}-${createdAt.day.toString().padLeft(2, '0')}';
  }

  /// Returns a formatted creation time string
  String get formattedTime {
    return '${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}';
  }

  /// Returns a formatted creation datetime string
  String get formattedDateTime {
    return '$formattedDate $formattedTime';
  }

  /// Creates a copy of this metadata with optionally updated values
  GraffitiMetadata copyWith({
    DateTime? createdAt,
    bool? isVisible,
  }) {
    return GraffitiMetadata(
      createdAt: createdAt ?? this.createdAt,
      isVisible: isVisible ?? this.isVisible,
    );
  }

  /// Shows the graffiti
  GraffitiMetadata show() {
    return copyWith(isVisible: true);
  }

  /// Hides the graffiti
  GraffitiMetadata hide() {
    return copyWith(isVisible: false);
  }

  /// Toggles the visibility of the graffiti
  GraffitiMetadata toggleVisibility() {
    return copyWith(isVisible: !isVisible);
  }

  @override
  List<Object?> get props => [createdAt, isVisible];

  @override
  String toString() {
    return 'GraffitiMetadata(createdAt: $formattedDateTime, '
           'isVisible: $isVisible, age: $relativeTimeString)';
  }
}