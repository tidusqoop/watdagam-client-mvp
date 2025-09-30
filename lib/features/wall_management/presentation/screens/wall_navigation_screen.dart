import 'package:flutter/material.dart';
import '../../../../shared/domain/value_objects/location.dart';
import '../../../graffiti_board/presentation/screens/graffiti_wall_screen.dart';
import '../../../graffiti_board/data/repositories/graffiti_repository.dart';
import '../../domain/entities/wall.dart';
import 'wall_list_screen.dart';
import '../widgets/wall_info_dialog.dart';

/// Main navigation screen that handles wall selection and graffiti wall display
class WallNavigationScreen extends StatefulWidget {
  final GraffitiRepository graffitiRepository;
  final Location? userLocation;

  const WallNavigationScreen({
    super.key,
    required this.graffitiRepository,
    this.userLocation,
  });

  @override
  State<WallNavigationScreen> createState() => _WallNavigationScreenState();
}

class _WallNavigationScreenState extends State<WallNavigationScreen> {
  Wall? _selectedWall;
  bool _showWallList = false;

  @override
  void initState() {
    super.initState();
    _initializeWithDefaultWall();
  }

  /// Initialize with a default wall for demonstration
  void _initializeWithDefaultWall() {
    // Start with wall list to let user choose
    setState(() {
      _showWallList = true;
    });
  }

  /// Handle wall selection from the wall list
  void _onWallSelected(String wallId) {
    // Mock wall selection - replace with actual wall retrieval
    final selectedWall = _getMockWallById(wallId);
    
    if (selectedWall != null) {
      // Check if user can access this wall
      final canAccess = widget.userLocation != null
          ? selectedWall.canAccess(MockUser(), widget.userLocation!)
          : true; // Allow access if no location (for demo)

      if (canAccess) {
        setState(() {
          _selectedWall = selectedWall;
          _showWallList = false;
        });

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${selectedWall.name}에 입장했습니다'),
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        // Show access denied message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${selectedWall.name}에 접근할 수 없습니다. 더 가까이 가서 시도해주세요.'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  /// Handle wall list navigation
  void _onShowWallList() {
    setState(() {
      _showWallList = true;
    });
  }

  /// Handle wall info display
  void _onShowWallInfo() {
    if (_selectedWall != null) {
      showDialog(
        context: context,
        builder: (context) => WallInfoDialog(
          wall: _selectedWall!,
          userLocation: widget.userLocation,
        ),
      );
    }
  }

  /// Mock wall data - replace with actual repository call
  Wall? _getMockWallById(String wallId) {
    final mockWalls = {
      'wall_1': Wall.createPublic(
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
      'wall_2': Wall.createPublic(
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
      'wall_3': Wall.createPublic(
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
      'wall_4': Wall.createPublic(
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
      'wall_5': Wall.createPublic(
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
    };

    return mockWalls[wallId];
  }

  @override
  Widget build(BuildContext context) {
    // Show wall list
    if (_showWallList) {
      return WallListScreen(
        userLocation: widget.userLocation,
        onWallSelected: _onWallSelected,
      );
    }

    // Show graffiti wall with enhanced toolbar
    if (_selectedWall != null) {
      return _buildGraffitiWallWithEnhancedToolbar();
    }

    // Fallback: show wall list
    return WallListScreen(
      userLocation: widget.userLocation,
      onWallSelected: _onWallSelected,
    );
  }

  Widget _buildGraffitiWallWithEnhancedToolbar() {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: _onShowWallList,
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _selectedWall!.name,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '낙서 ${_selectedWall!.graffitiCount}개 • ${_selectedWall!.location.address}',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          // Wall info button
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.black),
            onPressed: _onShowWallInfo,
            tooltip: '담벼락 정보',
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onPressed: () {
              _showWallMenu();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Graffiti wall screen
          GraffitiWallScreen(
            repository: widget.graffitiRepository,
            selectedWall: _selectedWall,
          ),

          // Enhanced bottom toolbar overlay
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildEnhancedBottomToolbar(),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedBottomToolbar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            offset: const Offset(0, -2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Wall info banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.location_city,
                  size: 16,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _selectedWall!.name,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                GestureDetector(
                  onTap: _onShowWallInfo,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      Icons.info_outline,
                      size: 16,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Main toolbar with wall navigation
          Container(
            height: 80,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                // Wall list button
                _buildToolButton(
                  Icons.location_on,
                  Theme.of(context).colorScheme.primary,
                  _onShowWallList,
                  tooltip: '담벼락 목록',
                ),
                
                const SizedBox(width: 12),

                // Graffiti wall controls would go here
                // (This would be handled by the embedded GraffitiWallScreen)
                Expanded(
                  child: Center(
                    child: Text(
                      '낙서 도구',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolButton(
    IconData icon,
    Color iconColor,
    VoidCallback onPressed, {
    String? tooltip,
  }) {
    Widget button = GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              offset: const Offset(0, 2),
              blurRadius: 4,
            ),
          ],
        ),
        child: Icon(icon, color: iconColor, size: 24),
      ),
    );

    if (tooltip != null) {
      return Tooltip(
        message: tooltip,
        child: button,
      );
    }

    return button;
  }

  void _showWallMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('담벼락 정보'),
              onTap: () {
                Navigator.pop(context);
                _onShowWallInfo();
              },
            ),
            ListTile(
              leading: const Icon(Icons.list),
              title: const Text('다른 담벼락 보기'),
              onTap: () {
                Navigator.pop(context);
                _onShowWallList();
              },
            ),
            ListTile(
              leading: const Icon(Icons.refresh),
              title: const Text('새로고침'),
              onTap: () {
                Navigator.pop(context);
                // Trigger refresh in graffiti wall
              },
            ),
          ],
        ),
      ),
    );
  }
}

// Temporary mock user class
class MockUser {
  String get id => 'mock_user';
  List<String> get visitedWallIds => [];
  
  bool hasVisitedWall(String wallId) => visitedWallIds.contains(wallId);
}

// Import for WallLocation
import '../../domain/value_objects/wall_location.dart';