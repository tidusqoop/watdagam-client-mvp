import 'package:flutter/material.dart';
import '../../core/constants/canvas_constants.dart';

/// Utility class for coordinate calculations
class CoordinateUtils {
  /// Calculate precise world delta for drag operations
  static Offset calculateWorldDelta(
    DragUpdateDetails details,
    TransformationController controller,
  ) {
    // GestureDetector가 InteractiveViewer 내부에 있으므로
    // details.delta는 이미 월드 좌표계의 델타임
    return details.delta;
  }
  
  /// Get current world center from transformation controller
  static Offset getCurrentWorldCenter(
    TransformationController controller,
    Size screenSize,
  ) {
    final transform = controller.value;
    final screenCenter = Offset(screenSize.width / 2, screenSize.height / 2);
    final scale = transform.getMaxScaleOnAxis();
    final translation = transform.getTranslation();
    
    return Offset(
      (screenCenter.dx - translation.x) / scale,
      (screenCenter.dy - translation.y) / scale,
    );
  }
  
  /// Clamp position to canvas boundaries
  static Offset clampToCanvasBounds(
    Offset position,
    Size noteSize,
  ) {
    return Offset(
      position.dx.clamp(0.0, CanvasConstants.CANVAS_WIDTH - noteSize.width),
      position.dy.clamp(0.0, CanvasConstants.CANVAS_HEIGHT - noteSize.height),
    );
  }
}