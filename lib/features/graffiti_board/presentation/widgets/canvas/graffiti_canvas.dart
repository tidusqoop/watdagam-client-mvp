import 'package:flutter/material.dart';
import '../../../data/models/graffiti_note.dart';
import '../../../../../core/constants/canvas_constants.dart';
import '../graffiti_note_widget.dart';
import 'grid_painter.dart';
import 'transformation_controller.dart';
import 'drag_handler.dart';

/// Main graffiti canvas widget
class GraffitiCanvas extends StatefulWidget {
  final List<GraffitiNote> notes;
  final Function(GraffitiNote) onNoteUpdate;
  final EnhancedTransformationController transformationController;
  final VoidCallback? onDoubleClick; // 새로 추가

  const GraffitiCanvas({
    super.key,
    required this.notes,
    required this.onNoteUpdate,
    required this.transformationController,
    this.onDoubleClick,
  });

  @override
  State<GraffitiCanvas> createState() => _GraffitiCanvasState();
}

class _GraffitiCanvasState extends State<GraffitiCanvas> {
  late final DragHandler _dragHandler;

  @override
  void initState() {
    super.initState();
    _dragHandler = DragHandler(
      onLocalUpdate: widget.onNoteUpdate,
      onRepositoryUpdate: widget.onNoteUpdate,
    );
  }

  @override
  void dispose() {
    _dragHandler.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTap: widget.onDoubleClick,
      child: InteractiveViewer(
        transformationController: widget.transformationController,
        constrained: false,
        minScale: CanvasConstants.MIN_SCALE,
        maxScale: CanvasConstants.MAX_SCALE,
        child: Container(
          width: CanvasConstants.CANVAS_WIDTH,
          height: CanvasConstants.CANVAS_HEIGHT,
          child: CustomPaint(
            painter: GridPainter(),
            child: Stack(
              children: widget.notes
                  .map((note) => GraffitiNoteWidget(
                        note: note,
                        dragHandler: _dragHandler,
                        transformationController: widget.transformationController,
                      ))
                  .toList(),
            ),
          ),
        ),
      ),
    );
  }
}