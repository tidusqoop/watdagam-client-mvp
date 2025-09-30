import 'package:flutter/material.dart';
import '../screens/wall_list_screen.dart';

/// Horizontal scrollable filter buttons for wall list
class WallFilterButtons extends StatelessWidget {
  final WallFilter selectedFilter;
  final Function(WallFilter) onFilterChanged;

  const WallFilterButtons({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: WallFilter.values.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = WallFilter.values[index];
          final isSelected = selectedFilter == filter;

          return FilterChip(
            label: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _getFilterIcon(filter),
                  size: 18,
                  color: isSelected 
                      ? theme.colorScheme.onPrimary
                      : theme.colorScheme.onSurface,
                ),
                const SizedBox(width: 6),
                Text(
                  filter.displayName,
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected 
                        ? theme.colorScheme.onPrimary
                        : theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            selected: isSelected,
            onSelected: (selected) {
              if (selected) {
                onFilterChanged(filter);
              }
            },
            backgroundColor: theme.colorScheme.surface,
            selectedColor: theme.colorScheme.primary,
            checkmarkColor: theme.colorScheme.onPrimary,
            side: BorderSide(
              color: isSelected 
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outline.withOpacity(0.3),
              width: isSelected ? 2 : 1,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          );
        },
      ),
    );
  }

  IconData _getFilterIcon(WallFilter filter) {
    switch (filter) {
      case WallFilter.nearby:
        return Icons.near_me;
      case WallFilter.recent:
        return Icons.schedule;
      case WallFilter.popular:
        return Icons.trending_up;
      case WallFilter.visited:
        return Icons.history;
      case WallFilter.all:
        return Icons.list;
    }
  }
}