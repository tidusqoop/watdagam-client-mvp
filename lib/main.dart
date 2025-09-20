import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';

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
  final String text;
  final Color color;
  final Offset position;
  final Size size;
  final IconData? icon;
  final String? username;

  GraffitiNote({
    required this.id,
    required this.text,
    required this.color,
    required this.position,
    required this.size,
    this.icon,
    this.username,
  });
}

// 모눈종이 배경을 그리는 CustomPainter
class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    // 20px 간격으로 세로선 그리기
    for (double x = 0; x < size.width; x += 20) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // 20px 간격으로 가로선 그리기
    for (double y = 0; y < size.height; y += 20) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class GraffitiWallScreen extends StatefulWidget {
  const GraffitiWallScreen({super.key});

  @override
  State<GraffitiWallScreen> createState() => _GraffitiWallScreenState();
}

class _GraffitiWallScreenState extends State<GraffitiWallScreen> {
  // 색상 팔레트 (샘플 기반)
  final List<Color> graffitiColors = [
    Color(0xFFFFB6C1), // 연분홍 (샘플과 동일)
    Color(0xFFFFEB9C), // 연노랑
    Color(0xFF98FB98), // 연두색
    Color(0xFFB19CD9), // 연보라
    Color(0xFF87CEEB), // 하늘색
    Color(0xFFF0E68C), // 카키색
  ];

  // 아이콘 선택 옵션
  final List<IconData> graffitiIcons = [
    Icons.face,      // 얼굴
    Icons.favorite,  // 하트
    Icons.home,      // 집
  ];

  // 확대/축소를 위한 컨트롤러
  final TransformationController _transformationController = TransformationController();

  List<GraffitiNote> notes = [
    GraffitiNote(
      id: '1',
      text: '감기라하자',
      color: Colors.pink.shade200,
      position: const Offset(50, 200),
      size: const Size(80, 40),
    ),
    GraffitiNote(
      id: '2',
      text: '스케치\n감기라하자',
      color: Colors.pink.shade100,
      position: const Offset(150, 250),
      size: const Size(180, 100),
      icon: Icons.face,
      username: '스케치',
    ),
    GraffitiNote(
      id: '3',
      text: '여행자일씨',
      color: Colors.yellow.shade200,
      position: const Offset(50, 420),
      size: const Size(100, 80),
      icon: Icons.favorite,
    ),
    GraffitiNote(
      id: '4',
      text: '',
      color: Colors.green.shade200,
      position: const Offset(300, 380),
      size: const Size(80, 60),
    ),
    GraffitiNote(
      id: '5',
      text: '집콕 스케치\n집콕가',
      color: Colors.pink.shade100,
      position: const Offset(200, 500),
      size: const Size(200, 120),
      icon: Icons.home,
    ),
  ];

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
          // Main wall area with grid background and zoom functionality
          InteractiveViewer(
            transformationController: _transformationController,
            minScale: 0.5,
            maxScale: 3.0,
            child: Container(
              width: double.infinity,
              height: double.infinity,
              child: CustomPaint(
                painter: GridPainter(),
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  child: Stack(
                    children: notes.map((note) => _buildGraffitiNote(note)).toList(),
                  ),
                ),
              ),
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
            // 현재 변환(확대/축소) 상태를 고려한 실제 이동량 계산
            final double scale = _transformationController.value.getMaxScaleOnAxis();
            final double adjustedDelta = 1.0 / scale;

            // 새로운 위치 계산 (화면 경계 체크)
            final double newX = (note.position.dx + details.delta.dx * adjustedDelta)
                .clamp(0.0, MediaQuery.of(context).size.width - note.size.width);
            final double newY = (note.position.dy + details.delta.dy * adjustedDelta)
                .clamp(0.0, MediaQuery.of(context).size.height - note.size.height - 80); // 툴바 높이 고려

            // notes 리스트에서 해당 노트 찾아서 위치 업데이트
            final int index = notes.indexWhere((n) => n.id == note.id);
            if (index != -1) {
              notes[index] = GraffitiNote(
                id: note.id,
                text: note.text,
                color: note.color,
                position: Offset(newX, newY),
                size: note.size,
                icon: note.icon,
                username: note.username,
              );
            }
          });
        },
        child: DottedBorder(
          dashPattern: [5, 3],
          color: note.color.withOpacity(0.8),
          strokeWidth: 2,
          borderType: BorderType.RRect,
          radius: Radius.circular(8),
          child: Container(
            width: note.size.width,
            height: note.size.height,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: note.color,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (note.username != null)
                Row(
                  children: [
                    if (note.icon != null)
                      Icon(note.icon, size: 16, color: Colors.brown),
                    const SizedBox(width: 4),
                    Text(
                      note.username!,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              if (note.text.isNotEmpty)
                Expanded(
                  child: Center(
                    child: Text(
                      note.text,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              if (note.icon != null && note.username == null)
                Center(
                  child: Icon(
                    note.icon,
                    size: 20,
                    color: Colors.red,
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
          icons: graffitiIcons,
          onAdd: (String text, Color color, IconData? icon, String? username) {
            setState(() {
              notes.add(GraffitiNote(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                text: text,
                color: color,
                position: Offset(100, 200), // 기본 위치
                size: Size(120, 80),        // 기본 크기
                icon: icon,
                username: username,
              ));
            });
          },
        );
      },
    );
  }

  void _zoomIn() {
    final Matrix4 currentTransform = Matrix4.copy(_transformationController.value);
    const double scaleFactor = 1.2;

    // 현재 스케일 값 계산
    final double currentScale = currentTransform.getMaxScaleOnAxis();
    final double newScale = (currentScale * scaleFactor).clamp(0.5, 3.0);

    // 중앙점 기준 확대
    final Matrix4 newTransform = Matrix4.identity()
      ..scale(newScale);

    _transformationController.value = newTransform;
  }

  void _zoomOut() {
    final Matrix4 currentTransform = Matrix4.copy(_transformationController.value);
    const double scaleFactor = 1.0 / 1.2;

    // 현재 스케일 값 계산
    final double currentScale = currentTransform.getMaxScaleOnAxis();
    final double newScale = (currentScale * scaleFactor).clamp(0.5, 3.0);

    // 중앙점 기준 축소
    final Matrix4 newTransform = Matrix4.identity()
      ..scale(newScale);

    _transformationController.value = newTransform;
  }

  void _panMode() {
    // 현재 위치로 리셋
    _transformationController.value = Matrix4.identity();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('뷰 리셋됨'),
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

// 낙서 추가 다이얼로그
class _AddGraffitiDialog extends StatefulWidget {
  final List<Color> colors;
  final List<IconData> icons;
  final Function(String text, Color color, IconData? icon, String? username) onAdd;

  const _AddGraffitiDialog({
    required this.colors,
    required this.icons,
    required this.onAdd,
  });

  @override
  State<_AddGraffitiDialog> createState() => _AddGraffitiDialogState();
}

class _AddGraffitiDialogState extends State<_AddGraffitiDialog> {
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  Color _selectedColor = Color(0xFFFFB6C1);
  IconData? _selectedIcon;

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
            // 텍스트 입력
            TextField(
              controller: _textController,
              decoration: InputDecoration(
                labelText: '낙서 내용',
                hintText: '여기에 메시지를 입력하세요',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            SizedBox(height: 16),

            // 사용자명 입력
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: '사용자명 (선택사항)',
                hintText: '이름을 입력하세요',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),

            // 색상 선택
            Text('색상 선택:', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Wrap(
              spacing: 8,
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
            SizedBox(height: 16),

            // 아이콘 선택
            Text('아이콘 선택 (선택사항):', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ...widget.icons.map((icon) {
                  final isSelected = icon == _selectedIcon;
                  return GestureDetector(
                    onTap: () => setState(() =>
                      _selectedIcon = isSelected ? null : icon),
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.grey.shade200 : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected ? Colors.blue : Colors.grey.shade300,
                          width: 2,
                        ),
                      ),
                      child: Icon(icon, size: 24),
                    ),
                  );
                }).toList(),
                // 아이콘 없음 옵션
                GestureDetector(
                  onTap: () => setState(() => _selectedIcon = null),
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: _selectedIcon == null ? Colors.grey.shade200 : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _selectedIcon == null ? Colors.blue : Colors.grey.shade300,
                        width: 2,
                      ),
                    ),
                    child: Icon(Icons.close, size: 24, color: Colors.grey),
                  ),
                ),
              ],
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
            if (_textController.text.trim().isNotEmpty) {
              widget.onAdd(
                _textController.text.trim(),
                _selectedColor,
                _selectedIcon,
                _usernameController.text.trim().isEmpty
                  ? null
                  : _usernameController.text.trim(),
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
    _textController.dispose();
    _usernameController.dispose();
    super.dispose();
  }
}
