# 왔다감 앱 MVP 전략 - 디자인 우선 접근법

## 🎯 전략 방향성

**핵심 원칙**: 샘플 디자인과의 유사성 최대화 + 핵심 기능으로 범위 축소

현재 구현된 기능보다는 **샘플 디자인과 비슷하게 만드는 것**을 최우선으로 하고, 복잡한 하단 툴바를 **낙서 생성 + 확대/축소**만 남기는 MVP 전략으로 진행합니다.

## 📊 현재 상태 vs 목표 분석

### 현재 구현 상태
- ✅ 기본 낙서 노트 표시 (5개 샘플 데이터)
- ✅ 컨테이너 기반 UI 구조
- ✅ 아이콘 + 사용자명 + 텍스트 모델
- ❌ **단색 회색 배경** (`Colors.grey.shade50`)
- ❌ **실선 테두리** (`BorderStyle.solid`)
- ❌ **복잡한 하단 툴바** (14개 버튼)

### 샘플 디자인 목표
- 🎯 **모눈종이 격자 배경** - 즉시 낙서벽 느낌 구현
- 🎯 **점선 테두리** - 진짜 낙서 노트 느낌
- 🎯 **심플한 하단 툴바** - 핵심 기능만

## 🚀 MVP 핵심 기능 정의

### Phase 1: 디자인 개선 (최우선, 2시간)
1. **모눈종이 배경 구현** (60분)
   ```dart
   // CustomPainter로 격자 패턴 그리기
   class GridPainter extends CustomPainter {
     @override
     void paint(Canvas canvas, Size size) {
       final paint = Paint()
         ..color = Colors.grey.shade300
         ..strokeWidth = 0.5;

       // 20px 간격 격자 그리기
       for (double x = 0; x < size.width; x += 20) {
         canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
       }
       for (double y = 0; y < size.height; y += 20) {
         canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
       }
     }
   }
   ```

2. **점선 테두리 적용** (60분)
   ```dart
   // dotted_border 패키지 사용
   dependencies:
     dotted_border: ^2.1.0

   // 적용
   DottedBorder(
     dashPattern: [5, 3],
     color: note.color.withOpacity(0.8),
     strokeWidth: 2,
     child: Container(...)
   )
   ```

### Phase 2: 하단 툴바 단순화 (1시간)
**현재 14개 버튼 → 5개 핵심 버튼으로 축소**

```dart
// 최종 MVP 툴바 구성
Row(
  mainAxisAlignment: MainAxisAlignment.spaceAround,
  children: [
    IconButton(icon: Icons.add, onPressed: _addGraffiti),       // 낙서 추가
    IconButton(icon: Icons.zoom_in, onPressed: _zoomIn),        // 확대
    IconButton(icon: Icons.zoom_out, onPressed: _zoomOut),      // 축소
    IconButton(icon: Icons.pan_tool, onPressed: _panMode),      // 이동 모드
    IconButton(icon: Icons.palette, onPressed: _colorPicker),   // 색상 선택
  ],
)
```

### Phase 3: 기본 상호작용 (2시간)
1. **낙서 추가 기능** (90분)
   - 간단한 다이얼로그로 텍스트 입력
   - 아이콘 선택 (face, favorite, home 3개만)
   - 색상 선택 (6개 기본 색상)

2. **확대/축소 기능** (30분)
   - Transform.scale 위젯 사용
   - 핀치 줌 제스처 지원

## ⚡ 구현 우선순위 (ROI 기준)

| 순위 | 작업 | 예상시간 | 시각적 임팩트 | 구현 난이도 | ROI |
|------|------|----------|---------------|-------------|-----|
| 1 | 모눈종이 배경 | 60분 | ⭐⭐⭐⭐⭐ | ⭐⭐☆☆☆ | 🔥 최고 |
| 2 | 점선 테두리 | 60분 | ⭐⭐⭐⭐☆ | ⭐⭐☆☆☆ | 🔥 최고 |
| 3 | 툴바 단순화 | 60분 | ⭐⭐⭐☆☆ | ⭐☆☆☆☆ | ⚡ 높음 |
| 4 | 낙서 추가 | 90분 | ⭐⭐⭐☆☆ | ⭐⭐⭐☆☆ | ⚡ 높음 |
| 5 | 확대/축소 | 30분 | ⭐⭐☆☆☆ | ⭐⭐☆☆☆ | 💡 보통 |

## 🎨 디자인 시스템 정의

### 색상 팔레트 (샘플 기반)
```dart
final List<Color> graffitiColors = [
  Color(0xFFFFB6C1), // 연분홍 (샘플과 동일)
  Color(0xFFFFEB9C), // 연노랑
  Color(0xFF98FB98), // 연두색
  Color(0xFFB19CD9), // 연보라
  Color(0xFF87CEEB), // 하늘색
  Color(0xFFF0E68C), // 카키색
];
```

### 노트 스타일 표준
- **크기**: 최소 80x60px, 최대 250x150px
- **패딩**: 내부 8px
- **모서리**: 8px 둥근 모서리
- **테두리**: 2px 점선
- **그림자**: 선택사항 (Phase 3에서 고려)

### 아이콘 시스템
```dart
final List<IconData> graffitiIcons = [
  Icons.face,      // 얼굴
  Icons.favorite,  // 하트
  Icons.home,      // 집
];
```

## 📋 즉시 실행 가능한 액션 플랜

### 🎯 2시간 안에 80% 유사도 달성
1. **모눈종이 배경 구현** (첫 번째 작업)
   - `CustomPaint(painter: GridPainter())`로 배경 교체
   - 20px 간격, 연한 회색 선

2. **점선 테두리 적용** (두 번째 작업)
   - `pubspec.yaml`에 `dotted_border` 추가
   - 모든 `_buildGraffitiNote`에 `DottedBorder` 래핑

3. **하단 툴바 리팩토링** (세 번째 작업)
   - 현재 복잡한 2줄 → 1줄 5개 버튼으로 단순화

### 🚀 4시간 안에 기본 상호작용 완성
4. **낙서 추가 다이얼로그**
   - `showDialog`로 간단한 입력 화면
   - 텍스트, 아이콘, 색상 선택

5. **확대/축소 기능**
   - `InteractiveViewer` 위젯 활용

## 💡 기술적 고려사항

### 의존성 추가
```yaml
dependencies:
  flutter:
    sdk: flutter
  dotted_border: ^2.1.0  # 점선 테두리
```

### 상태 관리
- 현재 `StatefulWidget` 구조 유지 (단순함)
- 추후 Provider 고려 (Phase 3 이후)

### 성능 최적화
- CustomPainter 캐싱
- 노트 개수 제한 (50개 이하 권장)

## 📊 예상 결과

### 2시간 후
- 샘플과 **80% 유사한 비주얼**
- 즉시 "낙서벽" 컨셉 인식 가능
- 전문적인 첫인상

### 4시간 후
- **기본적인 낙서 추가 가능**
- 확대/축소로 둘러보기 가능
- 데모 가능한 수준의 MVP

### 다음 단계 고려사항
- 드래그앤드롭 완성 (현재 부분 구현)
- 노트 편집/삭제 기능
- 로컬 저장 기능
- 실시간 동기화 (장기적)

## 🤔 의사결정 포인트

1. **언제 시작하시겠습니까?**
   - 지금 당장: 모눈종이 배경부터
   - 계획 먼저: 더 구체적인 설계 후

2. **첫 번째 목표는?**
   - 2시간 내 비주얼 개선: 즉시 효과
   - 4시간 내 기능 완성: 완전한 MVP

3. **다음 세션 준비는?**
   - 필요한 패키지 미리 설치
   - 디자인 레퍼런스 정리
   - 코드 백업 및 브랜치 생성

**어떤 방향으로 진행하시겠습니까?**