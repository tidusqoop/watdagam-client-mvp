import 'package:flutter/material.dart';

enum AuthorAlignment {
  center,    // 중앙 정렬
  right,     // 오른쪽 정렬
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
  final DateTime createdAt;       // 작성 시간

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
    DateTime? createdAt,          // Allow null input for convenience
  }) : author = (author?.trim().isEmpty ?? true) ? '익명' : author!.trim(),
       createdAt = createdAt ?? DateTime.now();

  GraffitiNote copyWith({
    String? id,
    String? content,
    Color? backgroundColor,
    Offset? position,
    Size? size,
    String? author,
    AuthorAlignment? authorAlignment,
    double? opacity,
    double? cornerRadius,
    DateTime? createdAt,
  }) {
    return GraffitiNote(
      id: id ?? this.id,
      content: content ?? this.content,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      position: position ?? this.position,
      size: size ?? this.size,
      author: author ?? this.author,
      authorAlignment: authorAlignment ?? this.authorAlignment,
      opacity: opacity ?? this.opacity,
      cornerRadius: cornerRadius ?? this.cornerRadius,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

extension GraffitiNoteJson on GraffitiNote {
  // JSON에서 GraffitiNote로 변환
  static GraffitiNote fromJson(Map<String, dynamic> json) {
    return GraffitiNote(
      id: json['id'] as String,
      content: json['content'] as String,
      backgroundColor: _hexToColor(json['background_color'] as String),
      position: Offset(
        (json['position']['x'] as num).toDouble(),
        (json['position']['y'] as num).toDouble(),
      ),
      size: Size(
        (json['size']['width'] as num).toDouble(),
        (json['size']['height'] as num).toDouble(),
      ),
      author: json['author'] as String?,
      authorAlignment: _stringToAlignment(json['author_alignment'] as String? ?? 'center'),
      opacity: (json['opacity'] as num?)?.toDouble() ?? 0.7,
      cornerRadius: (json['corner_radius'] as num?)?.toDouble() ?? 12.0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  // GraffitiNote를 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'background_color': _colorToHex(backgroundColor),
      'position': {
        'x': position.dx,
        'y': position.dy,
      },
      'size': {
        'width': size.width,
        'height': size.height,
      },
      'author': author,
      'author_alignment': _alignmentToString(authorAlignment),
      'opacity': opacity,
      'corner_radius': cornerRadius,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Helper methods for JSON conversion
  static Color _hexToColor(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) {
      hex = 'FF$hex'; // Add alpha if not present
    }
    return Color(int.parse(hex, radix: 16));
  }

  static String _colorToHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
  }

  static AuthorAlignment _stringToAlignment(String alignment) {
    switch (alignment.toLowerCase()) {
      case 'right':
        return AuthorAlignment.right;
      case 'center':
      default:
        return AuthorAlignment.center;
    }
  }

  static String _alignmentToString(AuthorAlignment alignment) {
    switch (alignment) {
      case AuthorAlignment.right:
        return 'right';
      case AuthorAlignment.center:
        return 'center';
    }
  }
}