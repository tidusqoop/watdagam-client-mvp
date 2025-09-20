# Project Structure for Watdagam

## Directory Layout
```
watdagam/
├── android/          # Android-specific configuration
├── ios/              # iOS-specific configuration  
├── lib/              # Main Dart source code
│   └── main.dart     # Entry point and main UI implementation
├── test/             # Unit and widget tests
│   └── widget_test.dart
├── web/              # Web platform support
├── windows/          # Windows desktop support
├── linux/            # Linux desktop support
├── macos/            # macOS desktop support
├── sample/           # Design references and mockups
│   └── sample_wall_ui.png
├── pubspec.yaml      # Dependencies and project configuration
├── analysis_options.yaml  # Dart analysis configuration
├── CLAUDE.md         # AI assistant project guidance
└── README.md         # Project documentation
```

## Key Files
- **`lib/main.dart`**: Complete app implementation with GraffitiWallScreen
- **`pubspec.yaml`**: Project configuration, dependencies (cupertino_icons, flutter_lints)
- **`sample/sample_wall_ui.png`**: UI design reference for implementation
- **`test/widget_test.dart`**: Basic widget tests (needs updating for current implementation)

## Current Architecture
- **Single File App**: All code currently in `main.dart`
- **Widget Hierarchy**: 
  - `WatdagamApp` (MaterialApp)
  - `GraffitiWallScreen` (StatefulWidget)
  - Custom widgets: `_buildGraffitiNote`, `_buildBottomToolbar`
- **Data Model**: `GraffitiNote` class with position, size, color, text properties

## Future Structure Recommendations
As the app grows, consider splitting into:
```
lib/
├── main.dart
├── models/
│   └── graffiti_note.dart
├── screens/
│   └── graffiti_wall_screen.dart
├── widgets/
│   ├── graffiti_note_widget.dart
│   └── bottom_toolbar.dart
└── utils/
    └── constants.dart
```