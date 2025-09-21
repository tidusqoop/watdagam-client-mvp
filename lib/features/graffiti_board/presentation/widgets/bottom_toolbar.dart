import 'package:flutter/material.dart';

/// Bottom toolbar with action buttons
class BottomToolbar extends StatelessWidget {
  final VoidCallback onAddGraffiti;
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final VoidCallback onResetView;
  final VoidCallback onRefresh;

  const BottomToolbar({
    super.key,
    required this.onAddGraffiti,
    required this.onZoomIn,
    required this.onZoomOut,
    required this.onResetView,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildToolButton(Icons.add, Colors.black, onAddGraffiti),        // 낙서 추가
          _buildToolButton(Icons.zoom_in, Colors.black, onZoomIn),         // 확대
          _buildToolButton(Icons.zoom_out, Colors.black, onZoomOut),       // 축소
          _buildToolButton(Icons.pan_tool, Colors.black, onResetView),     // 뷰 리셋
          _buildToolButton(Icons.refresh, Colors.black, onRefresh),        // 새로고침
        ],
      ),
    );
  }

  Widget _buildToolButton(IconData icon, Color iconColor, VoidCallback onPressed) {
    return GestureDetector(
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
              offset: Offset(0, 2),
              blurRadius: 4,
            ),
          ],
        ),
        child: Icon(icon, color: iconColor, size: 24),
      ),
    );
  }
}