import '../../../../shared/domain/value_objects/value_object.dart';

/// Enum representing the status of a wall
enum WallStatus {
  active,
  inactive,
  maintenance,
  archived;

  /// Returns the display name for the status in Korean
  String get displayName {
    switch (this) {
      case WallStatus.active:
        return '활성';
      case WallStatus.inactive:
        return '비활성';
      case WallStatus.maintenance:
        return '유지보수';
      case WallStatus.archived:
        return '보관됨';
    }
  }

  /// Returns the description for the status
  String get description {
    switch (this) {
      case WallStatus.active:
        return '낙서를 추가할 수 있습니다';
      case WallStatus.inactive:
        return '현재 사용할 수 없습니다';
      case WallStatus.maintenance:
        return '유지보수 중입니다';
      case WallStatus.archived:
        return '더 이상 사용되지 않습니다';
    }
  }

  /// Returns true if graffiti can be added to this wall
  bool get canAddGraffiti {
    return this == WallStatus.active;
  }

  /// Returns true if this wall can be accessed by users
  bool get isAccessible {
    return this == WallStatus.active || this == WallStatus.inactive;
  }

  /// Creates a WallStatus from string
  static WallStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'active':
      case '활성':
        return WallStatus.active;
      case 'inactive':
      case '비활성':
        return WallStatus.inactive;
      case 'maintenance':
      case '유지보수':
        return WallStatus.maintenance;
      case 'archived':
      case '보관됨':
        return WallStatus.archived;
      default:
        return WallStatus.active;
    }
  }
}

/// Represents metadata associated with a wall including capacity, status, and ownership
class WallMetadata extends ValueObject {
  final DateTime createdAt;
  final int maxCapacity;
  final WallStatus status;
  final String? ownerId;
  final int graffitiCount;

  const WallMetadata({
    required this.createdAt,
    required this.maxCapacity,
    required this.status,
    this.ownerId,
    required this.graffitiCount,
  });

  /// Creates default wall metadata for a new wall
  factory WallMetadata.createDefault({
    int maxCapacity = 100,
    String? ownerId,
  }) {
    return WallMetadata(
      createdAt: DateTime.now(),
      maxCapacity: maxCapacity,
      status: WallStatus.active,
      ownerId: ownerId,
      graffitiCount: 0,
    );
  }

  /// Creates wall metadata for a public wall (no owner)
  factory WallMetadata.createPublic({
    int maxCapacity = 200,
  }) {
    return WallMetadata(
      createdAt: DateTime.now(),
      maxCapacity: maxCapacity,
      status: WallStatus.active,
      ownerId: null,
      graffitiCount: 0,
    );
  }

  // Domain methods

  /// Checks if the wall is at capacity
  bool isAtCapacity() => graffitiCount >= maxCapacity;

  /// Checks if graffiti can be added to this wall
  bool canAddGraffiti() {
    return status.canAddGraffiti && !isAtCapacity();
  }

  /// Checks if the wall has an owner
  bool get hasOwner => ownerId != null && ownerId!.isNotEmpty;

  /// Checks if the wall is public (no owner)
  bool get isPublic => !hasOwner;

  /// Returns the remaining capacity
  int get remainingCapacity => maxCapacity - graffitiCount;

  /// Returns the capacity utilization as a percentage (0.0 to 1.0)
  double get capacityUtilization => graffitiCount / maxCapacity;

  /// Checks if the wall is nearly full (>80% capacity)
  bool get isNearlyFull => capacityUtilization > 0.8;

  /// Checks if the wall is accessible to users
  bool get isAccessible => status.isAccessible;

  /// Returns the age of the wall in days
  int get ageInDays => DateTime.now().difference(createdAt).inDays;

  /// Checks if the wall is new (created within last 7 days)
  bool get isNew => ageInDays <= 7;

  /// Creates a copy of this metadata with optionally updated values
  WallMetadata copyWith({
    DateTime? createdAt,
    int? maxCapacity,
    WallStatus? status,
    String? ownerId,
    int? graffitiCount,
  }) {
    return WallMetadata(
      createdAt: createdAt ?? this.createdAt,
      maxCapacity: maxCapacity ?? this.maxCapacity,
      status: status ?? this.status,
      ownerId: ownerId ?? this.ownerId,
      graffitiCount: graffitiCount ?? this.graffitiCount,
    );
  }

  /// Increments the graffiti count
  WallMetadata addGraffiti() {
    return copyWith(graffitiCount: graffitiCount + 1);
  }

  /// Decrements the graffiti count
  WallMetadata removeGraffiti() {
    final newCount = (graffitiCount - 1).clamp(0, maxCapacity);
    return copyWith(graffitiCount: newCount);
  }

  /// Updates the wall status
  WallMetadata updateStatus(WallStatus newStatus) {
    return copyWith(status: newStatus);
  }

  /// Updates the maximum capacity
  WallMetadata updateCapacity(int newMaxCapacity) {
    return copyWith(maxCapacity: newMaxCapacity);
  }

  /// Sets the owner of the wall
  WallMetadata setOwner(String newOwnerId) {
    return copyWith(ownerId: newOwnerId);
  }

  /// Removes the owner (makes the wall public)
  WallMetadata removeOwner() {
    return copyWith(ownerId: null);
  }

  /// Creates a WallMetadata from JSON map
  factory WallMetadata.fromJson(Map<String, dynamic> json) {
    return WallMetadata(
      createdAt: DateTime.parse(json['createdAt'] as String),
      maxCapacity: json['maxCapacity'] as int,
      status: WallStatus.fromString(json['status'] as String),
      ownerId: json['ownerId'] as String?,
      graffitiCount: json['graffitiCount'] as int,
    );
  }

  /// Converts WallMetadata to JSON map
  Map<String, dynamic> toJson() {
    return {
      'createdAt': createdAt.toIso8601String(),
      'maxCapacity': maxCapacity,
      'status': status.name,
      'ownerId': ownerId,
      'graffitiCount': graffitiCount,
    };
  }

  @override
  List<Object?> get props => [
    createdAt,
    maxCapacity,
    status,
    ownerId,
    graffitiCount,
  ];

  @override
  String toString() {
    return 'WallMetadata(status: ${status.name}, '
           'capacity: $graffitiCount/$maxCapacity, '
           'hasOwner: $hasOwner, '
           'age: ${ageInDays}days)';
  }
}