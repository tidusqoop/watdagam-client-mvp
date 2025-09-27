import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../data/models/temp_graffiti_note.dart';
import '../../data/models/graffiti_note.dart';
import '../../../../core/constants/canvas_constants.dart';
import '../../../../shared/utils/coordinate_utils.dart';
import 'graffiti_note_widget.dart';

/// 위치 선택 모드 위젯
class PositioningMode extends StatefulWidget {
  final TempGraffitiNote tempNote;
  final Function(GraffitiNote) onConfirm;
  final VoidCallback onCancel;
  final TransformationController transformationController;
  final Size screenSize;

  const PositioningMode({
    super.key,
    required this.tempNote,
    required this.onConfirm,
    required this.onCancel,
    required this.transformationController,
    required this.screenSize,
  });

  @override
  State<PositioningMode> createState() => _PositioningModeState();
}

class _PositioningModeState extends State<PositioningMode>
    with TickerProviderStateMixin {
  late TempGraffitiNote currentTempNote;
  late AnimationController _overlayController;
  late AnimationController _noteController;
  late Animation<double> _overlayAnimation;
  late Animation<double> _noteScaleAnimation;
  bool _isDragging = false;
  Offset? _lastTapPosition;

  @override
  void initState() {
    super.initState();
    currentTempNote = widget.tempNote;
    
    _overlayController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    
    _noteController = AnimationController(
      duration: Duration(milliseconds: 200),
      vsync: this,
    );

    _overlayAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _overlayController,
      curve: Curves.easeOut,
    ));

    _noteScaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _noteController,
      curve: Curves.elasticOut,
    ));

    // 진입 애니메이션 시작
    _overlayController.forward();
    _noteController.forward();
  }

  @override
  void dispose() {
    _overlayController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _overlayAnimation,
      builder: (context, child) {
        return Container(
          color: Colors.black.withOpacity(0.4 * _overlayAnimation.value),
          child: Stack(
            children: [
              // 메인 캔버스 영역 - 더블 탭 감지
              Positioned.fill(
                child: GestureDetector(
                  onTapDown: _handleTapDown,
                  onDoubleTap: _handleDoubleTap,
                  onPanStart: _handlePanStart,
                  onPanUpdate: _handlePanUpdate,
                  onPanEnd: _handlePanEnd,
                  child: Container(
                    color: Colors.transparent,
                  ),
                ),
              ),

              // 임시 낙서 노트 렌더링
              _buildTempNote(),

              // 상단 가이드 텍스트
              _buildTopGuide(),

              // 하단 액션 버튼들
              _buildBottomActions(),

              // 중앙 위치 버튼 (+ 버튼)
              _buildCenterPositionButton(),
            ],
          ),
        );
      },
    );
  }

  /// 임시 낙서 노트 렌더링
  Widget _buildTempNote() {
    // 월드 좌표를 화면 좌표로 변환
    final screenPosition = CoordinateUtils.worldToScreen(
      currentTempNote.initialPosition,
      widget.transformationController,
    );

    return AnimatedBuilder(
      animation: _noteScaleAnimation,
      builder: (context, child) {
        return Positioned(
          left: screenPosition.dx - currentTempNote.size.width / 2,
          top: screenPosition.dy - currentTempNote.size.height / 2,
          child: Transform.scale(
            scale: _noteScaleAnimation.value,
            child: Container(
              width: currentTempNote.size.width,
              height: currentTempNote.size.height,
              decoration: BoxDecoration(
                color: currentTempNote.backgroundColor.withOpacity(0.9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: _buildNoteContent(),
            ),
          ),
        );
      },
    );
  }

  /// 낙서 노트 내용 렌더링
  Widget _buildNoteContent() {
    return Padding(
      padding: EdgeInsets.all(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 메인 콘텐츠
          Expanded(
            child: Container(
              width: double.infinity,
              child: Text(
                currentTempNote.content,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                  height: 1.3,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          
          // 작성자
          if (currentTempNote.author.isNotEmpty && currentTempNote.author != '익명')
            Container(
              width: double.infinity,
              child: Text(
                '- ${currentTempNote.author} -',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.black54,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: currentTempNote.authorAlignment == AuthorAlignment.center
                    ? TextAlign.center
                    : TextAlign.right,
              ),
            ),
        ],
      ),
    );
  }

  /// 상단 가이드 텍스트
  Widget _buildTopGuide() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 20,
      left: 20,
      right: 20,
      child: FadeTransition(
        opacity: _overlayAnimation,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.95),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(
                Icons.touch_app,
                color: Colors.blue,
                size: 20,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  '원하는 위치를 더블 탭하거나 드래그하세요',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 중앙 위치 버튼 (+ 버튼)
  Widget _buildCenterPositionButton() {
    return Positioned(
      right: 20,
      top: MediaQuery.of(context).size.height / 2 - 28,
      child: FadeTransition(
        opacity: _overlayAnimation,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(28),
            onTap: _moveToScreenCenter,
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.3),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                Icons.add,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 하단 액션 버튼들
  Widget _buildBottomActions() {
    return Positioned(
      bottom: MediaQuery.of(context).padding.bottom + 20,
      left: 20,
      right: 20,
      child: FadeTransition(
        opacity: _overlayAnimation,
        child: Row(
          children: [
            // 취소 버튼
            Expanded(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: _handleCancel,
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Center(
                      child: Text(
                        '취소',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            
            SizedBox(width: 12),
            
            // 확인 버튼
            Expanded(
              flex: 2,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: _handleConfirm,
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.3),
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        '이 위치에 낙서하기',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 탭 다운 위치 저장
  void _handleTapDown(TapDownDetails details) {
    _lastTapPosition = details.globalPosition;
  }

  /// 더블 탭 처리
  void _handleDoubleTap() {
    if (_lastTapPosition == null) return;
    
    HapticFeedback.lightImpact();
    
    // 탭한 위치를 월드 좌표로 변환
    final worldPosition = CoordinateUtils.screenToWorld(
      _lastTapPosition!,
      widget.transformationController,
    );

    setState(() {
      currentTempNote = currentTempNote.copyWithPosition(worldPosition);
    });

    // 피드백 애니메이션
    _noteController.reset();
    _noteController.forward();
  }

  /// 화면 중앙으로 이동
  void _moveToScreenCenter() {
    HapticFeedback.lightImpact();
    
    final screenCenter = Offset(
      widget.screenSize.width / 2,
      widget.screenSize.height / 2,
    );
    
    final worldPosition = CoordinateUtils.screenToWorld(
      screenCenter,
      widget.transformationController,
    );

    setState(() {
      currentTempNote = currentTempNote.copyWithPosition(worldPosition);
    });

    // 피드백 애니메이션
    _noteController.reset();
    _noteController.forward();
  }

  /// 드래그 시작
  void _handlePanStart(DragStartDetails details) {
    _isDragging = true;
    HapticFeedback.selectionClick();
  }

  /// 드래그 업데이트
  void _handlePanUpdate(DragUpdateDetails details) {
    if (!_isDragging) return;

    // 드래그 위치를 월드 좌표로 변환
    final worldPosition = CoordinateUtils.screenToWorld(
      details.globalPosition,
      widget.transformationController,
    );

    setState(() {
      currentTempNote = currentTempNote.copyWithPosition(worldPosition);
    });
  }

  /// 드래그 종료
  void _handlePanEnd(DragEndDetails details) {
    _isDragging = false;
    HapticFeedback.lightImpact();
  }

  /// 취소 처리
  void _handleCancel() {
    HapticFeedback.lightImpact();
    
    _overlayController.reverse().then((_) {
      widget.onCancel();
    });
  }

  /// 확인 처리
  void _handleConfirm() {
    HapticFeedback.mediumImpact();
    
    final finalNote = currentTempNote.toGraffitiNote();
    
    _overlayController.reverse().then((_) {
      widget.onConfirm(finalNote);
    });
  }
}