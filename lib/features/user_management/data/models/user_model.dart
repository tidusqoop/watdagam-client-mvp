import 'dart:convert';
import 'package:isar/isar.dart';
import '../../domain/entities/user.dart';
import '../../domain/value_objects/user_preferences.dart';

part 'user_model.g.dart';

/// Isar data model for User entity with database annotations
/// Extends the domain User entity for persistence layer
@collection
class UserModel extends User {
  Id? isarId;

  @Index()
  @override
  String get id => super.id;

  @Index()
  @override
  String? get email => super.email;

  @Index()
  @override
  DateTime get createdAt => super.createdAt;

  /// Serialized UserPreferences as JSON string for Isar storage
  late String preferencesJson;

  /// Serialized visited wall IDs as JSON string for Isar storage
  late String visitedWallIdsJson;

  UserModel({
    required String id,
    required String name,
    String? email,
    String? avatarPath,
    required DateTime createdAt,
    required UserPreferences preferences,
    required List<String> visitedWallIds,
  }) : super(
          id: id,
          name: name,
          email: email,
          avatarPath: avatarPath,
          createdAt: createdAt,
          preferences: preferences,
          visitedWallIds: visitedWallIds,
        ) {
    preferencesJson = _serializePreferences(preferences);
    visitedWallIdsJson = jsonEncode(visitedWallIds);
  }

  /// Factory constructor from domain User entity
  factory UserModel.fromDomain(User user) {
    return UserModel(
      id: user.id,
      name: user.name,
      email: user.email,
      avatarPath: user.avatarPath,
      createdAt: user.createdAt,
      preferences: user.preferences,
      visitedWallIds: user.visitedWallIds,
    );
  }

  /// Converts model back to domain User entity
  User toDomain() {
    return User(
      id: id,
      name: name,
      email: email,
      avatarPath: avatarPath,
      createdAt: createdAt,
      preferences: _deserializePreferences(preferencesJson),
      visitedWallIds: _deserializeVisitedWallIds(visitedWallIdsJson),
    );
  }

  /// Factory constructor from JSON map
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String?,
      avatarPath: json['avatarPath'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      preferences: UserPreferences.fromJson(json['preferences'] as Map<String, dynamic>),
      visitedWallIds: List<String>.from(json['visitedWallIds'] as List),
    );
  }

  /// Converts model to JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatarPath': avatarPath,
      'createdAt': createdAt.toIso8601String(),
      'preferences': preferences.toJson(),
      'visitedWallIds': visitedWallIds,
    };
  }

  /// Serializes UserPreferences to JSON string
  String _serializePreferences(UserPreferences preferences) {
    return jsonEncode(preferences.toJson());
  }

  /// Deserializes UserPreferences from JSON string
  UserPreferences _deserializePreferences(String json) {
    return UserPreferences.fromJson(jsonDecode(json) as Map<String, dynamic>);
  }

  /// Deserializes visited wall IDs from JSON string
  List<String> _deserializeVisitedWallIds(String json) {
    return List<String>.from(jsonDecode(json) as List);
  }

  /// Creates a copy with updated fields
  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? avatarPath,
    DateTime? createdAt,
    UserPreferences? preferences,
    List<String>? visitedWallIds,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarPath: avatarPath ?? this.avatarPath,
      createdAt: createdAt ?? this.createdAt,
      preferences: preferences ?? this.preferences,
      visitedWallIds: visitedWallIds ?? this.visitedWallIds,
    );
  }
}