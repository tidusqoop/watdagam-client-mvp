import 'package:get_it/get_it.dart';
import 'package:isar/isar.dart';

// Shared dependencies
import '../shared/data/cache/cache_manager.dart';
import '../shared/data/database/database_service.dart';

// User management dependencies
import '../features/user_management/data/datasources/user_data_source.dart';
import '../features/user_management/data/datasources/local_user_data_source.dart';
import '../features/user_management/data/repositories/user_repository_impl.dart';
import '../features/user_management/domain/repositories/user_repository.dart';

// Wall management dependencies
import '../features/wall_management/data/datasources/wall_data_source.dart';
import '../features/wall_management/data/datasources/local_wall_data_source.dart';
import '../features/wall_management/data/repositories/wall_repository_impl.dart';
import '../features/wall_management/domain/repositories/wall_repository.dart';

// Graffiti board dependencies
import '../features/graffiti_board/data/datasources/graffiti_data_source.dart';
import '../features/graffiti_board/data/datasources/local_graffiti_data_source.dart';
import '../features/graffiti_board/data/repositories/graffiti_repository_impl.dart';
import '../features/graffiti_board/domain/repositories/graffiti_repository.dart';

/// Dependency injection container
final GetIt sl = GetIt.instance;

/// Initializes all dependencies for the data layer
/// Follows the dependency injection pattern from the design document
Future<void> initializeDependencies() async {
  // Initialize database first
  final isar = await DatabaseService.getInstance();

  // Initialize sample data for development
  await DatabaseService.initializeSampleData(isar);

  // Register core dependencies
  sl.registerLazySingleton<Isar>(() => isar);
  sl.registerLazySingleton<CacheManager>(() => CacheManager());

  // Register data sources
  sl.registerLazySingleton<UserDataSource>(
    () => LocalUserDataSource(
      isar: sl<Isar>(),
      cache: sl<CacheManager>(),
    ),
  );

  sl.registerLazySingleton<WallDataSource>(
    () => LocalWallDataSource(
      isar: sl<Isar>(),
      cache: sl<CacheManager>(),
    ),
  );

  sl.registerLazySingleton<GraffitiDataSource>(
    () => LocalGraffitiDataSource(
      isar: sl<Isar>(),
      cache: sl<CacheManager>(),
    ),
  );

  // Register repositories
  sl.registerLazySingleton<UserRepository>(
    () => UserRepositoryImpl(
      dataSource: sl<UserDataSource>(),
    ),
  );

  sl.registerLazySingleton<WallRepository>(
    () => WallRepositoryImpl(
      dataSource: sl<WallDataSource>(),
    ),
  );

  sl.registerLazySingleton<GraffitiRepository>(
    () => GraffitiRepositoryImpl(
      dataSource: sl<GraffitiDataSource>(),
    ),
  );

  print('✅ Data layer dependencies initialized successfully');
}

/// Resets all dependencies (useful for testing)
Future<void> resetDependencies() async {
  await sl.reset();
  await DatabaseService.close();
}

/// Gets database statistics for debugging
Future<Map<String, int>> getDatabaseStats() async {
  return await DatabaseService.getDatabaseStats();
}

/// Performs database maintenance
Future<void> performDatabaseMaintenance() async {
  await DatabaseService.performMaintenance();
}

/// Checks database integrity
Future<bool> checkDatabaseIntegrity() async {
  return await DatabaseService.checkIntegrity();
}

/// Resets the entire database (for testing/development)
Future<void> resetDatabase() async {
  await DatabaseService.resetDatabase();

  // Reinitialize sample data
  final isar = sl<Isar>();
  await DatabaseService.initializeSampleData(isar);

  print('🔄 Database reset and reinitialized');
}

/// Extension methods for easier access to repositories
extension ServiceLocatorExtensions on GetIt {
  UserRepository get userRepository => get<UserRepository>();
  WallRepository get wallRepository => get<WallRepository>();
  GraffitiRepository get graffitiRepository => get<GraffitiRepository>();
  CacheManager get cacheManager => get<CacheManager>();
  Isar get database => get<Isar>();
}

/// Development utilities
class DevelopmentUtils {
  /// Generates sample data for testing
  static Future<void> generateSampleData() async {
    final userRepo = sl.userRepository;
    final wallRepo = sl.wallRepository;
    final graffitiRepo = sl.graffitiRepository;

    print('🔧 Generating additional sample data...');

    // Create additional sample users
    final users = [
      User.create(
        id: 'user_2',
        name: '김철수',
        email: 'kim@example.com',
      ),
      User.create(
        id: 'user_3',
        name: '이영희',
        email: 'lee@example.com',
      ),
    ];

    await userRepo.createUsers(users);

    // Create additional sample walls
    final walls = [
      Wall.createPublic(
        id: 'wall_2',
        name: '홍대 담벼락',
        description: '홍대 예술의 거리 담벼락',
        location: WallLocation(
          latitude: 37.5563,
          longitude: 126.9230,
          address: '서울특별시 마포구 홍대입구',
        ),
      ),
      Wall.createPublic(
        id: 'wall_3',
        name: '강남 담벼락',
        description: '강남역 근처 담벼락',
        location: WallLocation(
          latitude: 37.4979,
          longitude: 127.0276,
          address: '서울특별시 강남구 강남대로',
        ),
      ),
    ];

    await wallRepo.createWalls(walls);

    print('✅ Additional sample data generated');
  }

  /// Prints current repository statistics
  static Future<void> printRepositoryStats() async {
    final userRepo = sl.userRepository;
    final wallRepo = sl.wallRepository;
    final graffitiRepo = sl.graffitiRepository;

    final allUsers = await userRepo.getAllUsers();
    final allWalls = await wallRepo.getAllWalls();
    final allGraffiti = await graffitiRepo.getAllGraffiti();

    print('\n📊 Repository Statistics:');
    print('  Users: ${allUsers.length}');
    print('  Walls: ${allWalls.length}');
    print('  Graffiti: ${allGraffiti.length}');
    print('');
  }

  /// Clears all cache
  static void clearCache() {
    sl.cacheManager.clear();
    print('🧹 Cache cleared');
  }
}