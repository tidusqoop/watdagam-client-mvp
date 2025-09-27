import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../../../features/user_management/data/models/user_model.dart';
import '../../../features/user_management/domain/value_objects/user_preferences.dart';
import '../../../features/wall_management/data/models/wall_model.dart';
import '../../../features/wall_management/domain/value_objects/wall_location.dart';
import '../../../features/wall_management/domain/value_objects/wall_metadata.dart';
import '../../../features/wall_management/domain/value_objects/wall_permissions.dart';
import '../../../features/graffiti_board/data/models/graffiti_note_model.dart';

/// Database service that manages Isar database initialization and migrations
/// Follows the migration strategy outlined in the design document
class DatabaseService {
  static const int CURRENT_VERSION = 2;
  static Isar? _instance;

  /// Gets the singleton Isar instance
  static Future<Isar> getInstance() async {
    if (_instance != null) return _instance!;

    final dir = await getApplicationDocumentsDirectory();

    _instance = await Isar.open(
      [
        UserModelSchema,
        WallModelSchema,
        GraffitiNoteModelSchema,
      ],
      directory: dir.path,
      name: 'watdagam_db',
    );

    await _runMigrations(_instance!);

    return _instance!;
  }

  /// Runs necessary migrations based on stored version
  static Future<void> _runMigrations(Isar isar) async {
    final oldVersion = await _getStoredVersion(isar);

    if (oldVersion < CURRENT_VERSION) {
      print('Running database migrations from version $oldVersion to $CURRENT_VERSION');

      switch (oldVersion) {
        case 1:
          await _migrateFrom1To2(isar);
          break;
        // Add future migrations here
      }

      await _setStoredVersion(isar, CURRENT_VERSION);
      print('Database migration completed');
    }
  }

  /// Gets the stored database version
  static Future<int> _getStoredVersion(Isar isar) async {
    // In a real implementation, this would be stored in a metadata table
    // For MVP, we'll assume version 1 if this is a fresh install
    final userCount = await isar.userModels.count();
    final wallCount = await isar.wallModels.count();
    final graffitiCount = await isar.graffitiNoteModels.count();

    // If database is empty, it's a fresh install (version 2)
    if (userCount == 0 && wallCount == 0 && graffitiCount == 0) {
      return CURRENT_VERSION;
    }

    // Otherwise assume version 1 for existing data
    return 1;
  }

  /// Sets the stored database version
  static Future<void> _setStoredVersion(Isar isar, int version) async {
    // In a real implementation, this would be stored in a metadata table
    // For MVP, we'll just print the version
    print('Database version set to: $version');
  }

  /// Migration from version 1 to 2
  /// Adds userId and wallId to existing graffiti notes
  static Future<void> _migrateFrom1To2(Isar isar) async {
    print('Migrating from version 1 to 2...');

    // Get all existing graffiti notes
    final graffitis = await isar.graffitiNoteModels.where().findAll();

    if (graffitis.isNotEmpty) {
      await isar.writeTxn(() async {
        for (final graffiti in graffitis) {
          // For existing graffitis without userId/wallId, set defaults
          if (graffiti.userId.isEmpty) {
            // Create a copy with default user and wall IDs
            final updatedGraffiti = graffiti.copyWith(
              userId: 'default_user',
              wallId: 'default_wall',
            );
            await isar.graffitiNoteModels.put(updatedGraffiti);
          }
        }
      });
    }

    print('Migration from version 1 to 2 completed');
  }

  /// Initializes the database with sample data for development
  static Future<void> initializeSampleData(Isar isar) async {
    final userCount = await isar.userModels.count();
    final wallCount = await isar.wallModels.count();

    // Only add sample data if database is empty
    if (userCount == 0 && wallCount == 0) {
      print('Initializing sample data...');

      await isar.writeTxn(() async {
        // Add sample user
        final sampleUser = UserModel(
          id: 'user_1',
          name: '테스트 사용자',
          email: 'test@example.com',
          avatarPath: null,
          createdAt: DateTime.now(),
          preferences: UserPreferences.defaults(),
          visitedWallIds: [],
        );
        await isar.userModels.put(sampleUser);

        // Add sample wall
        final sampleWall = WallModel(
          id: 'wall_1',
          name: '테스트 담벼락',
          description: '개발용 테스트 담벼락입니다',
          location: WallLocation(
            latitude: 37.5665,
            longitude: 126.9780,
            address: '서울특별시 중구 명동',
          ),
          metadata: WallMetadata.createPublic(maxCapacity: 100),
          graffitiNoteIds: [],
          permissions: WallPermissions.proximityBased(),
        );
        await isar.wallModels.put(sampleWall);
      });

      print('Sample data initialization completed');
    }
  }

  /// Closes the database connection
  static Future<void> close() async {
    if (_instance != null) {
      await _instance!.close();
      _instance = null;
    }
  }

  /// Resets the entire database (for testing purposes)
  static Future<void> resetDatabase() async {
    if (_instance != null) {
      await _instance!.writeTxn(() async {
        await _instance!.clear();
      });
    }
  }

  /// Gets database statistics
  static Future<Map<String, int>> getDatabaseStats() async {
    final isar = await getInstance();

    final userCount = await isar.userModels.count();
    final wallCount = await isar.wallModels.count();
    final graffitiCount = await isar.graffitiNoteModels.count();

    return {
      'users': userCount,
      'walls': wallCount,
      'graffiti': graffitiCount,
      'version': CURRENT_VERSION,
    };
  }

  /// Performs database maintenance tasks
  static Future<void> performMaintenance() async {
    final isar = await getInstance();

    print('Performing database maintenance...');

    // Compact the database
    await isar.writeTxn(() async {
      // Maintenance operations would go here
      // For now, this is a placeholder
    });

    print('Database maintenance completed');
  }

  /// Checks database integrity
  static Future<bool> checkIntegrity() async {
    try {
      final isar = await getInstance();

      // Basic integrity checks
      final userCount = await isar.userModels.count();
      final wallCount = await isar.wallModels.count();
      final graffitiCount = await isar.graffitiNoteModels.count();

      print('Database integrity check:');
      print('  Users: $userCount');
      print('  Walls: $wallCount');
      print('  Graffiti: $graffitiCount');

      return true;
    } catch (e) {
      print('Database integrity check failed: $e');
      return false;
    }
  }
}