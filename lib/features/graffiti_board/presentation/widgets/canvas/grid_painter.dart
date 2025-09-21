import 'package:flutter/material.dart';
import '../../../../../core/constants/canvas_constants.dart';

/// 모눈종이 배경을 그리는 CustomPainter
class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 0.3  // 더 얇은 선
      ..style = PaintingStyle.stroke;

    // 20px 간격으로 세로선 그리기
    for (double x = 0; x < size.width; x += CanvasConstants.GRID_SIZE) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // 20px 간격으로 가로선 그리기
    for (double y = 0; y < size.height; y += CanvasConstants.GRID_SIZE) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}