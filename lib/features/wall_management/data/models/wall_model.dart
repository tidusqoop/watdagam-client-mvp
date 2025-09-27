import 'dart:convert';
import 'dart:math';
import 'package:isar/isar.dart';
import '../../domain/entities/wall.dart';
import '../../domain/value_objects/wall_location.dart';
import '../../domain/value_objects/wall_metadata.dart';
import '../../domain/value_objects/wall_permissions.dart';

part 'wall_model.g.dart';

/// Isar data model for Wall entity with database annotations
/// Extends the domain Wall entity for persistence layer
@collection
class WallModel extends Wall {
  Id? isarId;

  @Index()
  @override
  String get id => super.id;

  @Index(type: IndexType.geo)
  late double latitude;

  @Index(type: IndexType.geo)
  late double longitude;

  @Index()
  @override
  String get name => super.name;

  /// Serialized WallLocation as JSON string for Isar storage
  late String locationJson;

  /// Serialized WallMetadata as JSON string for Isar storage
  late String metadataJson;

  /// Serialized graffiti note IDs as JSON string for Isar storage
  late String graffitiNoteIdsJson;

  /// Serialized WallPermissions as JSON string for Isar storage
  late String permissionsJson;

  WallModel({
    required String id,
    required String name,
    required String description,
    required WallLocation location,
    required WallMetadata metadata,
    required List<String> graffitiNoteIds,
    required WallPermissions permissions,
  }) : super(
          id: id,
          name: name,
          description: description,
          location: location,
          metadata: metadata,
          graffitiNoteIds: graffitiNoteIds,
          permissions: permissions,
        ) {
    // Set geo-indexed fields for efficient location queries
    latitude = location.latitude;
    longitude = location.longitude;

    // Serialize complex objects as JSON strings
    locationJson = jsonEncode(location.toJson());
    metadataJson = jsonEncode(metadata.toJson());
    graffitiNoteIdsJson = jsonEncode(graffitiNoteIds);
    permissionsJson = jsonEncode(permissions.toJson());
  }

  /// Factory constructor from domain Wall entity
  factory WallModel.fromDomain(Wall wall) {
    return WallModel(
      id: wall.id,
      name: wall.name,
      description: wall.description,
      location: wall.location,
      metadata: wall.metadata,
      graffitiNoteIds: wall.graffitiNoteIds,
      permissions: wall.permissions,
    );
  }

  /// Converts model back to domain Wall entity
  Wall toDomain() {
    return Wall(
      id: id,
      name: name,
      description: description,
      location: _deserializeLocation(locationJson),
      metadata: _deserializeMetadata(metadataJson),
      graffitiNoteIds: _deserializeGraffitiNoteIds(graffitiNoteIdsJson),
      permissions: _deserializePermissions(permissionsJson),
    );
  }

  /// Factory constructor from JSON map
  factory WallModel.fromJson(Map<String, dynamic> json) {
    return WallModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      location: WallLocation.fromJson(json['location'] as Map<String, dynamic>),
      metadata: WallMetadata.fromJson(json['metadata'] as Map<String, dynamic>),
      graffitiNoteIds: List<String>.from(json['graffitiNoteIds'] as List),
      permissions: WallPermissions.fromJson(json['permissions'] as Map<String, dynamic>),
    );
  }

  /// Converts model to JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'location': location.toJson(),
      'metadata': metadata.toJson(),
      'graffitiNoteIds': graffitiNoteIds,
      'permissions': permissions.toJson(),
    };
  }

  /// Deserializes WallLocation from JSON string
  WallLocation _deserializeLocation(String json) {
    return WallLocation.fromJson(jsonDecode(json) as Map<String, dynamic>);
  }

  /// Deserializes WallMetadata from JSON string
  WallMetadata _deserializeMetadata(String json) {
    return WallMetadata.fromJson(jsonDecode(json) as Map<String, dynamic>);
  }

  /// Deserializes graffiti note IDs from JSON string
  List<String> _deserializeGraffitiNoteIds(String json) {
    return List<String>.from(jsonDecode(json) as List);
  }

  /// Deserializes WallPermissions from JSON string
  WallPermissions _deserializePermissions(String json) {
    return WallPermissions.fromJson(jsonDecode(json) as Map<String, dynamic>);
  }

  /// Calculates distance to a given location in kilometers
  double distanceToLocation(double lat, double lng) {
    const double earthRadiusKm = 6371.0;

    final double lat1Rad = latitude * pi / 180;
    final double lat2Rad = lat * pi / 180;
    final double deltaLatRad = (lat - latitude) * pi / 180;
    final double deltaLngRad = (lng - longitude) * pi / 180;

    final double a = sin(deltaLatRad / 2) * sin(deltaLatRad / 2) +
        cos(lat1Rad) * cos(lat2Rad) *
        sin(deltaLngRad / 2) * sin(deltaLngRad / 2);

    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadiusKm * c;
  }

  /// Creates a copy with updated fields
  WallModel copyWith({
    String? id,
    String? name,
    String? description,
    WallLocation? location,
    WallMetadata? metadata,
    List<String>? graffitiNoteIds,
    WallPermissions? permissions,
  }) {
    return WallModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      location: location ?? this.location,
      metadata: metadata ?? this.metadata,
      graffitiNoteIds: graffitiNoteIds ?? this.graffitiNoteIds,
      permissions: permissions ?? this.permissions,
    );
  }
}