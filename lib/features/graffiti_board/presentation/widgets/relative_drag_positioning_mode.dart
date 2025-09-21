import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../data/models/temp_graffiti_note.dart';
import '../../data/models/graffiti_note.dart';
import '../../../../core/constants/canvas_constants.dart';
import '../../../../shared/utils/coordinate_utils.dart';

/// 상대적 드래그 기반 위치 선택 모드 위젯
class RelativeDragPositioningMode extends StatefulWidget {
  final TempGraffitiNote tempNote;
  final Function(GraffitiNote) onConfirm;
  final VoidCallback onCancel;
  final TransformationController transformationController;

  const RelativeDragPositioningMode({
    super.key,
    required this.tempNote,
    required this.onConfirm,
    required this.onCancel,
    required this.transformationController,
  });

  @override
  State<RelativeDragPositioningMode> createState() => 
      _RelativeDragPositioningModeState();
}

class _RelativeDragPositioningModeState extends State<RelativeDragPositioningMode>
    with TickerProviderStateMixin {
  
  late Offset _currentWorldPosition;
  late Offset _initialDragPosition;
  late Offset _baseCenterPosition; // 드래그 시작 시의 기준점
  bool _isDragging = false;

  late AnimationController _overlayController;
  late AnimationController _noteController;
  late Animation<double> _overlayAnimation;
  late Animation<double> _noteScaleAnimation;

  @override
  void initState() {
    super.initState();
    
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
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _noteController,
      curve: Curves.elasticOut,
    ));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // MediaQuery가 사용 가능해진 후 초기 위치 설정
    _currentWorldPosition = _getScreenCenterInWorldCoords();
    
    // 진입 애니메이션 시작
    _overlayController.forward();
  }

  @override
  void dispose() {
    _overlayController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  /// 화면 중앙의 월드 좌표 계산
  Offset _getScreenCenterInWorldCoords() {
    final screenSize = MediaQuery.of(context).size;
    final screenCenter = Offset(screenSize.width / 2, screenSize.height / 2);
    return CoordinateUtils.screenToWorld(screenCenter, widget.transformationController);
  }

  /// 화면 델타를 월드 델타로 변환
  Offset _screenDeltaToWorldDelta(Offset screenDelta) {
    final transform = widget.transformationController.value;
    final scale = transform.getMaxScaleOnAxis();
    
    return Offset(
      screenDelta.dx / scale,
      screenDelta.dy / scale,
    );
  }

  /// 현재 월드 위치를 화면 위치로 변환
  Offset get _currentScreenPosition {
    return CoordinateUtils.worldToScreen(_currentWorldPosition, widget.transformationController);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: AnimatedBuilder(
        animation: _overlayAnimation,
        builder: (context, child) {
          return Container(
            color: Colors.black.withOpacity(0.4 * _overlayAnimation.value),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // 전체 화면 드래그 감지 영역
                Positioned.fill(
                  child: GestureDetector(
                    onPanStart: _handlePanStart,
                    onPanUpdate: _handlePanUpdate,
                    onPanEnd: _handlePanEnd,
                    child: Container(
                      color: Colors.transparent,
                    ),
                  ),
                ),

                // 드래그 가능한 임시 노트
                _buildDraggableNote(),

                // 상단 가이드
                _buildTopGuide(),

                // 플로팅 액션 버튼들
                _buildFloatingActions(),
              ],
            ),
          );
        },
      ),
    );
  }

  /// 드래그 가능한 임시 노트 렌더링
  Widget _buildDraggableNote() {
    final screenPos = _currentScreenPosition;
    final screenSize = MediaQuery.of(context).size;
    
    // 화면 경계 내에서만 표시되도록 제한
    final clampedLeft = (screenPos.dx - widget.tempNote.size.width / 2)
        .clamp(0.0, screenSize.width - widget.tempNote.size.width);
    final clampedTop = (screenPos.dy - widget.tempNote.size.height / 2)
        .clamp(0.0, screenSize.height - widget.tempNote.size.height);
    
    return AnimatedBuilder(
      animation: _noteScaleAnimation,
      builder: (context, child) {
        return Positioned(
          left: clampedLeft,
          top: clampedTop,
          child: IgnorePointer(
            child: Transform.scale(
              scale: _noteScaleAnimation.value,
              child: Container(
                width: widget.tempNote.size.width,
                height: widget.tempNote.size.height,
                decoration: BoxDecoration(
                  color: widget.tempNote.backgroundColor.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _isDragging ? Colors.blue : Colors.white,
                    width: _isDragging ? 3 : 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(_isDragging ? 0.3 : 0.2),
                      blurRadius: _isDragging ? 12 : 8,
                      offset: Offset(0, _isDragging ? 6 : 4),
                    ),
                  ],
                ),
                child: _buildNoteContent(),
              ),
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
            child: SizedBox(
              width: double.infinity,
              child: Text(
                widget.tempNote.content,
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
          if (widget.tempNote.author.isNotEmpty && widget.tempNote.author != '익명')
            SizedBox(
              width: double.infinity,
              child: Text(
                '- ${widget.tempNote.author} -',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.black54,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: widget.tempNote.authorAlignment == AuthorAlignment.center
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
                Icons.pan_tool,
                color: Colors.blue,
                size: 20,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  '낙서를 드래그해서 원하는 위치로 이동하세요',
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

  /// 플로팅 액션 버튼들
  Widget _buildFloatingActions() {
    return Positioned(
      bottom: MediaQuery.of(context).padding.bottom + 20,
      left: 20,
      right: 20,
      child: FadeTransition(
        opacity: _overlayAnimation,
        child: SafeArea(
          child: Row(
            children: [
              // 취소 버튼
              Expanded(
                child: Material(
                  color: Colors.transparent,
                  elevation: 0,
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
                  elevation: 0,
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
      ),
    );
  }

  /// 드래그 시작 처리
  void _handlePanStart(DragStartDetails details) {
    _isDragging = true;
    _initialDragPosition = details.globalPosition;
    _baseCenterPosition = _getScreenCenterInWorldCoords(); // 기준점 저장
    HapticFeedback.selectionClick();
    _noteController.forward();
  }

  /// 드래그 업데이트 처리 (상대적 이동)
  void _handlePanUpdate(DragUpdateDetails details) {
    if (!_isDragging || !mounted) return;
    
    // 드래그 시작점 대비 현재 위치의 delta 계산
    final dragDelta = details.globalPosition - _initialDragPosition;
    
    // 월드 좌표계에서의 delta로 변환
    final worldDelta = _screenDeltaToWorldDelta(dragDelta);
    
    // 저장된 기준점 사용
    final newPosition = _baseCenterPosition + worldDelta;
    
    // 상태 업데이트
    setState(() {
      _currentWorldPosition = newPosition;
    });
  }

  /// 드래그 종료 처리
  void _handlePanEnd(DragEndDetails details) {
    _isDragging = false;
    HapticFeedback.lightImpact();
    _noteController.reverse();
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
    
    final finalNote = widget.tempNote.toGraffitiNote();
    final updatedNote = finalNote.copyWith(position: _currentWorldPosition);
    
    _overlayController.reverse().then((_) {
      widget.onConfirm(updatedNote);
    });
  }
}