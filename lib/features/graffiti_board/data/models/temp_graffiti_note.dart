import 'package:flutter/material.dart';
import 'graffiti_note.dart';

/// 임시 낙서 노트 - 위치 선택 과정에서 사용되는 모델
class TempGraffitiNote {
  final String content;
  final String author;
  final Color backgroundColor;
  final AuthorAlignment authorAlignment;
  final Offset initialPosition;
  final Size size;

  TempGraffitiNote({
    required this.content,
    required this.author,
    required this.backgroundColor,
    required this.authorAlignment,
    required this.initialPosition,
  }) : size = _calculateAutoSize(content);

  /// 내용에 따른 자동 크기 계산
  static Size _calculateAutoSize(String content) {
    final baseSize = Size(140, 100);
    final lineCount = content.split('\n').length;
    final charCount = content.length;
    
    if (charCount > 50 || lineCount > 3) {
      return Size(180, 140); // 큰 크기
    } else if (charCount < 10 && lineCount == 1) {
      return Size(100, 80);  // 작은 크기
    }
    return baseSize; // 기본 크기
  }

  /// 새로운 위치로 복사본 생성
  TempGraffitiNote copyWithPosition(Offset newPosition) {
    return TempGraffitiNote(
      content: content,
      author: author,
      backgroundColor: backgroundColor,
      authorAlignment: authorAlignment,
      initialPosition: newPosition,
    );
  }

  /// 실제 GraffitiNote로 변환
  GraffitiNote toGraffitiNote({String? customId}) {
    return GraffitiNote(
      id: customId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      backgroundColor: backgroundColor,
      position: initialPosition,
      size: size,
      author: author,
      authorAlignment: authorAlignment,
    );
  }

  /// AddGraffitiDialog의 결과로부터 TempGraffitiNote 생성
  static TempGraffitiNote fromDialogResult({
    required String content,
    required Color backgroundColor,
    required String author,
    required AuthorAlignment authorAlignment,
    required Offset initialPosition,
  }) {
    return TempGraffitiNote(
      content: content,
      author: author,
      backgroundColor: backgroundColor,
      authorAlignment: authorAlignment,
      initialPosition: initialPosition,
    );
  }
}