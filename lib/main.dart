import 'package:flutter/material.dart';

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

class GraffitiWallScreen extends StatefulWidget {
  const GraffitiWallScreen({super.key});

  @override
  State<GraffitiWallScreen> createState() => _GraffitiWallScreenState();
}

class _GraffitiWallScreenState extends State<GraffitiWallScreen> {
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
          // Main wall area
          Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.grey.shade50,
            child: Stack(
              children: notes.map((note) => _buildGraffitiNote(note)).toList(),
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
          // Handle dragging
        },
        child: Container(
          width: note.size.width,
          height: note.size.height,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: note.color,
            border: Border.all(
              color: note.color.withOpacity(0.8),
              width: 2,
              style: BorderStyle.solid,
            ),
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
    );
  }

  Widget _buildBottomToolbar() {
    return Container(
      height: 120,
      color: Colors.white,
      child: Column(
        children: [
          // Top row with tools
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildToolButton(Icons.gesture, Colors.black),
                _buildToolButton(Icons.edit, Colors.black),
                _buildToolButton(Icons.edit_outlined, Colors.black),
                _buildToolButton(Icons.text_fields, Colors.black),
                _buildToolButton(Icons.crop_free, Colors.black),
                const Spacer(),
                _buildToolButton(Icons.search, Colors.black),
                _buildToolButton(Icons.zoom_in, Colors.black),
              ],
            ),
          ),
          // Bottom row with colors
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildColorButton(Colors.red),
                _buildColorButton(Colors.teal),
                _buildColorButton(Colors.yellow),
                _buildColorButton(Colors.green.shade300),
                _buildColorButton(Colors.pink.shade200),
                _buildColorButton(Colors.purple),
                const Spacer(),
                _buildToolButton(Icons.undo, Colors.black),
                _buildToolButton(Icons.redo, Colors.black),
                _buildToolButton(Icons.visibility, Colors.black),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolButton(IconData icon, Color color) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: Colors.white, size: 20),
    );
  }

  Widget _buildColorButton(Color color) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}
