import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';
import 'dart:async';
import 'dart:math' as math;

void main() {
  runApp(const WatdagamApp());
}

class WatdagamApp extends StatelessWidget {
  const WatdagamApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '왔다감',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.pink),
        useMaterial3: true,
      ),
      home: const GraffitiWallScreen(),
    );
  }
}

class GraffitiNote {
  final String id;
  final String content;           // 이모지 포함 통합 텍스트
  final Color backgroundColor;    // 파스텔 배경색
  final Offset position;
  final Size size;
  final String author;            // Always has value (never null), 빈칸일 경우 "익명"
  final AuthorAlignment authorAlignment; // 작성자 정렬 방식
  final double opacity;           // 투명도
  final double cornerRadius;      // 모서리 둥글기

  GraffitiNote({
    required this.id,
    required this.content,
    required this.backgroundColor,
    required this.position,
    required this.size,
    String? author,               // Allow null input for convenience
    this.authorAlignment = AuthorAlignment.center,
    this.opacity = 0.7,          // More transparent background
    this.cornerRadius = 12.0,
  }) : author = (author?.trim().isEmpty ?? true) ? '익명' : author!.trim();
}

enum AuthorAlignment {
  center,    // 중앙 정렬
  right,     // 오른쪽 정렬
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

// Unified drag handler with coordinate system integration
class UnifiedDragHandler {
  static Offset calculatePreciseWorldDelta(
    DragUpdateDetails details,
    TransformationController controller,
  ) {
    // GestureDetector가 InteractiveViewer 내부에 있으므로
    // details.delta는 이미 월드 좌표계의 델타임
    // 추가 변환 불필요!
    return details.delta;
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
  const GraffitiWallScreen({super.key});

  @override
  State<GraffitiWallScreen> createState() => _GraffitiWallScreenState();
}

class _GraffitiWallScreenState extends State<GraffitiWallScreen> {
  // 파스텔 색상 팔레트 (샘플 기반 개선)
  final List<Color> graffitiColors = [
    Color(0xFFFFC1CC), // 부드러운 핑크
    Color(0xFFFFE5B4), // 크림 옐로우
    Color(0xFFB4E5D1), // 민트 그린
    Color(0xFFD4C5F9), // 라벤더 퍼플
    Color(0xFFFFD1DC), // 베이비 핑크
    Color(0xFFF0F8E8), // 소프트 그린
    Color(0xFFFFF2CC), // 바닐라
    Color(0xFFE6F3FF), // 베이비 블루
    Color(0xFFF5E6FF), // 라이트 퍼플
    Color(0xFFFFE6F0), // 로즈 핑크
  ];

  // 빠른 이모지 접근 (선택사항)
  final List<String> quickEmojis = [
    '😊', '❤️', '🏠', '✈️', '📸', '🎉', '👋', '💕'
  ];

  // Enhanced transformation controller
  late final CorrectTransformationController _transformationController;

  List<GraffitiNote> notes = [
    GraffitiNote(
      id: '1',
      content: '감기라하자',
      backgroundColor: Color(0xFFFFC1CC),
      position: const Offset(50, 200),
      size: const Size(80, 60),
      author: null, // Will become "익명"
    ),
    GraffitiNote(
      id: '2',
      content: '😊 스케치\n감기라하자',
      backgroundColor: Color(0xFFFFD1DC),
      position: const Offset(150, 250),
      size: const Size(180, 100),
      author: '스케치',
      authorAlignment: AuthorAlignment.center,
    ),
    GraffitiNote(
      id: '3',
      content: '❤️ 여행자일씨',
      backgroundColor: Color(0xFFFFE5B4),
      position: const Offset(50, 420),
      size: const Size(100, 80),
      author: '', // Will become "익명"
    ),
    GraffitiNote(
      id: '4',
      content: '🎪 안녕하세요',
      backgroundColor: Color(0xFFB4E5D1),
      position: const Offset(300, 380),
      size: const Size(120, 80),
      author: null, // Will become "익명"
    ),
    GraffitiNote(
      id: '5',
      content: '🏠 집콕 스케치\n집콕가',
      backgroundColor: Color(0xFFFFD1DC),
      position: const Offset(200, 500),
      size: const Size(200, 120),
      author: '멍멍가',
      authorAlignment: AuthorAlignment.right,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _transformationController = CorrectTransformationController();

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
    super.dispose();
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
        title: const Text(
          '낙서집・2명 참여 중',
          style: TextStyle(color: Colors.black, fontSize: 16),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: Stack(
        children: [
          // 확장된 캔버스 영역
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
          setState(() {
            // Use unified drag handler
            final Offset worldDelta = UnifiedDragHandler.calculatePreciseWorldDelta(
              details,
              _transformationController,
            );

            // 새로운 위치 계산 (캔버스 경계 체크)
            final double newX = (note.position.dx + worldDelta.dx)
                .clamp(0.0, CanvasConfig.CANVAS_WIDTH - note.size.width);
            final double newY = (note.position.dy + worldDelta.dy)
                .clamp(0.0, CanvasConfig.CANVAS_HEIGHT - note.size.height);

            // notes 리스트에서 해당 노트 찾아서 위치 업데이트
            final int index = notes.indexWhere((n) => n.id == note.id);
            if (index != -1) {
              notes[index] = GraffitiNote(
                id: note.id,
                content: note.content,
                backgroundColor: note.backgroundColor,
                position: Offset(newX, newY),
                size: note.size,
                author: note.author,
                authorAlignment: note.authorAlignment,
                opacity: note.opacity,
                cornerRadius: note.cornerRadius,
              );
            }
          });
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
                // 작성자 표시 (always shown, never null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Align(
                    alignment: note.authorAlignment == AuthorAlignment.center
                      ? Alignment.center
                      : Alignment.centerRight,
                    child: Text(
                      note.author, // Always has value (never null)
                      style: TextStyle(
                        fontSize: 10.0,
                        color: Colors.black54,
                        fontWeight: FontWeight.w400,
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
          _buildToolButton(Icons.palette, Colors.black, _colorPicker),    // 색상 선택
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
          onAdd: (String content, Color color, String? author, AuthorAlignment alignment) {
            setState(() {
              // 현재 뷰포트 중앙에 새 낙서 추가
              final currentTransform = _transformationController.value;
              final screenSize = MediaQuery.of(context).size;
              final viewportCenter = Offset(
                (-currentTransform.getTranslation().x + screenSize.width / 2),
                (-currentTransform.getTranslation().y + screenSize.height / 2),
              );

              notes.add(GraffitiNote(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                content: content,
                backgroundColor: color,
                position: viewportCenter,
                size: Size(140, 100),        // 기본 크기
                author: author,              // Will auto-convert to "익명" if null/empty
                authorAlignment: alignment,
              ));
            });
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

  void _colorPicker() {
    // 색상 팔레트 표시를 위한 간단한 스낵바
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('색상은 낙서 추가 시 선택할 수 있습니다'),
        duration: Duration(seconds: 2),
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
  Color _selectedColor = Color(0xFFFFC1CC);
  AuthorAlignment _authorAlignment = AuthorAlignment.center;

  @override
  void initState() {
    super.initState();
    _selectedColor = widget.colors.first;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('새 낙서 추가'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 메인 내용 입력 (이모지 포함)
            TextField(
              controller: _contentController,
              decoration: InputDecoration(
                labelText: '내용',
                hintText: '메시지를 입력하세요 😊',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            SizedBox(height: 8),

            // 빠른 이모지 선택
            Text('빠른 이모지:', style: TextStyle(fontSize: 12, color: Colors.grey)),
            SizedBox(height: 4),
            Wrap(
              spacing: 8,
              children: widget.quickEmojis.map((emoji) {
                return GestureDetector(
                  onTap: () {
                    _contentController.text += emoji;
                    _contentController.selection = TextSelection.fromPosition(
                      TextPosition(offset: _contentController.text.length),
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(emoji, style: TextStyle(fontSize: 16)),
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 16),

            // 작성자명 입력
            TextField(
              controller: _authorController,
              decoration: InputDecoration(
                labelText: '작성자 (선택)',
                hintText: '빈칸일 경우 "익명"으로 표시됩니다',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),

            // 작성자 정렬 선택
            Text('작성자 위치:', style: TextStyle(fontWeight: FontWeight.bold)),
            Row(
              children: [
                Radio<AuthorAlignment>(
                  value: AuthorAlignment.center,
                  groupValue: _authorAlignment,
                  onChanged: (value) => setState(() => _authorAlignment = value!),
                ),
                Text('중앙'),
                Radio<AuthorAlignment>(
                  value: AuthorAlignment.right,
                  groupValue: _authorAlignment,
                  onChanged: (value) => setState(() => _authorAlignment = value!),
                ),
                Text('오른쪽'),
              ],
            ),
            SizedBox(height: 8),

            // 파스텔 색상 선택
            Text('색상 선택:', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.colors.map((color) {
                final isSelected = color == _selectedColor;
                return GestureDetector(
                  onTap: () => setState(() => _selectedColor = color),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: isSelected
                        ? Border.all(color: Colors.black, width: 3)
                        : Border.all(color: Colors.grey.shade300),
                    ),
                    child: isSelected
                      ? Icon(Icons.check, color: Colors.black54, size: 20)
                      : null,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('취소'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_contentController.text.trim().isNotEmpty) {
              widget.onAdd(
                _contentController.text.trim(),
                _selectedColor,
                _authorController.text.trim().isEmpty
                  ? null  // Will auto-convert to "익명" in GraffitiNote constructor
                  : _authorController.text.trim(),
                _authorAlignment,
              );
              Navigator.of(context).pop();
            }
          },
          child: Text('추가'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _contentController.dispose();
    _authorController.dispose();
    super.dispose();
  }
}