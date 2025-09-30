import 'package:flutter/material.dart';
import '../../../../shared/domain/value_objects/location.dart';
import '../../domain/entities/wall.dart';
import '../../data/datasources/local_wall_data_source.dart';
import '../../data/repositories/wall_repository_impl.dart';
import '../../../../shared/data/cache/cache_manager.dart';
import 'wall_list_tile.dart';
import '../screens/wall_list_screen.dart';

/// Widget displaying a filtered list of walls with loading states
class WallListView extends StatefulWidget {
  final WallFilter filter;
  final String searchQuery;
  final Location? userLocation;
  final Function(String wallId)? onWallSelected;

  const WallListView({
    super.key,
    required this.filter,
    required this.searchQuery,
    this.userLocation,
    this.onWallSelected,
  });

  @override
  State<WallListView> createState() => _WallListViewState();
}

class _WallListViewState extends State<WallListView> {
  List<Wall> _walls = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadWalls();
  }

  @override
  void didUpdateWidget(WallListView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.filter != widget.filter ||
        oldWidget.searchQuery != widget.searchQuery ||
        oldWidget.userLocation != widget.userLocation) {
      _loadWalls();
    }
  }

  Future<void> _loadWalls() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // TODO: Replace with proper dependency injection
      final repository = WallRepositoryImpl(
        dataSource: LocalWallDataSource(
          isar: MockIsar(), // Placeholder
          cache: CacheManager(),
        ),
      );

      List<Wall> walls;

      if (widget.searchQuery.isNotEmpty) {
        walls = await _searchWalls(repository, widget.searchQuery);
      } else {
        walls = await _getFilteredWalls(repository);
      }

      setState(() {
        _walls = walls;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<List<Wall>> _searchWalls(repository, String query) async {
    // Mock implementation - replace with actual repository call
    return _generateMockWalls().where((wall) {
      return wall.name.toLowerCase().contains(query.toLowerCase()) ||
          wall.description.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  Future<List<Wall>> _getFilteredWalls(repository) async {
    switch (widget.filter) {
      case WallFilter.nearby:
        if (widget.userLocation != null) {
          // Mock implementation - replace with actual repository call
          final allWalls = _generateMockWalls();
          allWalls.sort((a, b) {
            final distanceA = a.distanceToUser(widget.userLocation!);
            final distanceB = b.distanceToUser(widget.userLocation!);
            return distanceA.compareTo(distanceB);
          });
          return allWalls.take(20).toList();
        }
        return _generateMockWalls().take(10).toList();

      case WallFilter.recent:
        final walls = _generateMockWalls();
        walls.sort((a, b) => b.metadata.createdAt.compareTo(a.metadata.createdAt));
        return walls.take(20).toList();

      case WallFilter.popular:
        final walls = _generateMockWalls();
        walls.sort((a, b) => b.graffitiCount.compareTo(a.graffitiCount));
        return walls.take(20).toList();

      case WallFilter.visited:
        // Mock implementation - would need user context
        return _generateMockWalls().take(5).toList();

      case WallFilter.all:
        return _generateMockWalls();
    }
  }

  // Mock data generator - replace with actual data source
  List<Wall> _generateMockWalls() {
    return [
      Wall.createPublic(
        id: 'wall_1',
        name: '홍대 자유의 벽',
        description: '홍대 앞 예술가들의 자유로운 표현 공간',
        location: WallLocation(
          latitude: 37.5563,
          longitude: 126.9229,
          address: '서울특별시 마포구 홍대 앞',
        ),
        maxCapacity: 150,
      ),
      Wall.createPublic(
        id: 'wall_2',
        name: '이태원 글로벌 월',
        description: '다양한 문화가 만나는 국제적인 공간',
        location: WallLocation(
          latitude: 37.5349,
          longitude: 126.9945,
          address: '서울특별시 용산구 이태원동',
        ),
        maxCapacity: 200,
      ),
      Wall.createPublic(
        id: 'wall_3',
        name: '강남역 트렌드 월',
        description: '젊은이들의 핫한 소통 공간',
        location: WallLocation(
          latitude: 37.4979,
          longitude: 127.0276,
          address: '서울특별시 강남구 강남역',
        ),
        maxCapacity: 100,
      ),
      Wall.createPublic(
        id: 'wall_4',
        name: '부산 해운대 바다 벽',
        description: '바다를 바라보며 추억을 남기는 곳',
        location: WallLocation(
          latitude: 35.1584,
          longitude: 129.1604,
          address: '부산광역시 해운대구 해운대해변로',
        ),
        maxCapacity: 120,
      ),
      Wall.createPublic(
        id: 'wall_5',
        name: '제주 올레길 인증 벽',
        description: '제주 올레길을 완주한 사람들의 인증 공간',
        location: WallLocation(
          latitude: 33.3846,
          longitude: 126.5534,
          address: '제주특별자치도 제주시',
        ),
        maxCapacity: 80,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('담벼락을 불러오는 중...'),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              '담벼락을 불러올 수 없습니다',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadWalls,
              child: const Text('다시 시도'),
            ),
          ],
        ),
      );
    }

    if (_walls.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.location_off,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              widget.searchQuery.isNotEmpty
                  ? '검색 결과가 없습니다'
                  : '담벼락이 없습니다',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              widget.searchQuery.isNotEmpty
                  ? '"${widget.searchQuery}"에 대한 검색 결과가 없습니다'
                  : '이 지역에는 담벼락이 없습니다',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadWalls,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _walls.length,
        itemBuilder: (context, index) {
          final wall = _walls[index];
          return WallListTile(
            wall: wall,
            userLocation: widget.userLocation,
            onTap: () {
              widget.onWallSelected?.call(wall.id);
            },
          );
        },
      ),
    );
  }
}

// Temporary mock class - replace with actual Isar dependency
class MockIsar {
  // Mock implementation
}