import 'package:flutter/material.dart';
import '../../domain/entities/wall.dart';
import '../../../../utils/time_utils.dart';

/// Horizontal slider showing recently visited or created walls
class RecentWallsSlider extends StatelessWidget {
  final List<Wall>? walls;
  final Function(String wallId)? onWallTapped;

  const RecentWallsSlider({
    super.key,
    this.walls,
    this.onWallTapped,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final recentWalls = walls ?? _getMockRecentWalls();

    if (recentWalls.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            '최근 방문한 담벼락',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 140,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: recentWalls.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final wall = recentWalls[index];
              return _RecentWallCard(
                wall: wall,
                onTap: () => onWallTapped?.call(wall.id),
              );
            },
          ),
        ),
      ],
    );
  }

  List<Wall> _getMockRecentWalls() {
    // Mock recent walls - replace with actual data
    return [
      Wall.createPublic(
        id: 'recent_1',
        name: '홍대 자유의 벽',
        description: '예술가들의 자유로운 표현 공간',
        location: WallLocation(
          latitude: 37.5563,
          longitude: 126.9229,
          address: '서울특별시 마포구 홍대 앞',
        ),
      ),
      Wall.createPublic(
        id: 'recent_2',
        name: '강남역 트렌드 월',
        description: '젊은이들의 핫한 소통 공간',
        location: WallLocation(
          latitude: 37.4979,
          longitude: 127.0276,
          address: '서울특별시 강남구 강남역',
        ),
      ),
      Wall.createPublic(
        id: 'recent_3',
        name: '이태원 글로벌 월',
        description: '다양한 문화가 만나는 국제적인 공간',
        location: WallLocation(
          latitude: 37.5349,
          longitude: 126.9945,
          address: '서울특별시 용산구 이태원동',
        ),
      ),
    ];
  }
}

class _RecentWallCard extends StatelessWidget {
  final Wall wall;
  final VoidCallback? onTap;

  const _RecentWallCard({
    required this.wall,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: 200,
      child: Card(
        elevation: 4,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header image placeholder
              Container(
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _getWallColor(wall),
                      _getWallColor(wall).withOpacity(0.7),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  children: [
                    // Pattern overlay
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _GridPatternPainter(
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                    ),
                    // Wall icon
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.location_city,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Wall name
                      Text(
                        wall.name,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 4),

                      // Stats row
                      Row(
                        children: [
                          Icon(
                            Icons.edit,
                            size: 14,
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${wall.graffitiCount}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                          
                          const SizedBox(width: 12),
                          
                          Icon(
                            Icons.schedule,
                            size: 14,
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              TimeUtils.getRelativeTime(wall.metadata.createdAt),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(0.6),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),

                      const Spacer(),

                      // Access indicator
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.touch_app,
                              size: 12,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '다시 방문',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getWallColor(Wall wall) {
    if (!wall.isActive) return Colors.grey;
    if (wall.isAtCapacity) return Colors.red;
    if (wall.isNearlyFull) return Colors.orange;
    if (wall.isNew) return Colors.green;
    return Colors.blue;
  }
}

class _GridPatternPainter extends CustomPainter {
  final Color color;
  final double gridSize;

  _GridPatternPainter({
    required this.color,
    this.gridSize = 8.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    // Draw grid pattern
    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }

    for (double y = 0; y < size.height; y += gridSize) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Import needed for WallLocation
import '../../domain/value_objects/wall_location.dart';