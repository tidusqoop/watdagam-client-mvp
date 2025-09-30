import 'package:flutter/material.dart';
import '../../../../shared/domain/value_objects/location.dart';
import '../../domain/entities/wall.dart';
import '../../../../utils/time_utils.dart';

/// Individual tile widget for displaying wall information in a list
class WallListTile extends StatelessWidget {
  final Wall wall;
  final Location? userLocation;
  final VoidCallback? onTap;

  const WallListTile({
    super.key,
    required this.wall,
    this.userLocation,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final distance = userLocation != null
        ? wall.distanceToUser(userLocation!)
        : null;

    final canAccess = userLocation != null
        ? wall.canAccess(MockUser(), userLocation!) // TODO: Replace with actual user
        : false;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        onTap: canAccess ? onTap : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Wall icon with status indicator
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: _getWallColor(wall),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getWallIcon(wall),
                      color: Colors.white,
                      size: 24,
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Wall info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Wall name and distance
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                wall.name,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (distance != null) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _getDistanceColor(distance),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  _formatDistance(distance),
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),

                        const SizedBox(height: 4),

                        // Description
                        Text(
                          wall.description,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),

                        const SizedBox(height: 8),

                        // Location
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 16,
                              color: theme.colorScheme.onSurface.withOpacity(0.5),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                wall.location.address,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Statistics row
              Row(
                children: [
                  // Graffiti count
                  _buildStatChip(
                    icon: Icons.edit,
                    label: '${wall.graffitiCount}개',
                    color: theme.colorScheme.primary,
                  ),

                  const SizedBox(width: 8),

                  // Capacity indicator
                  _buildStatChip(
                    icon: Icons.storage,
                    label: '${(wall.capacityUtilization * 100).toInt()}%',
                    color: _getCapacityColor(wall.capacityUtilization),
                  ),

                  const SizedBox(width: 8),

                  // Creation time
                  _buildStatChip(
                    icon: Icons.schedule,
                    label: TimeUtils.getRelativeTime(wall.metadata.createdAt),
                    color: theme.colorScheme.outline,
                  ),

                  const Spacer(),

                  // Access indicator
                  if (!canAccess) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: theme.colorScheme.error.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.lock,
                            size: 14,
                            color: theme.colorScheme.error,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '접근 불가',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.error,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: theme.colorScheme.primary.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.touch_app,
                            size: 14,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '입장 가능',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
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

  IconData _getWallIcon(Wall wall) {
    if (!wall.isActive) return Icons.location_off;
    if (wall.isAtCapacity) return Icons.block;
    if (wall.isPrivate) return Icons.lock;
    return Icons.location_city;
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

// Temporary mock class - replace with actual User entity
class MockUser {
  String get id => 'mock_user';
  List<String> get visitedWallIds => [];
  
  bool hasVisitedWall(String wallId) => visitedWallIds.contains(wallId);
}