import 'dart:convert';
import 'package:isar/isar.dart';
import '../../domain/entities/graffiti_note.dart';
import '../../domain/value_objects/graffiti_content.dart';
import '../../domain/value_objects/graffiti_properties.dart';
import '../../domain/value_objects/graffiti_metadata.dart';

part 'graffiti_note_model.g.dart';

/// Isar data model for GraffitiNote entity with database annotations
/// Extends the domain GraffitiNote entity for persistence layer
@collection
class GraffitiNoteModel extends GraffitiNote {
  Id? isarId;

  @Index()
  @override
  String get id => super.id;

  @Index()
  @override
  String get wallId => super.wallId;

  @Index()
  @override
  String get userId => super.userId;

  @Index()
  @override
  DateTime get createdAt => super.metadata.createdAt;

  /// Serialized GraffitiContent as JSON string for Isar storage
  late String contentJson;

  /// Serialized GraffitiProperties as JSON string for Isar storage
  late String propertiesJson;

  /// Serialized GraffitiMetadata as JSON string for Isar storage
  late String metadataJson;

  /// Image path for direct access in queries
  String? imagePath;

  GraffitiNoteModel({
    required String id,
    required String wallId,
    required String userId,
    required GraffitiContent content,
    required GraffitiProperties properties,
    required GraffitiMetadata metadata,
  }) : super(
          id: id,
          wallId: wallId,
          userId: userId,
          content: content,
          properties: properties,
          metadata: metadata,
        ) {
    // Serialize complex objects as JSON strings
    contentJson = jsonEncode(content.toJson());
    propertiesJson = jsonEncode(properties.toJson());
    metadataJson = jsonEncode(metadata.toJson());

    // Extract image path for direct access
    imagePath = content.imagePath;
  }

  /// Factory constructor from domain GraffitiNote entity
  factory GraffitiNoteModel.fromDomain(GraffitiNote graffitiNote) {
    return GraffitiNoteModel(
      id: graffitiNote.id,
      wallId: graffitiNote.wallId,
      userId: graffitiNote.userId,
      content: graffitiNote.content,
      properties: graffitiNote.properties,
      metadata: graffitiNote.metadata,
    );
  }

  /// Converts model back to domain GraffitiNote entity
  GraffitiNote toDomain() {
    return GraffitiNote(
      id: id,
      wallId: wallId,
      userId: userId,
      content: _deserializeContent(contentJson),
      properties: _deserializeProperties(propertiesJson),
      metadata: _deserializeMetadata(metadataJson),
    );
  }

  /// Factory constructor from JSON map
  factory GraffitiNoteModel.fromJson(Map<String, dynamic> json) {
    return GraffitiNoteModel(
      id: json['id'] as String,
      wallId: json['wallId'] as String,
      userId: json['userId'] as String,
      content: GraffitiContent.fromJson(json['content'] as Map<String, dynamic>),
      properties: GraffitiProperties.fromJson(json['properties'] as Map<String, dynamic>),
      metadata: GraffitiMetadata.fromJson(json['metadata'] as Map<String, dynamic>),
    );
  }

  /// Converts model to JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'wallId': wallId,
      'userId': userId,
      'content': content.toJson(),
      'properties': properties.toJson(),
      'metadata': metadata.toJson(),
    };
  }

  /// Deserializes GraffitiContent from JSON string
  GraffitiContent _deserializeContent(String json) {
    return GraffitiContent.fromJson(jsonDecode(json) as Map<String, dynamic>);
  }

  /// Deserializes GraffitiProperties from JSON string
  GraffitiProperties _deserializeProperties(String json) {
    return GraffitiProperties.fromJson(jsonDecode(json) as Map<String, dynamic>);
  }

  /// Deserializes GraffitiMetadata from JSON string
  GraffitiMetadata _deserializeMetadata(String json) {
    return GraffitiMetadata.fromJson(jsonDecode(json) as Map<String, dynamic>);
  }

  /// Creates a copy with updated fields
  GraffitiNoteModel copyWith({
    String? id,
    String? wallId,
    String? userId,
    GraffitiContent? content,
    GraffitiProperties? properties,
    GraffitiMetadata? metadata,
  }) {
    return GraffitiNoteModel(
      id: id ?? this.id,
      wallId: wallId ?? this.wallId,
      userId: userId ?? this.userId,
      content: content ?? this.content,
      properties: properties ?? this.properties,
      metadata: metadata ?? this.metadata,
    );
  }
}