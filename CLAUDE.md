# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Summary
- **Flutter-based mobile app development** (플러터 기반 앱 개발)
- **Graffiti Wall SNS concept**: Digital recreation of travel/tourist graffiti walls where people write "oo왔다감!" (someone was here) messages
- **MVP Goal**: Interactive digital wall where users can create, resize, and position graffiti-style messages

## Development Commands

### Essential Flutter Commands
```bash
flutter pub get                 # Install/update dependencies
flutter run                     # Run app on connected device/emulator
flutter run -d chrome          # Run on web browser for quick testing
flutter test                    # Run all tests
flutter analyze                 # Static analysis and linting
flutter format .               # Format code according to Dart style
flutter build apk              # Build Android APK
flutter build ios              # Build iOS app (requires Xcode)
```

### Platform-specific Commands
```bash
# Quick web testing (fastest for UI development)
flutter run -d chrome

# iOS Simulator (macOS only)
flutter devices                # List available devices
flutter run -d "iPhone 16e"    # Run on specific simulator

# Android 
flutter run                     # Auto-selects connected Android device
```

## Architecture Overview

### Project Structure
```
lib/
├── main.dart                   # App entry point with repository injection
├── app/
│   └── app.dart               # Main application widget
├── config/
│   └── app_config.dart        # Environment and data source configuration
├── core/
│   ├── constants/             # App-wide constants
│   ├── theme/                 # App theme and styling
│   └── widgets/               # Shared widgets
├── features/
│   └── graffiti_board/        # Feature-based architecture
│       ├── data/
│       │   ├── models/        # Data models with JSON serialization
│       │   ├── datasources/   # Data layer abstraction
│       │   ├── repositories/  # Repository pattern implementation
│       │   └── mock/          # Mock data for development
│       └── presentation/
│           ├── screens/       # UI screens
│           └── widgets/       # Feature-specific widgets
├── shared/
│   ├── utils/                 # Shared utility functions
│   └── widgets/               # Common UI components
└── utils/                     # General utilities
```

### Clean Architecture Implementation

**Feature-Based Organization**: Each feature (e.g., graffiti_board) follows clean architecture principles:
- **Data Layer**: Models, datasources, repositories
- **Presentation Layer**: Screens, widgets, blocs (if using state management)
- **Domain Layer**: Use cases and business logic (to be added as needed)

**Key Components**:

**GraffitiNote Model**: Enhanced data structure with:
- Position, size, content, author, background color
- JSON serialization with comprehensive type handling
- AuthorAlignment enum for text positioning
- Opacity, corner radius, and timestamp support
- Korean language support for author names

**Repository Pattern**: 
- `GraffitiRepository` with datasource abstraction
- `MockGraffitiDataSource` for development (uses JSON file)
- `ApiGraffitiDataSource` ready for backend integration
- `DataSourceFactory` for environment-based selection

**Environment Configuration**:
- Development: Uses mock data from JSON file
- Staging/Production: Configured for API integration
- Feature flags through `AppConfig` class

**UI Architecture**:
- Interactive canvas with zoom and pan capabilities
- Drag and drop functionality for graffiti notes
- Grid-based background for authentic wall feel
- Custom transformation controllers for smooth interactions

### Dependencies
- `cupertino_icons`: iOS-style icons
- `dotted_border`: Custom border styling for graffiti notes
- `http`: HTTP client for API calls
- `flutter_lints`: Code quality enforcement

### Assets Configuration
- Mock data: `lib/features/graffiti_board/data/mock/graffiti_notes.json`
- Design reference: `sample/sample_wall_ui.png`

## Development Notes

### Current Implementation Status
- **Complete MVP functionality implemented** with interactive graffiti wall
- **Clean architecture** with feature-based separation of concerns
- **Advanced UI interactions**: Drag/resize/edit capabilities with transformation controllers
- **Grid-based canvas** with zoom indicator and authentic wall feel
- **Comprehensive data model** with JSON serialization and Korean language support
- **Mock data system** for offline development and testing
- **Ready for backend integration** with API datasource implementation

### Key Features Implemented
- **Interactive Canvas**: Zoom, pan, and grid background
- **Graffiti Management**: Create, edit, resize, and position notes
- **Transformation Controls**: Smooth drag and drop with visual feedback
- **Add Graffiti Dialog**: Custom styling with input validation
- **Time Display**: Relative time formatting (e.g., "3일 전")
- **Color System**: Predefined color palette with opacity control

### Development Workflow
- Use `flutter run -d chrome` for rapid UI iteration and testing
- Mock data allows full feature testing without backend dependency
- All data operations go through repository pattern for easy API integration
- Feature-based architecture supports parallel development

### Testing Strategy
- Run `flutter test` for unit/widget tests
- Use `flutter run -d chrome` for rapid UI iteration
- Mock data allows full feature testing without backend
- Grid and transformation testing in browser environment

### Code Style
- Follows `flutter_lints` standards (configured in `analysis_options.yaml`)
- Use `flutter format .` to format code according to Dart conventions
- Feature-based architecture with clean separation of concerns
- Repository pattern for data access abstraction
- Environment-based configuration pattern
- Korean language support in comments and user-facing text

### File Organization Patterns
- **Features**: Organized by business functionality (graffiti_board)
- **Layers**: Clear separation of data, presentation, and shared code
- **Naming**: Descriptive file names following Dart conventions
- **Assets**: JSON mock data organized within feature directories
- **Documentation**: Technical docs in `docs/` with implementation guides

### Architecture Guidelines
- **Repository Pattern**: All data access through repositories
- **Factory Pattern**: Environment-based datasource creation
- **Widget Composition**: Small, focused widgets with clear responsibilities
- **State Management**: Currently using StatefulWidget, ready for bloc/provider
- **Dependency Injection**: Constructor injection pattern throughout

### Common Development Tasks

#### Adding New Graffiti Features
1. Extend `GraffitiNote` model in `lib/features/graffiti_board/data/models/`
2. Update JSON serialization methods
3. Modify mock data in `graffiti_notes.json`
4. Update repository interfaces if needed
5. Implement UI changes in presentation layer

#### Backend Integration
1. Implement API endpoints in `ApiGraffitiDataSource`
2. Configure environment in `AppConfig`
3. Update `DataSourceFactory` for production builds
4. Test with mock data first, then switch to API

#### UI Customization
1. Modify theme in `lib/core/theme/`
2. Update constants in `lib/core/constants/`
3. Canvas customization in `lib/features/graffiti_board/presentation/widgets/canvas/`
4. Widget styling in respective feature widget directories