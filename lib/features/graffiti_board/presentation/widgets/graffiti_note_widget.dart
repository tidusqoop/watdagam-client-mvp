import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';
import '../../data/models/graffiti_note.dart';
import '../../../../shared/utils/color_utils.dart';
import '../../../../utils/time_utils.dart';
import 'canvas/drag_handler.dart';

/// Individual graffiti note widget
class GraffitiNoteWidget extends StatelessWidget {
  final GraffitiNote note;
  final DragHandler dragHandler;
  final TransformationController transformationController;

  const GraffitiNoteWidget({
    super.key,
    required this.note,
    required this.dragHandler,
    required this.transformationController,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: note.position.dx,
      top: note.position.dy,
      child: GestureDetector(
        onPanUpdate: (details) => dragHandler.handlePanUpdate(
          note,
          details,
          transformationController,
        ),
        child: DottedBorder(
          dashPattern: [8, 6],  // Longer dashes for better visibility
          color: ColorUtils.getBorderColor(note.backgroundColor),  // Darker, more saturated border
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
                NoteAuthorInfo(note: note),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Author and time information widget
class NoteAuthorInfo extends StatelessWidget {
  final GraffitiNote note;

  const NoteAuthorInfo({super.key, required this.note});

  @override
  Widget build(BuildContext context) {
    return Padding(
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
    );
  }
}