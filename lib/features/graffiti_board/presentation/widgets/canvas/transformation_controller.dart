import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../../core/constants/canvas_constants.dart';
import '../../../../../core/constants/app_constants.dart';

/// Enhanced transformation controller with smart zoom
class EnhancedTransformationController extends TransformationController {
  final ValueNotifier<double> currentZoomLevel = ValueNotifier(1.0);
  final ValueNotifier<bool> showZoomIndicator = ValueNotifier(false);
  Timer? _zoomIndicatorTimer;

  void precisePanAndZoom(double newScale, Offset worldCenter, Size screenSize) {
    // 1. 스케일 제한 적용
    final double clampedScale = newScale.clamp(CanvasConstants.MIN_SCALE, CanvasConstants.MAX_SCALE);

    // 2. 화면 중심 계산
    final Offset screenCenter = Offset(screenSize.width / 2, screenSize.height / 2);

    // 3. 정확한 변환 매트릭스 구성 (translate 먼저, scale 나중)
    final Matrix4 newTransform = Matrix4.identity()
      ..translate(screenCenter.dx - worldCenter.dx * clampedScale,
                  screenCenter.dy - worldCenter.dy * clampedScale)
      ..scale(clampedScale);

    value = newTransform;
    currentZoomLevel.value = clampedScale;
    showZoomIndicatorTemporary();
  }

  void resetToCenter(Size screenSize, Size canvasSize) {
    // 정확한 중앙 위치 계산
    final double centerTranslateX = (screenSize.width - canvasSize.width) / 2;
    final double centerTranslateY = (screenSize.height - canvasSize.height) / 2;

    value = Matrix4.identity()..translate(centerTranslateX, centerTranslateY);
    currentZoomLevel.value = 1.0;
  }

  void showZoomIndicatorTemporary() {
    showZoomIndicator.value = true;
    _zoomIndicatorTimer?.cancel();
    _zoomIndicatorTimer = Timer(AppConstants.ZOOM_INDICATOR_DURATION, () {
      showZoomIndicator.value = false;
    });
  }

  @override
  void dispose() {
    _zoomIndicatorTimer?.cancel();
    showZoomIndicator.dispose();
    currentZoomLevel.dispose();
    super.dispose();
  }
}