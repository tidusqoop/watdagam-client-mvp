import 'package:flutter/material.dart';

/// Enhanced bottom toolbar with action buttons and wall management navigation
class BottomToolbar extends StatelessWidget {
  final VoidCallback onAddGraffiti;
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final VoidCallback onResetView;
  final VoidCallback onRefresh;
  final VoidCallback? onWallList;
  final VoidCallback? onWallInfo;
  final String? currentWallName;

  const BottomToolbar({
    super.key,
    required this.onAddGraffiti,
    required this.onZoomIn,
    required this.onZoomOut,
    required this.onResetView,
    required this.onRefresh,
    this.onWallList,
    this.onWallInfo,
    this.currentWallName,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
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
          // Wall info banner (when wall is selected)
          if (currentWallName != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                border: Border(
                  bottom: BorderSide(
                    color: theme.colorScheme.outline.withOpacity(0.2),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.location_city,
                    size: 16,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      currentWallName!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (onWallInfo != null) ...[
                    GestureDetector(
                      onTap: onWallInfo,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          Icons.info_outline,
                          size: 16,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],

          // Main toolbar
          Container(
            height: 80,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                // Wall management section
                if (onWallList != null) ...[
                  _buildToolButton(
                    Icons.location_on,
                    theme.colorScheme.primary,
                    onWallList!,
                    tooltip: '담벼락 목록',
                  ),
                  const SizedBox(width: 12),
                ],

                // Main actions section
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildToolButton(
                        Icons.add,
                        Colors.black,
                        onAddGraffiti,
                        tooltip: '낙서 추가',
                      ),
                      _buildToolButton(
                        Icons.zoom_in,
                        Colors.black,
                        onZoomIn,
                        tooltip: '확대',
                      ),
                      _buildToolButton(
                        Icons.zoom_out,
                        Colors.black,
                        onZoomOut,
                        tooltip: '축소',
                      ),
                      _buildToolButton(
                        Icons.pan_tool,
                        Colors.black,
                        onResetView,
                        tooltip: '뷰 리셋',
                      ),
                      _buildToolButton(
                        Icons.refresh,
                        Colors.black,
                        onRefresh,
                        tooltip: '새로고침',
                      ),
                    ],
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
}