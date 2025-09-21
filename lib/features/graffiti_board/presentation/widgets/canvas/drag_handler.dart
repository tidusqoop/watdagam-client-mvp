import 'dart:async';
import 'package:flutter/material.dart';
import '../../../data/models/graffiti_note.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../shared/utils/coordinate_utils.dart';

/// Optimized drag handler with immediate UI updates and batched persistence
class DragHandler {
  Timer? _updateTimer;
  GraffitiNote? _pendingUpdate;
  final Function(GraffitiNote) onLocalUpdate;
  final Function(GraffitiNote) onRepositoryUpdate;
  
  DragHandler({
    required this.onLocalUpdate,
    required this.onRepositoryUpdate,
  });

  void handlePanUpdate(
    GraffitiNote note, 
    DragUpdateDetails details, 
    TransformationController controller,
  ) {
    // Use coordinate utils for precise world coordinate calculation
    final Offset worldDelta = CoordinateUtils.calculateWorldDelta(
      details,
      controller,
    );

    // 새로운 위치 계산 (캔버스 경계 체크)
    final Offset newPosition = CoordinateUtils.clampToCanvasBounds(
      note.position + worldDelta,
      note.size,
    );

    // Use optimized drag handler for immediate UI update + batched persistence
    handleDrag(note, newPosition);
  }

  void handleDrag(GraffitiNote note, Offset newPosition) {
    // 1. 즉시 로컬 상태 업데이트 (UI 반응성 확보)
    final updatedNote = note.copyWith(position: newPosition);
    onLocalUpdate(updatedNote);
    
    // 2. 배치 업데이트 스케줄링 (성능 최적화)
    _scheduleRepositoryUpdate(updatedNote);
  }
  
  void _scheduleRepositoryUpdate(GraffitiNote note) {
    // 기존 타이머 취소 (마지막 위치만 저장)
    _updateTimer?.cancel();
    _pendingUpdate = note;
    
    // 200ms 후 배치 업데이트
    _updateTimer = Timer(AppConstants.DRAG_UPDATE_DELAY, () {
      if (_pendingUpdate != null) {
        onRepositoryUpdate(_pendingUpdate!);
        _pendingUpdate = null;
      }
    });
  }

  void dispose() {
    _updateTimer?.cancel();
  }
}