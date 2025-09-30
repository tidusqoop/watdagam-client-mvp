import 'package:flutter/material.dart';
import '../../../../shared/domain/value_objects/location.dart';
import '../../domain/entities/wall.dart';
import '../../../../utils/time_utils.dart';

/// Dialog displaying detailed information about a wall
class WallInfoDialog extends StatelessWidget {
  final Wall wall;
  final Location? userLocation;

  const WallInfoDialog({
    super.key,
    required this.wall,
    this.userLocation,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final distance = userLocation != null
        ? wall.distanceToUser(userLocation!)
        : null;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _getWallColor(wall),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _getWallIcon(wall),
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              wall.name,
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              wall.description,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Status badges
                  Row(
                    children: [
                      _buildStatusBadge(
                        _getStatusText(wall),
                        _getStatusColor(wall),
                      ),
                      const SizedBox(width: 8),
                      if (distance != null)
                        _buildStatusBadge(
                          _formatDistance(distance),
                          _getDistanceColor(distance),
                        ),
                    ],
                  ),
                ],
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Location info
                  _buildInfoSection(
                    icon: Icons.location_on,
                    title: '위치',
                    content: wall.location.address,
                  ),

                  const SizedBox(height: 16),

                  // Statistics
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.edit,
                          label: '낙서 수',
                          value: '${wall.graffitiCount}개',
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.storage,
                          label: '사용률',
                          value: '${(wall.capacityUtilization * 100).toInt()}%',
                          color: _getCapacityColor(wall.capacityUtilization),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Creation info
                  _buildInfoSection(
                    icon: Icons.schedule,
                    title: '생성 시간',
                    content: TimeUtils.getRelativeTime(wall.metadata.createdAt),
                  ),

                  if (wall.metadata.hasOwner) ...[
                    const SizedBox(height: 16),
                    _buildInfoSection(
                      icon: Icons.person,
                      title: '소유자',
                      content: wall.metadata.ownerId ?? '알 수 없음',
                    ),
                  ],

                  const SizedBox(height: 16),

                  // Access permissions
                  _buildInfoSection(
                    icon: Icons.security,
                    title: '접근 권한',
                    content: _getAccessDescription(wall),
                  ),

                  const SizedBox(height: 20),

                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('닫기'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _canAccessWall(wall) 
                              ? () {
                                  Navigator.of(context).pop();
                                  // Navigate to wall action would be handled by parent
                                }
                              : null,
                          child: Text(_canAccessWall(wall) ? '입장하기' : '접근 불가'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildInfoSection({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: Colors.grey.shade600,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                content,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusText(Wall wall) {
    if (!wall.isActive) return '비활성';
    if (wall.isAtCapacity) return '가득참';
    if (wall.isNearlyFull) return '거의 가득참';
    if (wall.isNew) return '새로운 벽';
    return '활성';
  }

  String _getAccessDescription(Wall wall) {
    if (wall.permissions.isPublic) {
      if (wall.permissions.isProximityBased) {
        return '공개 벽 (${wall.permissions.accessRadius.toStringAsFixed(1)}km 이내에서 접근 가능)';
      }
      return '공개 벽 (누구나 접근 가능)';
    } else {
      return '비공개 벽 (소유자만 접근 가능)';
    }
  }

  bool _canAccessWall(Wall wall) {
    if (userLocation == null) return true; // Allow access for demo
    // Mock user access check
    return wall.canAccess(MockUser(), userLocation!);
  }

  Color _getWallColor(Wall wall) {
    if (!wall.isActive) return Colors.grey;
    if (wall.isAtCapacity) return Colors.red;
    if (wall.isNearlyFull) return Colors.orange;
    if (wall.isNew) return Colors.green;
    return Colors.blue;
  }

  IconData _getWallIcon(Wall wall) {
    if (!wall.isActive) return Icons.location_off;
    if (wall.isAtCapacity) return Icons.block;
    if (wall.isPrivate) return Icons.lock;
    return Icons.location_city;
  }

  Color _getStatusColor(Wall wall) {
    return _getWallColor(wall);
  }

  Color _getDistanceColor(double distance) {
    if (distance < 0.5) return Colors.green;
    if (distance < 2.0) return Colors.orange;
    return Colors.red;
  }

  Color _getCapacityColor(double utilization) {
    if (utilization < 0.5) return Colors.green;
    if (utilization < 0.8) return Colors.orange;
    return Colors.red;
  }

  String _formatDistance(double distance) {
    if (distance < 1.0) {
      return '${(distance * 1000).toInt()}m';
    } else {
      return '${distance.toStringAsFixed(1)}km';
    }
  }
}

// Temporary mock class
class MockUser {
  String get id => 'mock_user';
  List<String> get visitedWallIds => [];
  
  bool hasVisitedWall(String wallId) => visitedWallIds.contains(wallId);
}