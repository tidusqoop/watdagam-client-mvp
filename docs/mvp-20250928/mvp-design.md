# MVP Design Document: 낙서벽 SNS 앱 (Next Phase)

**작성일**: 2025-01-26  
**버전**: 1.0  
**대상**: 개발팀, 기술 설계 검토

---

## 📋 Executive Summary

본 문서는 낙서벽 SNS 앱의 다음 MVP 단계를 위한 종합적인 설계 가이드입니다. 현재 구축된 Clean Architecture 기반 위에서 사용자 시스템, 담벼락 관리, 지도 기능을 추가하는 것을 목표로 합니다.

### 🎯 설계 목표
- **확장성**: 새로운 기능 추가가 용이한 구조
- **유지보수성**: 명확한 관심사 분리와 의존성 관리
- **미래 준비성**: 서버 연동 시 최소한의 리팩토링
- **성능**: 오프라인 우선 접근법으로 빠른 사용자 경험
- **테스트 가능성**: 각 계층의 독립적 테스트 지원

---

## 🏗️ Architecture Overview

### Clean Architecture Layers

```
┌─────────────────────────────────────────────────────────┐
│                    Presentation Layer                    │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐     │
│  │    Blocs    │  │    Pages    │  │   Widgets   │     │
│  └─────────────┘  └─────────────┘  └─────────────┘     │
└─────────────────────────────────────────────────────────┘
                               │
┌─────────────────────────────────────────────────────────┐
│                     Domain Layer                        │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐     │
│  │  Entities   │  │ Use Cases   │  │ Repositories│     │
│  │             │  │             │  │ (Abstract)  │     │
│  └─────────────┘  └─────────────┘  └─────────────┘     │
└─────────────────────────────────────────────────────────┘
                               │
┌─────────────────────────────────────────────────────────┐
│                      Data Layer                         │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐     │
│  │ Repositories│  │ Data Sources│  │    Models   │     │
│  │(Concrete)   │  │             │  │             │     │
│  └─────────────┘  └─────────────┘  └─────────────┘     │
└─────────────────────────────────────────────────────────┘
                               │
┌─────────────────────────────────────────────────────────┐
│                  Infrastructure Layer                   │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐     │
│  │   Network   │  │   Storage   │  │  External   │     │
│  │             │  │             │  │  Services   │     │
│  └─────────────┘  └─────────────┘  └─────────────┘     │
└─────────────────────────────────────────────────────────┘
```

### Feature-Based Structure

```
lib/
├── app/                          # App-level configuration
├── core/                         # Shared utilities and constants
├── features/                     # Feature modules
│   ├── authentication/           # User authentication (Phase 1)
│   ├── user_management/          # User profile and settings
│   ├── graffiti_board/          # Existing graffiti functionality
│   ├── wall_management/         # Wall discovery and management
│   └── map_navigation/          # Map and location features
└── shared/                      # Cross-feature shared components
```

---

## 🎨 Domain Model Design

### Core Entities

#### 1. User Entity
```dart
class User extends Equatable {
  final String id;
  final String name;
  final String? email;
  final String? avatarPath;
  final DateTime createdAt;
  final UserPreferences preferences;
  final List<String> visitedWallIds;
  
  // Domain methods
  bool hasVisitedWall(String wallId) => visitedWallIds.contains(wallId);
  bool canAccessWall(Wall wall, Location currentLocation) {
    return hasVisitedWall(wall.id) || 
           wall.isWithinAccessRange(currentLocation);
  }
}

class UserPreferences extends ValueObject {
  final bool enableLocationTracking;
  final NotificationSettings notifications;
  final String preferredLanguage;
}
```

#### 2. Wall Entity
```dart
class Wall extends Equatable {
  final String id;
  final String name;
  final String description;
  final WallLocation location;
  final WallMetadata metadata;
  final List<String> graffitiNoteIds;
  final WallPermissions permissions;
  
  // Domain methods
  bool isWithinAccessRange(Location userLocation) {
    return location.distanceTo(userLocation) <= permissions.accessRadius;
  }
  
  bool canAddGraffiti(User user, Location userLocation) {
    return permissions.canAccess(user, userLocation) && 
           !metadata.isAtCapacity();
  }
}

class WallLocation extends ValueObject {
  final double latitude;
  final double longitude;
  final String address;
  
  double distanceTo(Location other) {
    // Haversine formula implementation
  }
}

class WallMetadata extends ValueObject {
  final DateTime createdAt;
  final int maxCapacity;
  final WallStatus status;
  final String? ownerId;
  
  bool isAtCapacity() => graffitiCount >= maxCapacity;
}
```

#### 3. Enhanced GraffitiNote Entity
```dart
class GraffitiNote extends Equatable {
  final String id;
  final String wallId;          // New: Association with wall
  final String userId;          // New: Association with user
  final GraffitiContent content;
  final GraffitiProperties properties;
  final GraffitiMetadata metadata;
  
  // Domain methods
  bool isOwnedBy(String userId) => this.userId == userId;
  bool isOverlapping(GraffitiNote other) {
    return properties.position.overlaps(other.properties.position);
  }
}

class GraffitiContent extends ValueObject {
  final String text;
  final String? imagePath;      // New: Image support
  final GraffitiSize size;      // New: Size constraints
  
  bool isValid() => text.trim().isNotEmpty && 
                   text.length <= size.maxCharacters;
}

enum GraffitiSize {
  small(Size(100, 80), 50),
  medium(Size(140, 100), 100),
  large(Size(200, 140), 200);
  
  const GraffitiSize(this.dimensions, this.maxCharacters);
  final Size dimensions;
  final int maxCharacters;
}
```

### Value Objects

#### Location
```dart
class Location extends ValueObject {
  final double latitude;
  final double longitude;
  final double? accuracy;
  final DateTime timestamp;
  
  // Distance calculation, validation, etc.
}
```

#### GraffitiPosition
```dart
class GraffitiPosition extends ValueObject {
  final Offset offset;
  final Size size;
  final int zIndex;
  
  bool overlaps(GraffitiPosition other) {
    // Collision detection logic
  }
}
```

---

## 🔧 Technical Architecture

### State Management Strategy

#### Bloc Pattern Implementation
```dart
// Wall Management Bloc
class WallBloc extends Bloc<WallEvent, WallState> {
  final GetNearbyWallsUseCase _getNearbyWallsUseCase;
  final SelectWallUseCase _selectWallUseCase;
  final LocationService _locationService;
  
  WallBloc({
    required GetNearbyWallsUseCase getNearbyWallsUseCase,
    required SelectWallUseCase selectWallUseCase,
    required LocationService locationService,
  }) : _getNearbyWallsUseCase = getNearbyWallsUseCase,
       _selectWallUseCase = selectWallUseCase,
       _locationService = locationService,
       super(WallInitial()) {
    on<LoadNearbyWalls>(_onLoadNearbyWalls);
    on<SelectWall>(_onSelectWall);
    on<UpdateUserLocation>(_onUpdateUserLocation);
  }
}

// Map Navigation Bloc
class MapBloc extends Bloc<MapEvent, MapState> {
  final GetWallMarkersUseCase _getWallMarkersUseCase;
  final LocationService _locationService;
  
  // Map-specific logic
}

// Enhanced Graffiti Bloc
class GraffitiBloc extends Bloc<GraffitiEvent, GraffitiState> {
  final GetWallGraffitiUseCase _getWallGraffitiUseCase;
  final CreateGraffitiUseCase _createGraffitiUseCase;
  final UpdateGraffitiUseCase _updateGraffitiUseCase;
  final ImageService _imageService;
  
  // Enhanced graffiti management
}
```

### Use Cases (Application Services)

#### Wall Management Use Cases
```dart
class GetNearbyWallsUseCase {
  final WallRepository _wallRepository;
  final LocationService _locationService;
  
  Future<Either<Failure, List<Wall>>> execute({
    Location? userLocation,
    double? radiusKm,
  }) async {
    try {
      final location = userLocation ?? await _locationService.getCurrentLocation();
      final walls = await _wallRepository.getNearbyWalls(
        location: location,
        radiusKm: radiusKm ?? 10.0,
      );
      return Right(walls);
    } catch (e) {
      return Left(LocationFailure(e.toString()));
    }
  }
}

class CanAccessWallUseCase {
  final WallRepository _wallRepository;
  final UserRepository _userRepository;
  
  Future<Either<Failure, bool>> execute({
    required String wallId,
    required String userId,
    required Location userLocation,
  }) async {
    try {
      final wall = await _wallRepository.getWallById(wallId);
      final user = await _userRepository.getUserById(userId);
      
      if (wall == null || user == null) {
        return Left(NotFoundFailure('Wall or user not found'));
      }
      
      final canAccess = user.canAccessWall(wall, userLocation);
      return Right(canAccess);
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
}
```

#### Enhanced Graffiti Use Cases
```dart
class CreateGraffitiWithImageUseCase {
  final GraffitiRepository _graffitiRepository;
  final ImageService _imageService;
  final UserRepository _userRepository;
  
  Future<Either<Failure, GraffitiNote>> execute({
    required String wallId,
    required String userId,
    required String text,
    required GraffitiSize size,
    required Offset position,
    String? imagePath,
  }) async {
    try {
      // Validate user can create graffiti
      final user = await _userRepository.getUserById(userId);
      if (user == null) return Left(NotFoundFailure('User not found'));
      
      // Process image if provided
      String? processedImagePath;
      if (imagePath != null) {
        processedImagePath = await _imageService.processAndStore(
          imagePath: imagePath,
          targetSize: size.dimensions,
        );
      }
      
      // Create graffiti note
      final graffiti = GraffitiNote(
        id: _generateId(),
        wallId: wallId,
        userId: userId,
        content: GraffitiContent(
          text: text,
          imagePath: processedImagePath,
          size: size,
        ),
        properties: GraffitiProperties(
          position: GraffitiPosition(
            offset: position,
            size: size.dimensions,
            zIndex: DateTime.now().millisecondsSinceEpoch,
          ),
          backgroundColor: _getRandomColor(),
          opacity: 0.9,
        ),
        metadata: GraffitiMetadata(
          createdAt: DateTime.now(),
          isVisible: true,
        ),
      );
      
      final result = await _graffitiRepository.create(graffiti);
      return Right(result);
    } catch (e) {
      return Left(CreationFailure(e.toString()));
    }
  }
}
```

### Repository Interfaces

#### Wall Repository
```dart
abstract class WallRepository {
  Future<List<Wall>> getNearbyWalls({
    required Location location,
    required double radiusKm,
  });
  
  Future<Wall?> getWallById(String id);
  
  Future<List<Wall>> getVisitedWalls(String userId);
  
  Future<List<Wall>> getWallsInBounds({
    required Location southWest,
    required Location northEast,
  });
  
  // Future server methods
  Future<Wall> createWall(Wall wall);
  Future<Wall> updateWall(Wall wall);
  Future<void> deleteWall(String id);
}
```

#### User Repository
```dart
abstract class UserRepository {
  Future<User?> getCurrentUser();
  Future<User?> getUserById(String id);
  Future<User> createUser(User user);
  Future<User> updateUser(User user);
  Future<void> markWallVisited(String userId, String wallId);
  
  // Authentication methods
  Future<User?> signIn(String email, String password);
  Future<User> signUp(String email, String password, String name);
  Future<void> signOut();
}
```

#### Enhanced Graffiti Repository
```dart
abstract class GraffitiRepository {
  Future<List<GraffitiNote>> getGraffitiByWall(String wallId);
  Future<List<GraffitiNote>> getGraffitiByUser(String userId);
  Future<GraffitiNote> create(GraffitiNote graffiti);
  Future<GraffitiNote> update(GraffitiNote graffiti);
  Future<void> delete(String id);
  
  // Batch operations for performance
  Future<List<GraffitiNote>> createBatch(List<GraffitiNote> graffitis);
  Future<void> syncWithServer();
}
```

### Service Interfaces

#### Location Service
```dart
abstract class LocationService {
  Future<Location> getCurrentLocation();
  Stream<Location> getLocationStream();
  Future<bool> requestPermissions();
  Future<bool> isLocationEnabled();
  double calculateDistance(Location from, Location to);
}
```

#### Image Service
```dart
abstract class ImageService {
  Future<String> processAndStore({
    required String imagePath,
    required Size targetSize,
  });
  
  Future<String> pickFromCamera();
  Future<String> pickFromGallery();
  Future<void> deleteImage(String path);
  Future<File> resizeImage(File image, Size targetSize);
  Future<File> compressImage(File image, int qualityPercent);
}
```

---

## 📊 Data Layer Implementation

### Local Storage Strategy

#### Database Schema (Hive/Isar)
```dart
// User Collection
@Collection()
class UserModel extends User {
  Id? id;
  
  @Index()
  late String email;
  
  @Backlink(to: 'userId')
  final graffitis = IsarLinks<GraffitiNoteModel>();
}

// Wall Collection
@Collection()
class WallModel extends Wall {
  Id? id;
  
  @Index(type: IndexType.geo)
  late double latitude;
  
  @Index(type: IndexType.geo)
  late double longitude;
  
  @Backlink(to: 'wallId')
  final graffitis = IsarLinks<GraffitiNoteModel>();
}

// Enhanced GraffitiNote Collection
@Collection()
class GraffitiNoteModel extends GraffitiNote {
  Id? id;
  
  @Index()
  late String wallId;
  
  @Index()
  late String userId;
  
  @Index()
  late DateTime createdAt;
  
  String? imagePath;
  
  final user = IsarLink<UserModel>();
  final wall = IsarLink<WallModel>();
}
```

#### Cache Strategy
```dart
class CacheManager {
  static const Duration CACHE_DURATION = Duration(hours: 1);
  
  final Map<String, CacheEntry> _cache = {};
  
  T? get<T>(String key) {
    final entry = _cache[key];
    if (entry != null && !entry.isExpired) {
      return entry.data as T;
    }
    return null;
  }
  
  void set<T>(String key, T data, {Duration? duration}) {
    _cache[key] = CacheEntry(
      data: data,
      expiresAt: DateTime.now().add(duration ?? CACHE_DURATION),
    );
  }
}
```

### Data Source Implementation

#### Local Data Sources
```dart
class LocalWallDataSource implements WallDataSource {
  final Isar _isar;
  final CacheManager _cache;
  
  @override
  Future<List<WallModel>> getNearbyWalls({
    required Location location,
    required double radiusKm,
  }) async {
    final cacheKey = 'nearby_walls_${location.latitude}_${location.longitude}_$radiusKm';
    
    // Check cache first
    final cached = _cache.get<List<WallModel>>(cacheKey);
    if (cached != null) return cached;
    
    // Query database
    final walls = await _isar.wallModels
        .where()
        .latitudeBetween(
          location.latitude - radiusKm / 111.0,
          location.latitude + radiusKm / 111.0,
        )
        .longitudeBetween(
          location.longitude - radiusKm / (111.0 * cos(location.latitude * pi / 180)),
          location.longitude + radiusKm / (111.0 * cos(location.latitude * pi / 180)),
        )
        .findAll();
    
    // Filter by exact distance and cache
    final filtered = walls.where((wall) {
      final distance = _calculateDistance(location, wall.location);
      return distance <= radiusKm;
    }).toList();
    
    _cache.set(cacheKey, filtered);
    return filtered;
  }
}
```

---

## 🌐 API Design for Future Server Integration

### RESTful API Specification

#### Authentication Endpoints
```yaml
# Authentication
POST /api/auth/signup
POST /api/auth/signin
POST /api/auth/refresh
POST /api/auth/signout

# User Management
GET    /api/users/me
PUT    /api/users/me
GET    /api/users/{id}
POST   /api/users/{id}/walls/{wallId}/visit
```

#### Wall Management Endpoints
```yaml
# Wall Discovery
GET    /api/walls/nearby?lat={lat}&lng={lng}&radius={km}
GET    /api/walls/search?q={query}
GET    /api/walls/{id}
POST   /api/walls
PUT    /api/walls/{id}
DELETE /api/walls/{id}

# Wall Access
POST   /api/walls/{id}/access-check
GET    /api/walls/{id}/graffitis
```

#### Graffiti Management Endpoints
```yaml
# Graffiti CRUD
GET    /api/graffitis?wallId={wallId}
POST   /api/graffitis
PUT    /api/graffitis/{id}
DELETE /api/graffitis/{id}

# Image Upload
POST   /api/graffitis/{id}/image
DELETE /api/graffitis/{id}/image
```

#### WebSocket Events for Real-time Updates
```yaml
# Subscribe to wall updates
SUBSCRIBE /walls/{wallId}/graffitis

# Real-time events
graffiti.created
graffiti.updated  
graffiti.deleted
wall.updated
user.joined_wall
user.left_wall
```

### Data Transfer Objects (DTOs)

```dart
// API Request/Response Models
class CreateGraffitiRequest {
  final String wallId;
  final String content;
  final String size;
  final PositionDto position;
  final String? imageBase64;
}

class GraffitiResponse {
  final String id;
  final String wallId;
  final String userId;
  final String content;
  final String? imageUrl;
  final PositionDto position;
  final DateTime createdAt;
  final UserSummaryDto user;
}

class WallSummaryResponse {
  final String id;
  final String name;
  final LocationDto location;
  final int graffitiCount;
  final bool canAccess;
  final double distanceKm;
}
```

### Synchronization Strategy
```dart
class SyncService {
  final ApiService _apiService;
  final LocalDatabase _localDb;
  
  Future<void> syncGraffitis() async {
    final lastSync = await _localDb.getLastSyncTime();
    final updates = await _apiService.getGraffitiUpdates(since: lastSync);
    
    await _localDb.transaction(() async {
      for (final update in updates) {
        switch (update.type) {
          case SyncUpdateType.created:
            await _localDb.insertGraffiti(update.graffiti);
            break;
          case SyncUpdateType.updated:
            await _localDb.updateGraffiti(update.graffiti);
            break;
          case SyncUpdateType.deleted:
            await _localDb.deleteGraffiti(update.graffitiId);
            break;
        }
      }
      await _localDb.setLastSyncTime(DateTime.now());
    });
  }
}
```

---

## 🚀 Implementation Strategy

### Phase 1: Data Foundation (2-3 days)

#### Day 1: Domain Layer Setup
- [ ] Create User, Wall, GraffitiNote entities
- [ ] Implement value objects (Location, GraffitiPosition, etc.)
- [ ] Define repository interfaces
- [ ] Set up domain services

#### Day 2: Data Layer Implementation
- [ ] Set up Isar database
- [ ] Implement local data sources
- [ ] Create repository implementations
- [ ] Add caching layer

#### Day 3: Use Cases and Testing
- [ ] Implement core use cases
- [ ] Add unit tests for domain logic
- [ ] Integration tests for repositories

### Phase 2: Wall Features Enhancement (4-5 days)

#### Days 1-2: Enhanced Graffiti System
- [ ] Implement size selection system
- [ ] Add image picker and processing
- [ ] Update graffiti creation flow
- [ ] Enhance graffiti display logic

#### Days 3-4: Wall Management
- [ ] Implement wall discovery logic
- [ ] Add access permission system
- [ ] Create wall list UI
- [ ] Update bottom toolbar

#### Day 5: Integration and Testing
- [ ] Integration testing
- [ ] Performance optimization
- [ ] UI/UX polish

### Phase 3: Map Integration (5-7 days)

#### Days 1-2: Location Services
- [ ] Implement location service
- [ ] Add permission handling
- [ ] Set up flutter_map integration

#### Days 3-4: Map UI and Navigation
- [ ] Create map screen with markers
- [ ] Implement wall selection flow
- [ ] Add distance calculation

#### Days 5-6: App Navigation Flow
- [ ] Update app entry point
- [ ] Implement navigation state management
- [ ] Add deep linking support

#### Day 7: Final Integration
- [ ] End-to-end testing
- [ ] Performance optimization
- [ ] Bug fixes and polish

---

## 📊 Performance Considerations

### Optimization Strategies

#### Database Performance
```dart
// Indexed queries for fast wall lookup
@Index(composite: [CompositeIndex(['latitude', 'longitude'])])
class WallModel {
  // Geographic indexing for nearby wall queries
}

// Lazy loading for large datasets
Future<List<GraffitiNote>> getWallGraffiti(String wallId, {
  int limit = 50,
  int offset = 0,
}) async {
  return await _isar.graffitiNoteModels
      .where()
      .wallIdEqualTo(wallId)
      .offset(offset)
      .limit(limit)
      .findAll();
}
```

#### Image Optimization
```dart
class ImageOptimizer {
  static const int MAX_WIDTH = 800;
  static const int MAX_HEIGHT = 600;
  static const int COMPRESSION_QUALITY = 85;
  
  Future<File> optimizeForDisplay(File original) async {
    final image = img.decodeImage(await original.readAsBytes())!;
    
    // Resize if too large
    final resized = img.copyResize(
      image,
      width: math.min(image.width, MAX_WIDTH),
      height: math.min(image.height, MAX_HEIGHT),
    );
    
    // Compress
    final compressed = img.encodeJpg(resized, quality: COMPRESSION_QUALITY);
    
    // Save optimized version
    final optimizedFile = File('${original.path}_optimized.jpg');
    await optimizedFile.writeAsBytes(compressed);
    
    return optimizedFile;
  }
}
```

#### Memory Management
- Implement image caching with size limits
- Use Flutter's `ListView.builder` for large lists
- Dispose of controllers and streams properly
- Implement pagination for graffiti lists

---

## 🧪 Testing Strategy

### Unit Tests
```dart
// Domain Entity Tests
class UserTest {
  group('User entity', () {
    test('canAccessWall returns true for visited walls', () {
      final user = User(visitedWallIds: ['wall1']);
      final wall = Wall(id: 'wall1');
      final location = Location(lat: 0, lng: 0);
      
      expect(user.canAccessWall(wall, location), isTrue);
    });
    
    test('canAccessWall returns true for nearby walls', () {
      final user = User(visitedWallIds: []);
      final wall = Wall(
        id: 'wall1',
        location: WallLocation(lat: 0, lng: 0),
        permissions: WallPermissions(accessRadius: 5.0),
      );
      final location = Location(lat: 0, lng: 0.01); // ~1km away
      
      expect(user.canAccessWall(wall, location), isTrue);
    });
  });
}

// Use Case Tests
class GetNearbyWallsUseCaseTest {
  group('GetNearbyWallsUseCase', () {
    late MockWallRepository mockRepository;
    late MockLocationService mockLocationService;
    late GetNearbyWallsUseCase useCase;
    
    setUp(() {
      mockRepository = MockWallRepository();
      mockLocationService = MockLocationService();
      useCase = GetNearbyWallsUseCase(mockRepository, mockLocationService);
    });
    
    test('returns nearby walls successfully', () async {
      // Arrange
      final location = Location(lat: 37.5665, lng: 126.9780); // Seoul
      final walls = [Wall(id: '1'), Wall(id: '2')];
      
      when(() => mockLocationService.getCurrentLocation())
          .thenAnswer((_) async => location);
      when(() => mockRepository.getNearbyWalls(
          location: location, radiusKm: 10.0))
          .thenAnswer((_) async => walls);
      
      // Act
      final result = await useCase.execute();
      
      // Assert
      expect(result.isRight(), isTrue);
      expect(result.getOrElse(() => []), equals(walls));
    });
  });
}
```

### Integration Tests
```dart
// Repository Integration Tests
class WallRepositoryIntegrationTest {
  group('WallRepository Integration', () {
    late Isar isar;
    late WallRepositoryImpl repository;
    
    setUp(() async {
      isar = await Isar.open([WallModelSchema]);
      repository = WallRepositoryImpl(LocalWallDataSource(isar));
    });
    
    tearDown(() async {
      await isar.close(deleteFromDisk: true);
    });
    
    test('can save and retrieve walls', () async {
      // Arrange
      final wall = Wall(
        id: 'test_wall',
        name: 'Test Wall',
        location: WallLocation(lat: 37.5665, lng: 126.9780),
      );
      
      // Act
      await repository.createWall(wall);
      final retrieved = await repository.getWallById('test_wall');
      
      // Assert
      expect(retrieved, equals(wall));
    });
  });
}
```

### Widget Tests
```dart
// Graffiti Widget Tests
class GraffitiNoteWidgetTest {
  group('GraffitiNoteWidget', () {
    testWidgets('displays graffiti content correctly', (tester) async {
      // Arrange
      final graffiti = GraffitiNote(
        id: '1',
        content: GraffitiContent(text: 'Test content'),
      );
      
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: GraffitiNoteWidget(graffiti: graffiti),
        ),
      );
      
      // Assert
      expect(find.text('Test content'), findsOneWidget);
    });
  });
}
```

---

## 📱 UI/UX Implementation Details

### Enhanced Graffiti Creation Flow

#### Size Selection Dialog
```dart
class GraffitiSizeSelector extends StatelessWidget {
  final Function(GraffitiSize) onSizeSelected;
  
  Widget build(BuildContext context) {
    return Column(
      children: GraffitiSize.values.map((size) {
        return ListTile(
          leading: Container(
            width: size.dimensions.width * 0.3,
            height: size.dimensions.height * 0.3,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          title: Text(size.name.toUpperCase()),
          subtitle: Text('최대 ${size.maxCharacters}자'),
          onTap: () => onSizeSelected(size),
        );
      }).toList(),
    );
  }
}
```

#### Image Integration
```dart
class GraffitiImagePicker extends StatefulWidget {
  final Function(String?) onImageSelected;
  
  State<GraffitiImagePicker> createState() => _GraffitiImagePickerState();
}

class _GraffitiImagePickerState extends State<GraffitiImagePicker> {
  String? _selectedImagePath;
  
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_selectedImagePath != null)
          Container(
            height: 200,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: FileImage(File(_selectedImagePath!)),
                fit: BoxFit.cover,
              ),
            ),
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton.icon(
              onPressed: _pickFromCamera,
              icon: Icon(Icons.camera_alt),
              label: Text('카메라'),
            ),
            ElevatedButton.icon(
              onPressed: _pickFromGallery,
              icon: Icon(Icons.photo_library),
              label: Text('갤러리'),
            ),
            if (_selectedImagePath != null)
              ElevatedButton.icon(
                onPressed: _removeImage,
                icon: Icon(Icons.delete),
                label: Text('제거'),
              ),
          ],
        ),
      ],
    );
  }
}
```

### Map Screen Implementation

#### Map with Wall Markers
```dart
class MapScreen extends StatefulWidget {
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  late MapBloc _mapBloc;
  
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<MapBloc, MapState>(
        builder: (context, state) {
          return FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              center: state.userLocation?.toLatLng() ?? seoul_center,
              zoom: 13.0,
              onTap: (tapPosition, point) {
                // Handle map tap
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.watdagam',
              ),
              MarkerLayer(
                markers: state.walls.map((wall) {
                  return Marker(
                    point: wall.location.toLatLng(),
                    builder: (context) => WallMarker(
                      wall: wall,
                      canAccess: wall.canAccess(state.currentUser, state.userLocation),
                      onTap: () => _onWallSelected(wall),
                    ),
                  );
                }).toList(),
              ),
              if (state.userLocation != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: state.userLocation!.toLatLng(),
                      builder: (context) => UserLocationMarker(),
                    ),
                  ],
                ),
            ],
          );
        },
      ),
      bottomSheet: WallListBottomSheet(),
    );
  }
}
```

#### Wall List Bottom Sheet
```dart
class WallListBottomSheet extends StatelessWidget {
  Widget build(BuildContext context) {
    return BlocBuilder<WallBloc, WallState>(
      builder: (context, state) {
        return DraggableScrollableSheet(
          initialChildSize: 0.3,
          minChildSize: 0.1,
          maxChildSize: 0.8,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  // Recent walls slider
                  if (state.recentWalls.isNotEmpty) ...[
                    SectionHeader(title: '최근 방문한 담벼락'),
                    RecentWallsSlider(walls: state.recentWalls),
                  ],
                  
                  // Filter buttons
                  FilterButtons(
                    selectedFilter: state.selectedFilter,
                    onFilterChanged: (filter) {
                      context.read<WallBloc>().add(FilterWalls(filter));
                    },
                  ),
                  
                  // Wall list
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: state.filteredWalls.length,
                      itemBuilder: (context, index) {
                        final wall = state.filteredWalls[index];
                        return WallListTile(
                          wall: wall,
                          onTap: () => _navigateToWall(context, wall),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
```

---

## 🔒 Security Considerations

### Data Protection
```dart
class SecurityService {
  // Encrypt sensitive local data
  Future<String> encryptSensitiveData(String data) async {
    final key = await _getEncryptionKey();
    final encrypter = Encrypter(AES(key));
    return encrypter.encrypt(data).base64;
  }
  
  // Validate image uploads
  bool isValidImage(File image) {
    final allowedExtensions = ['.jpg', '.jpeg', '.png'];
    final extension = path.extension(image.path).toLowerCase();
    return allowedExtensions.contains(extension) && 
           image.lengthSync() < MAX_IMAGE_SIZE;
  }
  
  // Sanitize user input
  String sanitizeUserInput(String input) {
    return input
        .replaceAll(RegExp(r'<[^>]*>'), '') // Remove HTML tags
        .replaceAll(RegExp(r'[^\w\s가-힣ㄱ-ㅎㅏ-ㅣ]'), '') // Allow only safe characters
        .trim();
  }
}
```

### Location Privacy
```dart
class LocationPrivacyService {
  // Add noise to location for privacy
  Location obfuscateLocation(Location original, {double radiusMeters = 100}) {
    final random = Random();
    final angle = random.nextDouble() * 2 * pi;
    final distance = random.nextDouble() * radiusMeters;
    
    final deltaLat = distance * cos(angle) / 111000;
    final deltaLng = distance * sin(angle) / (111000 * cos(original.latitude * pi / 180));
    
    return Location(
      latitude: original.latitude + deltaLat,
      longitude: original.longitude + deltaLng,
    );
  }
}
```

---

## 🌍 Internationalization Readiness

### Multi-language Support Structure
```dart
// lib/core/localization/app_localizations.dart
class AppLocalizations {
  static const List<Locale> supportedLocales = [
    Locale('ko', 'KR'),
    Locale('en', 'US'),
  ];
  
  static const LocalizationsDelegate<AppLocalizations> delegate = 
      _AppLocalizationsDelegate();
  
  String get addGraffiti => _translate('add_graffiti');
  String get selectSize => _translate('select_size');
  String get chooseImage => _translate('choose_image');
  String get nearbyWalls => _translate('nearby_walls');
  
  String _translate(String key) {
    return _translations[key] ?? key;
  }
}

// assets/translations/ko.json
{
  "add_graffiti": "낙서 추가",
  "select_size": "크기 선택",
  "choose_image": "이미지 선택",
  "nearby_walls": "근처 담벼락"
}

// assets/translations/en.json  
{
  "add_graffiti": "Add Graffiti",
  "select_size": "Select Size", 
  "choose_image": "Choose Image",
  "nearby_walls": "Nearby Walls"
}
```

---

## 📈 Migration Path and Deployment

### Database Migration Strategy
```dart
class DatabaseMigration {
  static const int CURRENT_VERSION = 2;
  
  static Future<void> migrate(Isar isar, int oldVersion) async {
    switch (oldVersion) {
      case 1:
        await _migrateFrom1To2(isar);
        break;
      // Add future migrations here
    }
  }
  
  static Future<void> _migrateFrom1To2(Isar isar) async {
    // Add user_id and wall_id to existing graffiti notes
    final graffitis = await isar.graffitiNoteModels.where().findAll();
    
    await isar.writeTxn(() async {
      for (final graffiti in graffitis) {
        graffiti.userId = 'default_user';
        graffiti.wallId = 'default_wall';
        await isar.graffitiNoteModels.put(graffiti);
      }
    });
  }
}
```

### Deployment Checklist
- [ ] Update pubspec.yaml with new dependencies
- [ ] Run database migrations
- [ ] Test on multiple device sizes
- [ ] Performance testing with large datasets
- [ ] Accessibility testing
- [ ] Update app store descriptions
- [ ] Prepare rollback plan

---

## 🎯 Success Metrics

### Technical Metrics
- **App Launch Time**: < 3 seconds
- **Database Query Performance**: < 100ms for nearby walls
- **Image Processing Time**: < 2 seconds
- **Memory Usage**: < 200MB peak
- **Crash Rate**: < 0.1%

### User Experience Metrics
- **Graffiti Creation Success Rate**: > 95%
- **Location Permission Grant Rate**: > 80%
- **Wall Discovery Time**: < 10 seconds
- **User Retention (Day 7)**: > 60%

### Business Metrics
- **Daily Active Users**: Growth trajectory
- **Graffiti per User per Session**: > 2
- **Wall Visit Rate**: > 70% of discovered walls
- **Feature Adoption Rate**: Size selection > 80%, Image upload > 40%

---

## 📚 Additional Resources

### Recommended Reading
- [Clean Architecture by Uncle Bob](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Flutter Bloc Pattern Documentation](https://bloclibrary.dev/)
- [Effective Dart Style Guide](https://dart.dev/guides/language/effective-dart)

### External Dependencies Documentation
- [flutter_map Documentation](https://docs.fleaflet.dev/)
- [image_picker Documentation](https://pub.dev/packages/image_picker)
- [Isar Database Documentation](https://isar.dev/)
- [get_it Dependency Injection](https://pub.dev/packages/get_it)

---

**문서 버전**: 1.0  
**최종 업데이트**: 2025-01-26  
**다음 리뷰 예정**: Phase 1 완료 후

이 설계 문서는 개발 진행에 따라 지속적으로 업데이트되며, 각 Phase 완료 후 회고를 통해 다음 단계를 최적화할 예정입니다.