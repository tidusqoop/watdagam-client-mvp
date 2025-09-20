import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';
import 'dart:async';

// New architecture imports
import 'data/models/graffiti_note.dart';
import 'data/repositories/graffiti_repository.dart';
import 'data/datasources/datasource_factory.dart';
import 'config/app_config.dart';
import 'utils/time_utils.dart';

void main() {
  // Print configuration for debugging
  AppConfig.printConfig();

  // Create repository with appropriate data source
  final repository = GraffitiRepository(
    DataSourceFactory.createGraffitiDataSource()
  );

  runApp(WatdagamApp(repository: repository));
}

class WatdagamApp extends StatelessWidget {
  final GraffitiRepository repository;

  const WatdagamApp({super.key, required this.repository});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '왔다감',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.pink),
        useMaterial3: true,
      ),
      home: GraffitiWallScreen(repository: repository),
    );
  }
}

// 확장된 캔버스 설정
class CanvasConfig {
  static const double CANVAS_WIDTH = 3000.0;   // 가상 캔버스 너비
  static const double CANVAS_HEIGHT = 4000.0;  // 가상 캔버스 높이
  static const double GRID_SIZE = 20.0;        // 그리드 간격
}

// Enhanced transformation controller with smart zoom
class CorrectTransformationController extends TransformationController {
  final ValueNotifier<double> currentZoomLevel = ValueNotifier(1.0);
  final ValueNotifier<bool> showZoomIndicator = ValueNotifier(false);
  Timer? _zoomIndicatorTimer;

  void precisePanAndZoom(double newScale, Offset worldCenter, Size screenSize) {
    // 1. 스케일 제한 적용
    final double clampedScale = newScale.clamp(0.3, 2.0);

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
    _zoomIndicatorTimer = Timer(const Duration(milliseconds: 2000), () {
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

// 모눈종이 배경을 그리는 CustomPainter
class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 0.3  // 더 얇은 선
      ..style = PaintingStyle.stroke;

    // 20px 간격으로 세로선 그리기
    for (double x = 0; x < size.width; x += CanvasConfig.GRID_SIZE) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // 20px 간격으로 가로선 그리기
    for (double y = 0; y < size.height; y += CanvasConfig.GRID_SIZE) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

// Optimized drag handler with immediate UI updates and batched persistence
class OptimizedDragHandler {
  Timer? _updateTimer;
  GraffitiNote? _pendingUpdate;
  final Function(GraffitiNote) onLocalUpdate;
  final Function(GraffitiNote) onRepositoryUpdate;
  
  OptimizedDragHandler({
    required this.onLocalUpdate,
    required this.onRepositoryUpdate,
  });

  static Offset calculatePreciseWorldDelta(
    DragUpdateDetails details,
    TransformationController controller,
  ) {
    // GestureDetector가 InteractiveViewer 내부에 있으므로
    // details.delta는 이미 월드 좌표계의 델타임
    // 추가 변환 불필요!
    return details.delta;
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
    _updateTimer = Timer(const Duration(milliseconds: 200), () {
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

// Unified drag handler with coordinate system integration (legacy support)
class UnifiedDragHandler {
  static Offset calculatePreciseWorldDelta(
    DragUpdateDetails details,
    TransformationController controller,
  ) {
    return OptimizedDragHandler.calculatePreciseWorldDelta(details, controller);
  }
}

// Zoom indicator UI component
class ZoomIndicator extends StatelessWidget {
  final double zoomLevel;
  final bool isVisible;

  const ZoomIndicator({
    Key? key,
    required this.zoomLevel,
    required this.isVisible,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: isVisible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 200),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          '${(zoomLevel * 100).round()}%',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class GraffitiWallScreen extends StatefulWidget {
  final GraffitiRepository repository;

  const GraffitiWallScreen({super.key, required this.repository});

  @override
  State<GraffitiWallScreen> createState() => _GraffitiWallScreenState();
}

class _GraffitiWallScreenState extends State<GraffitiWallScreen> {
  // 파스텔 색상 팔레트 (밝은 색 우선 정렬)
  final List<Color> graffitiColors = [
    Color(0xFFFFFFF8), // 따뜻한 화이트 (새로 추가)
    Color(0xFFF0F8E8), // 소프트 그린
    Color(0xFFE6F3FF), // 베이비 블루
    Color(0xFFFFF2CC), // 바닐라
    Color(0xFFFFE5B4), // 크림 옐로우
    Color(0xFFF5E6FF), // 라이트 퍼플
    Color(0xFFFFE6F0), // 로즈 핑크
    Color(0xFFB4E5D1), // 민트 그린
    Color(0xFFFFD1DC), // 베이비 핑크
    Color(0xFFD4C5F9), // 라벤더 퍼플
    Color(0xFFFFC1CC), // 부드러운 핑크 (마지막으로 이동)
  ];

  // 빠른 이모지 접근 (선택사항)
  final List<String> quickEmojis = [
    '😊', '❤️', '🏠', '✈️', '📸', '🎉', '👋', '💕'
  ];

  // Enhanced transformation controller
  late final CorrectTransformationController _transformationController;

  // Optimized drag handler
  late final OptimizedDragHandler _dragHandler;

  // Repository-based data management
  List<GraffitiNote> notes = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _transformationController = CorrectTransformationController();
    
    // Initialize optimized drag handler
    _dragHandler = OptimizedDragHandler(
      onLocalUpdate: _updateNoteLocally,
      onRepositoryUpdate: _updateNoteInRepository,
    );
    
    _loadNotes();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final screenSize = MediaQuery.of(context).size;
      final canvasSize = Size(CanvasConfig.CANVAS_WIDTH, CanvasConfig.CANVAS_HEIGHT);

      // 정확한 중앙 정렬
      _transformationController.resetToCenter(screenSize, canvasSize);
    });
  }

  @override
  void dispose() {
    _transformationController.dispose();
    _dragHandler.dispose();
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

  // Calculate darker border color from background color
  Color _getBorderColor(Color backgroundColor) {
    final HSVColor hsv = HSVColor.fromColor(backgroundColor);
    return hsv
        .withSaturation((hsv.saturation + 0.3).clamp(0.0, 1.0))
        .withValue((hsv.value - 0.4).clamp(0.0, 1.0))
        .toColor();
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
            InteractiveViewer(
              transformationController: _transformationController,
              constrained: false,
              minScale: 0.3,
              maxScale: 2.0,
              child: Container(
                width: CanvasConfig.CANVAS_WIDTH,
                height: CanvasConfig.CANVAS_HEIGHT,
                child: CustomPaint(
                  painter: GridPainter(),
                  child: Stack(
                    children: notes.map((note) => _buildGraffitiNote(note)).toList(),
                  ),
                ),
              ),
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

          // Bottom toolbar
          if (!isLoading && errorMessage == null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildBottomToolbar(),
            ),
        ],
      ),
    );
  }

  Widget _buildGraffitiNote(GraffitiNote note) {
    return Positioned(
      left: note.position.dx,
      top: note.position.dy,
      child: GestureDetector(
        onPanUpdate: (details) {
          // Use optimized drag handler for precise world coordinate calculation
          final Offset worldDelta = OptimizedDragHandler.calculatePreciseWorldDelta(
            details,
            _transformationController,
          );

          // 새로운 위치 계산 (캔버스 경계 체크)
          final double newX = (note.position.dx + worldDelta.dx)
              .clamp(0.0, CanvasConfig.CANVAS_WIDTH - note.size.width);
          final double newY = (note.position.dy + worldDelta.dy)
              .clamp(0.0, CanvasConfig.CANVAS_HEIGHT - note.size.height);

          final Offset newPosition = Offset(newX, newY);

          // Use optimized drag handler for immediate UI update + batched persistence
          _dragHandler.handleDrag(note, newPosition);
        },
        child: DottedBorder(
          dashPattern: [8, 6],  // Longer dashes for better visibility
          color: _getBorderColor(note.backgroundColor),  // Darker, more saturated border
          strokeWidth: 2.5,     // Thicker border
          borderType: BorderType.RRect,
          radius: Radius.circular(note.cornerRadius),
          child: Container(
            width: note.size.width,
            height: note.size.height,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: note.backgroundColor.withOpacity(note.opacity), // More transparent
              borderRadius: BorderRadius.circular(note.cornerRadius),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08), // Slightly stronger shadow
                  offset: Offset(0, 3),
                  blurRadius: 6,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 메인 컨텐츠 (이모지 포함)
                if (note.content.isNotEmpty)
                  Expanded(
                    child: Center(
                      child: Text(
                        note.content,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                          height: 1.3,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                // 작성자와 시간 표시 (같은 라인)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Align(
                    alignment: note.authorAlignment == AuthorAlignment.center
                      ? Alignment.center
                      : Alignment.centerRight,
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: note.author, // Always has value (never null)
                            style: TextStyle(
                              fontSize: 10.0,
                              color: Colors.black54,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          TextSpan(
                            text: ' · ', // 중간 높이 점 구분자
                            style: TextStyle(
                              fontSize: 10.0,
                              color: Colors.grey[400],
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                          TextSpan(
                            text: TimeUtils.getRelativeTime(note.createdAt),
                            style: TextStyle(
                              fontSize: 9.5,
                              color: Colors.grey[500],
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomToolbar() {
    return Container(
      height: 80,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildToolButton(Icons.add, Colors.black, _addGraffiti),        // 낙서 추가
          _buildToolButton(Icons.zoom_in, Colors.black, _zoomIn),         // 확대
          _buildToolButton(Icons.zoom_out, Colors.black, _zoomOut),       // 축소
          _buildToolButton(Icons.pan_tool, Colors.black, _panMode),       // 이동 모드
          _buildToolButton(Icons.refresh, Colors.black, _refreshNotes),   // 새로고침
        ],
      ),
    );
  }

  // 툴바 버튼 핸들러들
  void _addGraffiti() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return _AddGraffitiDialog(
          colors: graffitiColors,
          quickEmojis: quickEmojis,
          onAdd: (String content, Color color, String? author, AuthorAlignment alignment) async {
            // 현재 뷰포트 중앙에 새 낙서 추가
            final currentTransform = _transformationController.value;
            final screenSize = MediaQuery.of(context).size;
            final viewportCenter = Offset(
              (-currentTransform.getTranslation().x + screenSize.width / 2),
              (-currentTransform.getTranslation().y + screenSize.height / 2),
            );

            final newNote = GraffitiNote(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              content: content,
              backgroundColor: color,
              position: viewportCenter,
              size: Size(140, 100),        // 기본 크기
              author: author,              // Will auto-convert to "익명" if null/empty
              authorAlignment: alignment,
            );

            await _addNoteToRepository(newNote);
          },
        );
      },
    );
  }

  void _zoomIn() {
    final currentScale = _transformationController.currentZoomLevel.value;
    final newScale = (currentScale * 1.2).clamp(0.3, 2.0);

    // 현재 월드 중심점 유지
    final worldCenter = _getCurrentWorldCenter();
    final screenSize = MediaQuery.of(context).size;

    _transformationController.precisePanAndZoom(newScale, worldCenter, screenSize);
  }

  void _zoomOut() {
    final currentScale = _transformationController.currentZoomLevel.value;
    final newScale = (currentScale / 1.2).clamp(0.3, 2.0);

    final worldCenter = _getCurrentWorldCenter();
    final screenSize = MediaQuery.of(context).size;

    _transformationController.precisePanAndZoom(newScale, worldCenter, screenSize);
  }

  Offset _getCurrentWorldCenter() {
    final transform = _transformationController.value;
    final screenSize = MediaQuery.of(context).size;
    final screenCenter = Offset(screenSize.width / 2, screenSize.height / 2);

    // 화면 중심의 월드 좌표 계산
    final scale = _transformationController.currentZoomLevel.value;
    final translation = transform.getTranslation();

    return Offset(
      (screenCenter.dx - translation.x) / scale,
      (screenCenter.dy - translation.y) / scale,
    );
  }

  void _panMode() {
    // 캔버스 중앙으로 정확한 리셋
    final screenSize = MediaQuery.of(context).size;
    final canvasSize = Size(CanvasConfig.CANVAS_WIDTH, CanvasConfig.CANVAS_HEIGHT);

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

// 개선된 낙서 추가 다이얼로그
class _AddGraffitiDialog extends StatefulWidget {
  final List<Color> colors;
  final List<String> quickEmojis;
  final Function(String content, Color color, String? author, AuthorAlignment alignment) onAdd;

  const _AddGraffitiDialog({
    required this.colors,
    required this.quickEmojis,
    required this.onAdd,
  });

  @override
  State<_AddGraffitiDialog> createState() => _AddGraffitiDialogState();
}

class _AddGraffitiDialogState extends State<_AddGraffitiDialog> {
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();
  Color _selectedColor = Color(0xFFFFFFF8); // 기본값을 따뜻한 화이트로 변경
  AuthorAlignment _authorAlignment = AuthorAlignment.center;

  @override
  void initState() {
    super.initState();
    _selectedColor = widget.colors.first;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Container(
        constraints: BoxConstraints(maxWidth: 420, maxHeight: 600),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: Offset(0, 8),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Custom Header
            _buildHeader(context),
            
            // Content Area
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Content Input Section
                    _buildContentInput(),
                    SizedBox(height: 24),
                    
                    // Quick Emoji Section
                    _buildEmojiSection(),
                    SizedBox(height: 24),
                    
                    // Author Input Section
                    _buildAuthorSection(),
                    SizedBox(height: 24),
                    
                    // Color Selection Section
                    _buildColorSection(),
                    SizedBox(height: 32),
                    
                    // Action Buttons
                    _buildActionButtons(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Custom Header with Icon and Close Button
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(24, 20, 16, 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFF0F0F0), width: 1),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text('✏️', style: TextStyle(fontSize: 16)),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              '새 낙서 만들기',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A1A),
                letterSpacing: -0.5,
              ),
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(22),
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                width: 44,
                height: 44,
                child: Icon(
                  Icons.close,
                  color: Color(0xFF6B6B6B),
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Enhanced Content Input with Custom Styling
  Widget _buildContentInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel('내용'),
        SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Color(0xFFF8F9FA),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _contentController.text.isNotEmpty 
                ? Color(0xFF007AFF) 
                : Color(0xFFE5E5E5),
              width: _contentController.text.isNotEmpty ? 2 : 1,
            ),
          ),
          child: TextField(
            controller: _contentController,
            maxLines: 4,
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF1A1A1A),
              height: 1.4,
            ),
            decoration: InputDecoration(
              hintText: '어떤 이야기를 남길까요? ✨',
              hintStyle: TextStyle(
                color: Color(0xFF9B9B9B),
                fontSize: 16,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(16),
            ),
            onChanged: (_) => setState(() {}),
          ),
        ),
        if (_contentController.text.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(top: 4, right: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  '${_contentController.text.length}/100',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF9B9B9B),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  // Enhanced Emoji Quick Selection
  Widget _buildEmojiSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel('빠른 이모지'),
        SizedBox(height: 8),
        Container(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: widget.quickEmojis.length,
            itemBuilder: (context, index) {
              final emoji = widget.quickEmojis[index];
              return Padding(
                padding: EdgeInsets.only(right: 8),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      _contentController.text += emoji;
                      _contentController.selection = TextSelection.fromPosition(
                        TextPosition(offset: _contentController.text.length),
                      );
                      setState(() {});
                    },
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Color(0xFFF0F0F0),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          emoji,
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // Enhanced Author Input Section
  Widget _buildAuthorSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel('작성자'),
        SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Color(0xFFF8F9FA),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Color(0xFFE5E5E5)),
          ),
          child: TextField(
            controller: _authorController,
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF1A1A1A),
            ),
            decoration: InputDecoration(
              hintText: '작성자 이름 (선택사항)',
              hintStyle: TextStyle(
                color: Color(0xFF9B9B9B),
                fontSize: 16,
              ),
              prefixIcon: Container(
                width: 20,
                height: 20,
                child: Center(
                  child: Text('👤', style: TextStyle(fontSize: 16)),
                ),
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
        ),
        SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Color(0xFFF8F9FA),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: _buildAlignmentButton('중앙', AuthorAlignment.center),
              ),
              Container(width: 1, height: 32, color: Color(0xFFE5E5E5)),
              Expanded(
                child: _buildAlignmentButton('오른쪽', AuthorAlignment.right),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAlignmentButton(String label, AuthorAlignment alignment) {
    final isSelected = _authorAlignment == alignment;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => setState(() => _authorAlignment = alignment),
        child: Container(
          height: 44,
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? Color(0xFF007AFF) : Color(0xFF6B6B6B),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Enhanced Color Selection Grid
  Widget _buildColorSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel('색상 선택'),
        SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1,
          ),
          itemCount: widget.colors.length,
          itemBuilder: (context, index) {
            final color = widget.colors[index];
            final isSelected = color == _selectedColor;
            
            return GestureDetector(
              onTap: () => setState(() => _selectedColor = color),
              child: AnimatedContainer(
                duration: Duration(milliseconds: 200),
                curve: Curves.easeOut,
                transform: Matrix4.identity()..scale(isSelected ? 1.1 : 1.0),
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? Colors.white : Color(0xFFE5E5E5),
                    width: isSelected ? 3 : 1,
                  ),
                  boxShadow: [
                    if (isSelected)
                      BoxShadow(
                        color: color.withOpacity(0.3),
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                  ],
                ),
                child: isSelected
                  ? Center(
                      child: Icon(
                        Icons.check,
                        color: _getContrastColor(color),
                        size: 20,
                      ),
                    )
                  : null,
              ),
            );
          },
        ),
      ],
    );
  }

  // Enhanced Action Buttons
  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        // Primary Button
        Container(
          width: double.infinity,
          height: 52,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: _contentController.text.trim().isNotEmpty
                ? () {
                    widget.onAdd(
                      _contentController.text.trim(),
                      _selectedColor,
                      _authorController.text.trim().isEmpty
                        ? null
                        : _authorController.text.trim(),
                      _authorAlignment,
                    );
                    Navigator.of(context).pop();
                  }
                : null,
              child: Container(
                decoration: BoxDecoration(
                  gradient: _contentController.text.trim().isNotEmpty
                    ? LinearGradient(
                        colors: [Color(0xFF007AFF), Color(0xFF0056CC)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                  color: _contentController.text.trim().isEmpty
                    ? Color(0xFFE5E5E5)
                    : null,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    '낙서 만들기',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: _contentController.text.trim().isNotEmpty
                        ? Colors.white
                        : Color(0xFF9B9B9B),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 12),
        // Secondary Button
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              height: 44,
              child: Center(
                child: Text(
                  '취소',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF6B6B6B),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Helper Methods
  Widget _buildSectionLabel(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Color(0xFF6B6B6B),
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Color _getContrastColor(Color color) {
    // Calculate luminance to determine if we should use black or white text
    final luminance = color.computeLuminance();
    return luminance > 0.5 ? Colors.black54 : Colors.white;
  }

  @override
  void dispose() {
    _contentController.dispose();
    _authorController.dispose();
    super.dispose();
  }
}