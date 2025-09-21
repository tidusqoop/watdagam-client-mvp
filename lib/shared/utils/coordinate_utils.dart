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

  /// Convert world coordinates to screen coordinates
  static Offset worldToScreen(
    Offset worldPosition,
    TransformationController controller,
  ) {
    final transform = controller.value;
    final scale = transform.getMaxScaleOnAxis();
    final translation = transform.getTranslation();
    
    return Offset(
      worldPosition.dx * scale + translation.x,
      worldPosition.dy * scale + translation.y,
    );
  }

  /// Convert screen coordinates to world coordinates
  static Offset screenToWorld(
    Offset screenPosition,
    TransformationController controller,
  ) {
    final transform = controller.value;
    final scale = transform.getMaxScaleOnAxis();
    final translation = transform.getTranslation();
    
    return Offset(
      (screenPosition.dx - translation.x) / scale,
      (screenPosition.dy - translation.y) / scale,
    );
  }

  /// Get current viewport bounds in world coordinates
  static Rect getViewportBounds(
    TransformationController controller,
    Size screenSize,
  ) {
    final topLeft = screenToWorld(Offset.zero, controller);
    final bottomRight = screenToWorld(
      Offset(screenSize.width, screenSize.height),
      controller,
    );
    
    return Rect.fromLTRB(
      topLeft.dx,
      topLeft.dy,
      bottomRight.dx,
      bottomRight.dy,
    );
  }
}