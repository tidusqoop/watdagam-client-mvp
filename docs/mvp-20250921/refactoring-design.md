# 왔다감 앱 리팩토링 설계 문서

## 📋 목차
1. [현재 상태 분석](#현재-상태-분석)
2. [설계 목표](#설계-목표)
3. [아키텍처 설계](#아키텍처-설계)
4. [상세 설계](#상세-설계)
5. [마이그레이션 계획](#마이그레이션-계획)
6. [구현 가이드라인](#구현-가이드라인)

---

## 🔍 현재 상태 분석

### 주요 문제점
- **단일 파일 집중**: `lib/main.dart`에 1,200+ 라인, 8개 클래스 집중
- **관심사 분리 부족**: UI, 비즈니스 로직, 상태 관리 혼재
- **확장성 제약**: 새 화면 추가 시 복잡도 급증
- **테스트 어려움**: 거대한 위젯으로 인한 유닛 테스트 한계

### 현재 클래스 구조
```
lib/main.dart:
├── WatdagamApp (앱 루트)
├── CanvasConfig (상수 클래스)
├── CorrectTransformationController (줌/팬 컨트롤러)
├── GridPainter (격자 그리기)
├── OptimizedDragHandler (드래그 처리)
├── UnifiedDragHandler (레거시 지원)
├── ZoomIndicator (줌 표시기)
├── GraffitiWallScreen (메인 화면)
└── _AddGraffitiDialog (다이얼로그)
```

### 기존 데이터 레이어 (양호)
```
lib/data/:
├── models/graffiti_note.dart ✅
├── repositories/graffiti_repository.dart ✅
├── datasources/ ✅
│   ├── graffiti_datasource.dart
│   ├── mock_graffiti_datasource.dart
│   ├── api_graffiti_datasource.dart
│   └── datasource_factory.dart
└── mock/graffiti_notes.json ✅
```

---

## 🎯 설계 목표

### 1. 확장성 (Scalability)
- 새 화면 추가 용이성
- 기능별 독립적 개발 가능
- 컴포넌트 재사용성 극대화

### 2. 유지보수성 (Maintainability)
- 관심사 분리 (Separation of Concerns)
- 단일 책임 원칙 (Single Responsibility)
- 명확한 의존성 구조

### 3. 테스트 가능성 (Testability)
- 위젯별 독립 테스트
- 비즈니스 로직 단위 테스트
- Mock 데이터 활용 용이성

### 4. 성능 최적화 (Performance)
- 불필요한 위젯 리빌드 방지
- 상태 관리 최적화
- 메모리 사용량 관리

---

## 🏗️ 아키텍처 설계

### Feature-based Clean Architecture

```
lib/
├── main.dart                           # 앱 진입점
├── app/
│   ├── app.dart                       # MaterialApp 설정
│   └── routes/
│       ├── app_routes.dart            # 라우트 정의
│       └── route_generator.dart       # 동적 라우팅
├── core/
│   ├── constants/                     # 앱 전체 상수
│   ├── theme/                         # 테마 정의
│   ├── widgets/                       # 공통 위젯
│   └── utils/                         # 공통 유틸리티
├── features/
│   ├── auth/                          # 인증 기능
│   ├── wall_selection/                # 낙서장 선택
│   └── graffiti_board/                # 낙서판 (현재 구현)
├── shared/                            # 도메인 간 공유
└── config/                            # 환경 설정
```

### 각 Feature 내부 구조 (Clean Architecture)

```
features/graffiti_board/
├── data/                              # 데이터 레이어
│   ├── models/
│   ├── repositories/
│   └── datasources/
├── domain/                            # 도메인 레이어
│   ├── entities/
│   ├── repositories/
│   └── usecases/
└── presentation/                      # 프레젠테이션 레이어
    ├── screens/
    ├── widgets/
    └── blocs/ (또는 providers/)
```

---

## 📐 상세 설계

### 1. 앱 진입점 단순화

#### `lib/main.dart`
```dart
void main() {
  // 환경 설정 초기화
  AppConfig.printConfig();
  
  // 의존성 주입 설정
  final repository = GraffitiRepository(
    DataSourceFactory.createGraffitiDataSource()
  );
  
  runApp(WatdagamApp(repository: repository));
}
```

#### `lib/app/app.dart`
```dart
class WatdagamApp extends StatelessWidget {
  final GraffitiRepository repository;
  
  const WatdagamApp({super.key, required this.repository});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '왔다감',
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.graffitiWall,
      onGenerateRoute: RouteGenerator.generateRoute,
      home: GraffitiWallScreen(repository: repository),
    );
  }
}
```

### 2. 핵심 상수 분리

#### `lib/core/constants/canvas_constants.dart`
```dart
class CanvasConstants {
  static const double CANVAS_WIDTH = 3000.0;
  static const double CANVAS_HEIGHT = 4000.0;
  static const double GRID_SIZE = 20.0;
  static const double MIN_SCALE = 0.3;
  static const double MAX_SCALE = 2.0;
}
```

#### `lib/core/constants/app_constants.dart`
```dart
class AppConstants {
  static const String APP_NAME = '왔다감';
  static const Duration DRAG_UPDATE_DELAY = Duration(milliseconds: 200);
  static const Duration ZOOM_INDICATOR_DURATION = Duration(seconds: 2);
}
```

### 3. 테마 및 색상 시스템

#### `lib/core/theme/color_palette.dart`
```dart
class ColorPalette {
  static const List<Color> graffitiColors = [
    Color(0xFFFFFFF8), // 따뜻한 화이트
    Color(0xFFF0F8E8), // 소프트 그린
    Color(0xFFE6F3FF), // 베이비 블루
    Color(0xFFFFF2CC), // 바닐라
    Color(0xFFFFE5B4), // 크림 옐로우
    Color(0xFFF5E6FF), // 라이트 퍼플
    Color(0xFFFFE6F0), // 로즈 핑크
    Color(0xFFB4E5D1), // 민트 그린
    Color(0xFFFFD1DC), // 베이비 핑크
    Color(0xFFD4C5F9), // 라벤더 퍼플
    Color(0xFFFFC1CC), // 부드러운 핑크
  ];
  
  static const List<String> quickEmojis = [
    '😊', '❤️', '🏠', '✈️', '📸', '🎉', '👋', '💕'
  ];
}
```

#### `lib/core/theme/app_theme.dart`
```dart
class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.pink),
      useMaterial3: true,
      scaffoldBackgroundColor: Colors.grey.shade100,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: IconThemeData(color: Colors.black),
        titleTextStyle: TextStyle(
          color: Colors.black,
          fontSize: 16,
          fontWeight: FontWeight.normal,
        ),
      ),
    );
  }
}
```

### 4. 낙서판 기능 모듈화

#### `lib/features/graffiti_board/presentation/screens/graffiti_wall_screen.dart`
```dart
class GraffitiWallScreen extends StatefulWidget {
  final GraffitiRepository repository;
  
  const GraffitiWallScreen({super.key, required this.repository});
  
  @override
  State<GraffitiWallScreen> createState() => _GraffitiWallScreenState();
}

class _GraffitiWallScreenState extends State<GraffitiWallScreen> {
  late final GraffitiBloc _graffitiBloc;
  late final CanvasBloc _canvasBloc;
  
  @override
  void initState() {
    super.initState();
    _graffitiBloc = GraffitiBloc(widget.repository);
    _canvasBloc = CanvasBloc();
    _graffitiBloc.add(LoadGraffitiNotes());
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GraffitiAppBar(),
      body: BlocBuilder<GraffitiBloc, GraffitiState>(
        bloc: _graffitiBloc,
        builder: (context, state) {
          return Stack(
            children: [
              GraffitiCanvas(
                notes: state.notes,
                canvasBloc: _canvasBloc,
                onNoteUpdate: (note) => _graffitiBloc.add(UpdateNote(note)),
              ),
              Positioned(
                top: 20,
                right: 20,
                child: ZoomIndicator(),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: BottomToolbar(
                  onAddGraffiti: () => _showAddGraffitiDialog(),
                  onZoomIn: () => _canvasBloc.add(ZoomInEvent()),
                  onZoomOut: () => _canvasBloc.add(ZoomOutEvent()),
                  onResetView: () => _canvasBloc.add(ResetViewEvent()),
                  onRefresh: () => _graffitiBloc.add(LoadGraffitiNotes()),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
```

### 5. 위젯 컴포넌트 분리

#### `lib/features/graffiti_board/presentation/widgets/graffiti_canvas.dart`
```dart
class GraffitiCanvas extends StatefulWidget {
  final List<GraffitiNote> notes;
  final CanvasBloc canvasBloc;
  final Function(GraffitiNote) onNoteUpdate;
  
  const GraffitiCanvas({
    super.key,
    required this.notes,
    required this.canvasBloc,
    required this.onNoteUpdate,
  });
  
  @override
  State<GraffitiCanvas> createState() => _GraffitiCanvasState();
}

class _GraffitiCanvasState extends State<GraffitiCanvas> {
  late final TransformationController _transformationController;
  late final DragHandler _dragHandler;
  
  @override
  void initState() {
    super.initState();
    _transformationController = EnhancedTransformationController();
    _dragHandler = DragHandler(onNoteUpdate: widget.onNoteUpdate);
  }
  
  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
      transformationController: _transformationController,
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
                      transformationController: _transformationController,
                    ))
                .toList(),
          ),
        ),
      ),
    );
  }
}
```

#### `lib/features/graffiti_board/presentation/widgets/graffiti_note_widget.dart`
```dart
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
          dashPattern: [8, 6],
          color: ColorUtils.getBorderColor(note.backgroundColor),
          strokeWidth: 2.5,
          borderType: BorderType.RRect,
          radius: Radius.circular(note.cornerRadius),
          child: Container(
            width: note.size.width,
            height: note.size.height,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: note.backgroundColor.withOpacity(note.opacity),
              borderRadius: BorderRadius.circular(note.cornerRadius),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  offset: Offset(0, 3),
                  blurRadius: 6,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
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
                NoteAuthorInfo(note: note),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

### 6. 상태 관리 (Bloc Pattern)

#### `lib/features/graffiti_board/presentation/blocs/graffiti_bloc.dart`
```dart
// Events
abstract class GraffitiEvent {}

class LoadGraffitiNotes extends GraffitiEvent {}

class AddNote extends GraffitiEvent {
  final GraffitiNote note;
  AddNote(this.note);
}

class UpdateNote extends GraffitiEvent {
  final GraffitiNote note;
  UpdateNote(this.note);
}

class DeleteNote extends GraffitiEvent {
  final String noteId;
  DeleteNote(this.noteId);
}

// States
abstract class GraffitiState {
  final List<GraffitiNote> notes;
  final bool isLoading;
  final String? errorMessage;
  
  const GraffitiState({
    this.notes = const [],
    this.isLoading = false,
    this.errorMessage,
  });
}

class GraffitiInitial extends GraffitiState {}

class GraffitiLoading extends GraffitiState {
  const GraffitiLoading() : super(isLoading: true);
}

class GraffitiLoaded extends GraffitiState {
  const GraffitiLoaded(List<GraffitiNote> notes) : super(notes: notes);
}

class GraffitiError extends GraffitiState {
  const GraffitiError(String error) : super(errorMessage: error);
}

// Bloc
class GraffitiBloc extends Bloc<GraffitiEvent, GraffitiState> {
  final GraffitiRepository _repository;
  
  GraffitiBloc(this._repository) : super(GraffitiInitial()) {
    on<LoadGraffitiNotes>(_onLoadNotes);
    on<AddNote>(_onAddNote);
    on<UpdateNote>(_onUpdateNote);
    on<DeleteNote>(_onDeleteNote);
  }
  
  Future<void> _onLoadNotes(
    LoadGraffitiNotes event,
    Emitter<GraffitiState> emit,
  ) async {
    emit(GraffitiLoading());
    try {
      final notes = await _repository.getNotes();
      emit(GraffitiLoaded(notes));
    } catch (e) {
      emit(GraffitiError(e.toString()));
    }
  }
  
  Future<void> _onAddNote(
    AddNote event,
    Emitter<GraffitiState> emit,
  ) async {
    try {
      final addedNote = await _repository.addNote(event.note);
      final currentNotes = List<GraffitiNote>.from(state.notes);
      currentNotes.add(addedNote);
      emit(GraffitiLoaded(currentNotes));
    } catch (e) {
      emit(GraffitiError(e.toString()));
    }
  }
  
  Future<void> _onUpdateNote(
    UpdateNote event,
    Emitter<GraffitiState> emit,
  ) async {
    try {
      await _repository.updateNotePositionOptimized(
        event.note.id, 
        event.note.position,
      );
      
      final currentNotes = List<GraffitiNote>.from(state.notes);
      final index = currentNotes.indexWhere((n) => n.id == event.note.id);
      if (index != -1) {
        currentNotes[index] = event.note;
        emit(GraffitiLoaded(currentNotes));
      }
    } catch (e) {
      // 에러 발생 시 로컬 상태는 유지하고 로그만 남김
      if (AppConfig.enableDebugLogging) {
        print('Error updating note: $e');
      }
    }
  }
  
  Future<void> _onDeleteNote(
    DeleteNote event,
    Emitter<GraffitiState> emit,
  ) async {
    try {
      await _repository.deleteNote(event.noteId);
      final currentNotes = state.notes
          .where((note) => note.id != event.noteId)
          .toList();
      emit(GraffitiLoaded(currentNotes));
    } catch (e) {
      emit(GraffitiError(e.toString()));
    }
  }
}
```

#### `lib/features/graffiti_board/presentation/blocs/canvas_bloc.dart`
```dart
// Events
abstract class CanvasEvent {}

class ZoomInEvent extends CanvasEvent {}
class ZoomOutEvent extends CanvasEvent {}
class ResetViewEvent extends CanvasEvent {}
class UpdateZoomLevelEvent extends CanvasEvent {
  final double zoomLevel;
  UpdateZoomLevelEvent(this.zoomLevel);
}

// States
class CanvasState {
  final double zoomLevel;
  final bool showZoomIndicator;
  final Offset viewportCenter;
  
  const CanvasState({
    this.zoomLevel = 1.0,
    this.showZoomIndicator = false,
    this.viewportCenter = Offset.zero,
  });
  
  CanvasState copyWith({
    double? zoomLevel,
    bool? showZoomIndicator,
    Offset? viewportCenter,
  }) {
    return CanvasState(
      zoomLevel: zoomLevel ?? this.zoomLevel,
      showZoomIndicator: showZoomIndicator ?? this.showZoomIndicator,
      viewportCenter: viewportCenter ?? this.viewportCenter,
    );
  }
}

// Bloc
class CanvasBloc extends Bloc<CanvasEvent, CanvasState> {
  Timer? _zoomIndicatorTimer;
  
  CanvasBloc() : super(CanvasState()) {
    on<ZoomInEvent>(_onZoomIn);
    on<ZoomOutEvent>(_onZoomOut);
    on<ResetViewEvent>(_onResetView);
    on<UpdateZoomLevelEvent>(_onUpdateZoomLevel);
  }
  
  void _onZoomIn(ZoomInEvent event, Emitter<CanvasState> emit) {
    final newZoom = (state.zoomLevel * 1.2).clamp(
      CanvasConstants.MIN_SCALE, 
      CanvasConstants.MAX_SCALE,
    );
    _emitWithZoomIndicator(emit, newZoom);
  }
  
  void _onZoomOut(ZoomOutEvent event, Emitter<CanvasState> emit) {
    final newZoom = (state.zoomLevel / 1.2).clamp(
      CanvasConstants.MIN_SCALE, 
      CanvasConstants.MAX_SCALE,
    );
    _emitWithZoomIndicator(emit, newZoom);
  }
  
  void _onResetView(ResetViewEvent event, Emitter<CanvasState> emit) {
    emit(state.copyWith(
      zoomLevel: 1.0,
      viewportCenter: Offset.zero,
    ));
  }
  
  void _onUpdateZoomLevel(UpdateZoomLevelEvent event, Emitter<CanvasState> emit) {
    _emitWithZoomIndicator(emit, event.zoomLevel);
  }
  
  void _emitWithZoomIndicator(Emitter<CanvasState> emit, double zoomLevel) {
    emit(state.copyWith(
      zoomLevel: zoomLevel,
      showZoomIndicator: true,
    ));
    
    _zoomIndicatorTimer?.cancel();
    _zoomIndicatorTimer = Timer(AppConstants.ZOOM_INDICATOR_DURATION, () {
      emit(state.copyWith(showZoomIndicator: false));
    });
  }
  
  @override
  Future<void> close() {
    _zoomIndicatorTimer?.cancel();
    return super.close();
  }
}
```

### 7. 공통 컴포넌트

#### `lib/shared/widgets/custom_dialog.dart`
```dart
class CustomDialog extends StatelessWidget {
  final String title;
  final Widget content;
  final List<Widget>? actions;
  final EdgeInsets? contentPadding;
  
  const CustomDialog({
    super.key,
    required this.title,
    required this.content,
    this.actions,
    this.contentPadding,
  });
  
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
            _buildHeader(context),
            Flexible(
              child: SingleChildScrollView(
                padding: contentPadding ?? EdgeInsets.all(24),
                child: content,
              ),
            ),
            if (actions != null) ...[
              Padding(
                padding: EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Column(children: actions!),
              ),
            ],
          ],
        ),
      ),
    );
  }
  
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
          Expanded(
            child: Text(
              title,
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
}
```

### 8. 유틸리티 클래스

#### `lib/shared/utils/color_utils.dart`
```dart
class ColorUtils {
  static Color getBorderColor(Color backgroundColor) {
    final HSVColor hsv = HSVColor.fromColor(backgroundColor);
    return hsv
        .withSaturation((hsv.saturation + 0.3).clamp(0.0, 1.0))
        .withValue((hsv.value - 0.4).clamp(0.0, 1.0))
        .toColor();
  }
  
  static Color getContrastColor(Color color) {
    final luminance = color.computeLuminance();
    return luminance > 0.5 ? Colors.black54 : Colors.white;
  }
}
```

#### `lib/shared/utils/coordinate_utils.dart`
```dart
class CoordinateUtils {
  static Offset calculateWorldDelta(
    DragUpdateDetails details,
    TransformationController controller,
  ) {
    // GestureDetector가 InteractiveViewer 내부에 있으므로
    // details.delta는 이미 월드 좌표계의 델타임
    return details.delta;
  }
  
  static Offset getCurrentWorldCenter(
    TransformationController controller,
    Size screenSize,
  ) {
    final transform = controller.value;
    final screenCenter = Offset(screenSize.width / 2, screenSize.height / 2);
    final scale = transform.getMaxScaleOnAxis();
    final translation = transform.getTranslation();
    
    return Offset(
      (screenCenter.dx - translation.x) / scale,
      (screenCenter.dy - translation.y) / scale,
    );
  }
  
  static Offset clampToCanvasBounds(
    Offset position,
    Size noteSize,
  ) {
    return Offset(
      position.dx.clamp(0.0, CanvasConstants.CANVAS_WIDTH - noteSize.width),
      position.dy.clamp(0.0, CanvasConstants.CANVAS_HEIGHT - noteSize.height),
    );
  }
}
```

---

## 🚀 마이그레이션 계획

### Phase 1: 기본 구조 생성 (1-2일)

**1단계: 디렉토리 구조 생성**
```bash
mkdir -p lib/{app/{routes},core/{constants,theme,widgets,utils},features/graffiti_board/{presentation/{screens,widgets,blocs}},shared/{widgets,utils}}
```

**2단계: 상수 및 테마 분리**
- `CanvasConfig` → `lib/core/constants/canvas_constants.dart`
- 색상 팔레트 → `lib/core/theme/color_palette.dart`
- 앱 테마 → `lib/core/theme/app_theme.dart`

**3단계: 앱 구조 분리**
- `WatdagamApp` → `lib/app/app.dart`
- 라우팅 시스템 준비

### Phase 2: UI 컴포넌트 분리 (2-3일)

**1단계: 핵심 위젯 분리**
- `GraffitiWallScreen` → `lib/features/graffiti_board/presentation/screens/`
- `_AddGraffitiDialog` → `lib/features/graffiti_board/presentation/widgets/`
- `ZoomIndicator` → `lib/features/graffiti_board/presentation/widgets/`

**2단계: 캔버스 관련 컴포넌트 분리**
- `CorrectTransformationController` → `lib/features/graffiti_board/presentation/widgets/canvas/`
- `GridPainter` → `lib/features/graffiti_board/presentation/widgets/canvas/`
- `OptimizedDragHandler` → `lib/features/graffiti_board/presentation/widgets/canvas/`

**3단계: 재사용 가능한 컴포넌트 생성**
- 개별 낙서 노트 위젯 분리
- 하단 툴바 컴포넌트 분리
- 공통 다이얼로그 컴포넌트 생성

### Phase 3: 상태 관리 도입 (2-3일)

**1단계: Bloc 패턴 설정**
- `flutter_bloc` 의존성 추가
- `GraffitiBloc` 구현
- `CanvasBloc` 구현

**2단계: 상태 기반 UI 재구성**
- 기존 `setState` 기반 로직을 Bloc으로 전환
- 비동기 작업 Bloc으로 이관
- 에러 상태 관리 개선

**3단계: 성능 최적화**
- 불필요한 위젯 리빌드 제거
- `BlocBuilder`와 `BlocListener` 적절히 활용
- 메모리 누수 방지

### Phase 4: 공통 컴포넌트 및 유틸리티 (1-2일)

**1단계: 유틸리티 클래스 생성**
- 색상 계산 유틸리티
- 좌표 계산 유틸리티
- 시간 포맷팅 유틸리티

**2단계: 공통 위젯 라이브러리**
- 재사용 가능한 버튼 컴포넌트
- 공통 다이얼로그 시스템
- 로딩 및 에러 표시 컴포넌트

### Phase 5: 새 기능 준비 (각 1-2일)

**1단계: 인증 모듈 구조 준비**
- `lib/features/auth/` 디렉토리 생성
- 로그인/회원가입 화면 틀 구성
- 인증 상태 관리 준비

**2단계: 낙서장 선택 모듈 준비**
- `lib/features/wall_selection/` 디렉토리 생성
- 낙서장 목록 화면 틀 구성
- 낙서장 데이터 모델 설계

**3단계: 라우팅 시스템 완성**
- 화면 간 네비게이션 구현
- 딥링크 대응 준비
- 상태 유지 전략 수립

---

## 📋 구현 가이드라인

### 코딩 컨벤션

**1. 파일 및 클래스 명명**
```dart
// 파일명: snake_case
graffiti_wall_screen.dart
add_graffiti_dialog.dart

// 클래스명: PascalCase
class GraffitiWallScreen
class AddGraffitiDialog

// 변수 및 함수명: camelCase
final graffitiRepository
void onAddGraffiti()
```

**2. 디렉토리 구조 규칙**
- `screens/`: 전체 화면 위젯
- `widgets/`: 재사용 가능한 UI 컴포넌트
- `blocs/`: 상태 관리 (Bloc 패턴)
- `models/`: 데이터 모델
- `utils/`: 유틸리티 함수

**3. Import 순서**
```dart
// 1. Dart core libraries
import 'dart:async';
import 'dart:math';

// 2. Flutter libraries
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 3. Third-party packages
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dotted_border/dotted_border.dart';

// 4. Project imports (최상위부터)
import '../../config/app_config.dart';
import '../data/models/graffiti_note.dart';
import 'widgets/graffiti_canvas.dart';
```

### 성능 최적화 가이드라인

**1. 위젯 최적화**
```dart
// 좋은 예: const 생성자 사용
const GraffitiNoteWidget({
  super.key,
  required this.note,
});

// 나쁜 예: const 없이 위젯 생성
GraffitiNoteWidget({
  super.key,
  required this.note,
});
```

**2. 상태 관리 최적화**
```dart
// BlocBuilder 사용 시 특정 상태만 리빌드
BlocBuilder<GraffitiBloc, GraffitiState>(
  buildWhen: (previous, current) => 
      previous.notes.length != current.notes.length,
  builder: (context, state) {
    return YourWidget();
  },
);
```

**3. 메모리 관리**
```dart
@override
void dispose() {
  _transformationController.dispose();
  _dragHandler.dispose();
  _graffitiBloc.close();
  _canvasBloc.close();
  super.dispose();
}
```

### 테스트 전략

**1. 단위 테스트 (Unit Tests)**
```dart
// test/features/graffiti_board/blocs/graffiti_bloc_test.dart
group('GraffitiBloc', () {
  late GraffitiBloc bloc;
  late MockGraffitiRepository repository;
  
  setUp(() {
    repository = MockGraffitiRepository();
    bloc = GraffitiBloc(repository);
  });
  
  test('initial state is GraffitiInitial', () {
    expect(bloc.state, isA<GraffitiInitial>());
  });
  
  blocTest<GraffitiBloc, GraffitiState>(
    'emits [GraffitiLoading, GraffitiLoaded] when LoadGraffitiNotes is added',
    build: () => bloc,
    act: (bloc) => bloc.add(LoadGraffitiNotes()),
    expect: () => [
      isA<GraffitiLoading>(),
      isA<GraffitiLoaded>(),
    ],
  );
});
```

**2. 위젯 테스트 (Widget Tests)**
```dart
// test/features/graffiti_board/widgets/graffiti_note_widget_test.dart
testWidgets('GraffitiNoteWidget displays note content', (tester) async {
  final note = GraffitiNote(
    id: '1',
    content: 'Test content',
    backgroundColor: Colors.white,
    position: Offset.zero,
    size: Size(100, 100),
  );
  
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: GraffitiNoteWidget(
          note: note,
          dragHandler: MockDragHandler(),
          transformationController: TransformationController(),
        ),
      ),
    ),
  );
  
  expect(find.text('Test content'), findsOneWidget);
});
```

**3. 통합 테스트 (Integration Tests)**
```dart
// integration_test/graffiti_flow_test.dart
testWidgets('User can add and view graffiti notes', (tester) async {
  await tester.pumpWidget(MyApp());
  
  // 낙서 추가 버튼 탭
  await tester.tap(find.byIcon(Icons.add));
  await tester.pumpAndSettle();
  
  // 내용 입력
  await tester.enterText(find.byType(TextField), 'Test graffiti');
  
  // 저장 버튼 탭
  await tester.tap(find.text('낙서 만들기'));
  await tester.pumpAndSettle();
  
  // 낙서가 화면에 표시되는지 확인
  expect(find.text('Test graffiti'), findsOneWidget);
});
```

### 데이터 흐름 다이어그램

```
User Interaction
       ↓
  UI Widget
       ↓
   Bloc Event
       ↓
  Bloc Handler
       ↓
  Repository
       ↓
  DataSource
       ↓
   Backend/Mock
       ↓
  Repository
       ↓
   Bloc State
       ↓
  UI Update
```

### 에러 처리 전략

**1. Repository 레벨**
```dart
Future<List<GraffitiNote>> getNotes() async {
  try {
    return await _dataSource.getAllNotes();
  } on NetworkException catch (e) {
    throw RepositoryException('Network error: ${e.message}');
  } on CacheException catch (e) {
    throw RepositoryException('Cache error: ${e.message}');
  } catch (e) {
    throw RepositoryException('Unknown error: $e');
  }
}
```

**2. Bloc 레벨**
```dart
Future<void> _onLoadNotes(
  LoadGraffitiNotes event,
  Emitter<GraffitiState> emit,
) async {
  emit(GraffitiLoading());
  try {
    final notes = await _repository.getNotes();
    emit(GraffitiLoaded(notes));
  } on RepositoryException catch (e) {
    emit(GraffitiError(e.message));
  } catch (e) {
    emit(GraffitiError('Unexpected error occurred'));
  }
}
```

**3. UI 레벨**
```dart
BlocListener<GraffitiBloc, GraffitiState>(
  listener: (context, state) {
    if (state is GraffitiError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.errorMessage),
          action: SnackBarAction(
            label: 'Retry',
            onPressed: () => bloc.add(LoadGraffitiNotes()),
          ),
        ),
      );
    }
  },
  child: YourWidget(),
);
```

### 의존성 주입 전략

**1. Repository 의존성**
```dart
class GraffitiWallScreen extends StatefulWidget {
  final GraffitiRepository repository;
  
  const GraffitiWallScreen({
    super.key,
    required this.repository,
  });
}
```

**2. Bloc 의존성**
```dart
class GraffitiBloc extends Bloc<GraffitiEvent, GraffitiState> {
  final GraffitiRepository _repository;
  final AnalyticsService _analytics;
  
  GraffitiBloc({
    required GraffitiRepository repository,
    required AnalyticsService analytics,
  }) : _repository = repository,
       _analytics = analytics,
       super(GraffitiInitial());
}
```

---

## 📈 확장 계획

### 다음 기능들을 위한 준비

**1. 인증 시스템**
```
lib/features/auth/
├── data/
│   ├── models/user.dart
│   ├── repositories/auth_repository.dart
│   └── datasources/auth_datasource.dart
├── domain/
│   ├── entities/user_entity.dart
│   └── usecases/login_usecase.dart
└── presentation/
    ├── screens/login_screen.dart
    ├── widgets/login_form.dart
    └── blocs/auth_bloc.dart
```

**2. 낙서장 선택**
```
lib/features/wall_selection/
├── data/
│   ├── models/graffiti_wall.dart
│   └── repositories/wall_repository.dart
└── presentation/
    ├── screens/wall_selection_screen.dart
    ├── widgets/wall_card.dart
    └── blocs/wall_selection_bloc.dart
```

**3. 낙서장 배치 UI**
```
lib/features/wall_layout/
└── presentation/
    ├── screens/wall_layout_screen.dart
    ├── widgets/layout_designer.dart
    └── blocs/layout_bloc.dart
```

### 성능 모니터링

**1. 메트릭 수집**
- 위젯 렌더링 시간
- 메모리 사용량
- 네트워크 응답 시간
- 사용자 인터랙션 지연시간

**2. 모니터링 도구**
- Flutter Inspector
- Firebase Performance Monitoring
- Crashlytics
- Custom Analytics

---

## ✅ 마이그레이션 체크리스트

### Phase 1 체크리스트
- [ ] 디렉토리 구조 생성
- [ ] 상수 클래스 분리
- [ ] 테마 시스템 구축
- [ ] 앱 진입점 단순화

### Phase 2 체크리스트
- [ ] 메인 화면 위젯 분리
- [ ] 다이얼로그 컴포넌트 분리
- [ ] 캔버스 관련 컴포넌트 분리
- [ ] 개별 낙서 노트 위젯 분리

### Phase 3 체크리스트
- [ ] Bloc 패턴 도입
- [ ] 상태 기반 UI 전환
- [ ] 에러 처리 개선
- [ ] 성능 최적화

### Phase 4 체크리스트
- [ ] 공통 유틸리티 생성
- [ ] 재사용 가능한 위젯 라이브러리
- [ ] 테스트 코드 작성
- [ ] 문서화 완료

### Phase 5 체크리스트
- [ ] 새 기능 모듈 구조 준비
- [ ] 라우팅 시스템 완성
- [ ] 상태 관리 통합
- [ ] 배포 준비

---

이 설계 문서를 기반으로 단계적 리팩토링을 진행하면, 현재의 거대한 단일 파일을 유지보수 가능하고 확장 가능한 모듈형 구조로 전환할 수 있습니다. 각 단계는 독립적으로 실행 가능하며, 기능 손실 없이 점진적으로 개선할 수 있도록 설계되었습니다.