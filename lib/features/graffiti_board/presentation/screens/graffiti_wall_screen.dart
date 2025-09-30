import 'package:flutter/material.dart';
import '../../data/models/graffiti_note.dart';
import '../../data/models/temp_graffiti_note.dart';
import '../../data/repositories/graffiti_repository.dart';
import '../../../../config/app_config.dart';
import '../../../../core/constants/canvas_constants.dart';
import '../../../../shared/utils/coordinate_utils.dart';
import '../widgets/canvas/graffiti_canvas.dart';
import '../widgets/canvas/transformation_controller.dart';
import '../widgets/zoom_indicator.dart';
import '../widgets/bottom_toolbar.dart';
import '../widgets/add_graffiti_dialog.dart';
import '../widgets/relative_drag_positioning_mode.dart';

class GraffitiWallScreen extends StatefulWidget {
  final GraffitiRepository repository;
  final dynamic selectedWall; // Wall entity or null for default behavior

  const GraffitiWallScreen({
    super.key, 
    required this.repository,
    this.selectedWall,
  });

  @override
  State<GraffitiWallScreen> createState() => _GraffitiWallScreenState();
}

class _GraffitiWallScreenState extends State<GraffitiWallScreen> {
  // Enhanced transformation controller
  late final EnhancedTransformationController _transformationController;

  // Repository-based data management
  List<GraffitiNote> notes = [];
  bool isLoading = true;
  String? errorMessage;
  
  // New positioning flow state
  TempGraffitiNote? _tempNote;
  bool _isInPositioningMode = false;
  bool _hideBottomToolbar = false;

  @override
  void initState() {
    super.initState();
    _transformationController = EnhancedTransformationController();
    
    _loadNotes();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final screenSize = MediaQuery.of(context).size;
      final canvasSize = Size(CanvasConstants.CANVAS_WIDTH, CanvasConstants.CANVAS_HEIGHT);

      // 정확한 중앙 정렬
      _transformationController.resetToCenter(screenSize, canvasSize);
    });
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  /// Load notes from repository
  Future<void> _loadNotes() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final loadedNotes = await widget.repository.getNotes();
      setState(() {
        notes = loadedNotes;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load notes: $e';
        isLoading = false;
      });

      if (AppConfig.enableDebugLogging) {
        print('Error loading notes: $e');
      }
    }
  }

  /// Add new note through repository
  Future<void> _addNoteToRepository(GraffitiNote note) async {
    try {
      final addedNote = await widget.repository.addNote(note);
      setState(() {
        notes.add(addedNote);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add note: $e')),
      );

      if (AppConfig.enableDebugLogging) {
        print('Error adding note: $e');
      }
    }
  }

  /// Update note locally for immediate UI response
  void _updateNoteLocally(GraffitiNote note) {
    setState(() {
      final index = notes.indexWhere((n) => n.id == note.id);
      if (index != -1) {
        notes[index] = note;
      }
    });

    // Also update repository cache immediately for consistency
    widget.repository.updateNoteInCacheOnly(note);
    
    // Background persistence
    _updateNoteInRepository(note);
  }

  /// Update note through repository (background persistence)
  Future<void> _updateNoteInRepository(GraffitiNote note) async {
    try {
      // Use optimized repository method that handles immediate cache updates
      await widget.repository.updateNotePositionOptimized(note.id, note.position);
      
      if (AppConfig.enableDebugLogging) {
        print('Note ${note.id} position updated in repository');
      }
    } catch (e) {
      if (AppConfig.enableDebugLogging) {
        print('Error updating note in repository: $e');
      }
      
      // On error, we don't need to revert local state since it's already correct
      // The user can continue dragging and the next batch update will retry
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: const Icon(Icons.arrow_back, color: Colors.black),
        title: Text(
          '낙서집・${notes.length}개 낙서',
          style: const TextStyle(color: Colors.black, fontSize: 16),
        ),
        actions: [
          // Debug info button (development only)
          if (AppConfig.isDevelopment)
            IconButton(
              icon: Icon(Icons.info_outline, color: Colors.grey),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Debug Info'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: AppConfig.summary.entries
                          .map((e) => Text('${e.key}: ${e.value}'))
                          .toList(),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Close'),
                      ),
                    ],
                  ),
                );
              },
            ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: Stack(
        children: [
          // Loading indicator
          if (isLoading)
            const Center(child: CircularProgressIndicator()),

          // Error message
          if (errorMessage != null)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(errorMessage!),
                  ElevatedButton(
                    onPressed: _loadNotes,
                    child: Text('Retry'),
                  ),
                ],
              ),
            ),

          // Main canvas area
          if (!isLoading && errorMessage == null)
            GraffitiCanvas(
              notes: notes,
              onNoteUpdate: _updateNoteLocally,
              transformationController: _transformationController,
              onDoubleClick: _handleCanvasDoubleClick,
            ),

          // Positioning mode overlay
          if (_isInPositioningMode && _tempNote != null)
            RelativeDragPositioningMode(
              tempNote: _tempNote!,
              onConfirm: _handlePositioningConfirm,
              onCancel: _handlePositioningCancel,
              transformationController: _transformationController,
            ),

          // Zoom level indicator (top-right corner)
          Positioned(
            top: 20,
            right: 20,
            child: ValueListenableBuilder<bool>(
              valueListenable: _transformationController.showZoomIndicator,
              builder: (context, showIndicator, child) {
                return ValueListenableBuilder<double>(
                  valueListenable: _transformationController.currentZoomLevel,
                  builder: (context, zoomLevel, child) {
                    return ZoomIndicator(
                      zoomLevel: zoomLevel,
                      isVisible: showIndicator,
                    );
                  },
                );
              },
            ),
          ),

          // Bottom toolbar (조건부 표시)
          if (!isLoading && errorMessage == null && !_hideBottomToolbar)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: BottomToolbar(
                onAddGraffiti: _addGraffiti,
                onZoomIn: _zoomIn,
                onZoomOut: _zoomOut,
                onResetView: _resetView,
                onRefresh: _refreshNotes,
              ),
            ),
        ],
      ),
    );
  }

  // 툴바 버튼 핸들러들
  void _addGraffiti() {
    _startGraffitiCreation();
  }

  // 캔버스 더블클릭 핸들러
  void _handleCanvasDoubleClick() {
    _startGraffitiCreation();
  }

  // 낙서 생성 시작 (공통 로직)
  void _startGraffitiCreation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddGraffitiDialog(
          onAdd: _enterPositioningMode,
        );
      },
    );
  }

  // 배치 모드 진입
  void _enterPositioningMode(String content, Color color, String? author, AuthorAlignment alignment) {
    final screenSize = MediaQuery.of(context).size;
    final screenCenter = Offset(screenSize.width / 2, screenSize.height / 2);
    final worldCenter = CoordinateUtils.screenToWorld(
      screenCenter,
      _transformationController,
    );

    final tempNote = TempGraffitiNote.fromDialogResult(
      content: content,
      backgroundColor: color,
      author: author ?? '익명',
      authorAlignment: alignment,
      initialPosition: worldCenter,
    );

    setState(() {
      _tempNote = tempNote;
      _isInPositioningMode = true;
      _hideBottomToolbar = true; // 하단바 숨김
    });
  }

  // 배치 모드 종료
  void _exitPositioningMode() {
    setState(() {
      _isInPositioningMode = false;
      _tempNote = null;
      _hideBottomToolbar = false; // 하단바 복원
    });
  }

  void _zoomIn() {
    final currentScale = _transformationController.currentZoomLevel.value;
    final newScale = (currentScale * 1.2).clamp(CanvasConstants.MIN_SCALE, CanvasConstants.MAX_SCALE);

    // 현재 월드 중심점 유지
    final worldCenter = CoordinateUtils.getCurrentWorldCenter(
      _transformationController,
      MediaQuery.of(context).size,
    );
    final screenSize = MediaQuery.of(context).size;

    _transformationController.precisePanAndZoom(newScale, worldCenter, screenSize);
  }

  void _zoomOut() {
    final currentScale = _transformationController.currentZoomLevel.value;
    final newScale = (currentScale / 1.2).clamp(CanvasConstants.MIN_SCALE, CanvasConstants.MAX_SCALE);

    final worldCenter = CoordinateUtils.getCurrentWorldCenter(
      _transformationController,
      MediaQuery.of(context).size,
    );
    final screenSize = MediaQuery.of(context).size;

    _transformationController.precisePanAndZoom(newScale, worldCenter, screenSize);
  }

  void _resetView() {
    // 캔버스 중앙으로 정확한 리셋
    final screenSize = MediaQuery.of(context).size;
    final canvasSize = Size(CanvasConstants.CANVAS_WIDTH, CanvasConstants.CANVAS_HEIGHT);

    _transformationController.resetToCenter(screenSize, canvasSize);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('캔버스 중앙으로 이동'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _refreshNotes() async {
    await _loadNotes();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('노트 새로고침 완료'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  // 위치 선택 모드 핸들러들
  void _handlePositioningConfirm(GraffitiNote finalNote) async {
    _exitPositioningMode();
    
    await _addNoteToRepository(finalNote);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('낙서가 추가되었습니다! 🎨'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _handlePositioningCancel() {
    _exitPositioningMode();
  }
}